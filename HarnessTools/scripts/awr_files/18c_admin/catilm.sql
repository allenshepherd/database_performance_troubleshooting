Rem
Rem $Header: rdbms/admin/catilm.sql /st_rdbms_18.0/1 2017/12/08 14:50:20 hlakshma Exp $
Rem
Rem catilm.sql
Rem
Rem Copyright (c) 2011, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catilm.sql 
Rem
Rem    DESCRIPTION
Rem      ILM activity tracking related views
Rem
Rem    NOTES
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catilm.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catilm.sql
Rem SQL_PHASE: CATILM
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdeps.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    hlakshma    09/01/17 - Bug 27119186 : New view to support AIM feature
Rem                           access tracking 
Rem    hlakshma    04/03/17 - Bug 25825879: Internal diagnostic view for 
Rem                           AIM ( Project 68505) 
Rem    hlakshma    01/10/17 - Project 68505: New views for Automatic In-memory
Rem                           Management
Rem    hlakshma    08/03/16 - Fix column name in view
Rem                           dba_ilmdatamovementpolicies (bug-24402975)
Rem    hlakshma    03/22/16 - Add additional enumeration values in ADO views
Rem                           for DBIM related policies (project 45958)
Rem    prgaharw    03/04/16 - Proj 45958: Add IM policies cols to ADO views
Rem    sdeekshi    10/14/15 - Bug 21872833 - Add inherited_tablespace column to
Rem                           user_ilmobjects and dba_ilmobjects to indicate
Rem                           from which tablespace policy was inherited
Rem    hlakshma    10/04/15 - No need to filter objects in sys.redef_object$ 
Rem                           (Bug 21872978) in ILM views
Rem    vinisubr    08/11/15 - Bug 21351086: Fixed DBA_COL_USAGE_STATISTICS view
Rem                           definition so that it doesn't display object
Rem                           information for objects in different user  
Rem                           tablespaces with the same names.
Rem    hlakshma    08/04/15 - Use ORA_check_SYS_privilege instead of query on
Rem                           v$enabledprivs (bug-20354880)
Rem    vinisubr    04/27/15 - Bug 20878424: Fixed column-level statistics code
Rem                           to work with partitioned tables, and also fixed
Rem                           some review comments
Rem    vinisubr    03/25/15 - Project 58876: Support for views for in-memory 
Rem                           fixed table for kernel column-level statistics
Rem    hlakshma    03/16/15 - Project 45958: Support for IM policies
Rem    hlakshma    02/18/15 - Project 45958: Expand heat_map internal views to
Rem                           include frequency information
Rem    vyarehal    12/04/14 - bug#20128644 remove blankspace Padding
Rem    skayoor     11/30/14 - Proj 58196: Change Select priv to Read Priv
Rem    hlakshma    06/04/14 - Retain constant value for dictionary values
Rem                           across database versions
Rem    vradhakr    03/19/14 - Bug 17995069 : Make the heat_map_segment views
Rem                           show correct information efficiently.
Rem    prgaharw    03/07/14 - 18284005 - Init condition_type for RDONLY policies
Rem    prgaharw    02/24/14 - 17739520 - Introduce DELETED flag in views
Rem    hlakshma    02/12/14 - Add more states to the ADO views
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    sasounda    11/19/13 - 17746252: handle KZSRAT when creating all_* views
Rem    smuthuli    07/01/13 - Add ts# to _SYS_HEAT_MAP_SEG_HISTOGRAM
Rem    talliu      06/28/13 - Add CDB view for DBA view
Rem    hlakshma    03/11/13 - Exclude more interim objects from ADO views 
Rem    hlakshma    02/14/13 - Forward merge for bug 16038047 ( Exclude interim
Rem                           objects created during redefinition process from
Rem                           ADO Views)
Rem    vradhakr    01/21/13 - XbranchMerge vradhakr_bug-16067485 from
Rem                           st_rdbms_12.1.0.1
Rem    vradhakr    12/26/12 - Handle system status row in heat_map_stat$.
Rem    hlakshma    12/17/12 - Fix definition of view user_ilmresults
Rem    prgaharw    11/25/12 - 15865137 - Remove space from decoded string
Rem    vraja       10/23/12 - fix 4-way join underlying
Rem                           _SYS_HEAT_MAP_SEG_HISTOGRAM
Rem    vraja       10/15/12 - ILM renamed to HEAT_MAP
Rem    hlakshma    10/04/12 - Fix ILM view names
Rem    amylavar    09/24/12 - Change 'OLTP' to 'ADVANCED'
Rem    hlakshma    08/30/12 - Add support for EHCC row-level locking
Rem    hlakshma    04/06/12 - Modify views to include policies based on
Rem                           VALID_TIME_END
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    liaguo      02/21/12 - owner
Rem    prgaharw    02/16/12 - Decode READ ONLY flag in ILMPOLICY$ views
Rem    hlakshma    01/20/12 - Edit view user_ilmexecution to support
Rem                           manual override
Rem    liaguo      11/09/11 - Use obj# for views
Rem    hlakshma    11/09/11 - Move ILM related views from cdsqlddl.sql
Rem    liaguo      10/18/11 - show real time data with gv$ views
Rem    liaguo      09/30/11 - view changes
Rem    liaguo      06/08/11 - Project 32788 DB ILM
Rem    liaguo      06/08/11 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

/*
 * Internal HEAT MAP segment access stats histograms incl. real time access
 * info from GV$HEAT_MAP_SEGMENT.
 * Bug 27119186: Access tracking may be on even when heat_map has been 
 * turned off explicitly. The heat map views should show access tracked only 
 * heat_map was explicitly turned on. The bit position 1 of the 'flag' column
 * of heat_map_stat$ is set if the access represented in the row is tracked
 * when heat_map was off. Filter such rows in this view.
 */
create or replace view "_SYS_HEAT_MAP_SEG_HISTOGRAM"
    (OBJ#, DATAOBJ#, TS#, TRACK_TIME, SEGMENT_WRITE, SEGMENT_READ, FULL_SCAN,
     LOOKUP_SCAN, N_FTS, N_LOOKUP, N_WRITE)
as
   select s.obj#, s.dataobj#, s.ts#, s.track_time,
          decode(bitand(s.segment_access, 1), 1, 'YES', 'NO'),
          decode(bitand(s.segment_access, 2), 2, 'YES', 'NO'),
          decode(bitand(s.segment_access, 4), 4, 'YES', 'NO'),
          decode(bitand(s.segment_access, 8), 8, 'YES', 'NO'),
          s.n_fts, s.n_lookup, s.n_write
    from heat_map_stat$ s where s.OBJ# != -1
     and bitand(flag, 1) != 1
union
   select obj#, dataobj#, ts#, track_time,
          segment_write, segment_read, full_scan, lookup_scan,
          n_full_scan, n_lookup_scan, n_segment_write
     from
         GV$HEAT_MAP_SEGMENT
     where
       (segment_write = 'YES' OR lookup_scan = 'YES' OR full_scan = 'YES') AND
       con_id = SYS_CONTEXT('USERENV', 'CON_ID')
/

/*
 * Show various segment access info in the system. 
 */
create or replace view DBA_HEAT_MAP_SEG_HISTOGRAM
    (OWNER, OBJECT_NAME, SUBOBJECT_NAME, TRACK_TIME, SEGMENT_WRITE,
     FULL_SCAN, LOOKUP_SCAN)
as select u.name, o.name, o.subname, s.track_time,
          s.segment_write, s.full_scan, s.lookup_scan
from obj$ o, sys."_SYS_HEAT_MAP_SEG_HISTOGRAM" s, user$ u
where s.obj# = o.obj# 
 and o.owner# = u.user#
 order by o.obj#
/
create or replace public synonym DBA_HEAT_MAP_SEG_HISTOGRAM
for sys.DBA_HEAT_MAP_SEG_HISTOGRAM
/
grant read on DBA_HEAT_MAP_SEG_HISTOGRAM to PUBLIC with grant option
/
comment on table DBA_HEAT_MAP_SEG_HISTOGRAM is
'Segment access information for all segments'
/
comment on column DBA_HEAT_MAP_SEG_HISTOGRAM.TRACK_TIME is
'System time when the segment access was tracked'
/
comment on column DBA_HEAT_MAP_SEG_HISTOGRAM.SEGMENT_WRITE is
'Segment has write access YES/NO'
/
comment on column DBA_HEAT_MAP_SEG_HISTOGRAM.FULL_SCAN is
'Segment has full scan YES/NO'
/
comment on column DBA_HEAT_MAP_SEG_HISTOGRAM.LOOKUP_SCAN is
'Segment has lookup scan YES/NO'
/


execute CDBView.create_cdbview(false,'SYS','DBA_HEAT_MAP_SEG_HISTOGRAM','CDB_HEAT_MAP_SEG_HISTOGRAM');
grant select on SYS.CDB_HEAT_MAP_SEG_HISTOGRAM to select_catalog_role
/
create or replace public synonym CDB_HEAT_MAP_SEG_HISTOGRAM for SYS.CDB_HEAT_MAP_SEG_HISTOGRAM
/

/*
 * remark Show segment access information for an user's objects 
 */
create or replace view USER_HEAT_MAP_SEG_HISTOGRAM
   (OBJECT_NAME, SUBOBJECT_NAME, TRACK_TIME, SEGMENT_WRITE, FULL_SCAN, LOOKUP_SCAN)
as select o.name, o.subname, s.track_time,
   s.segment_write, s.full_scan, s.lookup_scan
from obj$ o, sys."_SYS_HEAT_MAP_SEG_HISTOGRAM" s
where o.owner#=userenv('SCHEMAID') 
  and s.obj# = o.obj#
