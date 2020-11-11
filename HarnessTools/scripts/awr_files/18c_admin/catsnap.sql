Rem Copyright (c) 1991, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catsnap.sql
Rem    DESCRIPTION
Rem      Creates data dictionary views for snapshots
Rem    NOTES
Rem      Must be run while connected to SYS or INTERNAL.
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catsnap.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catsnap.sql
Rem SQL_PHASE: CATSNAP
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catptabs.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem     pjulsaks   06/26/17  - Bug 25688154: Uppercase create_cdbview's input
Rem     jjye       08/04/16  - bug 21571874: MV uses dbms_scheduler
Rem     sramakri   06/14/16  - Remove CDC from 12.2
Rem     yanxie     02/22/16  - bug 22782938
Rem     tfyu       01/22/16  - Bug 22590054
Rem     sramakri   12/22/15  - bug-22455546
Rem     tfyu       08/07/15  - Bug 21577242
Rem     liding     06/05/15  - Bug 21049500: MV refresh usage stats
Rem     raeburns   05/31/15  - Use FORCE for types with only type dependents
Rem     sramakri   01/27/15  - bug-20301978
Rem     prakumar   01/23/15  - Bug 20309744: Support for long identifiers
Rem     yanxie     01/21/15  - bug 20339390
Rem     skayoor    11/30/14  - Proj 58196: Change Select priv to Read Priv
Rem     wesmith    11/18/14  - Project 47511: data-bound collation
Rem     minwei     05/15/14  - Modify dba_redefinition_status
Rem     sramakri   04/08/14  - bug-18528942
Rem     pjayapal   04/07/14  - Fix bug 18480887 
Rem     mziauddi   03/04/14  - #(18316994) add WITH_CLUSTERING column to
Rem                            *_ZONEMAPS views
Rem     surman     12/29/13  - 13922626: Update SQL metadata
Rem     pjayapal   01/21/13  - Fix bug 17670355. 
Rem     sasounda   11/19/13  - 17746252: handle KZSRAT when creating all_* view
Rem     tfyu       09/04/13  - Bug 16584211 
Rem     talliu     06/28/13  - Add CDB view for DBA view
Rem     liding     08/22/13  - bug 14116743
Rem     rrudd      03/13/13  - Fix bug 16438624.
Rem     mziauddi   08/18/12  - there is no PCT refresh for zonemap
Rem     panzho     05/29/12  - panzho_bug-14118698
Rem     surman     03/27/12  - 13615447: Add SQL patching tags
Rem     mziauddi   03/27/12  - check for zonemap freshness with unknown
Rem                            origin (prebuilt table case)
Rem     panzho     03/23/12  - bug 13873668, remove owner, current run fields
Rem     sramakri   02/23/12  - fix dba_sr_stlog_stats
Rem     sramakri   02/01/12  - rename xxx_sr_log_exception views to
Rem                            xxx_sr_stlog_exceptions
Rem     sramakri   01/10/12  - fix to dba_sr_obj_status
Rem     sramakri   11/22/11  - sync-refresh views changes
Rem     mziauddi   09/19/11  - remove background_refresh from zonemap views
Rem     rrudd      08/22/11  - Bug 12879651 Adding support for
Rem                            continue_after_errors during batched partition
Rem                            redefinition. Add views for viewing status
Rem     mziauddi   07/31/11  - DBA_ZONEMAPS: define INVALID attribute
Rem     xiaobma    08/09/11  - syncref exceptions and staging log status
Rem     sramakri   07/24/11  - syncref object and object_status view 
Rem     brwolf     07/18/11  - 32733: evaluation editions
Rem     panzho     07/18/11  - catalog views for sync-refresh
Rem     sramakri   06/22/11  - Sync Refresh types
Rem     mziauddi   03/31/11  - project 35612: add zonemap views
Rem     minwei     08/26/10  - Bug 8345040
Rem     alexsanc   11/19/09  - Bug 8826832
Rem     huagli     07/15/09  - expose commit SCN-based MV log info
Rem     avangala   04/02/09  - LAST_REFRESH_DATE in DBA_MVIEWS has to support
Rem                            for all the NLS languages
Rem     zqiu       05/27/08  - add FAST_CS for FAST CUBESOLVE
Rem     wesmith    10/22/07  - MV log purge optimization
Rem     zqiu       12/11/07  - hide 2nd cube mv pct refresh metadata
Rem     desingh    03/23/07  - bug5872368: ExplainMVArrayType size
Rem     zqiu       09/25/06  - hide secondary CUBE MVs
Rem     rburns     08/25/06  - move types into catsnap.sql
Rem     wesmith    07/11/06  - add application edition support
Rem     wesmith    04/17/06  - view dba_redefinition_{objects|errors}:
Rem                            add object type for MV logs
Rem     sramakri   12/07/05  - add pct infor to DBA_MVIEWS 
Rem     xan        05/19/04  - expose ntab and partition type in 
Rem                            dba_redefinition_objects
Rem     tfyu       01/29/03  - Bug stale_since
Rem     sxavier    11/18/02  - Fix staleness column in user_mviews
Rem     masubram   10/07/02  - add online redefinition views
Rem     mxiao      06/25/02  - change SNAPSHOT to MATERIALIZED VIEW
Rem     abgupta    07/09/02  - add UNKNOWN_TRUSTED_FD to DBA_MVIEWS
Rem     desinha    06/07/02  - fix lrg 100598 
Rem     desinha    04/29/02  - #2303866: change user => userenv('SCHEMAID')
Rem     pabingha   10/15/01  - fix *_snapshot_logs snapshot_id for CDC
Rem     twtong     10/12/01  - fix bug-2046799
Rem     sbedarka   08/20/01  - #(1862397) amend dba_mviews.rewrite_capability
Rem     twtong     07/16/01  - add unknown specific cols to catsnap.sql
Rem     twtong     06/25/01  - reflect NEED_COMPILE in cols depends on 
Rem                            summary mflags
Rem     gviswana   05/24/01  - CREATE OR REPLACE SYNONYM
Rem     pabingha   05/16/01  - add CDC metadata to MV Log views
Rem     bpanchap   02/16/01 -  Making LAST_REFRESH_DATE type date
Rem     mbrey      02/13/01 -  bug 1639332 replace snapshot with mview in views
Rem     tfyu       12/14/00 -  Add FAST_PCT
Rem     tfyu       01/18/01 -  fix bugs# 1588499 and 1588519
Rem     twtong     01/09/01 -  code review
Rem     twtong     12/20/00 -  modify staleness info in dba_mviews
Rem     slawande   11/21/00 -  Add sequence col to user_snapshot_logs.
Rem     bpanchap   11/20/00 -  Adding time to Last refresh date in dba_mviews
Rem     slawande   10/06/00 -  Adding bit to DBA_MVIEWS
Rem     rvenkate   10/02/00 -  modify snapshot views to add object_id
Rem     slawande   10/17/00 -  Add seq# info to
Rem     slawande   05/23/00 -  Add decode for insert-only AGG MVs.
Rem     wesmith    05/12/00 -  Exclude secondary MVs from queries on snap$
Rem     slawande   05/08/00 -  Update *_mviews with new MAV refresh capability.
Rem     rshaikh    10/08/99 -  bug 1025636: fix for sqlplus
Rem     alakshmi   10/14/99 -  Bug 557451: get snaptime from snap_reftime$ for 
Rem                            dba_snapshots
Rem     slawande   09/23/99 -  Remove fast/complete_refresh_time from *_mviews
Rem     bpanchap   08/11/99 -  Last refresh date should be null when build defe
Rem     igreenbe   07/29/99 -  adjust after_fast_refresh for MAVs              
Rem     bpanchap   08/06/99 -  Adding decode statement for last refresh 
Rem                            method; Bug 923186
Rem     igreenbe   07/16/99 -  add *_mviews views                              
Rem     hasun      11/13/98 -  BUG#730154: Fix *_snapshot for MJV and NEVER REF
Rem     wesmith    11/02/98 -  Fix view dba_refresh                            
Rem     nshodhan   09/09/98 -  Modify views to exclude RepAPI snapshots
Rem     hasun      05/21/98 -  Support UNKNOWN status for snapshots            
Rem     hasun      05/21/98 -  Change NONE to NEVER for *_snapshots.type       
Rem     hasun      05/14/98 -  Add prebuilt to *_snapshots
Rem     hasun      04/28/98 -  Add refresh_mode to *_snapshots               
Rem     hasun      04/10/98 -  Add status to *_snapshots                       
Rem     hasun      04/08/98 -  Support REFRESH FORCE option                    
Rem     jgalagal   01/20/98 -  Add aggregate snapshot in dba_snapshots         
Rem     masubram   03/27/97 -  fix comment on reg_snap$.rep_type
Rem     masubram   03/11/97 -  Modify the snapshot registration views
Rem     hasun      03/10/97 -  Expose parallel prop parameters
Rem     hasun      10/21/96 -  Add master_rollback_seg column to *_snapshots
Rem     masubram   10/11/96 -  Add dba_snapshot_log_filter_cols view
Rem     masubram   10/04/96 -  Fixed dba_snapshots to get snaptime from snap$
Rem     masubram   09/25/96 -  Fixed all_registered_snapshots
Rem     masubram   09/24/96 -  Add all_snapshot_logs,snap_ref_times, mod dba_sn
Rem     hasun      06/12/96 -  Add column comments
Rem     tpystyne   06/01/96 -  change rgchild$.type to rgchild$.type#
Rem     mmonajje   05/21/96 -  Replace interval col name with interval#
Rem     asurpur    05/15/96 -  Dictionary Protection: granting privileges on vi
Rem     asurpur    04/08/96 -  Dictionary Protection Implementation
Rem     hasun      05/06/96 -  replmerge
Rem     adowning   04/22/96 -  merge obj to main
Rem     hasun      04/18/96 -  Modify views for additional snapshot states
Rem     hasun      04/12/96 -  Add new COMPLEX snapshot type
Rem     hasun      04/10/96 -  Modify views for new snapshot id
Rem     hasun      03/26/96 -  Make DBA_SNAPSHOTS more robust
Rem     hasun      03/15/96 -  Add STATUS column to dba_snapshots
Rem     hasun      02/27/96 -  Merge from BIG
Rem     hasun      02/13/96 -  Add support for filter columns
Rem     ashgupta   02/08/96 -  Merging  snapshot registration code (proj 2045)
Rem     hasun      12/05/95 -  Modify []_snapshots and  []_snapshot_logs
Rem                            for primary key snapshots
Rem     jcchou     11/15/95 -  bug#302137 - refgroup in sys.snap$
Rem     jcchou     11/09/95 -  #310646 - rbs missing from views
Rem     jcchou     09/26/95 -  bug#310646 - rgroup$ views
Rem     ashgupta   02/08/96 -  Merging  snapshot registration code (proj 2045)
Rem     adowning   12/23/94 -  merge changes from branch 1.7.720.1
Rem     adowning   12/21/94 -  merge changes from branch 1.4.710.4
Rem     hasun      12/05/95 -  Modify []_snapshots and  []_snapshot_logs
Rem                            for primary key snapshots
Rem     adowning   12/05/94 -  fix all_snapshots
Rem     adowning   11/11/94 -  merge changes from branch 1.4.710.3
Rem     adowning   10/14/94 -  fix typo USER to DBA
Rem     wmaimone   05/26/94 -  #186155 add public synoyms for dba_
Rem     rjenkins   01/19/94 -  merge changes from branch 1.4.710.2
Rem     jbellemo   12/17/93 -  merge changes from branch 1.4.710.1
Rem     rjenkins   12/17/93 -  creating job queue
Rem     jbellemo   11/09/93 -  #170173: change uid to userenv schemaid
Rem     rjenkins   07/06/93 -  adding updatable snapshots
Rem     wbridge    12/03/92 -  fix error handling for refresh all 
Rem     tpystyne   11/08/92 -  use create or replace view 
Rem     glumpkin   10/25/92 -  Renamed from SNAPVEW.SQL 
Rem     mmoore     06/02/92 - #(96526) remove v$enabledroles 
Rem     rjenkins   01/14/92 -  copying changes from catalog.sql 
Rem     rjenkins   05/20/91 -         Creation 

@@?/rdbms/admin/sqlsessstart.sql

remark
remark    FAMILY "SNAPSHOTS"
remark    Table replication definitions.
remark

create or replace view DBA_SNAPSHOTS
(OWNER, NAME, TABLE_NAME, MASTER_VIEW, MASTER_OWNER, MASTER, MASTER_LINK,
 CAN_USE_LOG, UPDATABLE, REFRESH_METHOD, LAST_REFRESH, ERROR,
 FR_OPERATIONS, CR_OPERATIONS, TYPE, NEXT, START_WITH, REFRESH_GROUP, 
 UPDATE_TRIG, UPDATE_LOG, QUERY, MASTER_ROLLBACK_SEG, STATUS, REFRESH_MODE,
 PREBUILT)
as
select s.sowner, s.vname, tname, mview, t.mowner, t.master, mlink,
       decode(bitand(s.flag,1),  0, 'NO', 'YES'), 
       decode(bitand(s.flag,2),  0, 'NO', 'YES'), 
       decode(bitand(s.flag,16),             16, 'ROWID', 
	      (decode(bitand(s.flag,32),     32, 'PRIMARY KEY', 
	      (decode(bitand(s.flag,8192), 8192, 'JOIN VIEW', 
	      (decode(bitand(s.flag,4096), 4096, 'AGGREGATE', 
              (decode(bitand(s.flag,256),   256, 'COMPLEX',
              (decode(bitand(s.flag,536870912),   536870912, 'OBJECT ID', 
                                                 'UNKNOWN'))))))))))),
       t.snaptime, s.error#, 
       decode(bitand(s.status,1), 0, 'REGENERATE', 'VALID'),
       decode(bitand(s.status,2), 0, 'REGENERATE', 'VALID'),
       decode(s.auto_fast, 
              'C',  'COMPLETE', 
              'F',  'FAST', 
              '?',  'FORCE',
              'N',  'NEVER',
              NULL, 'FORCE', 'ERROR'), 
       s.auto_fun, s.auto_date, r.refgroup, s.ustrg, s.uslog, 
       s.query_txt, s.mas_roll_seg,
       decode(bitand(s.status,4),         4, 'INVALID',
	      (decode(bitand(s.status,8), 8, 'UNKNOWN',
                                             'VALID'))),
       decode(NVL(s.auto_fun, 'null'), 
              'null', decode(s.auto_fast,                  'N', 'NEVER', 
                             (decode(bitand(s.flag, 32768),  0, 'DEMAND',
                                                                'COMMIT'))),
	      'PERIODIC'),
       decode(bitand(s.flag,131072), 0, 'NO', 'YES')
from sys.snap$ s, sys.rgchild$ r, sys.snap_reftime$ t
where t.sowner = s.sowner
and t.vname = s.vname
and t.instsite = 0
and s.instsite = 0
and not (bitand(s.flag, 268435456) > 0         /* MV with user-defined types */
         and bitand(s.objflag, 32) > 0)                      /* secondary MV */
and not (bitand(s.flag2, 33554432) > 0)                 /* secondary CUBE MV */
and not (bitand(s.flag3, 512) > 0)                                /* zonemap */
and t.tablenum = 0
and t.sowner  = r.owner (+) 
and t.vname = r.name (+)
and nvl(r.instsite,0) = 0
and r.type# (+) = 'SNAPSHOT'
/
create or replace public synonym DBA_SNAPSHOTS for DBA_SNAPSHOTS
/
comment on table DBA_SNAPSHOTS is
'All snapshots in the database'
/
comment on column DBA_SNAPSHOTS.OWNER is
'Owner of the snapshot'
/
comment on column DBA_SNAPSHOTS.NAME is
'The view used by users and applications for viewing the snapshot'
/
comment on column DBA_SNAPSHOTS.TABLE_NAME is
'Table the snapshot is stored in -- has an extra column for the master rowid'
/
comment on column DBA_SNAPSHOTS.MASTER_VIEW is
'View of the master table, owned by the snapshot owner, used for refreshes'
/
comment on column DBA_SNAPSHOTS.MASTER_OWNER is
'Owner of the master table'
/
comment on column DBA_SNAPSHOTS.MASTER is
'Name of the master table that this snapshot is a copy of'
/
comment on column DBA_SNAPSHOTS.MASTER_LINK is
'Database link name to the master site'
/
comment on column DBA_SNAPSHOTS.CAN_USE_LOG is
'If NO, this snapshot is complex and will never use a log'
/
comment on column DBA_SNAPSHOTS.UPDATABLE is
'If NO, the snapshot is read only.  Look up REPLICATION'
/
comment on column DBA_SNAPSHOTS.REFRESH_METHOD is
'The values used to drive a fast refresh of the snapshot'
/
comment on column DBA_SNAPSHOTS.LAST_REFRESH is
'SYSDATE from the master site at the time of the last refresh'
/
comment on column DBA_SNAPSHOTS.ERROR is
'The number of failed automatic refreshes since last successful refresh'
/
comment on column DBA_SNAPSHOTS.FR_OPERATIONS is
'If REGENERATE, then the fast refresh operations have not been generated'
/
comment on column DBA_SNAPSHOTS.CR_OPERATIONS is
'If REGENERATE, then the complete refresh operations have not been generated'
/
comment on column DBA_SNAPSHOTS.TYPE is
'The type of refresh (complete,fast,force) for all automatic refreshes'
/
comment on column DBA_SNAPSHOTS.NEXT is
'The date function used to compute next refresh dates'
/
comment on column DBA_SNAPSHOTS.START_WITH is
'The date function used to compute next refresh dates'
/
comment on column DBA_SNAPSHOTS.REFRESH_GROUP is
'All snapshots in a given refresh group get refreshed in the same transaction'
/
comment on column DBA_SNAPSHOTS.UPDATE_TRIG is
'The name of the trigger which fills the UPDATE_LOG'
/
comment on column DBA_SNAPSHOTS.UPDATE_LOG is
'The table which logs changes made to an updatable snapshots'
/
comment on column DBA_SNAPSHOTS.QUERY is
'The original query that this snapshot is an instantiation of'
/
comment on column DBA_SNAPSHOTS.MASTER_ROLLBACK_SEG is
'Rollback segment to use at the master site'
/
comment on column DBA_SNAPSHOTS.STATUS is
'The status of the contents of the snapshot'
/
comment on column DBA_SNAPSHOTS.REFRESH_MODE is
'This indicates how and when the snapshot will be refreshed'
/
comment on column DBA_SNAPSHOTS.PREBUILT is
'If YES, this snapshot uses a prebuilt table as the base table'
/
grant select on DBA_SNAPSHOTS to select_catalog_role
/

execute CDBView.create_cdbview(false,'SYS','DBA_SNAPSHOTS','CDB_SNAPSHOTS');
grant select on SYS.CDB_SNAPSHOTS to select_catalog_role
/
create or replace public synonym CDB_SNAPSHOTS for SYS.CDB_SNAPSHOTS
/

/*
 * define the ability to "access a snapshot" as the ability to
 * "access the snapshot's table_name (e.g., snap$_foo).
 */
create or replace view ALL_SNAPSHOTS
as select s.* from dba_snapshots s, sys.obj$ o, sys.user$ u
where o.owner#     = u.user#
  and s.table_name = o.name
  and u.name       = s.owner
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
comment on table ALL_SNAPSHOTS is
'Snapshots the user can access'
/
comment on column ALL_SNAPSHOTS.OWNER is
'Owner of the snapshot'
/
comment on column ALL_SNAPSHOTS.NAME is
'The view used by users and applications for viewing the snapshot'
/
comment on column ALL_SNAPSHOTS.TABLE_NAME is
'Table the snapshot is stored in -- has an extra column for the master rowid'
/
comment on column ALL_SNAPSHOTS.MASTER_VIEW is
'View of the master table, owned by the snapshot owner, used for refreshes'
/
comment on column ALL_SNAPSHOTS.MASTER_OWNER is
'Owner of the master table'
/
comment on column ALL_SNAPSHOTS.MASTER is
'Name of the master table that this snapshot is a copy of'
/
comment on column ALL_SNAPSHOTS.MASTER_LINK is
'Database link name to the master site'
/
comment on column ALL_SNAPSHOTS.CAN_USE_LOG is
'If NO, this snapshot is complex and will never use a log'
/
comment on column ALL_SNAPSHOTS.UPDATABLE is
'If NO, the snapshot is read only.  Look up REPLICATION'
/
comment on column ALL_SNAPSHOTS.REFRESH_METHOD is
'The values used to drive a fast refresh of the snapshot'
/
comment on column ALL_SNAPSHOTS.LAST_REFRESH is
'SYSDATE from the master site at the time of the last refresh'
/
comment on column ALL_SNAPSHOTS.ERROR is
'The error returned last time an automatic refresh was attempted'
/
comment on column ALL_SNAPSHOTS.TYPE is
'The type of refresh (complete,fast,force) for all automatic refreshes'
/
comment on column ALL_SNAPSHOTS.NEXT is
'The date function used to compute next refresh dates'
/
comment on column ALL_SNAPSHOTS.START_WITH is
'The date function used to compute next refresh dates'
/
comment on column ALL_SNAPSHOTS.REFRESH_GROUP is
'All snapshots in a given refresh group get refreshed in the same transaction'
/
comment on column ALL_SNAPSHOTS.UPDATE_TRIG is
'The name of the trigger which fills the UPDATE_LOG'
/
comment on column ALL_SNAPSHOTS.UPDATE_LOG is
'The table which logs changes made to an updatable snapshots'
/
comment on column ALL_SNAPSHOTS.QUERY is
'The original query that this snapshot is an instantiation of'
/
comment on column ALL_SNAPSHOTS.MASTER_ROLLBACK_SEG is
'Rollback segment to use at the master site'
/
comment on column ALL_SNAPSHOTS.STATUS is
'The status of the contents of the snapshot'
/
comment on column ALL_SNAPSHOTS.REFRESH_MODE is
'This indicates how and when the snapshot will be refreshed'
/
comment on column ALL_SNAPSHOTS.PREBUILT is
'If YES, this snapshot uses a prebuilt table as the base table'
/
create or replace public synonym ALL_SNAPSHOTS for ALL_SNAPSHOTS
/
grant read on ALL_SNAPSHOTS to public with grant option
/
create or replace view USER_SNAPSHOTS
as select s.* from dba_snapshots s, sys.user$ u
where u.user# = userenv('SCHEMAID')
  and s.owner = u.name
/
comment on table USER_SNAPSHOTS is
'Snapshots the user can look at'
/
comment on column USER_SNAPSHOTS.OWNER is
'Owner of the snapshot'
/
comment on column USER_SNAPSHOTS.NAME is
'The view used by users and applications for viewing the snapshot'
/
comment on column USER_SNAPSHOTS.TABLE_NAME is
'Table the snapshot is stored in -- has an extra column for the master rowid'
/
comment on column USER_SNAPSHOTS.MASTER_VIEW is
'View of the master table, owned by the snapshot owner, used for refreshes'
/
comment on column USER_SNAPSHOTS.MASTER_OWNER is
'Owner of the master table'
/
comment on column USER_SNAPSHOTS.MASTER is
'Name of the master table that this snapshot is a copy of'
/
comment on column USER_SNAPSHOTS.MASTER_LINK is
'Database link name to the master site'
/
comment on column USER_SNAPSHOTS.CAN_USE_LOG is
'If NO, this snapshot is complex and will never use a log'
/
comment on column USER_SNAPSHOTS.UPDATABLE is
'If NO, the snapshot is read only.  Look up REPLICATION'
/
comment on column USER_SNAPSHOTS.REFRESH_METHOD is
'The values used to drive a fast refresh of the snapshot'
/
comment on column USER_SNAPSHOTS.LAST_REFRESH is
'SYSDATE from the master site at the time of the last refresh'
/
comment on column USER_SNAPSHOTS.ERROR is
'The error returned last time an automatic refresh was attempted'
/
comment on column USER_SNAPSHOTS.TYPE is
'The type of refresh (complete,fast,force) for all automatic refreshes'
/
comment on column USER_SNAPSHOTS.NEXT is
'The date function used to compute next refresh dates'
/
comment on column USER_SNAPSHOTS.START_WITH is
'The date function used to compute next refresh dates'
/
comment on column USER_SNAPSHOTS.REFRESH_GROUP is
'All snapshots in a given refresh group get refreshed in the same transaction'
/
comment on column USER_SNAPSHOTS.UPDATE_TRIG is
'The name of the trigger which fills the UPDATE_LOG'
/
comment on column USER_SNAPSHOTS.UPDATE_LOG is
'The table which logs changes made to an updatable snapshots'
/
comment on column USER_SNAPSHOTS.QUERY is
'The original query that this snapshot is an instantiation of'
/
comment on column USER_SNAPSHOTS.MASTER_ROLLBACK_SEG is
'Rollback segment to use at the master site'
/
comment on column USER_SNAPSHOTS.STATUS is
'The status of the contents of the snapshot'
/
comment on column USER_SNAPSHOTS.REFRESH_MODE is
'This indicates how and when the snapshot will be refreshed'
/
comment on column USER_SNAPSHOTS.PREBUILT is
'If YES, this snapshot uses a prebuilt table as the base table'
/
create or replace public synonym USER_SNAPSHOTS for USER_SNAPSHOTS
/
grant read on USER_SNAPSHOTS to public with grant option
/
rem
rem This view family is being replaced with [DBA/ALL/USER]_MVIEW_LOGS and 
rem [DBA/ALL/USER]_BASE_TABLE_MVIEWS for the 9i release. For changes to the 
rem [DBA/ALL/USER]_SNAPSHOT_LOGS view family, verify whether changes need
rem to be done to the replacement views.
rem 
create or replace view DBA_SNAPSHOT_LOGS
( LOG_OWNER, MASTER, LOG_TABLE, LOG_TRIGGER, ROWIDS, PRIMARY_KEY, OBJECT_ID,
  FILTER_COLUMNS, SEQUENCE, INCLUDE_NEW_VALUES,
  CURRENT_SNAPSHOTS, SNAPSHOT_ID)
as
select m.mowner, m.master, m.log, m.trig,
       decode(bitand(m.flag,1), 0, 'NO', 'YES'),
       decode(bitand(m.flag,2), 0, 'NO', 'YES'),
       decode(bitand(m.flag,512), 0, 'NO', 'YES'),
       decode(bitand(m.flag,4), 0, 'NO', 'YES'),
       decode(bitand(m.flag,1024), 0, 'NO', 'YES'),
       decode(bitand(m.flag,16), 0, 'NO', 'YES'),
       s.snaptime, s.snapid
from sys.mlog$ m, sys.slog$ s
where s.mowner (+) = m.mowner
  and s.master (+) = m.master
/
create or replace public synonym DBA_SNAPSHOT_LOGS for DBA_SNAPSHOT_LOGS
/
comment on table DBA_SNAPSHOT_LOGS is
'All snapshot logs in the database'
/
comment on column DBA_SNAPSHOT_LOGS.LOG_OWNER is
'Owner of the snapshot log'
/
comment on column DBA_SNAPSHOT_LOGS.MASTER is
'Name of the master table which  changes are logged'
/
comment on column DBA_SNAPSHOT_LOGS.LOG_TABLE is
'Log table; with rowids and timestamps of rows which changed in the master'
/
comment on column DBA_SNAPSHOT_LOGS.LOG_TRIGGER is
'An after-row trigger on the master which inserts rows into the log'
/
comment on column DBA_SNAPSHOT_LOGS.ROWIDS is
'If YES, the snapshot log records rowid information'
/
comment on column DBA_SNAPSHOT_LOGS.PRIMARY_KEY is
'If YES, the snapshot log records primary key information'
/
comment on column DBA_SNAPSHOT_LOGS.OBJECT_ID is
'If YES, the snapshot log records object id information'
/
comment on column DBA_SNAPSHOT_LOGS.FILTER_COLUMNS is
'If YES, the snapshot log records filter column information'
/
comment on column DBA_SNAPSHOT_LOGS.SEQUENCE is
'If YES, the snapshot log records sequence information'
/
comment on column DBA_SNAPSHOT_LOGS.INCLUDE_NEW_VALUES is
'If YES, the snapshot log records old and new values (else only old values)'
/
comment on column DBA_SNAPSHOT_LOGS.CURRENT_SNAPSHOTS is
'One date per snapshot -- the date the snapshot of the master last refreshed'
/
comment on column DBA_SNAPSHOT_LOGS.SNAPSHOT_ID is
'Unique identifier of the snapshot'
/
grant select on DBA_SNAPSHOT_LOGS to select_catalog_role
/

execute CDBView.create_cdbview(false,'SYS','DBA_SNAPSHOT_LOGS','CDB_SNAPSHOT_LOGS');
grant select on SYS.CDB_SNAPSHOT_LOGS to select_catalog_role
/
create or replace public synonym CDB_SNAPSHOT_LOGS for SYS.CDB_SNAPSHOT_LOGS
/

create or replace view ALL_SNAPSHOT_LOGS
as select s.* from dba_snapshot_logs s, sys.obj$ o, sys.user$ u
where o.owner#     = u.user#
  and s.log_table = o.name
  and u.name       = s.log_owner
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
comment on table ALL_SNAPSHOT_LOGS is
'All snapshot logs in the database that the user can see'
/
comment on column ALL_SNAPSHOT_LOGS.LOG_OWNER is
'Owner of the snapshot log'
/
comment on column ALL_SNAPSHOT_LOGS.MASTER is
'Name of the master table which changes are logged'
/
comment on column ALL_SNAPSHOT_LOGS.LOG_TABLE is
'Log table; with  rowids and timestamps of rows which changed in the master'
/
comment on column ALL_SNAPSHOT_LOGS.LOG_TRIGGER is
'An after-row trigger on the master which inserts rows into the log'
/
comment on column ALL_SNAPSHOT_LOGS.ROWIDS is
'If YES, the snapshot log records rowid information'
/
comment on column ALL_SNAPSHOT_LOGS.PRIMARY_KEY is
'If YES, the snapshot log records primary key information'
/
comment on column ALL_SNAPSHOT_LOGS.OBJECT_ID is
'If YES, the snapshot log records object id information'
/
comment on column ALL_SNAPSHOT_LOGS.FILTER_COLUMNS is
'If YES, the snapshot log records filter column information'
/
comment on column ALL_SNAPSHOT_LOGS.SEQUENCE is
'If YES, the snapshot log records sequence information'
/
comment on column ALL_SNAPSHOT_LOGS.INCLUDE_NEW_VALUES is
'If YES, the snapshot log records old and new values (else only old values)'
/
comment on column ALL_SNAPSHOT_LOGS.CURRENT_SNAPSHOTS is
'One date per snapshot -- the date the snapshot of the master last refreshed'
/
comment on column ALL_SNAPSHOT_LOGS.SNAPSHOT_ID is
'Unique identifier of the snapshot'
/
create or replace public synonym ALL_SNAPSHOT_LOGS for ALL_SNAPSHOT_LOGS
/
grant read on ALL_SNAPSHOT_LOGS to public with grant option
/
create or replace view USER_SNAPSHOT_LOGS
( LOG_OWNER, MASTER, LOG_TABLE, LOG_TRIGGER, ROWIDS, PRIMARY_KEY,
  OBJECT_ID, FILTER_COLUMNS, SEQUENCE, INCLUDE_NEW_VALUES,
  CURRENT_SNAPSHOTS, SNAPSHOT_ID)
as
select log_owner, master, log_table, log_trigger, rowids, primary_key,
       object_id, filter_columns, sequence, include_new_values, 
       current_snapshots, snapshot_id
from dba_snapshot_logs s, sys.user$ u
where s.log_owner = u.name
  and u.user# = userenv('SCHEMAID')
/
comment on table USER_SNAPSHOT_LOGS is
'All snapshot logs owned by the user'
/
comment on column USER_SNAPSHOT_LOGS.LOG_OWNER is
'Owner of the snapshot log'
/
comment on column USER_SNAPSHOT_LOGS.MASTER is
'Name of the master table which changes are logged'
/
comment on column USER_SNAPSHOT_LOGS.LOG_TABLE is
'Log table; with rowids and timestamps of rows which changed in the
master'
/
comment on column USER_SNAPSHOT_LOGS.LOG_TRIGGER is
'Trigger on master table; fills the snapshot log'
/
comment on column USER_SNAPSHOT_LOGS.ROWIDS is
'If YES, the snapshot log records rowid information'
/
comment on column USER_SNAPSHOT_LOGS.PRIMARY_KEY is
'If YES, the snapshot log records primary key information'
/
comment on column USER_SNAPSHOT_LOGS.OBJECT_ID is
'If YES, the snapshot log records object id information'
/
comment on column USER_SNAPSHOT_LOGS.FILTER_COLUMNS is
'If YES, the snapshot log records filter column information'
/
comment on column USER_SNAPSHOT_LOGS.SEQUENCE is
'If YES, the snapshot log records sequence information'
/
comment on column USER_SNAPSHOT_LOGS.INCLUDE_NEW_VALUES is
'If YES, the snapshot log records old and new values (else only old values)'
/
comment on column USER_SNAPSHOT_LOGS.CURRENT_SNAPSHOTS is
'Dates that all known simple snapshots last refreshed'
/
create or replace public synonym USER_SNAPSHOT_LOGS for USER_SNAPSHOT_LOGS
/
grant read on USER_SNAPSHOT_LOGS to public with grant option
/


create or replace view DBA_RCHILD 
as select REFGROUP, OWNER, NAME, TYPE# from rgchild$ r
   where r.instsite = 0 
/
comment on table DBA_RCHILD is
'All the children in any refresh group.  This view is not a join.'
/
create or replace public synonym DBA_RCHILD for DBA_RCHILD
/
grant select on DBA_RCHILD to select_catalog_role
/


execute CDBView.create_cdbview(false,'SYS','DBA_RCHILD','CDB_RCHILD');
grant select on SYS.CDB_RCHILD to select_catalog_role
/
create or replace public synonym CDB_RCHILD for SYS.CDB_RCHILD
/

create or replace view DBA_RGROUP
as select REFGROUP, OWNER, NAME,
          decode(bitand(flag,1),1,'Y',0,'N','?') IMPLICIT_DESTROY,
          decode(bitand(flag,2),2,'Y',0,'N','?') PUSH_DEFERRED_RPC,
          decode(bitand(flag,4),4,'Y',0,'N','?') REFRESH_AFTER_ERRORS,
          ROLLBACK_SEG,
          JOB,
          purge_opt#   PURGE_OPTION,
          parallelism# PARALLELISM,
          heap_size#   HEAP_SIZE,
          JOB_NAME
  from rgroup$ r
   where r.instsite = 0 
/
comment on table DBA_RGROUP is
'All refresh groups.  This view is not a join.'
/
comment on column DBA_RGROUP.REFGROUP is
'Internal identifier of refresh group'
/
comment on column DBA_RGROUP.OWNER is
'Owner of the refresh group'
/
comment on column DBA_RGROUP.NAME is
'Name of the refresh group'
/
comment on column DBA_RGROUP.IMPLICIT_DESTROY is
'Y or N, if Y then destroy the refresh group when its last item is subtracted'
/
comment on column DBA_RGROUP.PUSH_DEFERRED_RPC is
'Y or N, if Y then push changes from snapshot to master before refresh'
/
comment on column DBA_RGROUP.REFRESH_AFTER_ERRORS is
'If Y, proceed with refresh despite error when pushing deferred RPCs'
/
comment on column DBA_RGROUP.ROLLBACK_SEG is
'Name of the rollback segment to use while refreshing'
/
comment on column DBA_RGROUP.JOB is
'Identifier of job used to automatically refresh the group'
/
comment on column DBA_RGROUP.PURGE_OPTION is
'The method for purging the transaction queue after each push'
/
comment on column DBA_RGROUP.PARALLELISM is
'The level of parallelism for transaction propagation'
/
comment on column DBA_RGROUP.HEAP_SIZE is
'The heap size used for transaction propagation'
/
comment on column DBA_RGROUP.JOB_NAME is
'The name of Job used to automatically refresh the group'
/
create or replace public synonym DBA_RGROUP for DBA_RGROUP
/
grant select on DBA_RGROUP to select_catalog_role
/


execute CDBView.create_cdbview(false,'SYS','DBA_RGROUP','CDB_RGROUP');
grant select on SYS.CDB_RGROUP to select_catalog_role
/
create or replace public synonym CDB_RGROUP for SYS.CDB_RGROUP
/

create or replace view DBA_REFRESH
AS SELECT ROWNER, 
          RNAME, 
          REFGROUP, 
          IMPLICIT_DESTROY, 
          PUSH_DEFERRED_RPC,
          REFRESH_AFTER_ERRORS,
          ROLLBACK_SEG,
          JOB,
          NEXT_DATE,
          INTERVAL,
          BROKEN,
          PURGE_OPTION,
          PARALLELISM,
          HEAP_SIZE,
          JOB_NAME
  FROM (
      SELECT r.owner AS ROWNER, r.name AS RNAME, r.REFGROUP AS REFGROUP,
          decode(bitand(r.flag,1),1,'Y',0,'N','?') AS IMPLICIT_DESTROY,
          decode(bitand(r.flag,2),2,'Y',0,'N','?') AS PUSH_DEFERRED_RPC,
          decode(bitand(r.flag,4),4,'Y',0,'N','?') AS REFRESH_AFTER_ERRORS,
          r.rollback_seg AS ROLLBACK_SEG,
          j.JOB AS JOB, j.NEXT_DATE AS NEXT_DATE, j.INTERVAL# AS INTERVAL, 
          decode(bitand(j.flag,1),1,'Y',0,'N','?') AS BROKEN,
          r.purge_opt# AS PURGE_OPTION,
          r.parallelism# AS PARALLELISM,
          r.heap_size# AS HEAP_SIZE,
          r.job_name AS JOB_NAME
      FROM  rgroup$ r, job$ j
      WHERE r.instsite = 0
      AND   r.job_name IS NULL AND r.job = j.job(+) 
      UNION ALL
      SELECT r.owner AS ROWNER, r.name AS RNAME, r.REFGROUP AS REFGROUP,
          decode(bitand(r.flag,1),1,'Y',0,'N','?') AS IMPLICIT_DESTROY,
          decode(bitand(r.flag,2),2,'Y',0,'N','?') AS PUSH_DEFERRED_RPC,
          decode(bitand(r.flag,4),4,'Y',0,'N','?') AS REFRESH_AFTER_ERRORS,
          r.rollback_seg AS ROLLBACK_SEG,
          r.JOB AS JOB, 
          CAST(s.start_date AS DATE) AS NEXT_DATE, 
          substr(s.repeat_interval,1,200) AS INTERVAL,
          decode(s.enabled,'FALSE','Y','TRUE','N','?') AS BROKEN,
          r.purge_opt#  AS  PURGE_OPTION,
          r.parallelism# AS PARALLELISM,
          r.heap_size#   AS HEAP_SIZE,
          r.job_name     AS JOB_NAME
      FROM  rgroup$ r, dba_scheduler_jobs s
      where r.instsite = 0 
        AND r.owner = s.owner(+)
        and r.job_name IS NOT NULL AND r.job_name = s.job_name(+)
  )
/
comment on table DBA_REFRESH is
'All the refresh groups'
/
comment on column DBA_REFRESH.ROWNER is
'Name of the owner of the refresh group'
/
comment on column DBA_REFRESH.RNAME is
'Name of the refresh group'
/
comment on column DBA_REFRESH.REFGROUP is
'Internal identifier of refresh group'
/
comment on column DBA_REFRESH.IMPLICIT_DESTROY is
'Y or N, if Y then destroy the refresh group when its last item is subtracted'
/
comment on column DBA_REFRESH.PUSH_DEFERRED_RPC is
'Y or N, if Y then push changes from snapshot to master before refresh'
/
comment on column DBA_REFRESH.REFRESH_AFTER_ERRORS is
'If Y, proceed with refresh despite error when pushing deferred RPCs'
/
comment on column DBA_REFRESH.ROLLBACK_SEG is
'Name of the rollback segment to use while refreshing'
/
comment on column DBA_REFRESH.JOB is
'Identifier of job used to automatically refresh the group'
/
comment on column DBA_REFRESH.NEXT_DATE is
'Date that this job will next be automatically refreshed, if not broken'
/
comment on column DBA_REFRESH.INTERVAL is
'A date function used to compute the next NEXT_DATE'
/
comment on column DBA_REFRESH.BROKEN is
'Y or N, Y is the job is broken and will never be run'
/
comment on column DBA_REFRESH.PURGE_OPTION is
'The method for purging the transaction queue after each push'
/
comment on column DBA_REFRESH.PARALLELISM is
'The level of parallelism for transaction propagation'
/
comment on column DBA_REFRESH.HEAP_SIZE is
'The heap size used for transaction propagation'
/
comment on column DBA_REFRESH.JOB_NAME is
'The name of job used to automatically refresh the group'
/
create or replace public synonym DBA_REFRESH for DBA_REFRESH
/
grant select on DBA_REFRESH to select_catalog_role
/


execute CDBView.create_cdbview(false,'SYS','DBA_REFRESH','CDB_REFRESH');
grant select on SYS.CDB_REFRESH to select_catalog_role
/
create or replace public synonym CDB_REFRESH for SYS.CDB_REFRESH
/