order by o.obj#
/
create or replace public synonym USER_HEAT_MAP_SEG_HISTOGRAM
for sys.USER_HEAT_MAP_SEG_HISTOGRAM
/
grant read on USER_HEAT_MAP_SEG_HISTOGRAM to PUBLIC with grant option
/
comment on table USER_HEAT_MAP_SEG_HISTOGRAM is
'Segment access information for segments owned by the user'
/
comment on column USER_HEAT_MAP_SEG_HISTOGRAM.TRACK_TIME is
'System time when the segment access was tracked'
/
comment on column USER_HEAT_MAP_SEG_HISTOGRAM.SEGMENT_WRITE is
'Segment has write access YES/NO'
/
comment on column USER_HEAT_MAP_SEG_HISTOGRAM.FULL_SCAN is
'Segment has full scan YES/NO'
/
comment on column USER_HEAT_MAP_SEG_HISTOGRAM.LOOKUP_SCAN is
'Segment has lookup scan YES/NO'
/


create or replace view ALL_HEAT_MAP_SEG_HISTOGRAM
    (OWNER, OBJECT_NAME, SUBOBJECT_NAME, TRACK_TIME, SEGMENT_WRITE,
      FULL_SCAN, LOOKUP_SCAN)
as select u.name, o.name, o.subname, s.track_time,
          s.segment_write, s.full_scan, s.lookup_scan