create or replace view ALL_REFRESH
as select * from dba_refresh where 
  ( rowner = (select name from sys.user$ where user# = userenv('SCHEMAID')))
  or userenv('SCHEMAID') = 0 or exists
  (select kzsrorol
     from x$kzsro x, sys.system_privilege_map m, sys.sysauth$ s
     where x.kzsrorol = s.grantee# and
           s.privilege# = m.privilege and
           m.name = 'ALTER ANY MATERIALIZED VIEW')
/
comment on table ALL_REFRESH is
'All the refresh groups that the user can touch'
/
comment on column ALL_REFRESH.ROWNER is
'Name of the owner of the refresh group'
/
comment on column ALL_REFRESH.RNAME is
'Name of the refresh group'
/
comment on column ALL_REFRESH.REFGROUP is
'Internal identifier of refresh group'
/
comment on column ALL_REFRESH.IMPLICIT_DESTROY is
'Y or N, if Y then destroy the refresh group when its last item is subtracted'
/
comment on column ALL_REFRESH.PUSH_DEFERRED_RPC is
'Y or N, if Y then push changes from snapshot to master before refresh'
/
comment on column ALL_REFRESH.REFRESH_AFTER_ERRORS is
'If Y, proceed with refresh despite error when pushing deferred RPCs'
/
comment on column ALL_REFRESH.ROLLBACK_SEG is
'Name of the rollback segment to use while refreshing'
/
comment on column ALL_REFRESH.JOB is
'Identifier of job used to automatically refresh the group'
/
comment on column ALL_REFRESH.NEXT_DATE is
'Date that this job will next be automatically refreshed, if not broken'
/
comment on column ALL_REFRESH.INTERVAL is
'A date function used to compute the next NEXT_DATE'
/
comment on column ALL_REFRESH.BROKEN is
'Y or N, Y is the job is broken and will never be run'
/
comment on column ALL_REFRESH.PURGE_OPTION is
'The method for purging the transaction queue after each push'
/
comment on column ALL_REFRESH.PARALLELISM is
'The level of parallelism for transaction propagation'
/
comment on column ALL_REFRESH.HEAP_SIZE is
'The heap size used for transaction propagation'
/
create or replace public synonym ALL_REFRESH for ALL_REFRESH
/
grant read on ALL_REFRESH to public with grant option
/


create or replace view USER_REFRESH 
as select d.* from dba_refresh d, sys.user$ u where 
d.rowner = u.name
and u.user# = userenv('SCHEMAID')
/
comment on table USER_REFRESH is
'All the refresh groups'
/
comment on column USER_REFRESH.ROWNER is
'Name of the owner of the refresh group'
/
comment on column USER_REFRESH.RNAME is
'Name of the refresh group'
/
comment on column USER_REFRESH.REFGROUP is
'Internal identifier of refresh group'
/
comment on column USER_REFRESH.IMPLICIT_DESTROY is
'Y or N, if Y then destroy the refresh group when its last item is subtracted'
/
comment on column USER_REFRESH.PUSH_DEFERRED_RPC is
'Y or N, if Y then push changes from snapshot to master before refresh'
/
comment on column USER_REFRESH.REFRESH_AFTER_ERRORS is
'If Y, proceed with refresh despite error when pushing deferred RPCs'
/
comment on column USER_REFRESH.ROLLBACK_SEG is
'Name of the rollback segment to use while refreshing'
/
comment on column USER_REFRESH.JOB is
'Identifier of job used to automatically refresh the group'
/
comment on column USER_REFRESH.NEXT_DATE is
'Date that this job will next be automatically refreshed, if not broken'
/
comment on column USER_REFRESH.INTERVAL is
'A date function used to compute the next NEXT_DATE'
/
comment on column USER_REFRESH.BROKEN is
'Y or N, Y is the job is broken and will never be run'
/
comment on column USER_REFRESH.PURGE_OPTION is
'The method for purging the transaction queue after each push'
/
comment on column USER_REFRESH.PARALLELISM is
'The level of parallelism for transaction propagation'
/
comment on column USER_REFRESH.HEAP_SIZE is
'The heap size used for transaction propagation'
/
create or replace public synonym USER_REFRESH for USER_REFRESH
/
grant read on USER_REFRESH to public with grant option
/


create or replace view DBA_REFRESH_CHILDREN
AS SELECT OWNER, 
          NAME, 
          TYPE, 
          ROWNER,
          RNAME, 
          REFGROUP,
          IMPLICIT_DESTROY,
          PUSH_DEFERRED_RPC,
          REFRESH_AFTER_ERRORS,
          ROLLBACK_SEG,
          JOB, 
          NEXT_DATE, 
          INTERVAL,
          BROKEN,
          PURGE_OPTION,
          PARALLELISM,
          HEAP_SIZE,
          JOB_NAME
  FROM (
      SELECT rc.owner AS OWNER, rc.name AS NAME, rc.TYPE# AS TYPE, 
          r.owner AS ROWNER, r.name AS RNAME, r.REFGROUP AS REFGROUP,
          decode(bitand(r.flag,1),1,'Y',0,'N','?') AS IMPLICIT_DESTROY,
          decode(bitand(r.flag,2),2,'Y',0,'N','?') AS PUSH_DEFERRED_RPC,
          decode(bitand(r.flag,4),4,'Y',0,'N','?') AS REFRESH_AFTER_ERRORS,
          r.rollback_seg AS ROLLBACK_SEG,
          j.job AS JOB, j.NEXT_DATE AS NEXT_DATE, j.INTERVAL# AS INTERVAL,
          decode(bitand(j.flag,1),1,'Y',0,'N','?') AS BROKEN,
          r.purge_opt#   AS PURGE_OPTION,
          r.parallelism# AS PARALLELISM,
          r.heap_size#   AS HEAP_SIZE ,
          r.JOB_NAME     AS JOB_NAME
      FROM rgroup$ r, rgchild$ rc, job$ j
      WHERE r.refgroup = rc.refgroup
        AND r.instsite = 0
        AND rc.instsite = 0
        AND r.job_name IS NULL AND r.job = j.job (+)
      UNION ALL
      SELECT rc.owner AS OWNER, 
          rc.name AS NAME, 
          rc.TYPE# AS TYPE, 
          r.owner AS ROWNER, 
          r.name AS RNAME, 
          r.REFGROUP AS REFGROUP,
          decode(bitand(r.flag,1),1,'Y',0,'N','?') AS IMPLICIT_DESTROY,
          decode(bitand(r.flag,2),2,'Y',0,'N','?') AS PUSH_DEFERRED_RPC,
          decode(bitand(r.flag,4),4,'Y',0,'N','?') AS REFRESH_AFTER_ERRORS,
          r.rollback_seg AS ROLLBACK_SEG,
          r.JOB AS JOB, 
          CAST(s.start_date AS DATE)  AS NEXT_DATE, 
          substr(s.repeat_interval,1,200) AS INTERVAL,
          decode(s.enabled,'FALSE','Y','TRUE','N','?') AS BROKEN,
          r.purge_opt#   AS PURGE_OPTION,
          r.parallelism# AS PARALLELISM,
          r.heap_size#   AS HEAP_SIZE ,
          r.JOB_NAME     AS JOB_NAME
      FROM rgroup$ r, rgchild$ rc, dba_scheduler_jobs s 
      WHERE r.refgroup = rc.refgroup
        AND r.instsite = 0
        AND rc.instsite = 0
        AND r.owner = s.owner(+)
        AND r.job_name IS NOT NULL AND r.job_name = s.job_name (+)
  )
/
comment on table DBA_REFRESH_CHILDREN is
'All the objects in refresh groups'
/
comment on column DBA_REFRESH_CHILDREN.OWNER is
'Owner of the object in the refresh group'
/
comment on column DBA_REFRESH_CHILDREN.NAME is
'Name of the object in the refresh group'
/
comment on column DBA_REFRESH_CHILDREN.TYPE is
'Type of the object in the refresh group'
/
comment on column DBA_REFRESH_CHILDREN.ROWNER is
'Name of the owner of the refresh group'
/
comment on column DBA_REFRESH_CHILDREN.RNAME is
'Name of the refresh group'
/
comment on column DBA_REFRESH_CHILDREN.REFGROUP is
'Internal identifier of refresh group'
/
comment on column DBA_REFRESH_CHILDREN.IMPLICIT_DESTROY is
'Y or N, if Y then destroy the refresh group when its last item is subtracted'
/
comment on column DBA_REFRESH_CHILDREN.PUSH_DEFERRED_RPC is
'Y or N, if Y then push changes from snapshot to master before refresh'
/
comment on column DBA_REFRESH_CHILDREN.REFRESH_AFTER_ERRORS is
'If Y, proceed with refresh despite error when pushing deferred RPCs'
/
comment on column DBA_REFRESH_CHILDREN.ROLLBACK_SEG is
'Name of the rollback segment to use while refreshing'
/
comment on column DBA_REFRESH_CHILDREN.JOB is
'Identifier of job used to automatically refresh the group'
/
comment on column DBA_REFRESH_CHILDREN.NEXT_DATE is
'Date that this job will next be automatically refreshed, if not broken'
/
comment on column DBA_REFRESH_CHILDREN.INTERVAL is
'A date function used to compute the next NEXT_DATE'
/
comment on column DBA_REFRESH_CHILDREN.BROKEN is
'Y or N, Y is the job is broken and will never be run'
/
comment on column DBA_REFRESH_CHILDREN.PURGE_OPTION is
'The method for purging the transaction queue after each push'
/
comment on column DBA_REFRESH_CHILDREN.PARALLELISM is
'The level of parallelism for transaction propagation'
/
comment on column DBA_REFRESH_CHILDREN.HEAP_SIZE is
'The heap size used for transaction propagation'
/
comment on column DBA_REFRESH_CHILDREN.JOB_NAME is
'The name of job used to automatically refresh the group'
/
create or replace public synonym DBA_REFRESH_CHILDREN for DBA_REFRESH_CHILDREN
/
grant select on DBA_REFRESH_CHILDREN to select_catalog_role
/


execute CDBView.create_cdbview(false,'SYS','DBA_REFRESH_CHILDREN','CDB_REFRESH_CHILDREN');
grant select on SYS.CDB_REFRESH_CHILDREN to select_catalog_role
/
create or replace public synonym CDB_REFRESH_CHILDREN for SYS.CDB_REFRESH_CHILDREN
/

create or replace view ALL_REFRESH_CHILDREN
as select * from dba_refresh_children where 
 ( rowner = (select name from sys.user$ where user# = userenv('SCHEMAID')))
  or userenv('SCHEMAID') = 0 or exists
  (select kzsrorol
     from x$kzsro x, sys.system_privilege_map m, sys.sysauth$ s    
     where x.kzsrorol = s.grantee# and
           s.privilege# = m.privilege and
           m.name = 'ALTER ANY MATERIALIZED VIEW')
/
comment on table ALL_REFRESH_CHILDREN is
'All the objects in refresh groups, where the user can touch the group'
/
comment on column ALL_REFRESH_CHILDREN.OWNER is
'Owner of the object in the refresh group'
/
comment on column ALL_REFRESH_CHILDREN.NAME is
'Name of the object in the refresh group'
/
comment on column ALL_REFRESH_CHILDREN.TYPE is
'Type of the object in the refresh group'
/
comment on column ALL_REFRESH_CHILDREN.ROWNER is
'Name of the owner of the refresh group'
/
comment on column ALL_REFRESH_CHILDREN.RNAME is
'Name of the refresh group'
/
comment on column ALL_REFRESH_CHILDREN.REFGROUP is
'Internal identifier of refresh group'
/
comment on column ALL_REFRESH_CHILDREN.IMPLICIT_DESTROY is
'Y or N, if Y then destroy the refresh group when its last item is subtracted'
/
comment on column ALL_REFRESH_CHILDREN.PUSH_DEFERRED_RPC is
'Y or N, if Y then push changes from snapshot to master before refresh'
/
comment on column ALL_REFRESH_CHILDREN.REFRESH_AFTER_ERRORS is
'If Y, proceed with refresh despite error when pushing deferred RPCs'
/
comment on column ALL_REFRESH_CHILDREN.ROLLBACK_SEG is
'Name of the rollback segment to use while refreshing'
/
comment on column ALL_REFRESH_CHILDREN.JOB is
'Identifier of job used to automatically refresh the group'
/
comment on column ALL_REFRESH_CHILDREN.NEXT_DATE is
'Date that this job will next be automatically refreshed, if not broken'
/
comment on column ALL_REFRESH_CHILDREN.INTERVAL is
'A date function used to compute the next NEXT_DATE'
/
comment on column ALL_REFRESH_CHILDREN.BROKEN is
'Y or N, Y is the job is broken and will never be run'
/
comment on column ALL_REFRESH_CHILDREN.PURGE_OPTION is
'The method for purging the transaction queue after each push'
/
comment on column ALL_REFRESH_CHILDREN.PARALLELISM is
'The level of parallelism for transaction propagation'
/
comment on column ALL_REFRESH_CHILDREN.HEAP_SIZE is
'The heap size used for transaction propagation'
/
create or replace public synonym ALL_REFRESH_CHILDREN for ALL_REFRESH_CHILDREN
/
grant read on ALL_REFRESH_CHILDREN to public with grant option
/


create or replace view USER_REFRESH_CHILDREN
as select d.* from dba_refresh_children d, sys.user$ u where 
d.rowner = u.name
and u.user#  = userenv('SCHEMAID')
/
comment on table USER_REFRESH_CHILDREN is
'All the objects in refresh groups, where the user owns the refresh group'
/
comment on column USER_REFRESH_CHILDREN.OWNER is
'Owner of the object in the refresh group'
/
comment on column USER_REFRESH_CHILDREN.NAME is
'Name of the object in the refresh group'
/
comment on column USER_REFRESH_CHILDREN.TYPE is
'Type of the object in the refresh group'
/
comment on column USER_REFRESH_CHILDREN.ROWNER is
'Name of the owner of the refresh group'
/
comment on column USER_REFRESH_CHILDREN.RNAME is
'Name of the refresh group'
/
comment on column USER_REFRESH_CHILDREN.REFGROUP is
'Internal identifier of refresh group'
/
comment on column USER_REFRESH_CHILDREN.IMPLICIT_DESTROY is
'Y or N, if Y then destroy the refresh group when its last item is subtracted'
/
comment on column USER_REFRESH_CHILDREN.PUSH_DEFERRED_RPC is
'Y or N, if Y then push changes from snapshot to master before refresh'
/
comment on column USER_REFRESH_CHILDREN.REFRESH_AFTER_ERRORS is
'If Y, proceed with refresh despite error when pushing deferred RPCs'
/
comment on column USER_REFRESH_CHILDREN.ROLLBACK_SEG is
'Name of the rollback segment to use while refreshing'
/
comment on column USER_REFRESH_CHILDREN.JOB is
'Identifier of job used to automatically refresh the group'
/
comment on column USER_REFRESH_CHILDREN.NEXT_DATE is
'Date that this job will next be automatically refreshed, if not broken'
/
comment on column USER_REFRESH_CHILDREN.INTERVAL is
'A date function used to compute the next NEXT_DATE'
/
comment on column USER_REFRESH_CHILDREN.BROKEN is
'Y or N, Y is the job is broken and will never be run'
/
comment on column USER_REFRESH_CHILDREN.PURGE_OPTION is
'The method for purging the transaction queue after each push'
/
comment on column USER_REFRESH_CHILDREN.PARALLELISM is
'The level of parallelism for transaction propagation'
/
comment on column USER_REFRESH_CHILDREN.HEAP_SIZE is
'The heap size used for transaction propagation'
/
create or replace public synonym USER_REFRESH_CHILDREN
   for USER_REFRESH_CHILDREN
/
grant read on USER_REFRESH_CHILDREN to public with grant option
/
rem
rem This view family is being replaced with [DBA/ALL/USER]_REGISTERED_MVIEWS
rem for the 9i release. For changes to the [DBA/ALL/USER]_REGISTERED_SNAPSHOTS
rem view family, verify whether changes need to be done to the replacement 
rem views.
rem
create or replace view DBA_REGISTERED_SNAPSHOTS 
  (OWNER, NAME, SNAPSHOT_SITE, CAN_USE_LOG, UPDATABLE, REFRESH_METHOD,
   SNAPSHOT_ID, VERSION, QUERY_TXT)
as select sowner, snapname, snapsite,
   decode(bitand(flag,1), 0 , 'NO', 'YES'),
   decode(bitand(flag,2), 0 , 'NO', 'YES'),
   decode(bitand(flag, 32),               32, 'PRIMARY KEY',
          decode(bitand(flag, 536870912), 536870912, 'OBJECT ID', 'ROWID')),
   snapshot_id, 
   decode(rep_type, 1, 'ORACLE 7 SNAPSHOT',
                    2, 'ORACLE 8 SNAPSHOT',
                    3, 'REPAPI SNAPSHOT',
                       'UNKNOWN'),
   query_txt
from sys.reg_snap$
/
create or replace public synonym DBA_REGISTERED_SNAPSHOTS
   for DBA_REGISTERED_SNAPSHOTS 
/
grant select on DBA_REGISTERED_SNAPSHOTS to select_catalog_role
/
comment on table DBA_REGISTERED_SNAPSHOTS is
'Remote snapshots of local tables'
/
comment on column DBA_REGISTERED_SNAPSHOTS.OWNER is
'Owner of the snapshot'
/
comment on column DBA_REGISTERED_SNAPSHOTS.NAME is
'The name of the snapshot'
/
comment on column DBA_REGISTERED_SNAPSHOTS.SNAPSHOT_SITE is
'Global name of the snapshot site'
/
comment on column DBA_REGISTERED_SNAPSHOTS.CAN_USE_LOG is
'If NO, this snapshot is complex and cannot fast refresh'
/
comment on column DBA_REGISTERED_SNAPSHOTS.UPDATABLE is
'If NO, the snapshot is read only'
/
comment on column DBA_REGISTERED_SNAPSHOTS.REFRESH_METHOD is
'Whether the snapshot uses rowid, primary key or object id for fast refresh'
/
comment on column DBA_REGISTERED_SNAPSHOTS.SNAPSHOT_ID is
'Identifier for the snapshot used by the master for fast refresh'
/
comment on column DBA_REGISTERED_SNAPSHOTS.VERSION is
'Version of snapshot'
/
comment on column DBA_REGISTERED_SNAPSHOTS.QUERY_TXT is
'Query defining the snapshot'
/


execute CDBView.create_cdbview(false,'SYS','DBA_REGISTERED_SNAPSHOTS','CDB_REGISTERED_SNAPSHOTS');
grant select on SYS.CDB_REGISTERED_SNAPSHOTS to select_catalog_role
/
create or replace public synonym CDB_REGISTERED_SNAPSHOTS for SYS.CDB_REGISTERED_SNAPSHOTS
/

create or replace view ALL_REGISTERED_SNAPSHOTS
as select  * from dba_registered_snapshots s
where exists (select a.snapshot_id from  all_snapshot_logs a
                             where  s.snapshot_id = a.snapshot_id)
or  userenv('SCHEMAID') = 1
or  ora_check_sys_privilege(userenv('SCHEMAID'), 2) = 1
/
comment on table ALL_REGISTERED_SNAPSHOTS is
'Remote snapshots of local tables that the user can see'
/
comment on column ALL_REGISTERED_SNAPSHOTS.OWNER is
'Owner of the snapshot'
/
comment on column ALL_REGISTERED_SNAPSHOTS.NAME is
'The name of the snapshot'
/
comment on column ALL_REGISTERED_SNAPSHOTS.SNAPSHOT_SITE is
'Global name of the snapshot site'
/
comment on column ALL_REGISTERED_SNAPSHOTS.CAN_USE_LOG is
'If NO, this snapshot is complex and cannot fast refresh'
/
comment on column ALL_REGISTERED_SNAPSHOTS.UPDATABLE is
'If NO, the snapshot is read only'
/
comment on column ALL_REGISTERED_SNAPSHOTS.REFRESH_METHOD is
'Whether the snapshot uses rowid or primary key or object id for fast refresh'
/
comment on column ALL_REGISTERED_SNAPSHOTS.SNAPSHOT_ID is
'Identifier for the snapshot used by the master for fast refresh'
/
comment on column ALL_REGISTERED_SNAPSHOTS.VERSION is
'Version of snapshot'
/
comment on column ALL_REGISTERED_SNAPSHOTS.QUERY_TXT is
'Query defining the snapshot'
/
create or replace public synonym ALL_REGISTERED_SNAPSHOTS
   for ALL_REGISTERED_SNAPSHOTS
/
grant read on ALL_REGISTERED_SNAPSHOTS to public with grant option
/
create or replace view USER_REGISTERED_SNAPSHOTS
as select * from dba_registered_snapshots s
where exists (select snapshot_id from user_snapshot_logs u
                  where s.snapshot_id = u.snapshot_id)
/
comment on table USER_REGISTERED_SNAPSHOTS is
'Remote snapshots of local tables currently using logs owned by the user'
/
comment on column USER_REGISTERED_SNAPSHOTS.OWNER is
'Owner of the snapshot'
/
comment on column USER_REGISTERED_SNAPSHOTS.NAME is
'The name of the snapshot'
/
comment on column USER_REGISTERED_SNAPSHOTS.SNAPSHOT_SITE is
'Global name of the snapshot site'
/
comment on column USER_REGISTERED_SNAPSHOTS.CAN_USE_LOG is
'If NO, this snapshot is complex and cannot fast refresh'
/
comment on column USER_REGISTERED_SNAPSHOTS.UPDATABLE is
'If NO, the snapshot is read only'
/
comment on column USER_REGISTERED_SNAPSHOTS.REFRESH_METHOD is
'Whether the snapshot uses rowid or primary key or object id for fast refresh'
/
comment on column USER_REGISTERED_SNAPSHOTS.SNAPSHOT_ID is
'Identifier for the snapshot used by the master for fast refresh'
/
comment on column USER_REGISTERED_SNAPSHOTS.VERSION is
'Version of snapshot'
/
comment on column USER_REGISTERED_SNAPSHOTS.QUERY_TXT is
'Query defining the snapshot'
/
create or replace public synonym USER_REGISTERED_SNAPSHOTS
   for USER_REGISTERED_SNAPSHOTS
/
grant read on USER_REGISTERED_SNAPSHOTS to public with grant option
/
rem
rem  Family of MVIEW views
rem

rem  DBA_MVIEWS

/* Some of the column values come from summary meta-data.  This meta-data
 * can be missing for pre-8.1.5 MVs.  Missing information will be assigned 
 * a null value.  The columns that depend on a summary row are REWRITE_ENABLED, 
 * REWRITE_CAPABILITY, LAST_REFRESH_TYPE, LAST_REFRESH_DATE
 *
 * 11g enhancement: three new fields have been added to get aggregate 
 * pct information related to the mv. These fields are NUM_PCT_TABLES,
 * NUM_FRESH_PCT_REGIONS and NUM_STALE_PCT_REGIONS.
 */

create or replace view DBA_MVIEWS
( OWNER,                    /* owner name                                   */
  MVIEW_NAME,               /* materialized view name                       */
  CONTAINER_NAME,           /* materialized view container table name       */
  QUERY,                    /* defining query                               */
  QUERY_LEN,                /* length of defining query (in bytes)          */
  UPDATABLE,                /* Y if updatable materialized view, else N     */
  UPDATE_LOG,               /* update log for updatable materialized views  */
  MASTER_ROLLBACK_SEG,      /* rollback segment for master site             */
  MASTER_LINK,              /* dblink for master site                       */
/* rewrite info:                                                            */
  REWRITE_ENABLED,          /* Y if enabled for rewrite, else N             */
  REWRITE_CAPABILITY,       /* NONE/TEXTMATCH/GENERAL                       */
                            /* (determined statically)                      */
/* refresh info:                                                            */
  REFRESH_MODE,             /* DEMAND/COMMIT/NEVER                          */
  REFRESH_METHOD,           /* COMPLETE/FORCE/FAST/NEVER                    */
  BUILD_MODE,               /* IMMEDIATE/DEFERRED/PREBUILT                  */
  FAST_REFRESHABLE,         /* NO/DIRLOAD/DML/DIRLOAD_DML/                  */
                            /* DIRLOAD_LIMITEDDML                           */
                            /* (determined statically)                      */
/* refresh execution:                                                       */
  LAST_REFRESH_TYPE,        /* COMPLETE/FAST/UNKNOWN                        */
  LAST_REFRESH_DATE,        /* date of last refresh                         */
  LAST_REFRESH_END_TIME,    /* end time of last refresh                     */
/* staleness:                                                               */
  STALENESS,                /* FRESH/STALE/UNUSABLE/UNKNOWN/UNDEFINED/      */
                            /* NEEDS_COMPLILE/COMPILATION_ERROR/            */
                            /* AUTHORIZATION_ERROR                          */
  AFTER_FAST_REFRESH,       /* FRESH/STALE/UNUSABLE/UNKNOWN/UNDEFINED/NA/   */
                            /* NEEDS_COMPILE/COMPILATION_ERROR/             */
                            /* AUTHORIZATION_ERROR                          */
/* specific info for MVs in unknown state                                   */
  UNKNOWN_PREBUILT,         /* (Y/N) MV is in unknown state because it is   */
                            /*       prebuilt                               */
  UNKNOWN_PLSQL_FUNC,       /* (Y/N) MV is in unknown state because it has  */
                            /*       PLSQL function                         */
  UNKNOWN_EXTERNAL_TABLE,   /* (Y/N) MV is in unknown state because it has  */
                            /*       external table                         */
  UNKNOWN_CONSIDER_FRESH,   /* (Y/N) MV is in unknown state because it is   */
                            /*       marked as consider fresh               */
  UNKNOWN_IMPORT,           /* (Y/N) MV is in unknown state because it is   */
                            /*       imported                               */
  UNKNOWN_TRUSTED_FD,       /* (Y/N) MV is in unknown state because it used */
                            /*       trusted constraints for refresh        */
/* meta-data info:                                                          */
  COMPILE_STATE,            /* VALID/NEEDS_COMPILE/COMPILATION_ERROR/       */
                            /* AUTHORIZATION_ERROR                          */
                            /* (state of the MV -- set by alter compile)    */
  USE_NO_INDEX,             /* Y if mv using no index, else N               */
  STALE_SINCE,              /* date of MV frist becoming stale              */
  NUM_PCT_TABLES,           /* number of PCT detail tables                  */
  NUM_FRESH_PCT_REGIONS,    /* number of fresh PCT partition regions        */
  NUM_STALE_PCT_REGIONS,    /* number of stale PCT partition regions        */
  SEGMENT_CREATED,          /* Y if segment is created, else N              */
  EVALUATION_EDITION,       /* evaluation edition name, NULL if none        */
  UNUSABLE_BEFORE,          /* unusable before edition, NULL if none        */
  UNUSABLE_BEGINNING,       /* unusable beginning edition, NULL if none     */
  DEFAULT_COLLATION,        /* default collation                            */
  ON_QUERY_COMPUTATION      /* (Y/N) MV is a real-time MV?                  */
)
as
select s.sowner as OWNER, s.vname as MVIEW_NAME, s.tname as CONTAINER_NAME, 
  s.query_txt as QUERY, s.query_len as QUERY_LEN, 
       decode(bitand(s.flag,2), 0, 'N', 'Y') as UPDATABLE,  /* updatable */
       s.uslog as UPDATE_LOG, s.mas_roll_seg as MASTER_ROLLBACK_SEG, s.mlink as MASTER_LINK,
       decode(w.mflags,
              '', '',  /* missing summary */
              decode(bitand(w.mflags, 4), 4, 'N', 'Y')) as REWRITE_ENABLED,
       /* rewrite capability
        *   KKQS_NOGR_PFLAGS:
        *     QSMG_SUM_PART_EXT_NAME + QSMG_SUM_CONNECT_BY +
        *     QSMG_SUM_RAW_OUTPUT + QSMG_SUM_SUBQUERY_HAVING +
        *     QSMG_SUM_SUBQUERY_WHERE + QSMG_SUM_SET_OPERATOR +
        *     QSMG_SUM_NESTED_CURSOR + QSMG_SUM_OUT_MISSING_GRPCOL +
        *     QSMG_SUM_AGGREGATE_NOT_TOP
        *
        *   KKQS_NOGR_XPFLAGS:
        *     QSMG_SUM_WCLS
        *
        *   QSMG_SUM_DATA_IGNORE - 2nd-class summary
        */
       decode(w.pflags,
              '', '',  /* missing summary */
              decode(bitand(w.pflags, 1073741824), /* 2nd-class summary */
                     1073741824, 'NONE',
                     /* 2152929292 = 2147483648 + 2048 + 4096 + 65536 + 131072 +
                      *              1048576 + 4194304 + 8 + 4
                      */
                     decode(bitand(w.pflags, 2152929292),
                            0, decode(bitand(w.xpflags, 8192),
                                      8192, 'TEXTMATCH',
                                      'GENERAL'),
                            'TEXTMATCH'))) as REWRITE_CAPABILITY,
       decode(s.auto_fast,
              'N', 'NEVER',
              decode(bitand(s.flag, 32768), 
                     0, decode(bitand(s.flag3, 67108864), 
                               0, 'DEMAND', 'STATEMENT'), 
                     'COMMIT')) as REFRESH_MODE,
       decode(s.auto_fast,   /* refresh method */
              'C',  'COMPLETE',
              'F',  'FAST',
              '?',  'FORCE',
              'N',  'NEVER',
              NULL, 'FORCE', 'ERROR') as REFRESH_METHOD,
       decode(bitand(s.flag, 131072),  /* build mode */
              131072, 'PREBUILT',
              decode(bitand(s.flag, 524288), 0, 'IMMEDIATE', 'DEFERRED')) as BUILD_MODE,
       /* fast refreshable 
        *     rowid+primary key+object id+subquery+complex+MAV+MJV+MAV1
        *     536900016 = 16+32+536870912+128+256+4096+8192+16384
        */
     decode(bitand(s.flag2, 67108864),
            67108864,  
            /* if primary CUBE MV, use its secondary MV's flag value to 
             * determine its FAST REFRESHABILITY. */ 
              (decode(bitand((select s2.flag from sys.snap$ s2 
                              where s2.parent_sowner=s.sowner and s2.parent_vname=s.vname), 536900016),
              16,        'DIRLOAD_DML',  /* rowid */
              32,        'DIRLOAD_DML',  /* primary key */
              536870912, 'DIRLOAD_DML',  /* object id */
              160,       'DIRLOAD_DML',  /* subquery - has both the primary key     */
                                 /* bit and the subquery bit  (32+128)      */
              536871040, 'DIRLOAD_DML',  /* subquery - has both the object id bit   */
                                 /* and the subquery bit (536870912+128)    */
              256,       'NO',   /* complex */
              4096,   decode(bitand(s.flag2,23),            /* KKZFAGG_INSO */
                             0,
                             'DIRLOAD_DML',                  /* regular MAV */
                             'DIRLOAD_LIMITEDDML'),      /* insert only MAV */
              8192,      'DIRLOAD_DML', /* MJV */
              16384,     'DIRLOAD_DML', /* MAV1 */
              decode(bitand(s.flag2, 16384), 
                     16384,   'DIRLOAD_DML', /* UNION_ALL MV */
                     'ERROR'))), 
            decode(                      
              bitand(s.flag, 536900016),
              16,        'DIRLOAD_DML',  /* rowid */
              32,        'DIRLOAD_DML',  /* primary key */
              536870912, 'DIRLOAD_DML',  /* object id */
              160,       'DIRLOAD_DML',  /* subquery - has both the primary key     */
                                 /* bit and the subquery bit  (32+128)      */
              536871040, 'DIRLOAD_DML',  /* subquery - has both the object id bit   */
                                 /* and the subquery bit (536870912+128)    */
              256,       'NO',   /* complex */
              4096,   decode(bitand(s.flag2,23),            /* KKZFAGG_INSO */
                             0,
                             'DIRLOAD_DML',                  /* regular MAV */
                             'DIRLOAD_LIMITEDDML'),      /* insert only MAV */
              8192,      'DIRLOAD_DML', /* MJV */
              16384,     'DIRLOAD_DML', /* MAV1 */
              decode(bitand(s.flag2, 16384), 
                     16384,   'DIRLOAD_DML', /* UNION_ALL MV */
                     'ERROR'))) as FAST_REFRESHABLE,
       /* fixing bug 923186 */
       decode(w.mflags,                    /*last refresh type */
              '','',                       /*missing summary */
              decode(bitand(w.mflags,16384+32768+4194304+1073741824), 
                     0, 'NA', 
                     16384, 'COMPLETE', 
                     32768, 'FAST',
                     4194304, 'FAST_PCT',
                     1073741824, 'FAST_CS',
                     'ERROR')) as LAST_REFRESH_TYPE,                  
       /* end fixing bug 923186 */
       /* the last refresh date should be of date type and not varchar,
       ** SO BE CAREFUL WITH CHANGES IN THE FOLLOWING DECODE
       */
       decode(w.lastrefreshdate,  /* last refresh date */
              NULL, to_date(NULL, 'DD-MON-YYYY'),  /* missing summary */
              decode(to_char(w.lastrefreshdate,'DD-MM-YYYY'),'01-01-1950', 
              to_date(NULL, 'DD-MON-YYYY'), w.lastrefreshdate)) as LAST_REFRESH_DATE,
       /* fixing bug 14116743 */
       decode(w.mflags,                    /*last refresh end time */
              NULL,  to_date(NULL, 'DD-MON-YYYY'),
              decode(bitand(w.mflags,16384+32768+4194304+1073741824), 
                     0, to_date(NULL, 'DD-MON-YYYY'), 
                     /* complete refresh */
                     16384, w.lastrefreshdate+w.fullrefreshtim/(24*60*60),
                     /* fast refresh */
                     32768, w.lastrefreshdate+w.increfreshtim/(24*60*60),
                     /* PCT refresh */
                     4194304, w.lastrefreshdate+w.increfreshtim/(24*60*60),
                     /* cube fastsolve refresh (treated as complete refresh) */
                     1073741824, w.lastrefreshdate+w.fullrefreshtim/(24*60*60),
                     to_date(NULL, 'DD-MON-YYYY'))) as LAST_REFRESH_END_TIME,
       /* staleness */
        decode(NVL(s.mlink,'null'),  /* not null implies remote */
              'null', decode(bitand(s.status, 4),  /* snapshot-invalid */
                             4, 'UNUSABLE',
                             decode(o.status,
                                    1, decode(w.mflags,
                                         '', '',  /* missing summary */
                                         decode(bitand(w.mflags, 8388608),
                                                8388608, 'IMPORT',            /* mv imported */
                                                decode(bitand(w.mflags, 64),  /* wh-unusable */
                                                       64, 'UNUSABLE',        /* unusable */
                                                       decode(bitand(w.mflags, 32), 
                                                              0,    /* unknown */
                                            /* known stale */  decode(bitand(w.mflags, 1),
                                                              0, 'FRESH',
                                                              'STALE'), 'UNKNOWN')))),
                                    2, 'AUTHORIZATION_ERROR',
                                    3, 'COMPILATION_ERROR',
                                    5, 'NEEDS_COMPILE',
                                    'ERROR')),
              'UNDEFINED') as STALENESS,  /* remote MV */
       /* after fast refresh */
       /* in the decode for after fast refresh, we only have to check
        * whether w.mflags is null once.  all of the other occurences 
        * fall under the first check.  if the summary information is not
        * null, we need to check for the warehouse unusable condition
        * before we check to see if the MV is complex.  if the summary
        * information is null, we still need to check whether the MV
        * is complex.  
        */
       decode(NVL(s.mlink,'null'),  /* remote */
              'null', decode(s.auto_fast,  /* never refresh */
                         'N', 'NA', 
                         decode(bitand(s.flag, 32768),  /* on commit */
                             32768, 'NA',
                             decode(bitand(s.status, 4),  /* snap-invalid */
                                4, 'NA',
                                decode(w.mflags,  /* missing summary */
                                   '', decode(bitand(s.flag, 256), /* complex */
                                              256, 'NA',
                                              ''),
                                   decode(o.status,
                                      1, decode(bitand(w.mflags, 8388608),
                                            8388608, 'UNKNOWN',        /* imported */
                  /* warehouse unusable */  decode(bitand(w.mflags, 64),
                                               64, 'NA',
                                               decode(bitand(s.flag, 256), /*complex*/
                                                  256, 'NA',
                                 /* unknown */    decode(bitand(w.mflags,32),
                                                     32, 'UNKNOWN',
                                 /* known stale */   decode(bitand(w.mflags, 1),
                                                        0, 'FRESH',
                  /* stale states (on-demand only)
                   * (This decode is the default clause for the known-stale 
                   * decode statement.  It should be indented there, but there
                   * isn't enough room.) 
                   */
                   decode(bitand(s.flag, 176), /* ri+pk+sq  */
                                               /* 16+32+128 */
                          0, decode(bitand(s.flag, 28672), /* mjv+mav1+mav  */
                                                         /* 8192+16384+4096 */
                                      0, 'ERROR', /* no mv type */
                /* mjv/mav/mav1 MV */ decode(bitand(w.mflags, 1576832),
                           /* 1576832 = 128+256+512+1024+2048+524288+1048576*/
                                      /*si + su + lsi + lsu + sf + sp + spu */
                                             128, 'FRESH',     /* si */
                                             256, 'UNKNOWN',   /* su */
                                             512, 'STALE',     /* sf */
                                             1024, 'FRESH',    /* lsi */
                                             2048, 'UNKNOWN',  /* lsu */
                                             524288, 'FRESH',  /* sp */
                                             1048576, 'UNKNOWN', /* spu */
                            /* 128+1024 */   1152, 'FRESH',    /* si+lsi*/
                            /* 256+2048 */   2304, 'UNKNOWN',  /* su+lsu*/
                                             'ERROR')),
   /* ri or pk or sq MV */  decode(bitand(w.mflags, 1576832),
                             /* 1576832 = 128+256+512+1024+2048+524288+1048576 */
                                   128, 'STALE',     /* si */
                                   256, 'STALE',     /* su */
                                   512, 'STALE',     /* sf */
                                   1024, 'FRESH',    /* lsi */
                                   2048, 'UNKNOWN',  /* lsu */
                                   524288, 'FRESH',  /* sp */
                                   1048576, 'UNKNOWN', /* spu */
                  /* 128+1024 */   1152, 'STALE',    /* si+lsi*/
                  /* 256+2048 */   2304, 'STALE',    /* su+lsu*/
                                   'ERROR'))))))),
                      2, 'AUTHORIZATION_ERROR',
                      3, 'COMPILATION_ERROR',
                      5, 'NEEDS_COMPILE',
                      'ERROR'))))),
              'UNDEFINED') as AFTER_FAST_REFRESH, /* remote mv */
       /* UNKNOWN_PREBUILT */ 
       decode(w.pflags,
              '','', /* missing summary */
              decode(bitand(s.flag, 131072),
                    131072, 'Y', 'N')) as UNKNOWN_PREBUILT,
       /* UNKNOWN_PLSQL_FUNC */
       decode(w.pflags,
              '','', /* missing summary */
              decode(bitand(w.pflags, 268435456),
                     268435456, 'Y', 'N')) as UNKNOWN_PLSQL_FUNC,
       /* UNKNOWN_EXTERNAL_TABLE */
       decode(w.xpflags,
              '','', /* missing summary */
              decode(bitand(w.xpflags, 32768),
                     32768, 'Y', 'N')) as UNKNOWN_EXTERNAL_TABLE,
       /* UNKNOWN_CONSIDER_FRESH */
       decode(w.mflags,
              '','', /* missing summary */
              decode(bitand(w.mflags, 8192),
                     8192, 'Y', 'N')) as UNKNOWN_CONSIDER_FRESH,
       /* UNKNOWN_IMPORT */
       decode(w.mflags,
              '','', /* missing summary */
              decode(bitand(w.mflags, 8388608),
                     8388608, 'Y', 'N')) as UNKNOWN_IMPORT,
       /* UNKNOWN_TRUSTED_FD */
       decode(w.mflags, 
              '','', /* missing summary */
              decode(bitand(w.mflags, 33554432),
                     33554432, 'Y', 'N')) as UNKNOWN_TRUSTED_FD,               
       decode(o.status, 
              1, 'VALID', 
              2, 'AUTHORIZATION_ERROR',
              3, 'COMPILATION_ERROR',
              5, 'NEEDS_COMPILE', 'ERROR') as COMPILE_STATE, /* compile st*/
       decode(bitand(s.flag2,1024), 0, 'N', 'Y') as USE_NO_INDEX, /* USE NO INDEX ? */
       (select min(TIME_DP) from sys.SMON_SCN_TIME 
        where (SCN_WRP*4294967295+ SCN_BAS) > 
              (select min(t.spare3)
               from tab$ t, dependency$ d
               where t.obj#= d.p_obj# and w.obj#=d.d_obj# and
                     t.spare3 > w.lastrefreshscn)) as STALE_SINCE,
           /* whether this is a PCT refresh enabled primary CUBE MV */
       (decode(bitand(w.xpflags, 8589934592), 0, 
        (select count(*) as num_pct_tables from 
          (select wd.sumobj#, wd.detailobj# from sys.sumdetail$ wd 
           where wd.detaileut > 0) wdd where wdd.sumobj# = w.obj#), 
        (select count(*) as num_pct_tables from 
          (select wd.sumobj#, wd.detailobj# from sys.sumdetail$ wd 
           where wd.detaileut > 2147483648 ) /* special secondary cube row */
                wdd where wdd.sumobj# = w.obj#)  )) as NUM_PCT_TABLES,
        (select num_fresh_partns from
             (select sumobj#, sum(num_fresh_partitions) as num_fresh_partns,
                            sum(num_stale_partitions) as num_stale_partns
              from
              (select sumobj#, 
               decode(partn_state, 'FRESH', partn_count, 0) 
               as num_fresh_partitions,
               decode(partn_state, 'STALE', partn_count, 0) 
               as num_stale_partitions
               from 
               (select sumobj#, partn_state, count(*) as partn_count from 
                (select sumobj#,
                        (case when partn_scn is NULL then 'FRESH' 
                         when partn_scn < mv_scn
                         then 'FRESH' else 'STALE' end) partn_state
                 from
                 (select sumobj#, mv_scn, sub_pobj#, max(partn_scn) partn_scn
                  from
                    /* from tabpart$ */
                  (select s.obj# as sumobj#, s.lastrefreshscn as mv_scn, 
                          t.obj# pobj#, t.obj# as sub_pobj#, 
                          t.spare1 as partn_scn
                   from sys.sum$ s, sys.sumdetail$ sd, sys.tabpart$ t 
                   where s.obj# = sd.sumobj# and sd.detailobj# = t.bo#
                         and bitand(sd.detaileut, 2147483648) = 0  
                                      /* NO secondary CUBE MV rows */
                   union  /* from sumdelta$ */
                   select s.obj# as sumobj#, s.lastrefreshscn as mv_scn,
                          t.tableobj# pobj#, t.spare2 as sub_pobj#, 
                          t.scn as partn_scn
                   from sys.sum$ s, sys.sumdetail$ sd, sys.sumdelta$ t
                   where s.obj# = sd.sumobj# and sd.detailobj# = t.tableobj#
                         and bitand(sd.detaileut, 2147483648) = 0
                                      /* NO secondary CUBE MV rows */
                   union /* from tabsubpart$ */
                   select s.sumobj#, s.mv_scn, s.pobj# pobj#, 
                          t.obj# as sub_pobj#,t.spare1 as partn_scn
                   from  tabsubpart$ t, 
                    (select s.obj# as sumobj#, s.lastrefreshscn as mv_scn, 
                            t.obj# pobj#, t.spare1 as partn_scn 
                     from sys.sum$ s, sys.sumdetail$ sd, sys.tabcompart$ t 
                     where s.obj# = sd.sumobj# and sd.detailobj# = t.bo#
                           and bitand(sd.detaileut, 2147483648) = 0  
                                      /* NO secondary CUBE MV rows */) s 
                   where t.pobj# = s.pobj#)
                  group by sumobj#,mv_scn, sub_pobj#)
                 )
                group by sumobj#, partn_state)) group by sumobj#) nfsp 
         where nfsp.sumobj# = w.obj#) as NUM_FRESH_PCT_REGIONS,
        (select num_stale_partns from
             (select sumobj#, sum(num_fresh_partitions) as num_fresh_partns,
                            sum(num_stale_partitions) as num_stale_partns
              from
              (select sumobj#, 
               decode(partn_state, 'FRESH', partn_count, 0) 
               as num_fresh_partitions,
               decode(partn_state, 'STALE', partn_count, 0) 
               as num_stale_partitions
               from 
               (select sumobj#, partn_state, count(*) as partn_count from 
                (select sumobj#, 
                        (case when partn_scn is NULL then 'FRESH' 
                         when partn_scn < mv_scn
                         then 'FRESH' else 'STALE' end) partn_state
                 from
                 (select sumobj#, mv_scn, sub_pobj#, max(partn_scn) partn_scn
                  from
                    /* from tabpart$ */
                  (select s.obj# as sumobj#, s.lastrefreshscn as mv_scn, 
                          t.obj# pobj#, t.obj# as sub_pobj#, 
                          t.spare1 as partn_scn
                   from sys.sum$ s, sys.sumdetail$ sd, sys.tabpart$ t 
                   where s.obj# = sd.sumobj# and sd.detailobj# = t.bo#
                         and bitand(sd.detaileut, 2147483648) = 0  
                                      /* NO secondary CUBE MV rows */
                   union  /* from sumdelta$ */
                   select s.obj# as sumobj#, s.lastrefreshscn as mv_scn,
                          t.tableobj# pobj#, t.spare2 as sub_pobj#, 
                          t.scn as partn_scn
                   from sys.sum$ s, sys.sumdetail$ sd, sys.sumdelta$ t
                   where s.obj# = sd.sumobj# and sd.detailobj# = t.tableobj#
                         and bitand(sd.detaileut, 2147483648) = 0
                                      /* NO secondary CUBE MV rows */
                   union /* from tabsubpart$ */
                   select s.sumobj#, s.mv_scn, s.pobj# pobj#, 
                          t.obj# as sub_pobj#,t.spare1 as partn_scn
                   from  tabsubpart$ t, 
                    (select s.obj# as sumobj#, s.lastrefreshscn as mv_scn, 
                            t.obj# pobj#, t.spare1 as partn_scn 
                     from sys.sum$ s, sys.sumdetail$ sd, sys.tabcompart$ t 
                     where s.obj# = sd.sumobj# and sd.detailobj# = t.bo#
                           and bitand(sd.detaileut, 2147483648) = 0  
                                      /* NO secondary CUBE MV rows */) s 
                   where t.pobj# = s.pobj#)
                  group by sumobj#,mv_scn, sub_pobj#)
                 )
                group by sumobj#, partn_state)) group by sumobj#) nfsp 
         where nfsp.sumobj# = w.obj#) as NUM_STALE_PCT_REGIONS,
decode(bitand(t.property, 17179869184), 17179869184, 'NO', 
              decode(bitand(t.property, 32), 32, 'N/A', 'YES')),
  s.eval_edition,
  case when w.unusablebefore# is null then null
    else (select name from obj$ where obj# = w.unusablebefore#) end,
  case when w.unusablebeginning# is null then null
    else (select name from obj$ where obj# = w.unusablebeginning#) end,
  nls_collation_name(nvl(o.dflcollid, 16382)),
       /* ON_QUERY_COMPUTATION */
       decode(bitand(s.flag3, 2097152),
              0, 'N', 'Y') as ON_QUERY_COMPUTATION
from sys.user$ u, sys.sum$ w, sys."_CURRENT_EDITION_OBJ" o, sys.snap$ s, 
     sys.tab$ t, sys.obj$ co
where w.containernam(+) = s.vname
  and w.containerobj# = co.obj#(+)
  and co.obj# = t.obj#(+)
  and o.obj#(+) = w.obj#
  and o.owner# = u.user#(+)
  and ((u.name = s.sowner) or (u.name IS NULL))
  and s.instsite = 0 
  and not (bitand(s.flag, 268435456) > 0       /* MV with user-defined types */
           and bitand(s.objflag, 32) > 0)                    /* secondary MV */
  and not (bitand(s.flag2, 33554432) > 0)               /* secondary CUBE MV */
  and not (bitand(s.flag3, 512) > 0)                              /* zonemap */
/

create or replace public synonym DBA_MVIEWS for DBA_MVIEWS
/
comment on table DBA_MVIEWS is
'All materialized views in the database'
/
comment on column DBA_MVIEWS.OWNER is
'Owner of the materialized view'
/
comment on column DBA_MVIEWS.MVIEW_NAME is
'Name of the materialized view'
/
comment on column DBA_MVIEWS.CONTAINER_NAME is
'Name of the materialized view container table'
/
comment on column DBA_MVIEWS.QUERY is
'The defining query that the materialized view instantiates'
/
comment on column DBA_MVIEWS.QUERY_LEN is
'The number of bytes in the defining query (based on the server character set'
/
comment on column DBA_MVIEWS.UPDATABLE is
'Indicates whether the materialized view can be updated'
/
comment on column DBA_MVIEWS.UPDATE_LOG is
'Name of the table that logs changes to an updatable materialized view'
/
comment on column DBA_MVIEWS.MASTER_ROLLBACK_SEG is
'Name of the rollback segment to use at the master site'
/
comment on column DBA_MVIEWS.MASTER_LINK is
'Name of the database link to the master site'
/
comment on column DBA_MVIEWS.REWRITE_ENABLED is
'Indicates whether rewrite is enabled for the materialized view'
/
comment on column DBA_MVIEWS.REWRITE_CAPABILITY is
'Indicates the kind of rewrite that is enabled'
/
comment on column DBA_MVIEWS.REFRESH_MODE is
'Indicates how and when the materialized view will be refreshed'
/
comment on column DBA_MVIEWS.REFRESH_METHOD is
'The default refresh method for the materialized view (complete, fast, ...)'
/
comment on column DBA_MVIEWS.BUILD_MODE is
'How and when to initially build (load) the materialized view container'
/
comment on column DBA_MVIEWS.FAST_REFRESHABLE is
'Indicates the kinds of operations that can be fast refreshed for the MV'
/
comment on column DBA_MVIEWS.LAST_REFRESH_TYPE is
'Indicates the kind of refresh that was last performed on the MV'
/
comment on column DBA_MVIEWS.LAST_REFRESH_DATE is
'The date that the materialized view was last refreshed'
/
comment on column DBA_MVIEWS.LAST_REFRESH_END_TIME is
'The time that the last materialized view refresh ended'
/
comment on column DBA_MVIEWS.STALENESS is
'Indicates the staleness state of the materialized view (fresh, stale, ...)'
/
comment on column DBA_MVIEWS.AFTER_FAST_REFRESH is
'Indicates the staleness state the MV will have after a fast refresh is done'
/
comment on column DBA_MVIEWS.UNKNOWN_PREBUILT is
'Indicates if the materialized view is prebuilt'
/
comment on column DBA_MVIEWS.UNKNOWN_PLSQL_FUNC is
'Indicates if the materialized view contains PL/SQL function'
/
comment on column DBA_MVIEWS.UNKNOWN_EXTERNAL_TABLE is
'Indicates if the materialized view contains external tables'
/
comment on column DBA_MVIEWS.UNKNOWN_CONSIDER_FRESH is
'Indicates if the materialized view is considered fresh'
/
comment on column DBA_MVIEWS.UNKNOWN_IMPORT is
'Indicates if the materialized view is imported'
/
comment on column DBA_MVIEWS.UNKNOWN_TRUSTED_FD is
'Indicates if the materialized view used trusted constraints for refresh'
/
comment on column DBA_MVIEWS.COMPILE_STATE is
'Indicates the validity of the MV meta-data'
/
comment on column DBA_MVIEWS.USE_NO_INDEX is
'Indicates whether the MV uses no index'
/
comment on column DBA_MVIEWS.STALE_SINCE is
'Time from when the materialized view became stale'
/
comment on column DBA_MVIEWS.NUM_PCT_TABLES is
'Number of PCT detail tables'
/
comment on column DBA_MVIEWS.NUM_FRESH_PCT_REGIONS is
'Number of fresh PCT partition regions'
/
comment on column DBA_MVIEWS.NUM_STALE_PCT_REGIONS is
'Number of stale PCT partition regions'
/
comment on column DBA_MVIEWS.SEGMENT_CREATED is 
'Whether the materialized view segment is created or not'
/
comment on column DBA_MVIEWS.EVALUATION_EDITION is
'Name of the evaluation edition assigned to the materialized view subquery'
/
comment on column DBA_MVIEWS.UNUSABLE_BEFORE is
'Name of the oldest edition eligible for query rewrite'
/
comment on column DBA_MVIEWS.UNUSABLE_BEGINNING is
'Name of the oldest edition in which query rewrite becomes perpetually disabled'
/
comment on column DBA_MVIEWS.DEFAULT_COLLATION is
'Default collation for the materialized view'
/
comment on column DBA_MVIEWS.ON_QUERY_COMPUTATION is
'Indicates if the materialized view is a Real-Time MV'
/
grant select on DBA_MVIEWS to select_catalog_role
/


execute CDBView.create_cdbview(false,'SYS','DBA_MVIEWS','CDB_MVIEWS');
grant select on SYS.CDB_MVIEWS to select_catalog_role
/
create or replace public synonym CDB_MVIEWS for SYS.CDB_MVIEWS
/

rem  ALL_MVIEWS

create or replace view ALL_MVIEWS
as select m.* from dba_mviews m, sys.obj$ o, sys.user$ u
where o.owner#     = u.user#
  and m.mview_name = o.name
  and u.name       = m.owner
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

create or replace public synonym ALL_MVIEWS for ALL_MVIEWS
/
comment on table ALL_MVIEWS is
'All materialized views in the database'
/
comment on column ALL_MVIEWS.OWNER is
'Owner of the materialized view'
/
comment on column ALL_MVIEWS.MVIEW_NAME is
'Name of the materialized view'
/
comment on column ALL_MVIEWS.CONTAINER_NAME is
'Name of the materialized view container table'
/
comment on column ALL_MVIEWS.QUERY is
'The defining query that the materialized view instantiates'
/
comment on column ALL_MVIEWS.QUERY_LEN is
'The number of bytes in the defining query (based on the server character set'
/
comment on column ALL_MVIEWS.UPDATABLE is
'Indicates whether the materialized view can be updated'
/
comment on column ALL_MVIEWS.UPDATE_LOG is
'Name of the table that logs changes to an updatable materialized view'
/
comment on column ALL_MVIEWS.MASTER_ROLLBACK_SEG is
'Name of the rollback segment to use at the master site'
/
comment on column ALL_MVIEWS.MASTER_LINK is
'Name of the database link to the master site'
/
comment on column ALL_MVIEWS.REWRITE_ENABLED is
'Indicates whether rewrite is enabled for the materialized view'
/
comment on column ALL_MVIEWS.REWRITE_CAPABILITY is
'Indicates the kind of rewrite that is enabled'
/
comment on column ALL_MVIEWS.REFRESH_MODE is
'Indicates how and when the materialized view will be refreshed'
/
comment on column ALL_MVIEWS.REFRESH_METHOD is
'The default refresh method for the materialized view (complete, fast, ...)'
/
comment on column ALL_MVIEWS.BUILD_MODE is
'How and when to initially build (load) the materialized view container'
/
comment on column ALL_MVIEWS.FAST_REFRESHABLE is
'Indicates the kinds of operations that can be fast refreshed for the MV'
/
comment on column ALL_MVIEWS.LAST_REFRESH_TYPE is
'Indicates the kind of refresh that was last performed on the MV'
/
comment on column ALL_MVIEWS.LAST_REFRESH_DATE is
'The date that the materialized view was last refreshed'
/
comment on column ALL_MVIEWS.LAST_REFRESH_END_TIME is
'The time that the last materialized view refresh ended'
/
comment on column ALL_MVIEWS.STALENESS is
'Indicates the staleness state of the materialized view (fresh, stale, ...)'
/
comment on column ALL_MVIEWS.AFTER_FAST_REFRESH is
'Indicates the staleness state the MV will have after a fast refresh is done'
/
comment on column ALL_MVIEWS.UNKNOWN_PREBUILT is
'Indicates if the materialized view is prebuilt'
/
comment on column ALL_MVIEWS.UNKNOWN_PLSQL_FUNC is
'Indicates if the materialized view contains PL/SQL function'
/
comment on column ALL_MVIEWS.UNKNOWN_EXTERNAL_TABLE is
'Indicates if the materialized view contains external tables'
/
comment on column ALL_MVIEWS.UNKNOWN_CONSIDER_FRESH is
'Indicates if the materialized view is considered fresh'
/
comment on column ALL_MVIEWS.UNKNOWN_IMPORT is
'Indicates if the materialized view is imported'
/
comment on column ALL_MVIEWS.UNKNOWN_TRUSTED_FD is
'Indicates if the materialized view used trusted constraints for refresh'
/
comment on column ALL_MVIEWS.COMPILE_STATE is
'Indicates the validity of the MV meta-data'
/
comment on column ALL_MVIEWS.USE_NO_INDEX is
'Indicates whether the MV uses no index'
/
comment on column ALL_MVIEWS.STALE_SINCE is
'Time from when the materialized view became stale'
/
comment on column ALL_MVIEWS.NUM_PCT_TABLES is
'Number of PCT detail tables'
/
comment on column ALL_MVIEWS.NUM_FRESH_PCT_REGIONS is
'Number of fresh PCT partition regions'
/
comment on column ALL_MVIEWS.NUM_STALE_PCT_REGIONS is
'Number of stale PCT partition regions'
/
comment on column ALL_MVIEWS.SEGMENT_CREATED is 
'Whether the materialized view segment is created or not'
/
comment on column ALL_MVIEWS.EVALUATION_EDITION is
'Name of the evaluation edition assigned to the materialized view subquery'
/
comment on column ALL_MVIEWS.UNUSABLE_BEFORE is
'Name of the oldest edition eligible for query rewrite'
/
comment on column ALL_MVIEWS.UNUSABLE_BEGINNING is
'Name of the oldest edition in which query rewrite becomes perpetually disabled'
/
comment on column ALL_MVIEWS.ON_QUERY_COMPUTATION is
'Indicates if the materialized view is a Real-Time MV'
/
grant read on ALL_MVIEWS to public with grant option
/

rem  USER_MVIEWS

create or replace view USER_MVIEWS
as select m.* from dba_mviews m, sys.user$ u
where u.user# = userenv('SCHEMAID')
  and m.owner = u.name
/

create or replace public synonym USER_MVIEWS for USER_MVIEWS
/
comment on table USER_MVIEWS is
'All materialized views in the database'
/
comment on column USER_MVIEWS.OWNER is
'Owner of the materialized view'
/
comment on column USER_MVIEWS.MVIEW_NAME is
'Name of the materialized view'
/
comment on column USER_MVIEWS.CONTAINER_NAME is
'Name of the materialized view container table'
/
comment on column USER_MVIEWS.QUERY is
'The defining query that the materialized view instantiates'
/
comment on column USER_MVIEWS.QUERY_LEN is
'The number of bytes in the defining query (based on the server character set'
/
comment on column USER_MVIEWS.UPDATABLE is
'Indicates whether the materialized view can be updated'
/
comment on column USER_MVIEWS.UPDATE_LOG is
'Name of the table that logs changes to an updatable materialized view'
/
comment on column USER_MVIEWS.MASTER_ROLLBACK_SEG is
'Name of the rollback segment to use at the master site'
/
comment on column USER_MVIEWS.MASTER_LINK is
'Name of the database link to the master site'
/
comment on column USER_MVIEWS.REWRITE_ENABLED is
'Indicates whether rewrite is enabled for the materialized view'
/
comment on column USER_MVIEWS.REWRITE_CAPABILITY is
'Indicates the kind of rewrite that is enabled'
/
comment on column USER_MVIEWS.REFRESH_MODE is
'Indicates how and when the materialized view will be refreshed'
/
comment on column USER_MVIEWS.REFRESH_METHOD is
'The default refresh method for the materialized view (complete, fast, ...)'
/
comment on column USER_MVIEWS.BUILD_MODE is
'How and when to initially build (load) the materialized view container'
/
comment on column USER_MVIEWS.FAST_REFRESHABLE is
'Indicates the kinds of operations that can be fast refreshed for the MV'
/
comment on column USER_MVIEWS.LAST_REFRESH_TYPE is
'Indicates the kind of refresh that was last performed on the MV'
/
comment on column USER_MVIEWS.LAST_REFRESH_DATE is
'The date that the materialized view was last refreshed'
/
comment on column USER_MVIEWS.LAST_REFRESH_END_TIME is
'The time that the last materialized view refresh ended'
/
comment on column USER_MVIEWS.STALENESS is
'Indicates the staleness state of the materialized view (fresh, stale, ...)'
/
comment on column USER_MVIEWS.AFTER_FAST_REFRESH is
'Indicates the staleness state the MV will have after a fast refresh is done'
/
comment on column USER_MVIEWS.UNKNOWN_PREBUILT is
'Indicates if the materialized view is prebuilt'
/
comment on column USER_MVIEWS.UNKNOWN_PLSQL_FUNC is
'Indicates if the materialized view contains PL/SQL function'
/
comment on column USER_MVIEWS.UNKNOWN_EXTERNAL_TABLE is
'Indicates if the materialized view contains external tables'
/
comment on column USER_MVIEWS.UNKNOWN_CONSIDER_FRESH is
'Indicates if the materialized view is considered fresh'
/
comment on column USER_MVIEWS.UNKNOWN_IMPORT is
'Indicates if the materialized view is imported'
/
comment on column USER_MVIEWS.UNKNOWN_TRUSTED_FD is
'Indicates if the materialized view used trusted constraints for refresh'
/
comment on column USER_MVIEWS.COMPILE_STATE is
'Indicates the validity of the MV meta-data'
/
comment on column USER_MVIEWS.USE_NO_INDEX is
'Indicates whether the MV uses no index'
/
comment on column USER_MVIEWS.STALE_SINCE is
'Time from when the materialized view became stale'
/
comment on column USER_MVIEWS.NUM_PCT_TABLES is
'Number of PCT detail tables'
/
comment on column USER_MVIEWS.NUM_FRESH_PCT_REGIONS is
'Number of fresh PCT partition regions'
/
comment on column USER_MVIEWS.NUM_STALE_PCT_REGIONS is
'Number of stale PCT partition regions'
/
comment on column USER_MVIEWS.SEGMENT_CREATED is 
'Whether the materialized view segment is created or not'
/
comment on column USER_MVIEWS.EVALUATION_EDITION is
'Name of the evaluation edition assigned to the materialized view subquery'
/
comment on column USER_MVIEWS.UNUSABLE_BEFORE is
'Name of the oldest edition eligible for query rewrite'
/
comment on column USER_MVIEWS.UNUSABLE_BEGINNING is
'Name of the oldest edition in which query rewrite becomes perpetually disabled'
/
comment on column USER_MVIEWS.ON_QUERY_COMPUTATION is
'Indicates if the materialized view is a Real-Time MV'
/
grant read on USER_MVIEWS to public with grant option
/

rem  DBA_MVIEW_REFRESH_TIMES
rem  must keep original [DBA/ALL/USER]_SNAPSHOT_REFRESH_TIMES names as 
rem  synonyms for backward compatibility

create or replace view DBA_MVIEW_REFRESH_TIMES
(OWNER, NAME, MASTER_OWNER, MASTER, LAST_REFRESH)
as select sowner, vname, mowner, master, snaptime
from sys.snap_reftime$ t
where t.instsite = 0 
/
create or replace public synonym DBA_SNAPSHOT_REFRESH_TIMES
   for DBA_MVIEW_REFRESH_TIMES
/
create or replace public synonym DBA_MVIEW_REFRESH_TIMES
   for DBA_MVIEW_REFRESH_TIMES
/
comment on table DBA_MVIEW_REFRESH_TIMES is
'All fast refreshable materialized views and their last refresh times for each master table'
/
comment on column DBA_MVIEW_REFRESH_TIMES.OWNER is
'Owner of the materialized view'
/
comment on column DBA_MVIEW_REFRESH_TIMES.NAME is
'The view used by users and applications for viewing the MV'
/
comment on column DBA_MVIEW_REFRESH_TIMES.MASTER_OWNER is
'Owner of the master table'
/
comment on column DBA_MVIEW_REFRESH_TIMES.MASTER is
'Name of the master table'
/
comment on column DBA_MVIEW_REFRESH_TIMES.LAST_REFRESH is
'SYSDATE from the master site at the time of the last refresh'
/
grant select on DBA_MVIEW_REFRESH_TIMES to select_catalog_role
/


execute CDBView.create_cdbview(false,'SYS','DBA_MVIEW_REFRESH_TIMES','CDB_MVIEW_REFRESH_TIMES');
grant select on SYS.CDB_MVIEW_REFRESH_TIMES to select_catalog_role
/
create or replace public synonym CDB_MVIEW_REFRESH_TIMES for SYS.CDB_MVIEW_REFRESH_TIMES
/

create or replace view ALL_MVIEW_REFRESH_TIMES
as select s.* from dba_mview_refresh_times s, all_mviews a
where s.owner = a.owner
and   s.name  = a.mview_name
/
comment on table ALL_MVIEW_REFRESH_TIMES is
'Materialized views and their last refresh times  for each master table that the user can look at'
/
comment on column  ALL_MVIEW_REFRESH_TIMES.OWNER is
'Owner of the materialized view'
/
comment on column ALL_MVIEW_REFRESH_TIMES.NAME is
'The view used by users and applications for viewing the MV'
/
comment on column ALL_MVIEW_REFRESH_TIMES.MASTER_OWNER is
'Owner of the master table'
/
comment on column ALL_MVIEW_REFRESH_TIMES.MASTER is
'Name of the master table'
/
comment on column ALL_MVIEW_REFRESH_TIMES.LAST_REFRESH is
'SYSDATE from the master site at the time of the last refresh'
/
create or replace public synonym ALL_SNAPSHOT_REFRESH_TIMES
   for ALL_MVIEW_REFRESH_TIMES
/
create or replace public synonym ALL_MVIEW_REFRESH_TIMES
   for ALL_MVIEW_REFRESH_TIMES
/
grant read on ALL_MVIEW_REFRESH_TIMES to public with grant option
/
create or replace view USER_MVIEW_REFRESH_TIMES
as select s.* from dba_mview_refresh_times s, sys.user$ u
where u.user# = userenv('SCHEMAID')
  and s.owner = u.name
/
comment on table USER_MVIEW_REFRESH_TIMES is
'Materialized views and their last refresh times for each master table that the user can look at'
/
comment on column  USER_MVIEW_REFRESH_TIMES.OWNER is
'Owner of the materialized view'
/
comment on column USER_MVIEW_REFRESH_TIMES.NAME is
'The view used by users and applications for viewing the MV'
/
comment on column  USER_MVIEW_REFRESH_TIMES.MASTER_OWNER is
'Owner of the master table'
/
comment on column  USER_MVIEW_REFRESH_TIMES.MASTER is
'Name of the master table'
/
comment on column USER_MVIEW_REFRESH_TIMES.LAST_REFRESH is
'SYSDATE from the master site at the time of the last refresh'
/
create or replace public synonym USER_SNAPSHOT_REFRESH_TIMES
   for USER_MVIEW_REFRESH_TIMES
/
create or replace public synonym USER_MVIEW_REFRESH_TIMES
   for USER_MVIEW_REFRESH_TIMES
/
grant read on USER_MVIEW_REFRESH_TIMES to public with grant option
/
rem
rem This view family replaced [DBA/ALL/USER]_SNAPSHOT_LOGS for the 9i 
rem release. For changes to this family, check to see if the original
rem needs changing as well.
rem 
create or replace view DBA_MVIEW_LOGS
( LOG_OWNER, MASTER, LOG_TABLE, LOG_TRIGGER, ROWIDS, PRIMARY_KEY, OBJECT_ID,
  FILTER_COLUMNS, SEQUENCE, INCLUDE_NEW_VALUES, 
  PURGE_ASYNCHRONOUS, PURGE_DEFERRED, PURGE_START, PURGE_INTERVAL, 
  LAST_PURGE_DATE, LAST_PURGE_STATUS, NUM_ROWS_PURGED, COMMIT_SCN_BASED,
  STAGING_LOG)
as
select m.mowner, m.master, m.log, m.trig, 
       decode(bitand(m.flag,1), 0, 'NO', 'YES'),
       decode(bitand(m.flag,2), 0, 'NO', 'YES'),
       decode(bitand(m.flag,512), 0, 'NO', 'YES'),
       decode(bitand(m.flag,4), 0, 'NO', 'YES'),
       decode(bitand(m.flag,1024), 0, 'NO', 'YES'),
       decode(bitand(m.flag,16), 0, 'NO', 'YES'),
       decode(bitand(m.flag,16384), 0, 'NO', 'YES'),
       decode(bitand(m.flag,32768), 0, 'NO', 'YES'),
       purge_start, purge_next, last_purge_date, 
       last_purge_status, rows_purged,
       decode(bitand(m.flag, 65536), 0, 'NO', 'YES'),
       'NO'
from sys.mlog$ m 
union
select u1.name, o2.name, o1.name, null, null, null,
       null, null, null, null, null, null, null, null, null, null, null,
       null, 'YES'
from sys.syncref$_table_info srt, sys.obj$ o1, sys.user$ u1,
     sys.obj$ o2
where o1.owner# = u1.user# and o1.obj# = srt.staging_log_obj#
      and o2.obj# = srt.table_obj#
/
create or replace public synonym DBA_MVIEW_LOGS for DBA_MVIEW_LOGS
/
comment on table DBA_MVIEW_LOGS is
'All materialized view logs in the database'
/
comment on column DBA_MVIEW_LOGS.LOG_OWNER is
'Owner of the materialized view log'
/
comment on column DBA_MVIEW_LOGS.MASTER is
'Name of the master table which changes are logged'
/
comment on column DBA_MVIEW_LOGS.LOG_TABLE is
'Log table; with rowids and timestamps of rows which changed in the master'
/
comment on column DBA_MVIEW_LOGS.LOG_TRIGGER is
'An after-row trigger on the master which inserts rows into the log'
/
comment on column DBA_MVIEW_LOGS.ROWIDS is
'If YES, the materialized view log records rowid information'
/
comment on column DBA_MVIEW_LOGS.PRIMARY_KEY is
'If YES, the materialized view log records primary key information'
/
comment on column DBA_MVIEW_LOGS.OBJECT_ID is
'If YES, the materialized view log records object id information'
/
comment on column DBA_MVIEW_LOGS.FILTER_COLUMNS is
'If YES, the materialized view log records filter column information'
/
comment on column DBA_MVIEW_LOGS.SEQUENCE is
'If YES, the materialized view log records sequence information'
/
comment on column DBA_MVIEW_LOGS.INCLUDE_NEW_VALUES is
'If YES, the materialized view log records old and new values (else only old values)'
/
comment on column DBA_MVIEW_LOGS.PURGE_ASYNCHRONOUS is
'If YES, the materialized view log is purged asynchronously'
/
comment on column DBA_MVIEW_LOGS.PURGE_DEFERRED is
'If YES, the materialized view log is purged in a deferred manner'
/
comment on column DBA_MVIEW_LOGS.PURGE_START is
'For deferred purge, the purge start date'
/
comment on column DBA_MVIEW_LOGS.PURGE_INTERVAL is
'For deferred purge, the purge interval'
/
comment on column DBA_MVIEW_LOGS.LAST_PURGE_DATE is
'Date of the last purge'
/
comment on column DBA_MVIEW_LOGS.LAST_PURGE_STATUS is
'Status of the last purge: error code or 0 for success'
/
comment on column DBA_MVIEW_LOGS.NUM_ROWS_PURGED is
'Number of rows purged in the last purge'
/
comment on column DBA_MVIEW_LOGS.COMMIT_SCN_BASED is
'If YES, the materialized view log is commit SCN-based'
/
comment on column DBA_MVIEW_LOGS.STAGING_LOG is
'If YES, the log is a staging log for synchronous refresh'
/
grant select on DBA_MVIEW_LOGS to select_catalog_role
/

execute CDBView.create_cdbview(false,'SYS','DBA_MVIEW_LOGS','CDB_MVIEW_LOGS');
grant select on SYS.CDB_MVIEW_LOGS to select_catalog_role
/
create or replace public synonym CDB_MVIEW_LOGS for SYS.CDB_MVIEW_LOGS
/

create or replace view ALL_MVIEW_LOGS
as select s.* from dba_mview_logs s, sys.obj$ o, sys.user$ u
where o.owner#     = u.user#
  and s.log_table = o.name
  and u.name       = s.log_owner
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
comment on table ALL_MVIEW_LOGS is
'All materialized view logs in the database that the user can see'
/
comment on column ALL_MVIEW_LOGS.LOG_OWNER is
'Owner of the materialized view log'
/
comment on column ALL_MVIEW_LOGS.MASTER is
'Name of the master table which changes are logged'
/
comment on column ALL_MVIEW_LOGS.LOG_TABLE is
'Log table; with  rowids and timestamps of rows which changed in the master'
/
comment on column ALL_MVIEW_LOGS.LOG_TRIGGER is
'An after-row trigger on the master which inserts rows into the log'
/
comment on column ALL_MVIEW_LOGS.ROWIDS is
'If YES, the materialized view log records rowid information'
/
comment on column ALL_MVIEW_LOGS.PRIMARY_KEY is
'If YES, the materialized view log records primary key information'
/
comment on column ALL_MVIEW_LOGS.OBJECT_ID is
'If YES, the materialized view log records object id information'
/
comment on column ALL_MVIEW_LOGS.FILTER_COLUMNS is
'If YES, the materialized view log records filter column information'
/
comment on column ALL_MVIEW_LOGS.SEQUENCE is
'If YES, the materialized view log records sequence information'
/
comment on column ALL_MVIEW_LOGS.INCLUDE_NEW_VALUES is
'If YES, the materialized view log records old and new values (else only old values)'
/
comment on column ALL_MVIEW_LOGS.PURGE_ASYNCHRONOUS is
'If YES, the materialized view log is purged asynchronously'
/
comment on column ALL_MVIEW_LOGS.PURGE_DEFERRED is
'If YES, the materialized view log is purged in a deferred manner'
/
comment on column ALL_MVIEW_LOGS.PURGE_START is
'For deferred purge, the purge start date'
/
comment on column ALL_MVIEW_LOGS.PURGE_INTERVAL is
'For deferred purge, the purge interval'
/
comment on column ALL_MVIEW_LOGS.LAST_PURGE_DATE is
'Date of the last purge'
/
comment on column ALL_MVIEW_LOGS.LAST_PURGE_STATUS is
'Status of the last purge: error code or 0 for success'
/
comment on column ALL_MVIEW_LOGS.NUM_ROWS_PURGED is
'Number of rows purged in the last purge'
/
comment on column ALL_MVIEW_LOGS.COMMIT_SCN_BASED is
'If YES, the materialized view log is commit SCN-based'
/
comment on column ALL_MVIEW_LOGS.STAGING_LOG is
'If YES, the log is a staging log for synchronous refresh'
/
create or replace public synonym ALL_MVIEW_LOGS for ALL_MVIEW_LOGS
/
grant read on ALL_MVIEW_LOGS to public with grant option
/
create or replace view USER_MVIEW_LOGS
as select s.* from dba_mview_logs s, sys.user$ u
where s.log_owner = u.name
  and u.user# = userenv('SCHEMAID')
/
comment on table USER_MVIEW_LOGS is
'All materialized view logs owned by the user'
/
comment on column USER_MVIEW_LOGS.LOG_OWNER is
'Owner of the materialized view log'
/
comment on column USER_MVIEW_LOGS.MASTER is
'Name of the master table which changes are logged'
/
comment on column USER_MVIEW_LOGS.LOG_TABLE is
'Log table; with rowids and timestamps of rows which changed in the
master'
/
comment on column USER_MVIEW_LOGS.LOG_TRIGGER is
'Trigger on master table; fills the materialized view log'
/
comment on column USER_MVIEW_LOGS.ROWIDS is
'If YES, the materialized view log records rowid information'
/
comment on column USER_MVIEW_LOGS.PRIMARY_KEY is
'If YES, the materialized view log records primary key information'
/
comment on column USER_MVIEW_LOGS.OBJECT_ID is
'If YES, the materialized view log records object id information'
/
comment on column USER_MVIEW_LOGS.FILTER_COLUMNS is
'If YES, the materialized view log records filter column information'
/
comment on column USER_MVIEW_LOGS.SEQUENCE is
'If YES, the materialized view log records sequence information'
/
comment on column USER_MVIEW_LOGS.INCLUDE_NEW_VALUES is
'If YES, the materialized view log records old and new values (else only old values)'
/
comment on column USER_MVIEW_LOGS.PURGE_ASYNCHRONOUS is
'If YES, the materialized view log is purged asynchronously'
/
comment on column USER_MVIEW_LOGS.PURGE_DEFERRED is
'If YES, the materialized view log is purged in a deferred manner'
/
comment on column USER_MVIEW_LOGS.PURGE_START is
'For deferred purge, the purge start date'
/
comment on column USER_MVIEW_LOGS.PURGE_INTERVAL is
'For deferred purge, the purge interval'
/
comment on column USER_MVIEW_LOGS.LAST_PURGE_DATE is
'Date of the last purge'
/
comment on column USER_MVIEW_LOGS.LAST_PURGE_STATUS is
'Status of the last purge: error code or 0 for success'
/
comment on column USER_MVIEW_LOGS.NUM_ROWS_PURGED is
'Number of rows purged in the last purge'
/
comment on column USER_MVIEW_LOGS.COMMIT_SCN_BASED is
'If YES, the materialized view log is commit SCN-based'
/
comment on column USER_MVIEW_LOGS.STAGING_LOG is
'If YES, the log is a staging log for synchronous refresh'
/
create or replace public synonym USER_MVIEW_LOGS for USER_MVIEW_LOGS
/
grant read on USER_MVIEW_LOGS to public with grant option
/
rem
rem This view family partially replaced [DBA/ALL/USER]_SNAPSHOT_LOGS for the  
rem 9i release. For changes to this family, check to see if the original
rem needs changing as well.
rem 
create or replace view DBA_BASE_TABLE_MVIEWS
( OWNER, MASTER, MVIEW_LAST_REFRESH_TIME, MVIEW_ID)
as
select owner, master,  
       CASE WHEN t1 IS NULL THEN t2 ELSE t1  END, id 
from
    (select s.snapid id, s.mowner owner, s.master master,
           ( select e.last_refresh_date
             from dba_mviews e ,sys.snap$ f
             where f.vname = e.mview_name
               and f.sowner = e.owner
               and f.snapid(+) = s.snapid)  t1, s.snaptime t2
    from sys.slog$ s);	
/

create or replace public synonym DBA_BASE_TABLE_MVIEWS
   for DBA_BASE_TABLE_MVIEWS
/
comment on table DBA_BASE_TABLE_MVIEWS is
'All materialized views with log(s) in the database'
/
comment on column DBA_BASE_TABLE_MVIEWS.OWNER is
'Owner of the master table which changes are logged'
/
comment on column DBA_BASE_TABLE_MVIEWS.MASTER is
'Name of the master table which changes are logged'
/
comment on column DBA_BASE_TABLE_MVIEWS.MVIEW_LAST_REFRESH_TIME is
'One date per materialized view -- the date the materialized view was last refreshed'
/
comment on column DBA_BASE_TABLE_MVIEWS.MVIEW_ID is
'Unique identifier of the materialized view'
/
grant select on DBA_BASE_TABLE_MVIEWS to select_catalog_role
/


execute CDBView.create_cdbview(false,'SYS','DBA_BASE_TABLE_MVIEWS','CDB_BASE_TABLE_MVIEWS');
grant select on SYS.CDB_BASE_TABLE_MVIEWS to select_catalog_role
/
create or replace public synonym CDB_BASE_TABLE_MVIEWS for SYS.CDB_BASE_TABLE_MVIEWS
/

rem privilege checking being performed through all_mview_logs

create or replace view ALL_BASE_TABLE_MVIEWS
as select s.* from dba_base_table_mviews s, all_mview_logs a
where a.log_owner = s.owner
  and a.master = s.master
/
comment on table ALL_BASE_TABLE_MVIEWS is
'All materialized views with log(s) in the database that the user can see'
/
comment on column ALL_BASE_TABLE_MVIEWS.OWNER is
'Owner of the master table which changes are logged'
/
comment on column ALL_BASE_TABLE_MVIEWS.MASTER is
'Name of the master table which changes are logged'
/
comment on column ALL_BASE_TABLE_MVIEWS.MVIEW_LAST_REFRESH_TIME is
'One date per materialized view -- the date the materialized view was last refreshed'
/
comment on column ALL_BASE_TABLE_MVIEWS.MVIEW_ID is
'Unique identifier of the materialized view'
/
create or replace public synonym ALL_BASE_TABLE_MVIEWS
   for ALL_BASE_TABLE_MVIEWS
/
grant read on ALL_BASE_TABLE_MVIEWS to public with grant option
/
create or replace view USER_BASE_TABLE_MVIEWS
as select s.* from dba_base_table_mviews s, sys.user$ u
where s.owner = u.name
  and u.user# = userenv('SCHEMAID')
/
comment on table USER_BASE_TABLE_MVIEWS is
'All materialized views with log(s) owned by the user in the database'
/
comment on column USER_BASE_TABLE_MVIEWS.OWNER is
'Owner of the master table which changes are logged'
/
comment on column USER_BASE_TABLE_MVIEWS.MASTER is
'Name of the master table which changes are logged'
/
comment on column USER_BASE_TABLE_MVIEWS.MVIEW_LAST_REFRESH_TIME is
'One date per materialized view -- the date the materialized view was last refreshed'
/
comment on column USER_BASE_TABLE_MVIEWS.MVIEW_ID is
'Unique identifier of the materialized view'
/
create or replace public synonym USER_BASE_TABLE_MVIEWS
   for USER_BASE_TABLE_MVIEWS
/
grant read on USER_BASE_TABLE_MVIEWS to public with grant option
/
rem
rem This view family replaced [DBA/ALL/USER]_REGISTERED_SNAPSHOTS for the  
rem 9i release. For changes to this family, check to see if the original
rem needs changing as well.
rem 
create or replace view DBA_REGISTERED_MVIEWS 
  (OWNER, NAME, MVIEW_SITE, CAN_USE_LOG, UPDATABLE, REFRESH_METHOD,
   MVIEW_ID, VERSION, QUERY_TXT)
as select sowner, snapname, snapsite,
   decode(bitand(flag,1), 0 , 'NO', 'YES'),
   decode(bitand(flag,2), 0 , 'NO', 'YES'),
   decode(bitand(flag, 32),               32, 'PRIMARY KEY',
          decode(bitand(flag, 536870912), 536870912, 'OBJECT ID', 'ROWID')),
   snapshot_id, 
   decode(rep_type, 1, 'ORACLE 7 MATERIALIZED VIEW',
                    2, 'ORACLE 8 MATERIALIZED VIEW',
                    3, 'REPAPI MATERIALIZED VIEW',
                       'UNKNOWN'),
   query_txt
from sys.reg_snap$
/
create or replace public synonym DBA_REGISTERED_MVIEWS
   for DBA_REGISTERED_MVIEWS 
/
grant select on DBA_REGISTERED_MVIEWS to select_catalog_role
/
comment on table DBA_REGISTERED_MVIEWS is
'Remote materialized views of local tables'
/
comment on column DBA_REGISTERED_MVIEWS.OWNER is
'Owner of the materialized view'
/
comment on column DBA_REGISTERED_MVIEWS.NAME is
'The name of the materialized view'
/
comment on column DBA_REGISTERED_MVIEWS.MVIEW_SITE is
'Global name of the materialized view site'
/
comment on column DBA_REGISTERED_MVIEWS.CAN_USE_LOG is
'If NO, this materialized view is complex and cannot fast refresh'
/
comment on column DBA_REGISTERED_MVIEWS.UPDATABLE is
'If NO, the materialized view is read only'
/
comment on column DBA_REGISTERED_MVIEWS.REFRESH_METHOD is
'Whether the materialized view uses rowid, primary key or object id for fast refresh'
/
comment on column DBA_REGISTERED_MVIEWS.MVIEW_ID is
'Identifier for the materialized view used by the master for fast refresh'
/
comment on column DBA_REGISTERED_MVIEWS.VERSION is
'Version of materialized view'
/
comment on column DBA_REGISTERED_MVIEWS.QUERY_TXT is
'Query defining the materialized view'
/


execute CDBView.create_cdbview(false,'SYS','DBA_REGISTERED_MVIEWS','CDB_REGISTERED_MVIEWS');
grant select on SYS.CDB_REGISTERED_MVIEWS to select_catalog_role
/
create or replace public synonym CDB_REGISTERED_MVIEWS for SYS.CDB_REGISTERED_MVIEWS
/

create or replace view ALL_REGISTERED_MVIEWS
as select  * from dba_registered_mviews s
where exists (select a.mview_id from all_base_table_mviews a
                             where  s.mview_id = a.mview_id)
or  userenv('SCHEMAID') = 1
or  ora_check_sys_privilege(userenv('SCHEMAID'), 2) = 1
/
comment on table ALL_REGISTERED_MVIEWS is
'Remote materialized views of local tables that the user can see'
/
comment on column ALL_REGISTERED_MVIEWS.OWNER is
'Owner of the materialized view'
/
comment on column ALL_REGISTERED_MVIEWS.NAME is
'The name of the materialized view'
/
comment on column ALL_REGISTERED_MVIEWS.MVIEW_SITE is
'Global name of the materialized view site'
/
comment on column ALL_REGISTERED_MVIEWS.CAN_USE_LOG is
'If NO, this materialized view is complex and cannot fast refresh'
/
comment on column ALL_REGISTERED_MVIEWS.UPDATABLE is
'If NO, the materialized view is read only'
/
comment on column ALL_REGISTERED_MVIEWS.REFRESH_METHOD is
'Whether the materialized view uses rowid or primary key or object id for fast refresh'
/
comment on column ALL_REGISTERED_MVIEWS.MVIEW_ID is
'Identifier for the materialized view used by the master for fast refresh'
/
comment on column ALL_REGISTERED_MVIEWS.VERSION is
'Version of materialized view'
/
comment on column ALL_REGISTERED_MVIEWS.QUERY_TXT is
'Query defining the materialized view'
/
create or replace public synonym ALL_REGISTERED_MVIEWS
   for ALL_REGISTERED_MVIEWS
/
grant read on ALL_REGISTERED_MVIEWS to public with grant option
/
create or replace view USER_REGISTERED_MVIEWS
as select * from dba_registered_mviews s
where exists (select u.mview_id from user_base_table_mviews u
                  where s.mview_id = u.mview_id)
/
comment on table USER_REGISTERED_MVIEWS is
'Remote materialized views of local tables currently using logs owned by the user'
/
comment on column USER_REGISTERED_MVIEWS.OWNER is
'Owner of the materialized view'
/
comment on column USER_REGISTERED_MVIEWS.NAME is
'The name of the materialized view'
/
comment on column USER_REGISTERED_MVIEWS.MVIEW_SITE is
'Global name of the materialized view site'
/
comment on column USER_REGISTERED_MVIEWS.CAN_USE_LOG is
'If NO, this materialized view is complex and cannot fast refresh'
/
comment on column USER_REGISTERED_MVIEWS.UPDATABLE is
'If NO, the materialized view is read only'
/
comment on column USER_REGISTERED_MVIEWS.REFRESH_METHOD is
'Whether the materialized view uses rowid or primary key or object id for fast refresh'
/
comment on column USER_REGISTERED_MVIEWS.MVIEW_ID is
'Identifier for the materialized view used by the master for fast refresh'
/
comment on column USER_REGISTERED_MVIEWS.VERSION is
'Version of materialized view'
/
comment on column USER_REGISTERED_MVIEWS.QUERY_TXT is
'Query defining the materialized view'
/
create or replace public synonym USER_REGISTERED_MVIEWS
   for USER_REGISTERED_MVIEWS
/
grant read on USER_REGISTERED_MVIEWS to public with grant option
/
/*
 * This view is currently used only by the replication manager and 
 * is not made public.  Use a synonym to maintain original name of 
 * [DBA/ALL/USER]_SNAPSHOT_LOG_FILTER_COLS for backward compatibility
 */
create or replace view DBA_MVIEW_LOG_FILTER_COLS
(OWNER, NAME, COLUMN_NAME)
as
select mowner, master, colname from sys.mlog_refcol$
/
comment on table DBA_MVIEW_LOG_FILTER_COLS is
'All filter columns (excluding PK cols) being logged in the materialized view logs'
/
comment on column DBA_MVIEW_LOG_FILTER_COLS.OWNER is
'Owner of the master table being logged'
/
comment on column DBA_MVIEW_LOG_FILTER_COLS.NAME is
'Name of the master table being logged'
/
comment on column DBA_MVIEW_LOG_FILTER_COLS.COLUMN_NAME is
'Filter column being logged'
/
create or replace public synonym DBA_SNAPSHOT_LOG_FILTER_COLS
   for DBA_MVIEW_LOG_FILTER_COLS
/
create or replace public synonym DBA_MVIEW_LOG_FILTER_COLS
   for DBA_MVIEW_LOG_FILTER_COLS
/
grant select on DBA_MVIEW_LOG_FILTER_COLS to select_catalog_role
/


execute CDBView.create_cdbview(false,'SYS','DBA_MVIEW_LOG_FILTER_COLS','CDB_MVIEW_LOG_FILTER_COLS');
grant select on SYS.CDB_MVIEW_LOG_FILTER_COLS to select_catalog_role
/
create or replace public synonym CDB_MVIEW_LOG_FILTER_COLS for SYS.CDB_MVIEW_LOG_FILTER_COLS
/

create or replace view MV_REFRESH_USAGE_STATS 
  (MV_TYPE#, REFRESH_METHOD#, REFRESH_MODE#, OUT_OF_PLACE#, ATOMIC#, COUNT#)
as select mv_type#, refresh_method#, refresh_mode#, out_of_place#, atomic#,
          sum(count#)
from sys.mv_refresh_usage_stats$
group by mv_type#, refresh_method#, refresh_mode#, out_of_place#, atomic#
/
comment on table MV_REFRESH_USAGE_STATS is
'MV refresh usage statistics'
/
comment on column MV_REFRESH_USAGE_STATS.MV_TYPE# is
'MV type, can be MAV, MJV, MAV1 or OTHER'
/
comment on column MV_REFRESH_USAGE_STATS.REFRESH_METHOD# is
'MV refresh method, can be fast, PCT, complete or sync refresh'
/
comment on column MV_REFRESH_USAGE_STATS.REFRESH_MODE# is
'MV refresh mode, can be on commit or on demand'
/
comment on column MV_REFRESH_USAGE_STATS.OUT_OF_PLACE# is
'whether it is out-of-place refresh'
/
comment on column MV_REFRESH_USAGE_STATS.ATOMIC# is
'whether it is atomic refresh'
/
comment on column MV_REFRESH_USAGE_STATS.COUNT# is
'count of a certain refresh case'
/

grant select on MV_REFRESH_USAGE_STATS to select_catalog_role
/

-------------------------------------------------------------------------------
-- Zonemap Views.
-------------------------------------------------------------------------------
--
-- DBA_ZONEMAPS
--
create or replace view DBA_ZONEMAPS
( OWNER,                    /* Zonemap owner name                           */
  ZONEMAP_NAME,             /* Zonemap name                                 */
  FACT_OWNER,               /* Fact table owner name                        */
  FACT_TABLE,               /* Fact table name                              */
  SCALE,                    /* Zonemap scale factor                         */
  HIERARCHICAL,             /* Zonemap is ierarchical or not                */
  WITH_CLUSTERING,          /* Is zonemap created with CLUSTERING clause    */
  QUERY,                    /* Zonemap defining query                       */
  QUERY_LEN,                /* Zonemap defining query length (in bytes)     */
  PRUNING,                  /* Zonemap enabled for pruning or not           */
  REFRESH_MODE,             /* Refresh on: COMMIT/DEMAND/LOAD/DATAMOVEMENT  */
  REFRESH_METHOD,           /* Refresh method: COMPLETE/FORCE/FAST          */
  LAST_REFRESH_METHOD,      /* Refresh method used last time                */
  LAST_REFRESH_TIME,        /* Time last refresh occurred                   */
  INVALID,                  /* Zonemap invalid (due to some DDL) or not     */
  STALE,                    /* Zonemap fully stale or not                   */
  UNUSABLE,                 /* Zonemap marked unusable (by user) or not     */
  COMPILE_STATE             /* Zonemap compile state                        */
)
as
select u.name as OWNER,
       o.name as ZONEMAP_NAME,
       s.mowner as FACT_OWNER,
       s.master as FACT_TABLE,
       w.zmapscale as SCALE,
       decode(bitand(s.flag3, 1024),
              0, 'NO', 'YES         ') as HIERARCHICAL,
       decode(bitand(w.xpflags, 549755813888),
              0, 'NO', 'YES            ') as WITH_CLUSTERING,
       s.query_txt as QUERY,
       s.query_len as QUERY_LEN,        
       decode(w.mflags,
              '', '',                                     /* missing summary */
              decode(bitand(w.mflags, 4),
                     4, 'DISABLED', 'ENABLED')) as PRUNING,
       decode(bitand(s.flag, 32768),
              32768, 'COMMIT',
              decode(bitand(s.flag3, 2048),
                     2048, decode(bitand(s.flag3, 4096),
                                  4096, 'LOAD DATAMOVEMENT', 'LOAD'),
                     decode(bitand(s.flag3, 4096),
                            4096, 'DATAMOVEMENT', 'DEMAND'))) as REFRESH_MODE,
       decode(s.auto_fast,
              'C',  'COMPLETE',
              'F',  'FAST',
              '?',  'FORCE',
              NULL, 'FORCE', 'ERROR-UNKNOWN ') as REFRESH_METHOD,
/***********
       decode(bitand(s.flag3, 16384),
              16384, 'OFF',
              decode(bitand(s.flag3, 8192),
                     8192, 'ON', 'ERROR-UNKNOWN     ')) as BACKGROUND_REFRESH,
***********/
       decode(w.mflags,
              '', '',                                     /* missing summary */
              decode(bitand(w.mflags,16384+32768),
                     0, 'NA', 
                     16384, 'COMPLETE', 
                     32768, 'FAST',
                     'ERROR-UNKNOWN      ')) as LAST_REFRESH_METHOD,
       decode(w.lastrefreshdate,
              NULL, to_timestamp(NULL),                   /* missing summary */
              decode(to_char(w.lastrefreshdate,'DD-MM-YYYY'),
                     '01-01-1950', to_timestamp(NULL),
                     to_timestamp(to_char(w.lastrefreshdate,
                                          'DD-MON-YYYY HH:MI:SS')))
             ) as LAST_REFRESH_TIME,
       decode(bitand(s.status, 4),                       /* snapshot-invalid */
              4, 'YES',
              decode(w.mflags,
                     '', '',                              /* missing summary */
                     decode(bitand(w.mflags, 64),
                            0, 'NO', 'YES    '))) as INVALID,
       decode(o.status, 1,                                   /* valid object */
          decode(w.mflags, '', '',                        /* missing summary */
             decode(bitand(w.mflags, 17179869184), 0,        /* not unusable */
                decode(bitand(w.mflags, 64), 0,               /* not invalid */
                   decode(bitand(w.mflags, 16+32), 0,           /* not fresh */
                          'YES', 'NO'),
                       'UNKNOWN'),          /* invalid (DDL, BUILD DEFERRED) */
                    'UNKNOWN')),                     /* user marked unusable */
              'UNKNOWN') as STALE,                         /* invalid object */
       decode(w.mflags,
              '', '',                                     /* missing summary */
              decode(bitand(w.mflags, 17179869184),
                     0, 'NO', 'YES     ')) as UNUSABLE,
       decode(o.status,
              1, 'VALID', 
              2, 'AUTHORIZATION_ERROR',
              3, 'COMPILATION_ERROR',
              5, 'NEEDS_COMPILE', 'ERROR-UNKNOWN') as COMPILE_STATE
from sys.user$ u, sys.sum$ w, sys.obj$ o, sys.snap$ s
where w.containernam(+) = s.vname
  and o.obj#(+) = w.obj#
  and o.owner# = u.user#(+)
  and ((u.name = s.sowner) or (u.name IS NULL))
  and s.instsite = 0
  and bitand(s.flag3, 512) = 512                       /* snapshot = zonemap */
  and bitand(w.xpflags, 34359738368) = 34359738368      /* summary = zonemap */
/
comment on table DBA_ZONEMAPS is 'All zonemaps in the database'
/
comment on column DBA_ZONEMAPS.OWNER is 'Zonemap owner name'
/
comment on column DBA_ZONEMAPS.ZONEMAP_NAME is 'Zonemap name'
/
comment on column DBA_ZONEMAPS.FACT_OWNER is 'Fact table owner name'
/
comment on column DBA_ZONEMAPS.FACT_TABLE is 'Fact table name'
/
comment on column DBA_ZONEMAPS.SCALE is 'Zonemap scale factor'
/
comment on column DBA_ZONEMAPS.HIERARCHICAL is 'Zonemap is hierarchical or not'
/
comment on column DBA_ZONEMAPS.WITH_CLUSTERING is 'Is zonemap created with clustering clause'
/
comment on column DBA_ZONEMAPS.QUERY is 'Zonemap defining query'
/
comment on column DBA_ZONEMAPS.QUERY_LEN is 'Zonemap defining query length'
/
comment on column DBA_ZONEMAPS.PRUNING is 'Zonemap enabled for pruning or not'
/
comment on column DBA_ZONEMAPS.REFRESH_MODE is 'Refresh on: commit/demand/load/datamovement'
/
comment on column DBA_ZONEMAPS.REFRESH_METHOD is 'Refresh method: force/complete/fast'
/
comment on column DBA_ZONEMAPS.LAST_REFRESH_METHOD is 'Refresh method used last time'
/
comment on column DBA_ZONEMAPS.LAST_REFRESH_TIME is 'Time last refresh occurred'
/
comment on column DBA_ZONEMAPS.INVALID is 'Zonemap invalid (due to some DDL) or not'
/
comment on column DBA_ZONEMAPS.STALE is 'Zonemap fully stale or not'
/
comment on column DBA_ZONEMAPS.UNUSABLE is 'Zonemap marked unusable (by user) or not'
/
comment on column DBA_ZONEMAPS.COMPILE_STATE is 'Zonemap compile state'
/
create or replace public synonym DBA_ZONEMAPS for DBA_ZONEMAPS
/
grant select on DBA_ZONEMAPS to select_catalog_role
/

execute CDBView.create_cdbview(false,'SYS','DBA_ZONEMAPS','CDB_ZONEMAPS');
grant select on SYS.CDB_ZONEMAPS to select_catalog_role
/
create or replace public synonym CDB_ZONEMAPS for SYS.CDB_ZONEMAPS
/

--
-- ALL_ZONEMAPS
--
create or replace view ALL_ZONEMAPS
as select z.* from dba_zonemaps z, sys.obj$ o, sys.user$ u
where o.owner#        = u.user#
  and z.zonemap_name  = o.name
  and u.name          = z.owner
  and o.type#         = 2                            /* table */
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
comment on table ALL_ZONEMAPS is 'Zonemaps accessible to the user'
/
comment on column ALL_ZONEMAPS.OWNER is 'Zonemap owner name'
/
comment on column ALL_ZONEMAPS.ZONEMAP_NAME is 'Zonemap name'
/
comment on column ALL_ZONEMAPS.FACT_OWNER is 'Fact table owner name'
/
comment on column ALL_ZONEMAPS.FACT_TABLE is 'Fact table name'
/
comment on column ALL_ZONEMAPS.SCALE is 'Zonemap scale factor'
/
comment on column ALL_ZONEMAPS.HIERARCHICAL is 'Zonemap is hierarchical or not'
/
comment on column ALL_ZONEMAPS.WITH_CLUSTERING is 'Is zonemap created with clustering clause'
/
comment on column ALL_ZONEMAPS.QUERY is 'Zonemap defining query'
/
comment on column ALL_ZONEMAPS.QUERY_LEN is 'Zonemap defining query length'
/
comment on column ALL_ZONEMAPS.PRUNING is 'Zonemap enabled for pruning or not'
/
comment on column ALL_ZONEMAPS.REFRESH_MODE is 'Refresh on: commit/demand/load/datamovement'
/
comment on column ALL_ZONEMAPS.REFRESH_METHOD is 'Refresh method: force/complete/fast'
/
comment on column ALL_ZONEMAPS.LAST_REFRESH_METHOD is 'Refresh method used last time'
/
comment on column ALL_ZONEMAPS.LAST_REFRESH_TIME is 'Time last refresh occurred'
/
comment on column ALL_ZONEMAPS.INVALID is 'Zonemap invalid (due to some DDL) or not'
/
comment on column ALL_ZONEMAPS.STALE is 'Zonemap fully stale or not'
/
comment on column ALL_ZONEMAPS.UNUSABLE is 'Zonemap marked unusable (by user) or not'
/
comment on column ALL_ZONEMAPS.COMPILE_STATE is 'Zonemap compile state'
/
create or replace public synonym ALL_ZONEMAPS for ALL_ZONEMAPS
/
grant read on ALL_ZONEMAPS to public with grant option
/
--
-- USER_ZONEMAPS
--
create or replace view USER_ZONEMAPS
as select z.* from dba_zonemaps z, sys.user$ u
where u.user# = userenv('SCHEMAID')
  and z.owner = u.name
/
comment on table USER_ZONEMAPS is 'Zonemaps owned by the user'
/
comment on column USER_ZONEMAPS.OWNER is 'Zonemap owner name'
/
comment on column USER_ZONEMAPS.ZONEMAP_NAME is 'Zonemap name'
/
comment on column USER_ZONEMAPS.FACT_OWNER is 'Fact table owner name'
/
comment on column USER_ZONEMAPS.FACT_TABLE is 'Fact table name'
/
comment on column USER_ZONEMAPS.SCALE is 'Zonemap scale factor'
/
comment on column USER_ZONEMAPS.HIERARCHICAL is 'Zonemap is hierarchical or not'
/
comment on column USER_ZONEMAPS.WITH_CLUSTERING is 'Is zonemap created with clustering clause'
/
comment on column USER_ZONEMAPS.QUERY is 'Zonemap defining query'
/
comment on column USER_ZONEMAPS.QUERY_LEN is 'Zonemap defining query length'
/
comment on column USER_ZONEMAPS.PRUNING is 'Zonemap enabled for pruning or not'
/
comment on column USER_ZONEMAPS.REFRESH_MODE is 'Refresh on: commit/demand/load/datamovement'
/
comment on column USER_ZONEMAPS.REFRESH_METHOD is 'Refresh method: force/complete/fast'
/
comment on column USER_ZONEMAPS.LAST_REFRESH_METHOD is 'Refresh method used last time'
/
comment on column USER_ZONEMAPS.LAST_REFRESH_TIME is 'Time last refresh occurred'
/
comment on column USER_ZONEMAPS.INVALID is 'Zonemap invalid (due to some DDL) or not'
/
comment on column USER_ZONEMAPS.STALE is 'Zonemap fully stale or not'
/
comment on column USER_ZONEMAPS.UNUSABLE is 'Zonemap marked unusable (by user) or not'
/
comment on column USER_ZONEMAPS.COMPILE_STATE is 'Zonemap compile state'
/
create or replace public synonym USER_ZONEMAPS for USER_ZONEMAPS
/
grant read on USER_ZONEMAPS to public with grant option
/

-------------------------------------------------------------------------------
-- Zonemap Measures Views.
-------------------------------------------------------------------------------
--
-- DBA_ZONEMAP_MEASURES
--
create or replace view DBA_ZONEMAP_MEASURES
( OWNER,                    /* Zonemap owner name                           */
  ZONEMAP_NAME,             /* Zonemap name                                 */
  MEASURE,                  /* Column whose MIN/MAX materialized            */
  POSITION_IN_SELECT,       /* Ordinal position of measure aggregate        */
  AGG_FUNCTION,             /* Type of aggregate function: MIN/MAX          */
  AGG_COLUMN_NAME           /* Aggregate column name in zonemap table       */
)
as
select s.sowner, s.vname, a.aggtext, a.sumcolpos#,
       decode(a.aggfunction, 18, 'MIN', 19, 'MAX',
              17, 'COUNT', 16, 'SUM', 'ERROR-UNKNOWN'),
       c.name
from sys.user$ u, sys.sum$ w, sys.obj$ o, sys.snap$ s, sys.sumagg$ a, sys.col$ c
where w.containernam(+) = s.vname
  and o.obj#(+) = w.obj#
  and o.owner# = u.user#(+)
  and ((u.name = s.sowner) or (u.name IS NULL))
  and a.sumobj# = w.obj#
  and a.containercol# = c.col#
  and w.containerobj# = c.obj#
  and s.instsite = 0
  and bitand(s.flag3, 512) = 512                       /* snapshot = zonemap */
  and bitand(w.xpflags, 34359738368) = 34359738368      /* summary = zonemap */
  and a.aggfunction != 17                                 /* exclude COUNT() */
  and a.aggfunction != 16                                   /* exclude SUM() */
/
comment on table DBA_ZONEMAP_MEASURES is 'All zonemap measures in the database'
/
comment on column DBA_ZONEMAP_MEASURES.OWNER is 'Zonemap owner name'
/
comment on column DBA_ZONEMAP_MEASURES.ZONEMAP_NAME is 'Zonemap name'
/
comment on column DBA_ZONEMAP_MEASURES.MEASURE is 'Column whose MIN/MAX materialized'
/
comment on column DBA_ZONEMAP_MEASURES.POSITION_IN_SELECT is 'Ordinal position of measure aggregate'
/
comment on column DBA_ZONEMAP_MEASURES.AGG_FUNCTION is 'Type of aggregate function: MIN/MAX'
/
comment on column DBA_ZONEMAP_MEASURES.AGG_COLUMN_NAME is 'Aggregate column name in zonemap table'
/
create or replace public synonym DBA_ZONEMAP_MEASURES for DBA_ZONEMAP_MEASURES
/
grant select on DBA_ZONEMAP_MEASURES to select_catalog_role
/

execute CDBView.create_cdbview(false,'SYS','DBA_ZONEMAP_MEASURES','CDB_ZONEMAP_MEASURES');
grant select on SYS.CDB_ZONEMAP_MEASURES to select_catalog_role
/
create or replace public synonym CDB_ZONEMAP_MEASURES for SYS.CDB_ZONEMAP_MEASURES
/

--
-- ALL_ZONEMAP_MEASURES
--
create or replace view ALL_ZONEMAP_MEASURES
as select z.* from dba_zonemap_measures z, sys.obj$ o, sys.user$ u
where o.owner#        = u.user#
  and z.zonemap_name  = o.name
  and u.name          = z.owner
  and o.type#         = 2                                    /* table */
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
comment on table ALL_ZONEMAP_MEASURES is 'Zonemap measures accessible to the user'
/
comment on column ALL_ZONEMAP_MEASURES.OWNER is 'Zonemap owner name'
/
comment on column ALL_ZONEMAP_MEASURES.ZONEMAP_NAME is 'Zonemap name'
/
comment on column ALL_ZONEMAP_MEASURES.MEASURE is 'Column whose MIN/MAX materialized'
/
comment on column ALL_ZONEMAP_MEASURES.POSITION_IN_SELECT is 'Ordinal position of measure aggregate'
/
comment on column ALL_ZONEMAP_MEASURES.AGG_FUNCTION is 'Type of aggregate function: MIN/MAX'
/
comment on column ALL_ZONEMAP_MEASURES.AGG_COLUMN_NAME is 'Aggregate column name in zonemap table'
/
create or replace public synonym ALL_ZONEMAP_MEASURES for ALL_ZONEMAP_MEASURES
/
grant read on ALL_ZONEMAP_MEASURES to public with grant option
/
--
-- USER_ZONEMAP_MEASURES
--
create or replace view USER_ZONEMAP_MEASURES
as select z.* from dba_zonemap_measures z, sys.user$ u
where u.user# = userenv('SCHEMAID')
  and z.owner = u.name
/
comment on table USER_ZONEMAP_MEASURES is 'Zonemap measures owned by the user'
/
comment on column USER_ZONEMAP_MEASURES.OWNER is 'Zonemap owner name'
/
comment on column USER_ZONEMAP_MEASURES.ZONEMAP_NAME is 'Zonemap name'
/
comment on column USER_ZONEMAP_MEASURES.MEASURE is 'Column whose MIN/MAX materialized'
/
comment on column USER_ZONEMAP_MEASURES.POSITION_IN_SELECT is 'Ordinal position of measure aggregate'
/
comment on column USER_ZONEMAP_MEASURES.AGG_FUNCTION is 'Type of aggregate function: MIN/MAX'
/
comment on column USER_ZONEMAP_MEASURES.AGG_COLUMN_NAME is 'Aggregate column name in zonemap table'
/
create or replace public synonym USER_ZONEMAP_MEASURES for USER_ZONEMAP_MEASURES
/
grant read on USER_ZONEMAP_MEASURES to public with grant option
/



/* This view is an online redefinition view and contains the objects
 * invoved in the current redefinition(s)
 */
create or replace view DBA_REDEFINITION_OBJECTS
(OBJECT_TYPE, OBJECT_OWNER, OBJECT_NAME, BASE_TABLE_OWNER, BASE_TABLE_NAME,
 INTERIM_OBJECT_OWNER, INTERIM_OBJECT_NAME, EDITION_NAME)
as
select decode(obj_type, 1, 'TABLE',
                        2, 'INDEX',
                        3, 'CONSTRAINT',
                        4, 'TRIGGER',
                        6, 'NESTED TABLE',
                        7, 'PARTITION',
                        10, 'MV LOG',
                        'UNKNOWN'),
       decode(ou.type#, 2, ou.ext_username, ou.name), obj_name, 
       bt_owner, bt_name, 
       decode(iu.type#, 2, iu.ext_username, iu.name), int_obj_name, 
       decode(ou.type#, 2, 
              (select name from sys.obj$ o where ou.spare2 = o.obj#),
              decode(obj_type, 4, 'ORA$BASE', NULL))  
from sys.redef_object$ ro, sys.user$ ou, sys.user$ iu
where ro.obj_owner = ou.name
and ro.int_obj_owner = iu.name
/
comment on column DBA_REDEFINITION_OBJECTS.OBJECT_TYPE is
'Type of the redefinition object'
/
comment on column DBA_REDEFINITION_OBJECTS.OBJECT_OWNER is
'Owner of the redefinition object'
/
comment on column DBA_REDEFINITION_OBJECTS.OBJECT_NAME is
'Name of the redefinition object'
/
comment on column DBA_REDEFINITION_OBJECTS.BASE_TABLE_OWNER is
'Owner of the base table of the redefinition object'
/
comment on column DBA_REDEFINITION_OBJECTS.BASE_TABLE_NAME is
'Name of the base table of the redefinition object'
/
comment on column DBA_REDEFINITION_OBJECTS.INTERIM_OBJECT_OWNER is
'Owner of the corresponding interim redefinition object'
/
comment on column DBA_REDEFINITION_OBJECTS.INTERIM_OBJECT_NAME is
'Name of the corresponding interim redefinition object'
/
comment on column DBA_REDEFINITION_OBJECTS.EDITION_NAME is
'Name of the edition that the redefinition object belongs to'
/
create or replace public synonym DBA_REDEFINITION_OBJECTS
   for DBA_REDEFINITION_OBJECTS
/
grant select on DBA_REDEFINITION_OBJECTS to select_catalog_role
/



execute CDBView.create_cdbview(false,'SYS','DBA_REDEFINITION_OBJECTS','CDB_REDEFINITION_OBJECTS');
grant select on SYS.CDB_REDEFINITION_OBJECTS to select_catalog_role
/
create or replace public synonym CDB_REDEFINITION_OBJECTS for SYS.CDB_REDEFINITION_OBJECTS
/

/* This view is an online redefinition view and contains the dependent objects
 * for which errors were raised while attempting to create similar objects 
 * onto the interim table of the redefinition
 */
create or replace view DBA_REDEFINITION_ERRORS
(OBJECT_TYPE, OBJECT_OWNER, OBJECT_NAME,
 BASE_TABLE_OWNER, BASE_TABLE_NAME, DDL_TXT, EDITION_NAME,
 ERR_NO, ERR_TXT)
as
select decode(obj_type, 1, 'TABLE',
                        2, 'INDEX',
                        3, 'CONSTRAINT',
                        4, 'TRIGGER',
                        6, 'NESTED TABLE',
                        7, 'PARTITION',
                        10, 'MV LOG',
                        'UNKNOWN'),
       decode(ou.type#, 2, ou.ext_username, ou.name), obj_name, 
       bt_owner, bt_name, ddl_txt, 
       decode(ou.type#, 2, 
              (select name from sys.obj$ o where ou.spare2 = o.obj#),
              decode(obj_type, 4, 'ORA$BASE', NULL)),
       e.err_no, e.err_txt
from sys.redef_dep_error$ e, sys.user$ ou
where e.obj_owner = ou.name
/
comment on column DBA_REDEFINITION_ERRORS.OBJECT_TYPE is
'Type of the redefinition object'
/
comment on column DBA_REDEFINITION_ERRORS.OBJECT_OWNER is
'Owner of the redefinition object'
/
comment on column DBA_REDEFINITION_ERRORS.OBJECT_NAME is
'Name of the redefinition object'
/
comment on column DBA_REDEFINITION_ERRORS.BASE_TABLE_OWNER is
'Owner of the base table of the redefinition object'
/
comment on column DBA_REDEFINITION_ERRORS.BASE_TABLE_NAME is
'Name of the base table of the redefinition object'
/
comment on column DBA_REDEFINITION_ERRORS.DDL_TXT is
'DDL used to create the corresponding interim dependent object'
/
comment on column DBA_REDEFINITION_ERRORS.EDITION_NAME is
'Name of the edition that the redefinition object belongs to'
/
comment on column DBA_REDEFINITION_ERRORS.ERR_NO is
'Oracle Error Number corresponding to this error'
/
comment on column DBA_REDEFINITION_ERRORS.ERR_TXT is
'Oracle Error Text corresponding to this error'
/
create or replace public synonym DBA_REDEFINITION_ERRORS
   for DBA_REDEFINITION_ERRORS
/
grant select on DBA_REDEFINITION_ERRORS to select_catalog_role
/


execute CDBView.create_cdbview(false,'SYS','DBA_REDEFINITION_ERRORS','CDB_REDEFINITION_ERRORS');
grant select on SYS.CDB_REDEFINITION_ERRORS to select_catalog_role
/
create or replace public synonym CDB_REDEFINITION_ERRORS for SYS.CDB_REDEFINITION_ERRORS
/

/* This view is an online redefinition view and contains the status of
 * the last redefinition operation for all partitions involved with
 * a redefinition
 */
create or replace view DBA_REDEFINITION_STATUS
(REDEFINITION_ID, BASE_TABLE_OWNER, BASE_TABLE_NAME, BASE_OBJECT_NAME, 
BASE_OBJECT_TYPE, INTERIM_OBJECT_OWNER, INTERIM_OBJECT_NAME,
OPERATION, STATUS, RESTARTABLE, ERR_TXT, ACTION, REFRESH_DEP_MVIEWS)
as
select rs.redef_id, ro.bt_owner, ro.bt_name,  rs.obj_name, 
       decode(ro.obj_type, 1, 'TABLE',
                           7, 'PARTITION',
                           'UNKNOWN'),
       ro.int_obj_owner, ro.int_obj_name,
       rs.prev_operation, rs.status, rs.restartable, rs.err_txt, rs.action,
       decode(bitand(r.flag,65536),65536,'Y','N') 
from ((sys.redef_status$ rs LEFT OUTER JOIN sys.redef_object$ ro
       ON rs.redef_id = ro.redef_id AND rs.obj_name = ro.obj_name)
      JOIN sys.redef$ r ON r.id = ro.redef_id)
/
comment on column DBA_REDEFINITION_STATUS.REDEFINITION_ID is
'Redefinition ID for this object'
/
comment on column DBA_REDEFINITION_STATUS.BASE_TABLE_OWNER is
'Owner of the base table of the redefinition object'
/
comment on column DBA_REDEFINITION_STATUS.BASE_TABLE_NAME is
'Name of the base table of the redefinition object'
/
comment on column DBA_REDEFINITION_STATUS.BASE_OBJECT_NAME is
'Name of the base object of the redefinition object'
/
comment on column DBA_REDEFINITION_STATUS.BASE_OBJECT_TYPE is
'TYPE of the base object of the redefinition object'
/
comment on column DBA_REDEFINITION_STATUS.INTERIM_OBJECT_OWNER is
'Owner of the interim object of the redefinition object'
/
comment on column DBA_REDEFINITION_STATUS.INTERIM_OBJECT_NAME is
'Name of the interim object of the redefinition object'
/
comment on column DBA_REDEFINITION_STATUS.STATUS is
'Status of the previous operation'
/
comment on column DBA_REDEFINITION_STATUS.OPERATION is
'The current operation'
/
comment on column DBA_REDEFINITION_STATUS.RESTARTABLE is
'The restartability of the previous operation'
/
comment on column DBA_REDEFINITION_STATUS.ERR_TXT is
'The error message raised from the previous operation'
/
comment on column DBA_REDEFINITION_STATUS.ACTION is
'The suggested action'
/
comment on column DBA_REDEFINITION_STATUS.REFRESH_DEP_MVIEWS is
'Refresh dependent materialized views?'
/
create or replace public synonym DBA_REDEFINITION_STATUS
   for DBA_REDEFINITION_STATUS
/
grant select on DBA_REDEFINITION_STATUS to select_catalog_role
/

execute CDBView.create_cdbview(false,'SYS','DBA_REDEFINITION_STATUS','CDB_REDEFINITION_STATUS');
grant select on SYS.CDB_REDEFINITION_STATUS to select_catalog_role
/
create or replace public synonym CDB_REDEFINITION_STATUS for SYS.CDB_REDEFINITION_STATUS
/

-----------------------------------------------------------------------
  
-- Note that the following VARRAY type definitions are intentionally defined
-- outside dbms_snapshot and created within the SYS schema. Due to a bug in 
-- JDBC (#1589780, #1518757), type definitions within a package are currently 
-- not visible to JDBC drivers.   ---- mthiyaga  01/19/01.
--
-- Create RewriteMsg type
-- The fields defined here are identical to the REWRITE_TABLE, which is an
-- alternate output medium for EXPLAIN REWRITE
--

CREATE OR REPLACE TYPE SYS.RewriteMessage FORCE AS OBJECT(
                mv_owner        VARCHAR2(128),
                mv_name         VARCHAR2(128),
                sequence        NUMBER(3),      /* sequence no of the msg */
                query_text      VARCHAR2(2000),
                query_block_no  NUMBER(3),      /* block no of the current subquery */
                rewritten_text  VARCHAR2(2000),             /* rewritten query text */
                message         VARCHAR2(512),
                pass            VARCHAR2(3),    /* indicate the no of rewrite passes */
                mv_in_msg       VARCHAR2(128),               /* MV in current message */
                measure_in_msg  VARCHAR2(128),          /* Measure in current message */
                join_back_tbl   VARCHAR2(128),      /* Join back table in current msg */ 
                join_back_col   VARCHAR2(128),     /* Join back column in current msg */ 
                original_cost   NUMBER(10),                   /* original query cost */ 
                rewritten_cost  NUMBER(10),                  /* rewritten query cost */ 
                flags           NUMBER,
                reserved1       NUMBER,
                reserved2       VARCHAR2(10)
)
/

GRANT EXECUTE ON SYS.RewriteMessage TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM RewriteMessage FOR SYS.RewriteMessage;
--
-- Create a VARRAY of type RewriteMessage
-- We don't expect the number of error messages to be more than a few.
-- But we allocate an array of size 256 elements, just in case.
--
--
--

CREATE OR REPLACE TYPE SYS.RewriteArrayType AS VARRAY(256) OF RewriteMessage
/
GRANT EXECUTE ON SYS.RewriteArrayType TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM RewriteArrayType FOR SYS.RewriteArrayType;

--
--
-- Create ExplainMVMessage type
-- The fields defined here are identical to the MV_CAPABILITIES_TABLE, which 
-- is an alternate output medium for EXPLAIN_MVIEW.
--

CREATE OR REPLACE TYPE SYS.ExplainMVMessage FORCE AS OBJECT (
   MVOWNER              VARCHAR(128),  -- NULL for SELECT based EXPLAIN_MVIEW
   MVNAME               VARCHAR(128),  -- NULL for SELECT based EXPLAIN_MVIEW
   CAPABILITY_NAME      VARCHAR(30),  -- A descriptive name of the particular
                                      -- capability:
                                      -- REWRITE
                                      --   Can do at least full text match
                                      --   rewrite
                                      -- REWRITE_PARTIAL_TEXT_MATCH
                                      --   Can do at leat full and partial
                                      --   text match rewrite
                                      -- REWRITE_GENERAL
                                      --   Can do all forms of rewrite
                                      -- REFRESH
                                      --   Can do at least complete refresh
                                      -- REFRESH_FROM_LOG_AFTER_INSERT
                                      --   Can do fast refresh from an mv log
                                      --   or change capture table at least
                                      --   when update operations are
                                      --   restricted to INSERT
                                      -- REFRESH_FROM_LOG_AFTER_ANY
                                      --   can do fast refresh from an mv log
                                      --   or change capture table after any
                                      --   combination of updates
                                      -- EUT
                                      --   Can do Enhanced Update Tracking on
                                      --   the table named in the RELATED_NAME
                                      --   column.  EUT is needed for fast
                                      --   refresh after partitioned
                                      --   maintenance operations on the table
                                      --   named in the RELATED_NAME column
                                      --   and to do non-stale tolerated
                                      --   rewrite when the mv is partially
                                      --   stale with respect to the table
                                      --   named in the RELATED_NAME column.
                                      --   EUT can also sometimes enable fast
                                      --   refresh of updates to the table
                                      --   named in the RELATED_NAME column
                                      --   when fast refresh from an mv log
                                      --   or change capture table is not
                                      --   possilbe.
   POSSIBLE             VARCHAR(1),   -- T = capability enabled
                                      -- F = capability disabled
   RELATED_TEXT         VARCHAR(2000),-- Owner.table.column, alias name, etc.
                                      -- related to this message.  The
                                      -- specific meaning of this column
                                      -- depends on the MSGNO column.  See
                                      -- the documentation for
                                      -- DBMS_MVIEW.EXPLAIN_MVIEW() for details
   RELATED_NUM          NUMBER,       -- When there is a numeric value
                                      -- associated with a row, it goes here.
                                      -- The specific meaning of this column
                                      -- depends on the MSGNO column.  See
                                      -- the documentation for
                                      -- DBMS_MVIEW.EXPLAIN_MVIEW() for details
   MSGNO                NUMBER,      -- When available, QSM message #
                                      -- explaining why disabled or more
                                      -- details when enabled.
   MSGTXT               VARCHAR(2000),-- Text associated with MSGNO.
   SEQ                  NUMBER)      -- Useful in ORDER BY clause when
                                      -- selecting from this table.
/
GRANT EXECUTE ON SYS.ExplainMVMessage TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM ExplainMVMessage FOR SYS.ExplainMVMessage;

--
-- Create a VARRAY of type ExplainMVMessage
-- We don't expect the number of error messages to be more than a few.
-- But we allocate an array of size 50 elements, just in case.
--
-- 11g: Array size changed to 100 elements.
-- bug5872368: Array size changed to 200 elements.

CREATE OR REPLACE TYPE SYS.ExplainMVArrayType AS VARRAY(200) OF SYS.ExplainMVMessage
/
GRANT EXECUTE ON SYS.ExplainMVArrayType TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM ExplainMVArrayType FOR SYS.ExplainMVArrayType;


-- 
-- Sync Refresh Types  -  used in the DBMS_SYNC_REFRESH pacakage
--
-- There are two types:

-- CanSyncRefMessage   -  an object-type describing the results of 
--                        Sync Refresh eligibilty analysis
-- 
-- CanSyncRefArrayType  - a varray of CanSyncRefMessage
--
-- This type is used by the following DBMS_SYNC_REFRESH.CAN_SYNCREF_TABLE 
-- API:
--
--  PROCEDURE can_syncref_table(schema_name   IN VARCHAR2, 
--                              table_name    IN VARCHAR2, 
--                              output_array   IN OUT Sys.CanSyncRefArrayType)
--
-- 
-- The can_syncref_table() procedure advises the user on whether the
-- table and its its dependent MV's are eligible for Sync Refresh. 
-- It provides an explanation of its analysis. If not eligible, 
-- the user can examine the reasons and take appropriate action if possible.
--      
-- The fields of CanSyncRefMessage have the following significance:
--
--
-- schema_name    -  The name of the schema of the table being analyzed.
--
-- table_name     -  The name of the  table being analyzed.
--
-- mv_schema_name -  The name of the schema of an MV dependent on the 
--                   the table being analyzed.
--
-- mv_name        -  The name of the MV dependent on the the table being 
--                   analyzed. 
--
-- eligible       -  This field can have two values - 'Y' means the MV
--                   is eligible for Sync Refresh based on the check or
--                   information supplied in the message field; 'N' indicate
--                   otherwise. In order to for the MV to be eligible the 
--                   MV must pass all the criteria.
-- 
-- seq_num        -  This field is just a sequence number starting with 1
--                   for each MV. It can be used to order the rows within 
--                   each MV to undertstand the eligibility analysis.
--
-- msg_number     -  The message-number of the message. The messages
--                   belong to the QSM facility and are defined in qsmus.msg
--
-- message        -  The message describing the eligibilty check or  
--                   information pertaining to the eligibility of the 
--                   MV for Sync Refresh.     
-- 


CREATE OR REPLACE TYPE CanSyncRefMessage FORCE IS OBJECT (
          schema_name        VARCHAR2(128),
          table_name         VARCHAR2(128), 
          mv_schema_name     VARCHAR2(128),
          mv_name            VARCHAR2(128),
          eligible           VARCHAR2(1),
          seq_num            NUMBER,
          msg_number         NUMBER,
          message            VARCHAR2(4000));
/

CREATE OR REPLACE TYPE  CanSyncRefArrayType AS VARRAY(256) OF 
Sys.CanSyncRefMessage;
/
GRANT EXECUTE ON SYS.CanSyncRefMessage TO PUBLIC;

CREATE OR REPLACE PUBLIC SYNONYM CanSyncRefMessage FOR SYS.CanSyncRefMessage;
/

GRANT EXECUTE ON SYS.CanSyncRefArrayType TO PUBLIC;
/

CREATE OR REPLACE PUBLIC SYNONYM CanSyncRefArrayType FOR 
SYS.CanSyncRefArrayType;
/

-------------------------------------------------------------------------------
-- DBA Syc_refresh group status all Views.
-------------------------------------------------------------------------------
--
-- dba_sr_grp_status_all
--

create or replace view DBA_SR_GRP_STATUS_ALL
( OWNER,
  GROUP_ID,
  OPERATION,                  /* 1 - PREPARE, 2- EXECUTE */
  STATUS,                     /* 0 - RUNNING, 1- COMPLETE, */
                              /* 2 - ERROR-SOFT, 3- ERROR-HARD, 4 -ABORT */
  CURRENT_RUN,                /* 'Y' - YES, 'N' - NO */
  CURRENT_GROUP,                /* 'Y' - YES, 'N' - NO */
  NUM_TBLS,
  NUM_MVS,
  BASE_TBLS_REFR_STATUS,
  NUM_MVS_COMPLETED,
  NUM_MVS_ABORTED,
  ERROR_NUMBER,               /* error number if any */
  ERROR_MESSAGE,              /* error message if any */
  PREPARE_START_TIME,         /* start-time of prepare_refresh */
  PREPARE_END_TIME,           /* end-time of prepare_refresh */
  EXECUTE_START_TIME,         /* start-time of execute_refresh */
  EXECUTE_END_TIME            /* end-time of execute_refresh */
)
as
select u1.name owner,
       st.group_id,
       decode(st.cur_run_opn,
              1, 'PREPARE',
              2, 'EXECUTE') operation,
       decode(st.cur_run_status,
              0, 'RUNNING',
              1, 'COMPLETE',
              2, 'ERROR_SOFT',
              3, 'ERROR_HARD',
              4, 'ABORT',
              5, 'PARTIAL') status,
       decode(st.cur_run_flag,
              0, 'N',
              1, 'Y')  current_run,
       decode(s1.current_group_flag,
              0, 'N',
              1, 'Y')  current_group,
       num_tbls,
       num_mvs,
       decode(st.base_tbls_refr_status,
              0, 'NOT PROCESSED',
              1, 'COMPLETE',
              4, 'ABORT') base_tbls_refr_status,
       num_mvs_completed,                   /* numbers of MVs completed if any */
       num_mvs_aborted,                     /* numbers of MVs aborted if any */
       error_number,                        /* error number if any */
       error_message,                       /* error message if any */
       prepare_start_time,                  /* start-time of prepare_refresh */
       prepare_end_time,                    /* end-time of prepare_refresh */
       execute_start_time,                  /* start-time of execute_refresh */
       execute_end_time                     /* end-time of execute_refresh */
from sys.syncref$_group_status st, sys.user$ u1, 
  (select distinct group_id, current_group_flag from sys.syncref$_objects) s1
where st.owner# = u1.user# and st.group_id = s1.group_id
/

comment on table DBA_SR_GRP_STATUS_ALL is
'All synchronous refresh groups in the database'
/

comment on column DBA_SR_GRP_STATUS_ALL.OWNER is
'Owner of the synchronous refresh group'
/

comment on column DBA_SR_GRP_STATUS_ALL.GROUP_ID is
'Group ID of the synchronous refresh group'
/

comment on column DBA_SR_GRP_STATUS_ALL.OPERATION is
'Current operation of the synchronous refresh group: PREPARE, EXECUTE'
/

comment on column DBA_SR_GRP_STATUS_ALL.STATUS is
'Status of the synchronous refresh group: RUNNING, NOT PROCESSED,  COMPLETE, ERROR-SOFT, ERROR-HARD,-ABORT '
/

comment on column DBA_SR_GRP_STATUS_ALL.CURRENT_RUN is
'Indicates whether the synchronous refresh group is in the current run: Y - YES, N - NO '
/

comment on column DBA_SR_GRP_STATUS_ALL.NUM_TBLS is
'The number of tables in the synchronous refresh group'
/

comment on column DBA_SR_GRP_STATUS_ALL.NUM_MVS is
'The number of materialized views in the synchronous refresh group'
/

comment on column DBA_SR_GRP_STATUS_ALL.BASE_TBLS_REFR_STATUS is
'Indicate the refresh status of base tables in the synchronous refresh group'
/

comment on column DBA_SR_GRP_STATUS_ALL.NUM_MVS_COMPLETED is
'The number of materialized views which have completed refresh in the synchronous refresh group'
/

comment on column DBA_SR_GRP_STATUS_ALL.NUM_MVS_ABORTED is
'The number of materialized view which have aborted refresh in the synchronous refresh group'
/

comment on column DBA_SR_GRP_STATUS_ALL.ERROR_NUMBER is
'Error number if any of the synchronous refresh group'
/

comment on column DBA_SR_GRP_STATUS_ALL.ERROR_MESSAGE is
'Error message if any of the synchronous refresh group'
/

comment on column DBA_SR_GRP_STATUS_ALL.PREPARE_START_TIME is
'Start-time of prepare_refresh of the synchronous refresh group'
/

comment on column DBA_SR_GRP_STATUS_ALL.PREPARE_END_TIME is
'End-time of prepare_refresh of the synchronous refresh group'
/

comment on column DBA_SR_GRP_STATUS_ALL.EXECUTE_START_TIME is
'Start-time of execute_refresh of the synchronous refresh group'
/

comment on column DBA_SR_GRP_STATUS_ALL.EXECUTE_END_TIME is
'End-time of execute_refresh of the synchronous refresh group'
/



execute CDBView.create_cdbview(false,'SYS','DBA_SR_GRP_STATUS_ALL','CDB_SR_GRP_STATUS_ALL');
grant select on SYS.CDB_SR_GRP_STATUS_ALL to select_catalog_role
/
create or replace public synonym CDB_SR_GRP_STATUS_ALL for SYS.CDB_SR_GRP_STATUS_ALL
/

-- catalog views dba_sr_grp_status

create or replace view dba_sr_grp_status
as select OWNER, GROUP_ID, OPERATION, STATUS, NUM_TBLS, NUM_MVS, 
BASE_TBLS_REFR_STATUS, NUM_MVS_COMPLETED, 
NUM_MVS_ABORTED, ERROR_NUMBER, ERROR_MESSAGE, 
PREPARE_START_TIME, PREPARE_END_TIME, EXECUTE_START_TIME, EXECUTE_END_TIME 
from dba_sr_grp_status_all
where current_run = 'Y' and current_group = 'Y'
/


execute CDBView.create_cdbview(false,'SYS','DBA_SR_GRP_STATUS','CDB_SR_GRP_STATUS');
grant select on SYS.CDB_sr_grp_status to select_catalog_role
/
create or replace public synonym CDB_sr_grp_status for SYS.CDB_sr_grp_status
/

-- catalog views user_sr_grp_status_all

create or replace view user_sr_grp_status_all
as select GROUP_ID, OPERATION, STATUS, CURRENT_RUN, CURRENT_GROUP,
NUM_TBLS, NUM_MVS , BASE_TBLS_REFR_STATUS, NUM_MVS_COMPLETED, 
NUM_MVS_ABORTED,ERROR_NUMBER, ERROR_MESSAGE, PREPARE_START_TIME, 
PREPARE_END_TIME, EXECUTE_START_TIME,  EXECUTE_END_TIME
from dba_sr_grp_status_all
where owner = SYS_CONTEXT ('USERENV', 'CURRENT_USER')
/

-- catalog views user_sr_grp_status

create or replace view user_sr_grp_status
as select GROUP_ID, OPERATION, STATUS,
NUM_TBLS, NUM_MVS , BASE_TBLS_REFR_STATUS, NUM_MVS_COMPLETED, 
NUM_MVS_ABORTED,ERROR_NUMBER, ERROR_MESSAGE, PREPARE_START_TIME, 
PREPARE_END_TIME, EXECUTE_START_TIME,  EXECUTE_END_TIME
from dba_sr_grp_status
where owner = SYS_CONTEXT ('USERENV', 'CURRENT_USER')
/

grant select on dba_sr_grp_status_all to select_catalog_role;
create or replace public synonym dba_sr_grp_status_all for dba_sr_grp_status_all;
/

grant select on dba_sr_grp_status to select_catalog_role;
create or replace public synonym dba_sr_grp_status for dba_sr_grp_status;
/

grant read on user_sr_grp_status_all to public;
create or replace public synonym user_sr_grp_status_all for user_sr_grp_status_all;
/

grant read on user_sr_grp_status to public;
create or replace public synonym user_sr_grp_status for user_sr_grp_status;
/

-------------------------------------------------------------------------------
-- DBA Syc_refresh object status all Views.
-------------------------------------------------------------------------------
--
-- dba_sr_obj_status_all
--

create or replace view DBA_SR_OBJ_STATUS_ALL
( 
  OWNER,
  NAME,
  TYPE,
  GROUP_ID,
  STATUS,
  CURRENT_RUN,                
  CURRENT_GROUP,                
  ERROR_NUMBER,               
  ERROR_MESSAGE,              
  LAST_MODIFIED_TIME
)
as
select u1.name owner,
       o1.name name,
       decode(o1.type#,
              2, 'TABLE',
              42, 'MVIEW') type,
       st.group_id,
       decode(st.status,
              0, 'NOT PROCESSED',
              1, 'COMPLETE',
              4, 'ABORT') status,
       decode(st.cur_run_flag,  
              0, 'N',
              1, 'Y')  current_run,
       decode(s1.current_group_flag,
              0, 'N',
              1, 'Y')  current_group,
       error_number,                        /* error number if any */
       error_message,                       /* error message if any */
       last_modified_time                   /* time of last refresh */
from sys.obj$ o1, sys.syncref$_objects s1, sys.syncref$_object_status st,
  sys.user$ u1
where o1.obj# = s1.obj# and s1.obj# = st.obj#
      and o1.type# = s1.object_type_flag and o1.owner# = u1.user# 
      and s1.group_id = st.group_id
/

comment on table DBA_SR_OBJ_STATUS_ALL is
'All synchronous refresh objects in the database'
/
comment on column DBA_SR_OBJ_STATUS_ALL.OWNER is
'Owner of the synchronous refresh object'
/
comment on column DBA_SR_OBJ_STATUS_ALL.NAME is
'Name of the synchronous refresh object'
/
comment on column DBA_SR_OBJ_STATUS_ALL.TYPE is
'Type of synchronous refresh object in the database: TABLE, MVIEW'
/
comment on column DBA_SR_OBJ_STATUS_ALL.GROUP_ID is
'Group ID of the synchronous refresh object'
/
comment on column DBA_SR_OBJ_STATUS_ALL.STATUS is
'Status of the synchronous refresh object: NOT PROCESSED, COMPLETE, ABORT'
/
comment on column DBA_SR_OBJ_STATUS_ALL.CURRENT_RUN is
'Indicates whether the synchronous refresh object is in the current run: Y - YES, N - NO '
/
comment on column DBA_SR_OBJ_STATUS_ALL.ERROR_NUMBER is
'Error number if any of the synchronous refresh object'
/
comment on column DBA_SR_OBJ_STATUS_ALL.ERROR_MESSAGE is
'Error message if any of the synchronous refresh object'
/
comment on column DBA_SR_OBJ_STATUS_ALL.LAST_MODIFIED_TIME is
'Last modified-time of the synchronous refresh object'
/


execute CDBView.create_cdbview(false,'SYS','DBA_SR_OBJ_STATUS_ALL','CDB_SR_OBJ_STATUS_ALL');
grant select on SYS.CDB_SR_OBJ_STATUS_ALL to select_catalog_role
/
create or replace public synonym CDB_SR_OBJ_STATUS_ALL for SYS.CDB_SR_OBJ_STATUS_ALL
/

-- catalog view dba_sr_obj_status

create or replace view dba_sr_obj_status
as select OWNER, NAME, TYPE, GROUP_ID, STATUS, ERROR_NUMBER,
ERROR_MESSAGE, LAST_MODIFIED_TIME
from dba_sr_obj_status_all
where current_run = 'Y' and current_group = 'Y'
/


execute CDBView.create_cdbview(false,'SYS','DBA_SR_OBJ_STATUS','CDB_SR_OBJ_STATUS');
grant select on SYS.CDB_sr_obj_status to select_catalog_role
/
create or replace public synonym CDB_sr_obj_status for SYS.CDB_sr_obj_status
/

-- catalog view user_sr_obj_status_all

create or replace view user_sr_obj_status_all
as select NAME, TYPE, GROUP_ID, STATUS,CURRENT_RUN,
CURRENT_GROUP, ERROR_NUMBER, ERROR_MESSAGE, LAST_MODIFIED_TIME
from dba_sr_obj_status_all
where owner = SYS_CONTEXT ('USERENV', 'CURRENT_USER')
/

-- catalog view user_sr_obj_status

create or replace view user_sr_obj_status
as select NAME, TYPE, GROUP_ID, STATUS, ERROR_NUMBER, ERROR_MESSAGE, LAST_MODIFIED_TIME
from dba_sr_obj_status
where owner = SYS_CONTEXT ('USERENV', 'CURRENT_USER')
/

grant select on dba_sr_obj_status_all to select_catalog_role;
create or replace public synonym dba_sr_obj_status_all for dba_sr_obj_status_all;
/

grant select on dba_sr_obj_status to select_catalog_role;
create or replace public synonym dba_sr_obj_status for dba_sr_obj_status;
/

grant read on user_sr_obj_status_all to public;
create or replace public synonym user_sr_obj_status_all for user_sr_obj_status_all;
/

grant read on user_sr_obj_status to public;
create or replace public synonym user_sr_obj_status for user_sr_obj_status;
/



-------------------------------------------------------------------------------
-- DBA Syc_refresh object all Views.
-------------------------------------------------------------------------------
--
-- dba_sr_obj_all
--

create or replace view DBA_SR_OBJ_ALL
( 
  OWNER,
  NAME,
  TYPE,
  GROUP_ID,
  CURRENT_GROUP,
  STAGING_LOG_NAME          
)
as
select u1.name owner,
       o1.name name,
       decode(o1.type#,
              2, 'TABLE',
              42, 'MVIEW') type,
       s1.group_id,
       decode(s1.current_group_flag,
              0, 'N',
              1, 'Y')  current_group,
       o2.name staging_log_name
from (sys.syncref$_objects s1 inner join sys.obj$ o1 
       on o1.obj# = s1.obj# and o1.type# = s1.object_type_flag
     inner join sys.user$ u1
       on o1.owner# = u1.user#)
     left outer join
     (sys.syncref$_table_info t1 inner join sys.obj$ o2
       on o2.obj# = t1.staging_log_obj#)
     on o1.obj# = t1.table_obj#
/

comment on table DBA_SR_OBJ_ALL is
'All synchronous refresh objects in the database'
/
comment on column DBA_SR_OBJ_ALL.OWNER is
'Owner of the synchronous refresh object'
/
comment on column DBA_SR_OBJ_ALL.NAME is
'Name of the synchronous refresh object'
/
comment on column DBA_SR_OBJ_ALL.TYPE is
'Type of synchronous refresh object in the database: TABLE, MVIEW'
/
comment on column DBA_SR_OBJ_ALL.GROUP_ID is
'Group ID of the synchronous refresh object'
/
comment on column DBA_SR_OBJ_ALL.CURRENT_GROUP is
'Indicates whether the synchronous refresh group is in the current group: Y - YES, N - NO '
/
comment on column DBA_SR_OBJ_ALL.STAGING_LOG_NAME is
'Staging log name of the synchronous refresh object table'
/



execute CDBView.create_cdbview(false,'SYS','DBA_SR_OBJ_ALL','CDB_SR_OBJ_ALL');
grant select on SYS.CDB_SR_OBJ_ALL to select_catalog_role
/
create or replace public synonym CDB_SR_OBJ_ALL for SYS.CDB_SR_OBJ_ALL
/

-- catalog view dba_sr_obj_status

create or replace view dba_sr_obj
as select OWNER, NAME, TYPE, GROUP_ID, 
STAGING_LOG_NAME from dba_sr_obj_all
where current_group = 'Y'
/


execute CDBView.create_cdbview(false,'SYS','DBA_SR_OBJ','CDB_SR_OBJ');
grant select on SYS.CDB_sr_obj to select_catalog_role
/
create or replace public synonym CDB_sr_obj for SYS.CDB_sr_obj
/

-- catalog view user_sr_obj_all

create or replace view user_sr_obj_all
as select NAME, TYPE, GROUP_ID, CURRENT_GROUP,
STAGING_LOG_NAME from dba_sr_obj_all
where owner = SYS_CONTEXT ('USERENV', 'CURRENT_USER')
/

-- catalog view user_sr_obj

create or replace view user_sr_obj
as select NAME, TYPE, GROUP_ID,
STAGING_LOG_NAME from dba_sr_obj
where owner = SYS_CONTEXT ('USERENV', 'CURRENT_USER')
/

grant select on dba_sr_obj_all to select_catalog_role;
create or replace public synonym dba_sr_obj_all for dba_sr_obj_all;
/

grant select on dba_sr_obj to select_catalog_role;
create or replace public synonym dba_sr_obj for dba_sr_obj;
/

grant read on user_sr_obj_all to public;
create or replace public synonym user_sr_obj_all for user_sr_obj_all;
/

grant read on user_sr_obj to public;
create or replace public synonym user_sr_obj for user_sr_obj;
/

-------------------------------------------------------------------------------
-- DBA Syc_refresh log_exceptions all Views.
-------------------------------------------------------------------------------
--
-- dba_sr_stlog_exceptions
--

create or replace view DBA_SR_STLOG_EXCEPTIONS
(
  OWNER,
  TABLE_NAME,
  STAGING_LOG_NAME,
  BAD_ROWID,
  ERROR_NUMBER,
  ERROR_MESSAGE  
)
as
select u1.name owner,
       o1.name name,
       o2.name name,
       log.bad_rowid,
       log.error_number,
       log.error_message
from sys.obj$ o1, sys.user$ u1, sys.syncref$_log_exceptions log,
     sys.obj$ o2
where log.table_obj# = o1.obj# and log.staging_log_obj# = o2.obj# and
      o1.owner# = u1.user#
/
comment on column DBA_SR_STLOG_EXCEPTIONS.OWNER is
'Owner of the base table for the synchronous refresh'
/
comment on column DBA_SR_STLOG_EXCEPTIONS.TABLE_NAME is
'Name of the base table for the synchronous refresh'
/
comment on column DBA_SR_STLOG_EXCEPTIONS.STAGING_LOG_NAME is
'Name of the staging log for the synchronous refresh'
/
comment on column DBA_SR_STLOG_EXCEPTIONS.BAD_ROWID is
'Row ID of the staging log row causing the exception for the synchronous refresh'
/
comment on column DBA_SR_STLOG_EXCEPTIONS.ERROR_NUMBER is
'Error number of the exception for the synchronous refresh'
/
comment on column DBA_SR_STLOG_EXCEPTIONS.ERROR_MESSAGE is
'Error message of the exception for the synchronous refresh'
/
create or replace public synonym DBA_SR_STLOG_EXCEPTIONS
   for DBA_SR_STLOG_EXCEPTIONS
/
grant select on DBA_SR_STLOG_EXCEPTIONS to select_catalog_role
/


execute CDBView.create_cdbview(false,'SYS','DBA_SR_STLOG_EXCEPTIONS','CDB_SR_STLOG_EXCEPTIONS');
grant select on SYS.CDB_SR_STLOG_EXCEPTIONS to select_catalog_role
/
create or replace public synonym CDB_SR_STLOG_EXCEPTIONS for SYS.CDB_SR_STLOG_EXCEPTIONS
/

create or replace view USER_SR_STLOG_EXCEPTIONS
as select  TABLE_NAME, STAGING_LOG_NAME, BAD_ROWID, ERROR_NUMBER, ERROR_MESSAGE 
from DBA_SR_STLOG_EXCEPTIONS
where owner = SYS_CONTEXT ('USERENV', 'CURRENT_USER')
/
comment on column USER_SR_STLOG_EXCEPTIONS.TABLE_NAME is
'Name of the base table for the synchronous refresh'
/
comment on column USER_SR_STLOG_EXCEPTIONS.STAGING_LOG_NAME is
'Name of the staging log for the synchronous refresh'
/
comment on column USER_SR_STLOG_EXCEPTIONS.BAD_ROWID is
'Row ID of the staging log row causing the exception for the synchronous refresh'
/
comment on column USER_SR_STLOG_EXCEPTIONS.ERROR_NUMBER is
'Error number of the exception for the synchronous refresh'
/
comment on column USER_SR_STLOG_EXCEPTIONS.ERROR_MESSAGE is
'Error message of the exception for the synchronous refresh'
/
create or replace public synonym USER_SR_STLOG_EXCEPTIONS for USER_SR_STLOG_EXCEPTIONS
/
grant read on USER_SR_STLOG_EXCEPTIONS to public with grant option
/


-- dba_sr_stlog_stats

create or replace view DBA_SR_STLOG_STATS
( 
  OWNER,
  TABLE_NAME,
  STAGING_LOG_NAME,          
  NUM_INSERTS,
  NUM_DELETES,
  NUM_UPDATES, 
  PSL_MODE
)
as select u1.name owner,
          o1.name table_name,
          o2.name staging_log_name,
          sts.num_inserts,
          sts.num_deletes,
          sts.num_updates, 
          decode(sts.psl_mode,
                 7, 'TRUSTED',
	         6, 'DELETE_TRUSTED and UPDATE_TRUSTED',
	         5, 'UPDATE_TRUSTED and INSERT_TRUSTED',
	         4, 'UPDATE_TRUSTED',
                 3, 'INSERT_TRUSTED and DELETE_TRUSTED',
                 2, 'DELETE_TRUSTED',
                 1, 'INSERT_TRUSTED',
                 0, 'ENFORCED') as psl_mode
  from  sys.obj$ o1, sys.user$ u1,
  sys.obj$ o2, sys.syncref$_table_info t1,
  sys.syncref$_stlog_stats sts
  where
      t1.table_obj# = o1.obj# and o1.owner# = u1.user#  and
      t1.staging_log_obj# = o2.obj# and
      t1.table_obj# = sts.table_obj#
/


execute CDBView.create_cdbview(false,'SYS','DBA_SR_STLOG_STATS','CDB_SR_STLOG_STATS');
grant select on SYS.CDB_SR_STLOG_STATS to select_catalog_role
/
create or replace public synonym CDB_SR_STLOG_STATS for SYS.CDB_SR_STLOG_STATS
/

create or replace view USER_SR_STLOG_STATS
as select TABLE_NAME, STAGING_LOG_NAME, NUM_INSERTS, NUM_DELETES, 
NUM_UPDATES, PSL_MODE
from DBA_SR_STLOG_STATS
where owner = SYS_CONTEXT ('USERENV', 'CURRENT_USER')
/

create or replace public synonym DBA_SR_STLOG_STATS for DBA_SR_STLOG_STATS
/
grant read on DBA_SR_STLOG_STATS to public with grant option
/
create or replace public synonym USER_SR_STLOG_STATS for USER_SR_STLOG_STATS
/
grant read on USER_SR_STLOG_STATS to public with grant option
/

-- dba_sr_partn_ops

create or replace view DBA_SR_PARTN_OPS
( 
  OWNER,
  TABLE_NAME,
  PARTITION_OP,
  PARTITION_NAME,
  OUTSIDE_TABLE_SCHEMA,
  OUTSIDE_TABLE_NAME
)
as
select u1.name owner,
       o1.name table_name,
       sts.partition_op,
       sts.partition_name,
       sts.outside_table_schema_name outside_table_schema,
       sts.outside_table_name outside_table_name
  from (sys.syncref$_objects s1 inner join sys.obj$ o1 
         on o1.obj# = s1.obj# and o1.type# = s1.object_type_flag and o1.type# = 2
         and current_group_flag = 1 inner join sys.user$ u1
          on o1.owner# = u1.user#)
     inner join sys.syncref$_partn_ops  sts
      on  o1.obj# = sts.table_obj#        
/


execute CDBView.create_cdbview(false,'SYS','DBA_SR_PARTN_OPS','CDB_SR_PARTN_OPS');
grant select on SYS.CDB_SR_PARTN_OPS to select_catalog_role
/
create or replace public synonym CDB_SR_PARTN_OPS for SYS.CDB_SR_PARTN_OPS
/

create or replace view USER_SR_PARTN_OPS
as select TABLE_NAME, PARTITION_OP, PARTITION_NAME,OUTSIDE_TABLE_SCHEMA,OUTSIDE_TABLE_NAME
from DBA_SR_PARTN_OPS
where owner = SYS_CONTEXT ('USERENV', 'CURRENT_USER')
/

create or replace public synonym DBA_SR_PARTN_OPS for DBA_SR_PARTN_OPS
/
grant read on DBA_SR_PARTN_OPS to public with grant option
/
create or replace public synonym USER_SR_PARTN_OPS for USER_SR_PARTN_OPS
/
grant read on USER_SR_PARTN_OPS to public with grant option
/




@?/rdbms/admin/sqlsessend.sql