from sys.obj$ o, sys.user$ u, sys."_SYS_HEAT_MAP_SEG_HISTOGRAM" s
where o.owner# = u.user#
  and (o.owner# = userenv('SCHEMAID') 
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or ora_check_SYS_privilege (o.owner#, o.type#) = 1                 
       )
  and o.obj# = s.obj#
order by s.obj#
/
create or replace public synonym ALL_HEAT_MAP_SEG_HISTOGRAM
for sys.ALL_HEAT_MAP_SEG_HISTOGRAM
/
grant read on ALL_HEAT_MAP_SEG_HISTOGRAM to PUBLIC with grant option
/
comment on table ALL_HEAT_MAP_SEG_HISTOGRAM is
'Segment access information for all segments visible to the user'
/
comment on column ALL_HEAT_MAP_SEG_HISTOGRAM.TRACK_TIME is
'System time when the segment access was tracked'
/
comment on column ALL_HEAT_MAP_SEG_HISTOGRAM.SEGMENT_WRITE is
'Segment has write access YES/NO'
/
comment on column ALL_HEAT_MAP_SEG_HISTOGRAM.FULL_SCAN is
'Segment has full scan YES/NO'
/
comment on column ALL_HEAT_MAP_SEG_HISTOGRAM.LOOKUP_SCAN is
'Segment has lookup scan YES/NO'
/

/*
 * Show last segment access time info for all objects enabled for ILM
 * activity tracking.
 */
create or replace view DBA_HEAT_MAP_SEGMENT
  (
    OWNER, OBJECT_NAME, SUBOBJECT_NAME, SEGMENT_WRITE_TIME, SEGMENT_READ_TIME, 
    FULL_SCAN, LOOKUP_SCAN
  )
as
select u.name, o.name, o.subname, 
    max (decode (hm.segment_write, 'YES', track_time, null)) SEGMENT_WRITE_TIME,
    max (decode (hm.segment_read, 'YES', track_time, null)) SEGMENT_READ_TIME,
    max (decode (hm.full_scan, 'YES', track_time, null)) FULL_SCAN,
    max (decode (hm.lookup_scan, 'YES', track_time, null)) LOOKUP_SCAN
  from obj$ o, user$ u, sys."_SYS_HEAT_MAP_SEG_HISTOGRAM" hm
  where o.obj# = hm.obj#
          and   o.owner# = u.user#
  group by u.name, o.name, o.subname
/
create or replace public synonym DBA_HEAT_MAP_SEGMENT
for sys.DBA_HEAT_MAP_SEGMENT
/
grant read on DBA_HEAT_MAP_SEGMENT to PUBLIC with grant option
/
comment on table DBA_HEAT_MAP_SEGMENT is
'Last segment access time'
/
comment on column DBA_HEAT_MAP_SEGMENT.SEGMENT_WRITE_TIME is
'Last segment write access time'
/
comment on column DBA_HEAT_MAP_SEGMENT.SEGMENT_READ_TIME is
'Last segment read access time'
/
comment on column DBA_HEAT_MAP_SEGMENT.FULL_SCAN is
'Last full scan time'
/
comment on column DBA_HEAT_MAP_SEGMENT.LOOKUP_SCAN is
'Last range scan or point scan time'
/


execute CDBView.create_cdbview(false,'SYS','DBA_HEAT_MAP_SEGMENT','CDB_HEAT_MAP_SEGMENT');
grant read on SYS.CDB_HEAT_MAP_SEGMENT to PUBLIC with grant option 
/
create or replace public synonym CDB_HEAT_MAP_SEGMENT for SYS.CDB_HEAT_MAP_SEGMENT
/

/*
 * Show last segment access time info for the user's objects that are
 * enabled for ILM activity tracking.
 */
create or replace view USER_HEAT_MAP_SEGMENT
  (
    OBJECT_NAME, SUBOBJECT_NAME, SEGMENT_WRITE_TIME, 
    SEGMENT_READ_TIME, FULL_SCAN, LOOKUP_SCAN
  )
as
select o.name, o.subname, 
    max (decode (hm.segment_write, 'YES', track_time, null)) SEGMENT_WRITE_TIME,
    max (decode (hm.segment_read, 'YES', track_time, null)) SEGMENT_READ_TIME,
    max (decode (hm.full_scan, 'YES', track_time, null)) FULL_SCAN,
    max (decode (hm.lookup_scan, 'YES', track_time, null)) LOOKUP_SCAN
  from obj$ o, sys."_SYS_HEAT_MAP_SEG_HISTOGRAM" hm
  where o.owner#=userenv('SCHEMAID') 
          and   o.obj# = hm.obj#
  group by o.name, o.subname
/
create or replace public synonym USER_HEAT_MAP_SEGMENT
for sys.USER_HEAT_MAP_SEGMENT
/
grant read on USER_HEAT_MAP_SEGMENT to PUBLIC with grant option
/
comment on table USER_HEAT_MAP_SEGMENT is
'Users segment last access time'
/
comment on column USER_HEAT_MAP_SEGMENT.SEGMENT_WRITE_TIME is
'Last segment write access time'
/
comment on column USER_HEAT_MAP_SEGMENT.SEGMENT_READ_TIME is
'Last segment read access time'
/
comment on column USER_HEAT_MAP_SEGMENT.FULL_SCAN is
'Last full scan time'
/
comment on column USER_HEAT_MAP_SEGMENT.LOOKUP_SCAN is
'Last range scan or point scan access time'
/

create or replace view ALL_HEAT_MAP_SEGMENT
  (
    OWNER, OBJECT_NAME, SUBOBJECT_NAME, SEGMENT_WRITE_TIME, 
    SEGMENT_READ_TIME, FULL_SCAN, LOOKUP_SCAN
  )
as
select u.name, o.name, o.subname, 
    max (decode (hm.segment_write, 'YES', track_time, null)) SEGMENT_WRITE_TIME,
    max (decode (hm.segment_read, 'YES', track_time, null)) SEGMENT_READ_TIME,
    max (decode (hm.full_scan, 'YES', track_time, null)) FULL_SCAN,
    max (decode (hm.lookup_scan, 'YES', track_time, null)) LOOKUP_SCAN
from obj$ o, user$ u, sys."_SYS_HEAT_MAP_SEG_HISTOGRAM" hm
where o.obj# = hm.obj#
and   o.owner# = u.user#
and   (o.owner# = userenv('SCHEMAID') 
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
        or ora_check_SYS_privilege (o.owner#, o.type#) = 1
       )
group by u.name, o.name, o.subname
/
create or replace public synonym ALL_HEAT_MAP_SEGMENT
for sys.ALL_HEAT_MAP_SEGMENT
/
grant read on ALL_HEAT_MAP_SEGMENT to PUBLIC with grant option
/
comment on table ALL_HEAT_MAP_SEGMENT is
'Users segment last access time'
/
comment on column ALL_HEAT_MAP_SEGMENT.SEGMENT_WRITE_TIME is
'Last segment write access time'
/
comment on column ALL_HEAT_MAP_SEGMENT.SEGMENT_READ_TIME is
'Last segment read access time'
/
comment on column ALL_HEAT_MAP_SEGMENT.FULL_SCAN is
'Last full scan time'
/
comment on column ALL_HEAT_MAP_SEGMENT.LOOKUP_SCAN is
'Last range scan or point scan access time'
/


/* For review of changes to ILM related views, please contact the 
 * data layer manager 
 */
  
/* This view provides information on ILM policies applicable to user objects.
 *
 * Note on ILM policy owner 
 * -----------------------
 * The user owns the policies on his/her own objects. 
 *
 * The tablespace level policies are owned by the policy creator. The policy
 * owner does not have any user semantics, so we do not expose this 
 * information. We maintain this only in anticipation of future changes where
 * an ILM policy can be created separately
 */

create or replace view USER_ILMPOLICIES
(POLICY_NAME, POLICY_TYPE, TABLESPACE, ENABLED, DELETED)
as 
select  a.name, 
        decode(a.ptype, 1, 'DATA MOVEMENT'),
        null,
        decode(bitand(a.FLAG,1),1,'NO',0,'YES'),
        decode(bitand(a.FLAG,64),0,'NO',64,'YES')
  from sys.ilm$ a  
 where a.owner#   = userenv('SCHEMAID')
   and bitand(a.flag,8)     = 0
union
/* Select tablespace level policies in tablespaces where the user has some
 * quota
 */ 
select a.name,
       decode(a.ptype, 1, 'DATA MOVEMENT'),
       b.name,
       decode(bitand(a.FLAG,1),1,'NO',0,'YES'),
       decode(bitand(a.FLAG,64),0,'NO',64,'YES')
  from sys.ilm$ a, 
       sys.ts$  b,
       sys.tsq$ c 
 where bitand(a.flag, 8) = 8 
   and  a.ts#    = b.ts#
   and  b.ts#    = c.ts#
   and  c.user# = userenv('SCHEMAID') 
   and (c.blocks > 0 or c.maxblocks != 0)
union
/* Select tablespace level policies in case the use has unlimited 
 * tablespace privileges
 */
select a.name,
       decode(a.ptype, 1, 'DATA MOVEMENT'),
       b.name,
       decode(bitand(a.FLAG,1),1,'NO',0,'YES'),
       decode(bitand(a.FLAG,64),0,'NO',64,'YES')
  from sys.ilm$ a,
       sys.ts$  b 
 where bitand(a.flag,8) = 8
   and a.ts# = b.ts#
   and exists
      (select null
         from sys.v$enabledprivs
        where priv_number = -15 /* UNLIMITED TABLESPACE */)  
/
comment on table USER_ILMPOLICIES is
 'ILM policies owned by the user'
/
comment on column USER_ILMPOLICIES.POLICY_NAME is
 'Name of the policy'
/
comment on column USER_ILMPOLICIES.POLICY_TYPE is
 'Type of the policy'
/
comment on column USER_ILMPOLICIES.TABLESPACE is 
 'Tablespace name in case of tablespace level policy'
/
comment on column USER_ILMPOLICIES.ENABLED is
 'Is the policy enabled?'
/
grant read on USER_ILMPOLICIES to public
/
create or replace public synonym user_ilmpolicies for sys.user_ilmpolicies
/

/* Properties of data movement related ILM policies applicable to user 
 * objects
 */ 

create or replace view USER_ILMDATAMOVEMENTPOLICIES 
(POLICY_NAME, ACTION_TYPE, SCOPE, COMPRESSION_LEVEL, TIER_TABLESPACE,
 TIER_STATUS, CONDITION_TYPE, CONDITION_DAYS, CUSTOM_FUNCTION,
 POLICY_SUBTYPE, ACTION_CLAUSE, TIER_TO)
as 
select a.name, 
       decode(b.action, 1, 'COMPRESSION', 2, 'STORAGE', 3, 'TIER',
                        4, 'EVICT', 5, 'ANNOTATE'),
       decode(b.scope, 1,'SEGMENT',2,'GROUP',3,'ROW'),
       decode(b.ctype, 2, 'ADVANCED', 
                       3, (CASE 
                           WHEN b.clevel = 1 and bitand(b.flag,32) = 0
                                  THEN 'QUERY LOW'
                           WHEN b.clevel = 2 and bitand(b.flag,32) = 0
                                  THEN 'QUERY HIGH' 
                           WHEN b.clevel = 3 and bitand(b.flag,32) = 0
                                  THEN 'ARCHIVE LOW'
                           WHEN b.clevel = 4 and bitand (b.flag,32) = 0
                                  THEN 'ARCHIVE HIGH'
                           WHEN b.clevel = 1 and bitand(b.flag,32)  = 32
                                  THEN 'QUERY LOW ROW LEVEL LOCKING'
                           WHEN b.clevel = 2 and bitand(b.flag,32)  = 32
                                  THEN 'QUERY HIGH ROW LEVEL LOCKING' 
                           WHEN b.clevel = 3 and bitand(b.flag,32)  = 32
                                  THEN 'ARCHIVE LOW ROW LEVEL LOCKING'
                           WHEN b.clevel = 4 and bitand (b.flag,32) = 32
                                  THEN 'ARCHIVE HIGH ROW LEVEL LOCKING'
                           END),
                      (CASE 
                       WHEN b.pol_subtype = 1 and b.ctype = 2
                            THEN 'NO MEMCOMPRESS'
                       WHEN b.pol_subtype = 1 and b.ctype = 8
                            THEN 'MEMCOMPRESS FOR DML'
                       WHEN b.pol_subtype = 1 and b.ctype = 10
                            THEN 'MEMCOMPRESS FOR QUERY LOW'
                       WHEN b.pol_subtype = 1 and b.ctype = 64
                            THEN 'MEMCOMPRESS FOR QUERY HIGH'
                       WHEN b.pol_subtype = 1 and b.ctype = 66
                            THEN 'MEMCOMPRESS FOR CAPACITY LOW'
                       WHEN b.pol_subtype = 1 and b.ctype = 72
                            THEN 'MEMCOMPRESS FOR CAPACITY HIGH'
                       END)),
       b.tier_tbs,
       decode(b.flag, 1, 'READ ONLY'),
       CASE 
       WHEN bitand(b.flag, 8) = 8 THEN 'USER DEFINED'
       WHEN b.action = 2 and  bitand(b.flag, 1) <> 1 THEN null
       ELSE 
       decode(b.condition, 0, 'LAST ACCESS TIME', 1,'LOW ACCESS', 
                           2,'LAST MODIFICATION TIME', 3,'CREATION TIME', 
                           5, 'VALID TIME END')
       END,
       b.days,
       b.custfunc,
       decode(b.pol_subtype, 0, 'DISK', 1, 'INMEMORY', 2, 'CELLMEMORY'),
       CASE
       WHEN b.pol_subtype = 1 and  b.action = 4 THEN
       to_clob('no inmemory')
       else
       b.actionc_clob
       END,
       decode(b.tier_to, 0, 'TABLESPACE', 1, 'INMEMORY', 2, 'CELLMEMORY')
  from sys.ilm$ a, sys.ilmpolicy$ b,
       (select a.policy# 
          from sys.ilm$ a
         where bitand(a.flag, 8) = 0
           and a.owner# = userenv('SCHEMAID')
        union
        select a.policy#
          from sys.ilm$ a , 
               sys.ts$  b,
               sys.tsq$ c 
        where  bitand(a.flag, 8) = 8
          and  a.ts#    = b.ts#
          and  b.ts#    = c.ts#
          and  c.user# = userenv('SCHEMAID') 
          and (c.blocks > 0 or c.maxblocks != 0)
        union     
         select a.policy#
          from sys.ilm$ a  
        where  bitand(a.flag, 8) = 8
          and  exists
         (select null
            from sys.v$enabledprivs
           where priv_number = -15 /* UNLIMITED TABLESPACE */)) c  
 where a.policy# = b.policy# 
   and a.policy# = c.policy#
/
comment on table USER_ILMDATAMOVEMENTPOLICIES is
 'Data movement related policies for a user'
/
comment on column USER_ILMDATAMOVEMENTPOLICIES.POLICY_NAME is
 'Name of the policy'
/
comment on column USER_ILMDATAMOVEMENTPOLICIES.ACTION_TYPE is
 'Type of the action executed by the policy'
/
comment on column USER_ILMDATAMOVEMENTPOLICIES.SCOPE is
 'Scope of the policy'
/
comment on column USER_ILMDATAMOVEMENTPOLICIES.COMPRESSION_LEVEL is
 'Compression level for the object'
/
comment on column USER_ILMDATAMOVEMENTPOLICIES.CONDITION_TYPE is
 'Column on which the policy is based'
/
comment on column USER_ILMDATAMOVEMENTPOLICIES.CONDITION_DAYS is
 'Value associated with the condition specified in days'
/
comment on column USER_ILMDATAMOVEMENTPOLICIES.CUSTOM_FUNCTION is
 'Optional function that evaluates the precondition on the policy '
/
comment on column USER_ILMDATAMOVEMENTPOLICIES.POLICY_SUBTYPE is
 'Storage tier on which the policy is specified'
/
comment on column USER_ILMDATAMOVEMENTPOLICIES.ACTION_CLAUSE is
 'Text of the action executed by the policy'
/
comment on column USER_ILMDATAMOVEMENTPOLICIES.TIER_TO is
 'Storage tier where the data is placed after the policy is executed'
/
grant read on USER_ILMDATAMOVEMENTPOLICIES to public
/
create or replace public synonym USER_ILMDATAMOVEMENTPOLICIES
for SYS.USER_ILMDATAMOVEMENTPOLICIES
/

/*
 * View all the objects and policies for a user. Many objects inherit 
 * policies via their parent objects. This view shows all the policies and 
 * the objects affected by the policies and indicates whether the policy is 
 * inherited by an object or is directly specified on it.
 */

create or replace view USER_ILMOBJECTS 
(POLICY_NAME, OBJECT_OWNER, OBJECT_NAME, SUBOBJECT_NAME, OBJECT_TYPE, 
 INHERITED_FROM, TBS_INHERITED_FROM, ENABLED, DELETED)
as 
/* 
 * Selects all <object,policy> information for policies on all objects.
 */
select a.name, d.name, c.name, c.subname, 
       DECODE(c.type#,19, 'TABLE PARTITION',
                      2,'TABLE',
                      34,'TABLE SUBPARTITION'), 
       (CASE 
        WHEN bitand(a.FLAG,8) = 8 
             THEN 'TABLESPACE'
        WHEN (b.obj_typ <> b.obj_typ_orig AND b.obj_typ_orig = 2) 
             THEN 'TABLE'
        WHEN (b.obj_typ <> b.obj_typ_orig AND b.obj_typ_orig = 19) 
             THEN 'TABLE PARTITION'
        ELSE 'POLICY NOT INHERITED'
        END),
       f.name,
       (CASE
        WHEN (bitand(b.FLAG,1)    = 1) 
             THEN 'NO'
        ELSE 'YES'
        END),
       (CASE
        WHEN (bitand(b.FLAG,64)    = 0)
             THEN 'NO'
        ELSE 'YES'
        END)
  from sys.ilm$ a, 
       sys.ilmobj$ b, 
       sys.obj$ c, 
       sys.user$ d,
       (select a.policy# 
          from sys.ilm$ a
         where bitand(a.flag, 8) = 0
           and a.owner# = userenv('SCHEMAID')
        union
        select a.policy#
          from sys.ilm$ a , 
               sys.ts$  b,
               sys.tsq$ c 
        where  bitand(a.flag, 8) = 8
          and  a.ts#    = b.ts#
          and  b.ts#    = c.ts#
          and  c.user# = userenv('SCHEMAID') 
          and (c.blocks > 0 or c.maxblocks != 0)
        union     
         select a.policy#
          from sys.ilm$ a  
        where  bitand(a.flag, 8) = 8
          and  exists
         (select null
            from sys.v$enabledprivs
           where priv_number = -15 /* UNLIMITED TABLESPACE */)) e,
       sys.ts$ f
 where a.policy# = b.policy#
   AND b.obj#    = c.obj#
   AND c.owner#  = d.user#  
   AND a.policy# = e.policy#
   AND c.name not like 'REDEF$%'
   AND c.name not like 'MLOG$%'
   AND f.ts# (+) = a.ts#
/
comment on table USER_ILMOBJECTS is 
 'Policies and the objects they affect for a user'
/
comment on column USER_ILMOBJECTS.POLICY_NAME is
 'Name of the policy'
/
comment on column USER_ILMOBJECTS.OBJECT_NAME is
 'Name of the object'
/
comment on column USER_ILMOBJECTS.SUBOBJECT_NAME is
 'Name of the subobject'
/
comment on column USER_ILMOBJECTS.OBJECT_TYPE is
 'Type of the object'
/
comment on column USER_ILMOBJECTS.INHERITED_FROM is
 'Is the policy inherited? If so from where?'
/
comment on column USER_ILMOBJECTS.TBS_INHERITED_FROM is
 'If this tablespace policy is inherited, from which tablespace?'
/

comment on column USER_ILMOBJECTS.ENABLED is
 'Is the policy enabled on the object?'
/

grant read on USER_ILMOBJECTS to public
/
create or replace public synonym USER_ILMOBJECTS 
for SYS.USER_ILMOBJECTS
/

/* Details regarding ILM execution for a user */

create or replace view USER_ILMTASKS
(TASK_ID, STATE, CREATION_TIME, START_TIME, COMPLETION_TIME)
AS
SELECT a.execution_id, 
       DECODE(a.execution_state, 1, 'INACTIVE',
                                 2, 'ACTIVE', 
                                 3, 'COMPLETED',
                                 'UNKNOWN'),
       a.creation_time, 
       a.start_time,
       a.completion_time
  FROM sys.ilm_execution$ a
 WHERE a.owner = userenv('SCHEMAID')
/
comment on table USER_ILMTASKS is 
 'Information on ILM execution for a user'
/
comment on column USER_ILMTASKS.TASK_ID is 
 'Number that uniquely identifies a specific ILM task'
/
comment on column USER_ILMTASKS.STATE is
 'State of the ILM task'
/
comment on column USER_ILMTASKS.CREATION_TIME is
 'Creation time of the ILM task'
/
comment on column USER_ILMTASKS.START_TIME is 
 'Time of start of a specific ILM task'
/
comment on column USER_ILMTASKS.COMPLETION_TIME is 
 'Time of completion of ILM task'
/

GRANT read ON USER_ILMTASKS TO public
/
create or replace public synonym USER_ILMTASKS
for SYS.USER_ILMTASKS
/

/* 
 * Details on policies considered for a particular execution. Also shows
 * the jobname that executes the policy in case the policy was selected for 
 * execution and reason in case the policy was not selected for execution. 
 */

create or replace view USER_ILMEVALUATIONDETAILS
(TASK_ID, POLICY_NAME, OBJECT_OWNER, OBJECT_NAME, SUBOBJECT_NAME, 
OBJECT_TYPE, SELECTED_FOR_EXECUTION, JOB_NAME, COMMENTS)
AS
SELECT b.execution_id, a.name , e.name, c.name , c.subname,
       DECODE(c.type#,19, 'TABLE PARTITION',
                      2,'TABLE',
                      34,'TABLE SUBPARTITION'),
       DECODE(b.jobscheduled, 0, 'SELECTED FOR EXECUTION',
                              1, 'POLICY DISABLED', 
                              2, 'SELECTED FOR EXECUTION',
                              3, 'SELECTED FOR EXECUTION',
                              4, 'POLICY OVERRULED',
                              5, 'INHERITED POLICY OVERRULED', 
                              6, 'PRECONDITION NOT SATISFIED', 
                              7, 'JOB ALREADY EXISTS',
                              8, 'POLICY SUCCESSFUL PREVIOUSLY',
                              9, 'NO OPERATION SINCE LAST ILM ACTION',
                              10, 'TARGET COMPRESSION NOT HIGHER THAN CURRENT',
                              11, 'ILM ONLY RECENTLY EVALUATED ON OBJECT',
                              12, 'STATISTICS NOT AVAILABLE',
                              13, 'TABLE HAS MATERIALIZED VIEW',  
                              14, 'IM ATTRIBUTE ALREADY SET',
                              15, 'IM ATTRIBUTE NOT SET',
                                  'NO'),
       b.jobname, b.comments 
  FROM sys.ilm$ a, 
       sys.ilm_executiondetails$ b, 
       sys.obj$ c, 
       sys.ilm_execution$ d, 
       sys.user$ e
 WHERE a.policy#    = b.policy#
   AND b.obj#         = c.obj#
   AND b.execution_id = d.execution_id
   AND d.owner        = userenv('SCHEMAID')
   AND c.owner#       = e.user#
/
comment on table USER_ILMEVALUATIONDETAILS is 
 'Details on policies considered for a particular task'
/
comment on column USER_ILMEVALUATIONDETAILS.TASK_ID is 
 'Number that uniquely identifies a specific ILM task'
/
comment on column USER_ILMEVALUATIONDETAILS.POLICY_NAME is 
 'Name of the policy'
/
comment on column USER_ILMEVALUATIONDETAILS.OBJECT_NAME is 
 'Name of the object'
/
comment on column USER_ILMEVALUATIONDETAILS.SUBOBJECT_NAME is 
 'Name of the subobject'
/
comment on column USER_ILMEVALUATIONDETAILS.OBJECT_TYPE is 
 'Type of the object'
/
comment on column USER_ILMEVALUATIONDETAILS.SELECTED_FOR_EXECUTION is 
 'Has the object been selected for execution?'
/
comment on column USER_ILMEVALUATIONDETAILS.JOB_NAME is 
 'Job name for executing the policy on the object if selected for execution'
/
comment on column USER_ILMEVALUATIONDETAILS.COMMENTS is 
 'More information if a policy is not selected for execution on an object'
/

grant read on USER_ILMEVALUATIONDETAILS to public
/

create or replace public synonym USER_ILMEVALUATIONDETAILS 
for SYS.USER_ILMEVALUATIONDETAILS
/

/* Information on jobs created for policies owned by a user.*/

create or replace view USER_ILMRESULTS
(TASK_ID, 
 JOB_NAME, 
 JOB_STATE, 
 START_TIME,
 COMPLETION_TIME, 
 COMMENTS,
 STATISTICS)
AS
SELECT a.execution_id, a.jobname,
       DECODE(a.job_status, 1,'JOB CREATED', 
                            2, 'COMPLETED SUCCESSFULLY', 
                            3, 'FAILED', 
                            4, 'STOPPED', 
                            5, 'JOB CREATION FAILED', 
                            6, 'JOB SCHEDULED', 
                            7, 'JOB DISABLED', 
                            8, 'JOB RUNNING',
                           10, 'DEPENDANT OBJECTS BEING REBUILT',
                           11, 'FAILED TO REBUILD DEPENDANT OBJECTS',
                           12, 'CREATING JOB',
                           13, 'JOB TO BE CREATED',
                               'NOT KNOWN'), 
       a.start_time,
       a.completion_time,
       a.comments,
       a.statistics
  FROM sys.ilm_results$ a, sys.ilm_execution$ b
 WHERE a.execution_id = b.execution_id
   AND b.owner          = userenv('SCHEMAID')
/

comment on table USER_ILMRESULTS is
 'Information on jobs created for a user'
/
comment on column USER_ILMRESULTS.TASK_ID is 
 'Number that uniquely identifies a specific ILM execution'
/
comment on column USER_ILMRESULTS.JOB_NAME is 
 'Job name for executing policies'
/
comment on column USER_ILMRESULTS.JOB_STATE is 
 'State of the Job'
/
comment on column USER_ILMRESULTS.START_TIME is 
 'Time of start of the job'
/
comment on column USER_ILMRESULTS.COMPLETION_TIME is 
 'Time of completion of the job'
/
comment on column USER_ILMRESULTS.COMMENTS is 
 'More information if the job failed'
/
comment on column USER_ILMRESULTS.STATISTICS is 
 'ILM job related statistics'
/

grant read on USER_ILMRESULTS to public
/

create or replace public SYNONYM USER_ILMRESULTS for SYS.USER_ILMRESULTS
/

/* ILM policies in the database*/

create or replace view DBA_ILMPOLICIES
(POLICY_NAME, 
 POLICY_TYPE, 
 TABLESPACE, 
 ENABLED,
 DELETED)
as 
select  a.name,
        decode(ptype, 1, 'DATA MOVEMENT'),
        null, 
        decode(bitand(FLAG,1),1,'NO',0,'YES'), 
        decode(bitand(FLAG,64),0,'NO',64,'YES')
  from sys.ilm$ a, sys.user$ b
 where a.owner# = b.user#  
   and bitand(a.flag, 8)   = 0
union
select  a.name,
        decode(ptype, 1, 'DATA MOVEMENT'),
        c.name, 
        decode(bitand(FLAG,1),1,'NO',0,'YES'),
        decode(bitand(FLAG,64),0,'NO',64,'YES')
  from sys.ilm$ a, sys.user$ b, sys.ts$ c
 where a.owner# = b.user#  
   and a.ts#    = c.ts#
   and bitand(a.flag, 8) = 8
/
comment on table DBA_ILMPOLICIES is
 'ILM policies in the database'
/
comment on column DBA_ILMPOLICIES.POLICY_NAME is
 'Name of the policy'
/
comment on column DBA_ILMPOLICIES.POLICY_TYPE is
 'Type of the policy'
/
comment on column DBA_ILMPOLICIES.ENABLED is
 'Is the policy enabled?'
/
grant select on DBA_ILMPOLICIES to select_catalog_role
/
create or replace public synonym dba_ilmpolicies for sys.dba_ilmpolicies
/


execute CDBView.create_cdbview(false,'SYS','DBA_ILMPOLICIES','CDB_ILMPOLICIES');
grant select on SYS.CDB_ILMPOLICIES to select_catalog_role
/
create or replace public synonym CDB_ILMPOLICIES for SYS.CDB_ILMPOLICIES
/

/* Properties of data movement related ILM policies*/ 

create or replace view DBA_ILMDATAMOVEMENTPOLICIES 
(POLICY_NAME,
 ACTION_TYPE, 
 SCOPE, 
 COMPRESSION_LEVEL,
 TIER_TABLESPACE, 
 TIER_STATUS, 
 CONDITION_TYPE, 
 CONDITION_DAYS, 
 CUSTOM_FUNCTION,
 POLICY_SUBTYPE,
 ACTION_CLAUSE,
 TIER_TO)
as 
select a.name, 
       decode(b.action, 1, 'COMPRESSION', 2, 'STORAGE', 3, 'TIER',
                        4, 'EVICT', 5, 'ANNOTATE'),
       decode(b.scope, 1,'SEGMENT',2,'GROUP',3,'ROW'),
       decode(b.ctype, 2, 'ADVANCED', 
                       3, (CASE 
                           WHEN b.clevel = 1 and bitand(b.flag,32) = 0
                                  THEN 'QUERY LOW'
                           WHEN b.clevel = 2 and bitand(b.flag,32) = 0
                                  THEN 'QUERY HIGH' 
                           WHEN b.clevel = 3 and bitand(b.flag,32) = 0
                                  THEN 'ARCHIVE LOW'
                           WHEN b.clevel = 4 and bitand (b.flag,32) = 0
                                  THEN 'ARCHIVE HIGH'
                           WHEN b.clevel = 1 and bitand(b.flag,32)  = 32
                                  THEN 'QUERY LOW ROW LEVEL LOCKING'
                           WHEN b.clevel = 2 and bitand(b.flag,32)  = 32
                                  THEN 'QUERY HIGH ROW LEVEL LOCKING' 
                           WHEN b.clevel = 3 and bitand(b.flag,32)  = 32
                                  THEN 'ARCHIVE LOW ROW LEVEL LOCKING'
                           WHEN b.clevel = 4 and bitand (b.flag,32) = 32
                                  THEN 'ARCHIVE HIGH ROW LEVEL LOCKING'
                           END),
                      (CASE 
                       WHEN b.pol_subtype = 1 and b.ctype = 2
                            THEN 'NO MEMCOMPRESS'
                       WHEN b.pol_subtype = 1 and b.ctype = 8
                            THEN 'MEMCOMPRESS FOR DML'
                       WHEN b.pol_subtype = 1 and b.ctype = 10
                            THEN 'MEMCOMPRESS FOR QUERY LOW'
                       WHEN b.pol_subtype = 1 and b.ctype = 64
                            THEN 'MEMCOMPRESS FOR QUERY HIGH'
                       WHEN b.pol_subtype = 1 and b.ctype = 66
                            THEN 'MEMCOMPRESS FOR CAPACITY LOW'
                       WHEN b.pol_subtype = 1 and b.ctype = 72
                            THEN 'MEMCOMPRESS FOR CAPACITY HIGH'
                       END)),
       b.tier_tbs,
       decode(b.flag, 1, 'READ ONLY'),
       CASE
       WHEN bitand(b.flag, 8) = 8 THEN 'USER DEFINED'
       WHEN b.action = 2 and  bitand(b.flag, 1) <> 1 THEN null
       ELSE
       decode(b.condition, 0, 'LAST ACCESS TIME', 1,'LOW ACCESS', 
                           2,'LAST MODIFICATION TIME', 3,'CREATION TIME', 
                           5, 'VALID TIME END')
       END,
       b.days,
       b.custfunc,
       decode(b.pol_subtype, 0, 'DISK', 1, 'INMEMORY', 2, 'CELLMEMORY'),
       CASE
       WHEN b.pol_subtype = 1 and  b.action = 4 THEN
       to_clob('no inmemory')
       else
       b.actionc_clob
       END,
       decode(b.tier_to, 0, 'TABLESPACE', 1, 'INMEMORY', 2, 'CELLMEMORY')
  from sys.ilm$ a, sys.ilmpolicy$ b
 where a.policy# = b.policy# 
/
comment on table DBA_ILMDATAMOVEMENTPOLICIES is
 'Data movement related policies in database'
/
comment on column DBA_ILMDATAMOVEMENTPOLICIES.POLICY_NAME is
 'Name of the policy'
/
comment on column DBA_ILMDATAMOVEMENTPOLICIES.ACTION_TYPE is
 'Type of the action executed by the policy'
/
comment on column DBA_ILMDATAMOVEMENTPOLICIES.SCOPE is
 'Scope of the policy'
/
comment on column DBA_ILMDATAMOVEMENTPOLICIES.COMPRESSION_LEVEL is
 'Compression level for the object'
/
comment on column DBA_ILMDATAMOVEMENTPOLICIES.TIER_TABLESPACE is
 'Tablespace to move the object to in case of storage tiering policy'
/
comment on column DBA_ILMDATAMOVEMENTPOLICIES.CONDITION_TYPE is
 'Column on which the policy is based'
/
comment on column DBA_ILMDATAMOVEMENTPOLICIES.CONDITION_DAYS is
 'Value associated with the condition specified in days'
/
comment on column DBA_ILMDATAMOVEMENTPOLICIES.CUSTOM_FUNCTION is
 'Optional function that evaluates the precondition on the policy '
/
comment on column DBA_ILMDATAMOVEMENTPOLICIES.POLICY_SUBTYPE is
 'Storage tier on which the policy is specified'
/
comment on column DBA_ILMDATAMOVEMENTPOLICIES.ACTION_CLAUSE is
 'Text of the action executed by the policy'
/
comment on column DBA_ILMDATAMOVEMENTPOLICIES.TIER_TO is
 'Storage tier where the data is placed after the policy is executed'
/
grant select on DBA_ILMDATAMOVEMENTPOLICIES to select_catalog_role
/
create or replace public synonym DBA_ILMDATAMOVEMENTPOLICIES
for SYS.DBA_ILMDATAMOVEMENTPOLICIES
/



execute CDBView.create_cdbview(false,'SYS','DBA_ILMDATAMOVEMENTPOLICIES','CDB_ILMDATAMOVEMENTPOLICIES');
grant select on SYS.CDB_ILMDATAMOVEMENTPOLICIES to select_catalog_role
/
create or replace public synonym CDB_ILMDATAMOVEMENTPOLICIES for SYS.CDB_ILMDATAMOVEMENTPOLICIES
/

/*
 * View all the objects and policies in the database. Many objects inherit 
 * policies via their parent objects. This view shows all the policies and 
 * the objects affected by the policies and indicates whether the policy is 
 * inherited by an object or is directly specified on it.
 */

create or replace view DBA_ILMOBJECTS 
(POLICY_NAME, OBJECT_OWNER, OBJECT_NAME, SUBOBJECT_NAME, 
 OBJECT_TYPE, INHERITED_FROM, TBS_INHERITED_FROM, ENABLED, DELETED)
as 
/* 
 * Selects all <object,policy> information for policies on all objects.
 */
select a.name, e.name, c.name, c.subname,
       DECODE(c.type#,19, 'TABLE PARTITION',
                      2,'TABLE',
                      34,'TABLE SUBPARTITION'), 
       (CASE 
        WHEN bitand(a.FLAG,8) = 8 
             THEN 'TABLESPACE'
        WHEN (b.obj_typ <> b.obj_typ_orig AND b.obj_typ_orig = 2) 
             THEN 'TABLE'
        WHEN (b.obj_typ <> b.obj_typ_orig AND b.obj_typ_orig = 19) 
             THEN 'TABLE PARTITION'
        ELSE 'POLICY NOT INHERITED'
        END),
       f.name, 
       (CASE
        WHEN (bitand(b.FLAG,1)    = 1) 
             THEN 'NO'
        ELSE 'YES'
        END),
       (CASE
        WHEN (bitand(b.FLAG,64)    = 0)
             THEN 'NO'
        ELSE 'YES'
        END)
  from sys.ilm$ a, 
       sys.ilmobj$ b, 
       sys.obj$ c, 
       sys.user$ e,
       sys.ts$ f
 where a.policy# = b.policy#
   AND b.obj#    = c.obj#  
   AND c.owner#  = e.user#
   and c.name not like 'REDEF$%'
   and c.name not like 'MLOG$%'
   and f.ts# (+) = a.ts#
/
comment on table DBA_ILMOBJECTS is 
 'Policies and the objects they affect in the database'
/
comment on column DBA_ILMOBJECTS.POLICY_NAME is
 'Name of the policy'
/
comment on column DBA_ILMOBJECTS.OBJECT_OWNER is
 'Owner of the object'
/
comment on column DBA_ILMOBJECTS.OBJECT_NAME is
 'Name of the object'
/
comment on column DBA_ILMOBJECTS.SUBOBJECT_NAME is
 'Name of the subobject'
/
comment on column DBA_ILMOBJECTS.OBJECT_TYPE is
 'Type of the object'
/
comment on column DBA_ILMOBJECTS.INHERITED_FROM is
 'Is the policy inherited? If so from where?'
/
comment on column DBA_ILMOBJECTS.TBS_INHERITED_FROM is
 'If this tablespace policy is inherited, from which tablespace?'
/

comment on column DBA_ILMOBJECTS.ENABLED is
 'Is the policy enabled on the object?'
/


grant select on DBA_ILMOBJECTS to select_catalog_role
/
create or replace public synonym DBA_ILMOBJECTS 
for SYS.DBA_ILMOBJECTS
/


execute CDBView.create_cdbview(false,'SYS','DBA_ILMOBJECTS','CDB_ILMOBJECTS');
grant select on SYS.CDB_ILMOBJECTS to select_catalog_role
/
create or replace public synonym CDB_ILMOBJECTS for SYS.CDB_ILMOBJECTS
/

/* Details regarding ILM execution*/

create or replace view DBA_ILMTASKS
(TASK_ID, TASK_OWNER, STATE, CREATION_TIME, START_TIME, COMPLETION_TIME)
AS
SELECT a.execution_id, b.name, 
       DECODE(a.execution_state, 1, 'INACTIVE',
                                 2, 'ACTIVE', 
                                 3, 'COMPLETED',
                                 'UNKNOWN'),
       a.creation_time, 
       a.start_time,
       a.completion_time
  FROM sys.ilm_execution$ a, sys.user$ b
 where a.owner = b.user#
/
comment on table DBA_ILMTASKS is 
 'Information on ILM execution'
/
comment on column DBA_ILMTASKS.TASK_ID is 
 'Number that uniquely identifies a specific ILM execution'
/
comment on column DBA_ILMTASKS.TASK_OWNER is 
 'Owner of the specific ILM execution'
/
comment on column DBA_ILMTASKS.STATE is
 'State of the ILM task'
/
comment on column DBA_ILMTASKS.CREATION_TIME is
 'Creation time of the ILM task'
/
comment on column DBA_ILMTASKS.START_TIME is 
 'Time of start of a specific ILM execution'
/

GRANT SELECT ON DBA_ILMTASKS TO select_catalog_role
/
create or replace public synonym DBA_ILMTASKS 
for SYS.DBA_ILMTASKS
/


execute CDBView.create_cdbview(false,'SYS','DBA_ILMTASKS','CDB_ILMTASKS');
grant select on SYS.CDB_ILMTASKS to select_catalog_role
/
create or replace public synonym CDB_ILMTASKS for SYS.CDB_ILMTASKS
/

/* 
 * Details on policies considered for a particular execution. Also shows
 * the jobname that executes the policy in case the policy was selected for 
 * execution and reason in case the policy was not selected for execution. 
 */

create or replace view DBA_ILMEVALUATIONDETAILS
(TASK_ID, POLICY_NAME, OBJECT_OWNER, OBJECT_NAME, 
SUBOBJECT_NAME, OBJECT_TYPE, SELECTED_FOR_EXECUTION, JOB_NAME, 
COMMENTS)
AS
SELECT b.execution_id, a.name , f.name, c.name , c.subname,
       DECODE(c.type#,19, 'TABLE PARTITION',
                      2,  'TABLE',
                      34,'TABLE SUBPARTITION'),
       DECODE(b.jobscheduled, 0, 'SELECTED FOR EXECUTION',
                              1, 'POLICY DISABLED',
                              2, 'SELECTED FOR EXECUTION', 
                              3, 'SELECTED FOR EXECUTION', 
                              4, 'POLICY OVERRULED',
                              5, 'INHERITED POLICY OVERRULED', 
                              6, 'PRECONDITION NOT SATISFIED', 
                              7, 'JOB ALREADY EXISTS',
                              8, 'POLICY SUCCESSFUL PREVIOUSLY',
                              9, 'NO OPERATION SINCE LAST ILM ACTION',
                              10, 'TARGET COMPRESSION NOT HIGHER THAN CURRENT',
                              11, 'ILM ONLY RECENTLY EVALUATED ON OBJECT',
                              12, 'STATISTICS NOT AVAILABLE',
                              13, 'TABLE HAS MATERIALIZED VIEW', 
                              14, 'IM ATTRIBUTE ALREADY SET' ,
                              15, 'IM ATTRIBUTE NOT SET',
                                  'NO'),
       b.jobname, b.comments 
  FROM sys.ilm$ a, 
       sys.ilm_executiondetails$ b, 
       sys.obj$ c, 
       sys.ilm_execution$ d, 
       sys.user$ f
 WHERE a.policy#      = b.policy#
   AND b.obj#         = c.obj#
   AND b.execution_id = d.execution_id
   AND c.owner#       = f.user#
/
comment on table DBA_ILMEVALUATIONDETAILS is 
 'Details on policies considered for a particular execution'
/
comment on column DBA_ILMEVALUATIONDETAILS.TASK_ID is 
 'Number that uniquely identifies a specific ILM execution'
/
comment on column DBA_ILMEVALUATIONDETAILS.POLICY_NAME is 
 'Name of the policy'
/
comment on column DBA_ILMEVALUATIONDETAILS.OBJECT_OWNER is 
 'Owner of the object'
/
comment on column DBA_ILMEVALUATIONDETAILS.OBJECT_NAME is 
 'Name of the object'
/
comment on column DBA_ILMEVALUATIONDETAILS.SUBOBJECT_NAME is 
 'Name of the subobject'
/
comment on column DBA_ILMEVALUATIONDETAILS.OBJECT_TYPE is 
 'Type of the object'
/
comment on column DBA_ILMEVALUATIONDETAILS.SELECTED_FOR_EXECUTION is 
 'Has the object been selected for execution?'
/
comment on column DBA_ILMEVALUATIONDETAILS.JOB_NAME is 
 'Job name for executing the policy on the object if selected for execution'
/
comment on column DBA_ILMEVALUATIONDETAILS.COMMENTS is 
 'More information if a policy is not selected for execution on an object'
/

grant select on DBA_ILMEVALUATIONDETAILS to select_catalog_role
/

create or replace public synonym DBA_ILMEVALUATIONDETAILS 
for SYS.DBA_ILMEVALUATIONDETAILS
/


execute CDBView.create_cdbview(false,'SYS','DBA_ILMEVALUATIONDETAILS','CDB_ILMEVALUATIONDETAILS');
grant select on SYS.CDB_ILMEVALUATIONDETAILS to select_catalog_role
/
create or replace public synonym CDB_ILMEVALUATIONDETAILS for SYS.CDB_ILMEVALUATIONDETAILS
/

/* Information on ILM jobs created*/

create or replace view DBA_ILMRESULTS
(TASK_ID, 
 JOB_NAME, 
 JOB_STATE, 
 START_TIME,
 COMPLETION_TIME, 
 COMMENTS,
 STATISTICS)
AS
SELECT a.execution_id, a.jobname,
       DECODE(a.job_status, 1,'JOB CREATED', 
                            2, 'COMPLETED SUCCESSFULLY', 
                            3, 'FAILED', 
                            4, 'STOPPED', 
                            5, 'JOB CREATION FAILED', 
                            6, 'JOB SCHEDULED', 
                            7, 'JOB DISABLED', 
                            8, 'JOB RUNNING',
                           10, 'DEPENDANT OBJECTS BEING REBUILT',
                           11, 'FAILED TO REBUILD DEPENDANT OBJECTS',
                           12, 'CREATING JOB',
                           13,'JOB TO BE CREATED',
                               'NOT KNOWN'), 
       a.start_time,
       a.completion_time, 
       a.comments,
       a.statistics
  FROM sys.ilm_results$ a, 
       sys.ilm_execution$ b
 WHERE a.execution_id = b.execution_id
/

comment on table DBA_ILMRESULTS is
 'Information on ILM jobs'
/
comment on column DBA_ILMRESULTS.TASK_ID is 
 'Number that uniquely identifies a specific ILM task'
/
comment on column DBA_ILMRESULTS.JOB_NAME is 
 'Job name for executing policies'
/
comment on column DBA_ILMRESULTS.JOB_STATE is 
 'State of the Job'
/
comment on column DBA_ILMRESULTS.START_TIME is 
 'Time of start of the job'
/
comment on column DBA_ILMRESULTS.COMPLETION_TIME is 
 'Time of completion of the job'
/
comment on column DBA_ILMRESULTS.COMMENTS is 
 'More information if the job failed'
/
comment on column DBA_ILMRESULTS.STATISTICS is 
 'ILM job related statistics'
/

grant select on DBA_ILMRESULTS to select_catalog_role
/

create or replace public SYNONYM DBA_ILMRESULTS for SYS.DBA_ILMRESULTS
/


execute CDBView.create_cdbview(false,'SYS','DBA_ILMRESULTS','CDB_ILMRESULTS');
grant select on SYS.CDB_ILMRESULTS to select_catalog_role
/
create or replace public synonym CDB_ILMRESULTS for SYS.CDB_ILMRESULTS
/

/* Information on ILM environment parameters */

create or replace view DBA_ILMPARAMETERS 
(NAME, VALUE)
as
select param_name, param_value
  from ilm_param$
/
comment on table DBA_ILMPARAMETERS is
 'Describes ILM PARAMETERS in the database and their values'
/
comment on column DBA_ILMPARAMETERS.NAME is
 'Name of the ILM environment parameter'
/
comment on column DBA_ILMPARAMETERS.VALUE is
 'Name of the ILM environment parameter value'
/

grant select on DBA_ILMPARAMETERS to select_catalog_role
/

create or replace public SYNONYM DBA_ILMPARAMETERS for SYS.DBA_ILMPARAMETERS
/

execute CDBView.create_cdbview(false,'SYS','DBA_ILMPARAMETERS','CDB_ILMPARAMETERS');
grant select on SYS.CDB_ILMPARAMETERS to select_catalog_role
/
create or replace public synonym CDB_ILMPARAMETERS for SYS.CDB_ILMPARAMETERS
/

/* User visible views to access internal column level statistics tables.
 */

/* DBA_COL_USAGE_STATISTICS aggregates statistics for every column, object, 
   stat_type triplet value related to column usage across the on-disk entries
   and the in-memory entries.
 */
create or replace view DBA_COL_USAGE_STATISTICS
  (SEGMENT_NAME, SUBOBJECT_NAME, TABLE_OWNER, TABLESPACE_NAME, COLUMN_NAME,
   COLUMN_ID, STATISTIC_NAME, BEGIN_TRACK_TIME, END_TRACK_TIME,
   STATISTIC_VALUE_INT, STATISTIC_VALUE_STR) as
select o.name, p.subname, u.name, ts.name, c.name, s.colid,
       (case s.stat_type
           when 0 then 'In Memory'
           when 1 then 'Is Scanned'
           when 2 then 'Is Projected'
           when 3 then 'Is Modified'
           when 4 then 'Num Scans'
           when 5 then 'Num Projects'
           when 6 then 'Num Updates'
           when 7 then 'Used in Predicate'
        end) as stat_name,
       s.track_time, i.track_time,
       (case s.stat_type
           when 1 then (case when (s.stat_val_int=1) then 1
              else (case when (i.stat_val_int=1) then 1 else 0 end) end)
           when 2 then (case when (s.stat_val_int=1) then 1
              else (case when (i.stat_val_int=1) then 1 else 0 end) end)
           when 3 then (case when (s.stat_val_int=1) then 1
              else (case when (i.stat_val_int=1) then 1 else 0 end) end)
           when 4 then (s.stat_val_int + i.stat_val_int)
           when 5 then (s.stat_val_int + i.stat_val_int)
           when 6 then (s.stat_val_int + i.stat_val_int)
           when 7 then (case when (s.stat_val_int=1) then 1
          else (case when (i.stat_val_int=1) then 1 else 0 end) end)
        end) as stat_val_int, s.stat_val_str
from COLUMN_STAT$ s, GV$COLUMN_STATISTICS i, USER$ u, 
(select obj#, name, subname, owner# from obj$ where name in (select distinct (o.name) from 
 obj$ o, COLUMN_STAT$ s where s.obj#=o.obj#) and type#=2) o, obj$ p,
COL$ c, TS$ ts
where s.obj#=i.obj# and
o.owner#=u.user# and
o.owner#=p.owner# and
p.obj# = s.obj# and
p.name = o.name and
c.obj#=o.obj# and
c.col#=s.colid and
s.ts#=ts.ts# and
s.colid=i.colid and
s.stat_type = i.stat_type and
s.stat_type in (0,1,2,3,4,5,6,7)
union
select o.name, p.subname, u.name, ts.name, c.name, s.colid,
        (case s.stat_type
           when 0 then 'In Memory'
           when 1 then 'Is Scanned'
           when 2 then 'Is Projected'
           when 3 then 'Is Modified'
           when 4 then 'Num Scans'
           when 5 then 'Num Projects'
           when 6 then 'Num Updates'
           when 7 then 'Used in Predicate'
        end) as stat_name,
       s.track_time, s.track_time, s.stat_val_int,s.stat_val_str
from COLUMN_STAT$ s, 
(select obj#, name, subname, owner# from obj$ where name in (select distinct (o.name) from 
 obj$ o, COLUMN_STAT$ s where s.obj#=o.obj#) and type#=2) o, obj$ p,
user$ u, ts$ ts, col$ c
where o.owner#=u.user# and
o.owner#=p.owner# and
p.obj# = s.obj# and
p.name = o.name and
c.obj#=o.obj# and
c.col#=s.colid and
s.ts#=ts.ts# and
s.stat_type in (0,1,2,3,4,5,6,7) and
(s.obj#, s.colid, s.stat_type) not in
          (select obj#, colid, stat_type from GV$COLUMN_STATISTICS)
union
select o.name, p.subname, u.name, ts.name, c.name, s.colid,
        (case s.stat_type
           when 0 then 'In Memory'
           when 1 then 'Is Scanned'
           when 2 then 'Is Projected'
           when 3 then 'Is Modified'
           when 4 then 'Num Scans'
           when 5 then 'Num Projects'
           when 6 then 'Num Updates'
           when 7 then 'Used in Predicate'
        end) as stat_name,
       s.track_time, s.track_time, s.stat_val_int,s.stat_val_str
from GV$COLUMN_STATISTICS s, 
(select obj#, name, owner# from obj$ where name in (select distinct (o.name) from 
 obj$ o, gv$column_statistics s where s.obj#=o.obj#) and type#=2) o, obj$ p,
user$ u, ts$ ts, col$ c
where o.owner#=u.user# and
o.owner#=p.owner# and
p.obj# = s.obj# and
p.name = o.name and
c.obj#=o.obj# and
c.col#=s.colid and
s.ts#=ts.ts# and
s.stat_type in (0,1,2,3,4,5,6,7) and
(s.obj#, s.colid, s.stat_type) not in
          (select obj#, colid, stat_type from COLUMN_STAT$)
/

create or replace public synonym DBA_COL_USAGE_STATISTICS
for sys.DBA_COL_USAGE_STATISTICS
/
grant read on DBA_COL_USAGE_STATISTICS to PUBLIC with grant option
/

execute CDBView.create_cdbview(false,'SYS','DBA_COL_USAGE_STATISTICS','CDB_COL_USAGE_STATISTICS');
grant read on SYS.CDB_COL_USAGE_STATISTICS to PUBLIC with grant option
/

create or replace public synonym CDB_COL_USAGE_STATISTICS for SYS.CDB_COL_USAGE_STATISTICS
/

/* Internal view that the AIM feature uses to get information on heat map
 * access. This view shows information only for in-memory enabled objects
 */
create or replace view "_SYS_AIM_SEG_HISTOGRAM"
    (OBJ#, DATAOBJ#, TS#, TRACK_TIME, SEGMENT_WRITE, SEGMENT_READ, FULL_SCAN,
     LOOKUP_SCAN, N_FTS, N_LOOKUP, N_WRITE)
as
   select s.obj#, s.dataobj#, s.ts#, s.track_time,
          decode(bitand(s.segment_access, 1), 1, 'YES', 'NO'),
          decode(bitand(s.segment_access, 2), 2, 'YES', 'NO'),
          decode(bitand(s.segment_access, 4), 4, 'YES', 'NO'),
          decode(bitand(s.segment_access, 8), 8, 'YES', 'NO'),
          s.n_fts, s.n_lookup, s.n_write
    from heat_map_stat$ s,
         tab$ t,
         seg$ se
   where t.obj# = s.obj#
     and t.dataobj# = s.dataobj#
     and se.hwmincr = t.dataobj#
/* in-memory enabled */
     and bitand(se.spare1,  4294967296) = 4294967296  
     and s.OBJ# != -1
union
    select s.obj#, s.dataobj#, s.ts#, s.track_time,
          decode(bitand(s.segment_access, 1), 1, 'YES', 'NO'),
          decode(bitand(s.segment_access, 2), 2, 'YES', 'NO'),
          decode(bitand(s.segment_access, 4), 4, 'YES', 'NO'),
          decode(bitand(s.segment_access, 8), 8, 'YES', 'NO'),
          s.n_fts, s.n_lookup, s.n_write
    from heat_map_stat$ s,
         tabpart$ t,
         seg$ se
   where t.obj# = s.obj#
     and t.dataobj# = s.dataobj#
     and se.hwmincr = t.dataobj#
/* in-memory enabled */
     and bitand(se.spare1,  4294967296) = 4294967296  
     and s.OBJ# != -1
union
    select s.obj#, s.dataobj#, s.ts#, s.track_time,
          decode(bitand(s.segment_access, 1), 1, 'YES', 'NO'),
          decode(bitand(s.segment_access, 2), 2, 'YES', 'NO'),
          decode(bitand(s.segment_access, 4), 4, 'YES', 'NO'),
          decode(bitand(s.segment_access, 8), 8, 'YES', 'NO'),
          s.n_fts, s.n_lookup, s.n_write
    from heat_map_stat$ s,
         tabsubpart$ t,
         seg$ se
   where t.obj# = s.obj#
     and t.dataobj# = s.dataobj#
     and se.hwmincr = t.dataobj#
/* in-memory enabled */
     and bitand(se.spare1,  4294967296) = 4294967296  
     and s.OBJ# != -1
union
   select obj#, dataobj#, ts#, track_time,
          segment_write, segment_read, full_scan, lookup_scan,
          n_full_scan, n_lookup_scan, n_segment_write
     from
         GV$IMHMSEG
     where
       (segment_write = 'YES' OR lookup_scan = 'YES' OR full_scan = 'YES') AND
       con_id = SYS_CONTEXT('USERENV', 'CON_ID')
/

GRANT SELECT ON SYS."_SYS_AIM_SEG_HISTOGRAM" TO select_catalog_role
/

/* Internal view for details regarding Automatic In-memory Management tasks*/

create or replace view "_INMEMORY_AIMTASKS" 
(TASK_ID, CREATION_TIME, TASK_TYPE, STATE)
AS 
SELECT 
       TASK_ID,
       CREATION_TIME,
       decode (TASK_TYPE, 0, 'REGULAR',
               1, 'DISCONTINUED',
                  'UNKNOWN'),
       decode (STATE, 0, 'RUNNING',
               1, 'DONE',
                  'UNKNOWN')
  FROM
(
SELECT  
       TASK_ID,
       CREATION_TIME, 
       TASK_TYPE,
       STATE
  FROM sys.x$kdmadotasks
UNION
SELECT
      TASK_ID,
      CREATION_TIME,
      TASK_TYPE,
      STATE
 FROM sys.ado_imtasks$  
WHERE task_id not in (select task_id from gv$im_adotasks)
)
/

comment on table "_INMEMORY_AIMTASKS" is 
 'Information on tasks for automatic inmemory store management (AIM)'
/
comment on column "_INMEMORY_AIMTASKS".TASK_ID is 
 'Number that uniquely identifies a specific AIM task'
/
comment on column "_INMEMORY_AIMTASKS".TASK_TYPE is 
 'AIM task type'
/
comment on column "_INMEMORY_AIMTASKS".CREATION_TIME is
 'Creation time of the task'
/
comment on column "_INMEMORY_AIMTASKS".STATE is
 'State of the task'
/

GRANT SELECT ON SYS."_INMEMORY_AIMTASKS" TO select_catalog_role
/

/* Details regarding Automatic In-memory Management tasks*/

create or replace view DBA_INMEMORY_AIMTASKS
as 
SELECT 
       TASK_ID,
       CREATION_TIME,
       STATE
from SYS."_INMEMORY_AIMTASKS"
where task_type = 'REGULAR'
/

GRANT SELECT ON DBA_INMEMORY_AIMTASKS TO select_catalog_role
/

create or replace public synonym DBA_INMEMORY_AIMTASKS 
for SYS.DBA_INMEMORY_AIMTASKS
/

comment on table DBA_INMEMORY_AIMTASKS is 
 'Information on tasks for automatic inmemory store management (AIM)'
/
comment on column DBA_INMEMORY_AIMTASKS.TASK_ID is 
 'Number that uniquely identifies a specific AIM task'
/
comment on column DBA_INMEMORY_AIMTASKS.CREATION_TIME is
 'Creation time of the task'
/
comment on column DBA_INMEMORY_AIMTASKS.STATE is
 'State of the task'
/

execute CDBView.create_cdbview(false,'SYS','DBA_INMEMORY_AIMTASKS', 'CDB_INMEMORY_AIMTASKS');

grant select on SYS.CDB_INMEMORY_AIMTASKS to select_catalog_role
/

create or replace public synonym CDB_INMEMORY_AIMTASKS for SYS.CDB_INMEMORY_AIMTASKS
/

/* Internal view for details regarding AIM task details */
create or replace view "_INMEMORY_AIMTASKDETAILS"
(TASK_ID, OBJECT_OWNER, OBJECT_NAME, SUBOBJECT_NAME, ACTION, STATE, 
 EST_IMSIZE, VALUE, IM_POP_STATE, IMBYTES, BLOCKSINMEM, DATABLOCKS)
AS
SELECT  
       TASK_ID,
       OWNER,
       OBJNAME,
       SUBOBJNAME,
       decode(ACTN, 1, 'POPULATE',           
                        2, 'PARTIAL POPULATE',   
                        3, 'EVICT',              
                        4, 'NO ACTION',          
                          'UNKNOWN'),                
       decode(STATE,  0, 'SCHEDULED',
                        1, 'PROCESSING',
                        2, 'DONE',
                        3, 'PROCESSING',
                        4, 'FAILED',
                        5, 'DONE',  
                           'UNKNOWN'),
       ESTSIZE,
       VAL,
       decode(IM_POP_STATE, 0, 'INMEMORY',
                              1, 'INMEMORY_COMPLETE',
                              2, 'INMEMORY_PARTIAL',
                              3, 'NOTINMEMORY'),
       IMBYTES,
       BLOCKSINMEM,
       DATABLOCKS
  FROM
(
SELECT 
       TASK_ID,
       C.NAME OWNER,
       B.NAME OBJNAME,
       B.SUBNAME SUBOBJNAME,
       A.ACTN,
       A.STATE,
       A.ESTSIZE,
       A.VAL,
       A.IM_POP_STATE,
       A.IMBYTES,
       A.BLOCKSINMEM,
       A.DATABLOCKS
  FROM sys.x$kdmadotaskdetails a,
       sys.obj$ b, 
       sys.user$ c
 WHERE a.objn = b.obj#
   and b.owner# = c.user#
UNION
SELECT  
       TASK_ID,
       C.NAME OWNER,
       B.NAME OBJNAME,
       B.SUBNAME SUBOBJNAME,
       A.ACTION ACTN,
       A.STATE STATE,
       A.EST_IMSIZE ESTSIZE,
       A.val,
       A.IM_POP_STATE,
       A.IMBYTES,
       A.BLOCKSINMEM,
       A.DATABLOCKS
  FROM sys.ado_imsegtaskdetails$ a,
       sys.obj$ b, 
       sys.user$ c
 WHERE a.obj# = b.obj#
   and b.owner# = c.user#
   and task_id not in (select task_id from gv$im_adotasks)
)
/

comment on table "_INMEMORY_AIMTASKDETAILS" is 
 'Information on details for an automatic inmemory management task'
/
comment on column "_INMEMORY_AIMTASKDETAILS".TASK_ID is 
 'Number that uniquely identifies a specific AIM task'
/
comment on column "_INMEMORY_AIMTASKDETAILS".OBJECT_OWNER is
 'Owner of the object subject to AIM action'
/
comment on column "_INMEMORY_AIMTASKDETAILS".OBJECT_NAME is
 'Name of the object subject to AIM action'
/
comment on column "_INMEMORY_AIMTASKDETAILS".SUBOBJECT_NAME is
 'Name of the subobject subject to AIM action'
/
comment on column "_INMEMORY_AIMTASKDETAILS".ACTION is
 'Action taken on the object'
/
comment on column "_INMEMORY_AIMTASKDETAILS".STATE is
 'Status of the action on the object'
/
comment on column "_INMEMORY_AIMTASKDETAILS".EST_IMSIZE is
 'Action taken on the object'
/
comment on column "_INMEMORY_AIMTASKDETAILS".VALUE is
 'Status of the action on the object'
/
comment on column "_INMEMORY_AIMTASKDETAILS".IM_POP_STATE is
 'IM populate state of the object as seen by AIM during task creation'
/

GRANT SELECT ON SYS."_INMEMORY_AIMTASKDETAILS" TO select_catalog_role
/

/* Details regarding Automatic In-memory Management tasks execution*/

create or replace view DBA_INMEMORY_AIMTASKDETAILS
(TASK_ID, OBJECT_OWNER, OBJECT_NAME, SUBOBJECT_NAME, ACTION, STATE)
AS
SELECT  
       TASK_ID,
       OBJECT_OWNER,
       OBJECT_NAME,
       SUBOBJECT_NAME,   
       ACTION,
       STATE
  FROM SYS."_INMEMORY_AIMTASKDETAILS"
 WHERE task_id in (select task_id 
                     from SYS."_INMEMORY_AIMTASKS"
                    where task_type = 'REGULAR')
/

grant select on DBA_INMEMORY_AIMTASKDETAILS to select_catalog_role
/

create or replace public synonym DBA_INMEMORY_AIMTASKDETAILS
for SYS.DBA_INMEMORY_AIMTASKDETAILS
/

comment on table DBA_INMEMORY_AIMTASKDETAILS is 
 'Information on details for an automatic inmemory management task'
/
comment on column DBA_INMEMORY_AIMTASKDETAILS.TASK_ID is 
 'Number that uniquely identifies a specific AIM task'
/
comment on column DBA_INMEMORY_AIMTASKDETAILS.OBJECT_OWNER is
 'Owner of the object subject to AIM action'
/
comment on column DBA_INMEMORY_AIMTASKDETAILS.OBJECT_NAME is
 'Name of the object subject to AIM action'
/
comment on column DBA_INMEMORY_AIMTASKDETAILS.SUBOBJECT_NAME is
 'Name of the subobject subject to AIM action'
/
comment on column DBA_INMEMORY_AIMTASKDETAILS.ACTION is
 'Action taken on the object'
/
comment on column DBA_INMEMORY_AIMTASKDETAILS.STATE is
 'Status of the action on the object'
/

execute CDBView.create_cdbview(false,'SYS','DBA_INMEMORY_AIMTASKDETAILS', 'CDB_INMEMORY_AIMTASKDETAILS');

grant select on SYS.CDB_INMEMORY_AIMTASKDETAILS to select_catalog_role
/

create or replace public synonym CDB_INMEMORY_AIMTASKDETAILS for SYS.CDB_INMEMORY_AIMTASKDETAILS
/


@?/rdbms/admin/sqlsessend.sql
