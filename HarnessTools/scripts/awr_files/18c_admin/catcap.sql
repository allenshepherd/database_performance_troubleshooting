Rem
Rem $Header: rdbms/admin/catcap.sql /main/78 2017/06/26 16:01:18 pjulsaks Exp $
Rem
Rem catcap.sql
Rem
Rem Copyright (c) 2001, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catcap.sql - streams capture views
Rem
Rem    DESCRIPTION
Rem      This file contains all the views for streams capture
Rem
Rem    NOTES
Rem
Rem    The order of the from clause listed from left to right
Rem    should be from highest cardinality to lowest cardinality for better
Rem    performance.  The optimizer choses driving tables from right to left
Rem    and using smaller tables first will eliminate more rows early on.
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catcap.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catcap.sql
Rem SQL_PHASE: CATCAP
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catstr.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    pjulsaks    06/26/17 - Bug 25688154: Uppercase create_cdbview's input
Rem    thbaby      03/13/17 - Bug 25688154: upper case owner name
Rem    lzheng      10/07/16 - fix bug 24810747
Rem    anupkk      08/20/16 - XbranchMerge anupkk_bug-24372897 from
Rem                           st_rdbms_12.2.0.1.0
Rem    lzheng      08/19/16 - Bug 24490854: remove OGG Proc rep support for CTX 
Rem                              and procedures pgragma'd manural
Rem    anupkk      08/17/16 - Bug 24372897: Add dbms_rls_int
Rem    qiwang      04/21/16 - BUG 23142632: correct pkg name in OGG PLSQL
Rem                           mapping table
Rem    ssubrama    04/19/16 - bug 22968133 replicate registrations
Rem    lzheng      03/03/16 - Remove DBMS_GOLDENGATE_ADM_INT_INVOK from
Rem                           gg$_supported_packages table
Rem    ssubrama    03/02/16 - bug 22319358 add AQ rule to mapping table
Rem    ssubrama    12/09/15 - bug 21976900 add aq procedures to mapping table
Rem    lzheng      11/16/15 - add a new column to gg$_supported_packages
Rem    sravada     08/27/15 - add new MDSYS package
Rem    lzheng      07/02/15 - add dbms_prvtaqis
Rem    huntran     05/08/15 - auto CDR procedural replication
Rem    lzheng      04/27/15 - fix bug20965189: remove RAS packages
Rem    lzheng      01/13/15 - fix bug 20348210: add supported procedure view 
Rem                           for proc replication; external to internal pkg
Rem                           mapping, etc.
Rem    skayoor     11/30/14 - Proj 58196: Change Select priv to Read Priv
Rem    lzheng      11/14/14 - add views for ogg$_supported_pkgs,
Rem                           ogg$_procedure_annotation and
Rem                           ogg$_proc_object_exclusion
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    jovillag    11/06/13 - bug 17709106: mark _GV$SXGG* and _V$SXGG* views 
Rem                           as container_data views if they have a CON_ID
Rem                           column
Rem    talliu      06/28/13 - Add CDB view for DBA view
Rem    lzheng      10/25/12 - dba_capture: no query to gv$ views.
Rem    lzheng      04/09/12 - add private views _(G)V$SXGG_CAPTURE
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    lzheng      01/26/12 - fix lrg6695420
Rem    lzheng      12/16/11 - extend DBA_CAPTURE
Rem    tianli      12/09/11 - set_param for cdb
Rem    lzheng      11/16/11 - move (g)v$xstream_capture and
Rem                           (g)v$goldengate_capture from cdrixed.sql to here
Rem    lzheng      11/01/11 - add dba_xstream_split_merge and
Rem                           dba_xstream_split_merge_hist
Rem    tianli      03/31/11 - support pdb in xstream
Rem    rmao        05/17/10 - bug 9716742: change dba_capture.purpose
Rem    rmao        04/27/10 - add "XStream Streams" to dba_capture.purpose
Rem    thoang      03/10/10 - modify dba_capture.purpose to set GG first
Rem    juyuan      01/25/10 - add dba_capture.purpose
Rem    yurxu       11/10/09 - add start_time in DBA_CAPTURE view
Rem    rihuang     08/19/09 - filter out recyclebin obj from prepared tables
Rem    rmao        03/23/09 - drop columns job_status, job_next_run_date from
Rem                           dba_streams_split_merge_hist
Rem    rmao        11/19/08 - define dbms_streams_split_merge_hist
Rem    rmao        11/11/08 - add script_status, job_next_run_date to
Rem                           dba_streams_split_merge view
Rem    rmao        02/15/08 - add dba_streams_split_merge view
Rem    legao       02/01/07 - modify DBA_CAPTURE view implementation
Rem    cschmidt    08/08/06 - get_req_ckpt_scn() has changed - update
Rem    liwong      05/10/06 - sync capture cleanup 
Rem    thoang      05/06/05 - add synchronous capture 
Rem    htran       10/27/04 - add supplemental logging info to prepared views
Rem    nshodhan    07/29/04 - add resetlogs_change#, reset_timestamp
Rem    nshodhan    07/07/04 - add bitand for purgeable
Rem    nshodhan    06/11/04 - add last_enqueued_scn, checkpoint_retention_time
Rem    mtao        04/06/04 - bug 3376610: advance_session
Rem    sbalaram    10/28/03 - Bug 3219753: select correct checkpoint_scn
Rem    wesmith     07/29/03 - view DBA_CAPTURE: remove join to AQ tables
Rem    htran       06/26/03 - optimized dba/all_capture_prepared_tables
Rem    elu         04/23/03 - modify all_capture
Rem    nshodhan    04/21/03 - expose downstream capture to users
Rem    alakshmi    03/07/03 - add capture_user
Rem    htran       11/07/02 - a.include changed to substr(a.include, 1, 3)
Rem    alakshmi    11/11/02 - add version in dba_capture
Rem    liwong      11/04/02 - Add logfile_assignment
Rem    liwong      10/23/02 - Add status_change_time
Rem    htran       10/16/02 - unify some names with logminer
Rem    dcassine    10/01/02 - added start and end date to _DBA_CAPTURE
Rem    nshodhan    10/02/02 - add max_checkpoint_scn
Rem    nshodhan    09/15/02 - use_dblink -> use_database_link
Rem    elu         09/10/02 - add negative rule sets
Rem    rrawat      09/25/02 - Bug-2293353
Rem    liwong      08/19/02 - Modify DBA_CAPTURE_EXTRA_ATTRIBUTES
Rem    nshodhan    07/26/02 - fix all_capture
Rem    liwong      07/22/02 - Extend LCR support
Rem    liwong      07/07/02 - Downstream capture
Rem    nshodhan    07/02/02 - Downstream capture
Rem    sbalaram    06/17/02 - Fix bug 2395423
Rem    nshodhan    03/22/02 - bug#2265077: missing cols in ALL_CAPTURE
Rem    nshodhan    03/19/02 - fix dba_capture.start_scn
Rem    narora      01/11/02 - add captured_scn, applied_scn
Rem    wesmith     01/09/02 - Streams export/import support
Rem    sbalaram    12/10/01 - use create or replace synonym
Rem    sbalaram    11/16/01 - Fix comments on some views
Rem    alakshmi    11/08/01 - Merged alakshmi_apicleanup
Rem    masubram    11/01/01 - modify views accessing  streams$_capture_object
Rem    sbalaram    10/29/01 - add views
Rem    apadmana    10/26/01 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

----------------------------------------------------------------------------
-- view to get capture process details
----------------------------------------------------------------------------
-- Private view select to all columns from streams$_capture_process
-- Used by export. Respective catalog views will select from this view.
create or replace view "_DBA_CAPTURE"
as select 
  queue_oid, queue_owner, queue_name, capture#, capture_name,
  status, ruleset_owner, ruleset_name, logmnr_sid, predumpscn,
  dumpseqbeg, dumpseqend, postdumpscn, flags, start_scn, capture_userid,
  spare1, spare2, spare3, use_dblink, first_scn, source_dbname,
  spare4, spare5, spare6, spare7, negative_ruleset_owner, 
  negative_ruleset_name, start_date, end_date, status_change_time,
  error_number, error_message, version, start_scn_time, source_root_name
from sys.streams$_capture_process
/
grant select on "_DBA_CAPTURE" to exp_full_database
/

create or replace view "_SXGG_DBA_CAPTURE"
  (CAPTURE_NAME, QUEUE_NAME, QUEUE_OWNER, RULE_SET_NAME,
   RULE_SET_OWNER, CAPTURE_USER, START_SCN, STATUS, CAPTURED_SCN, APPLIED_SCN,
   USE_DATABASE_LINK, FIRST_SCN, SOURCE_DATABASE, SOURCE_DBID,
   SOURCE_RESETLOGS_SCN, SOURCE_RESETLOGS_TIME, LOGMINER_ID,
   NEGATIVE_RULE_SET_NAME, NEGATIVE_RULE_SET_OWNER, MAX_CHECKPOINT_SCN,
   REQUIRED_CHECKPOINT_SCN, LOGFILE_ASSIGNMENT, STATUS_CHANGE_TIME,
   ERROR_NUMBER, ERROR_MESSAGE, VERSION, CAPTURE_TYPE, LAST_ENQUEUED_SCN,
   CHECKPOINT_RETENTION_TIME, START_TIME, PURPOSE, SOURCE_ROOT_NAME,
   OLDEST_SCN)
as
select cp.capture_name, 
       cp.queue_name, cp.queue_owner, cp.ruleset_name,
       cp.ruleset_owner, u.name, cp.start_scn,
       decode(cp.status, 1, 'DISABLED',
                         2, 'ENABLED',
                         4, 'ABORTED', 'UNKNOWN'),
       cp.spare1, cp.spare2,
       decode(cp.use_dblink, 1, 'YES', 'NO'),
       cp.first_scn, cp.source_dbname, dl.source_dbid, dl.source_resetlogs_scn,
       dl.source_resetlogs_time, cp.logmnr_sid, cp.negative_ruleset_name,
       cp.negative_ruleset_owner, 
       nvl(dl.checkpoint_scn, 0),
       dbms_logrep_util.get_req_ckpt_scn(dl.id, nvl(cp.spare2,0)),
       decode(bitand(cp.flags, 4), 4, 'IMPLICIT', 'EXPLICIT'),
       cp.status_change_time, cp.error_number,
       cp.error_message, cp.version,
       decode(bitand(cp.flags, 64), 64, 'DOWNSTREAM', 'LOCAL'),
       dbms_logrep_util.get_last_enq_scn(cp.capture_name), cp.spare3,
       cp.start_scn_time,
       -- When GG and XOUT are set concurrently, GG purpose takes precedence.  
       (case 
         when bitand(cp.flags, 524288) = 524288    -- 0x80000
           then 'GoldenGate Capture'
         when bitand(cp.flags, 1048576) = 1048576  -- 0x100000
           then 'XStream Out'
         when bitand(cp.flags, 2048)= 2048  -- 0x800
           then 'AUDIT VAULT'
         when bitand(cp.flags, 2) = 2
           then 'CHANGE DATA CAPTURE'
        else
          ( select 'XStream Streams' from  dual where exists
              (select 1 from sys.props$
                where name = 'GG_XSTREAM_FOR_STREAMS' and value$ = 'T')
            union
            select 'Streams' from  dual where NOT exists
              (select 1 from sys.props$
             where name = 'GG_XSTREAM_FOR_STREAMS' and value$ = 'T'))
       end), cp.source_root_name,
       cp.spare5
  from "_DBA_CAPTURE" cp, dba_logmnr_session dl,
       sys.user$ u
 where dl.id (+) = cp.logmnr_sid 
   and cp.capture_userid = u.user# (+)
   and (bitand(cp.flags,512) != 512) -- skip sync capture
/

create or replace view DBA_CAPTURE
  (CAPTURE_NAME, QUEUE_NAME, QUEUE_OWNER, RULE_SET_NAME,
   RULE_SET_OWNER, CAPTURE_USER, START_SCN, STATUS, CAPTURED_SCN, APPLIED_SCN,
   USE_DATABASE_LINK, FIRST_SCN, SOURCE_DATABASE, SOURCE_DBID,
   SOURCE_RESETLOGS_SCN, SOURCE_RESETLOGS_TIME, LOGMINER_ID,
   NEGATIVE_RULE_SET_NAME, NEGATIVE_RULE_SET_OWNER, MAX_CHECKPOINT_SCN,
   REQUIRED_CHECKPOINT_SCN, LOGFILE_ASSIGNMENT, STATUS_CHANGE_TIME,
   ERROR_NUMBER, ERROR_MESSAGE, VERSION, CAPTURE_TYPE, LAST_ENQUEUED_SCN,
   CHECKPOINT_RETENTION_TIME, START_TIME, PURPOSE, SOURCE_ROOT_NAME,
   CLIENT_NAME, CLIENT_STATUS, OLDEST_SCN, FILTERED_SCN)
as
select capture_name, queue_name, queue_owner, rule_set_name,
   rule_set_owner, capture_user, start_scn, status, captured_scn, applied_scn,
   use_database_link, first_scn, source_database, source_dbid,
   source_resetlogs_scn, source_resetlogs_time, logminer_id,
   negative_rule_set_name, negative_rule_set_owner, max_checkpoint_scn,
   required_checkpoint_scn, logfile_assignment, status_change_time,
   error_number, error_message, version, capture_type, last_enqueued_scn,
   checkpoint_retention_time, start_time, purpose, source_root_name,
   null, null, null, null
from "_SXGG_DBA_CAPTURE" cp
where cp.purpose NOT IN ('GoldenGate Capture', 'XStream Out') -- Streams Capture
union
select capture_name, queue_name, queue_owner, rule_set_name,
   rule_set_owner, capture_user, start_scn, status, captured_scn, applied_scn,
   use_database_link, first_scn, source_database, source_dbid,
   source_resetlogs_scn, source_resetlogs_time, logminer_id,
   negative_rule_set_name, negative_rule_set_owner, max_checkpoint_scn,
   required_checkpoint_scn, logfile_assignment, status_change_time,
   error_number, error_message, version, capture_type, last_enqueued_scn,
   checkpoint_retention_time, start_time, purpose, source_root_name,
   decode((select count(*) from xstream$_server x
           where x.capture_name = cp.capture_name),
           1,
           decode(cp.purpose, 'GoldenGate Capture',
                     (select substr(x.user_comment, 
                             1,instr(x.user_comment,' ') - 1)   -- Extract Name
                      from xstream$_server x
                      where x.capture_name = cp.capture_name),
                     (select x.server_name              -- Outbound Server Name
                      from xstream$_server x
                      where x.capture_name = cp.capture_name)
                     ),
           NULL),
   decode((select count(*) from xstream$_server x
           where x.capture_name = cp.capture_name),
           1,
           (decode(cp.status, 
                   'ENABLED',
                   decode((select bitand(flags,8) from xstream$_server x
                          where x.capture_name = cp.capture_name), 
                          8,  -- 0x8 client attached
                          'ATTACHED', 'DETACHED'), 
                   'DETACHED')),
            NULL),
   cp.oldest_scn,
   decode((select count(*) 
           from sys.xstream$_server x, sys.streams$_apply_process ap, 
                sys.streams$_apply_milestone am
           where cp.capture_name = x.capture_name
                 and x.server_name = ap.apply_name
                 and cp.queue_owner = ap.queue_owner
                 and cp.queue_name = ap.queue_name
                 and ap.apply# = am.apply#),
           1,
           (select am.start_scn 
            from sys.xstream$_server x, sys.streams$_apply_process ap,
                 sys.streams$_apply_milestone am
            where cp.capture_name = x.capture_name
                  and x.server_name = ap.apply_name
                  and cp.queue_owner = ap.queue_owner
                  and cp.queue_name = ap.queue_name
                  and ap.apply# = am.apply#),
           NULL)
from "_SXGG_DBA_CAPTURE" cp
where cp.purpose in ('GoldenGate Capture', 'XStream Out')
/

comment on table DBA_CAPTURE is
'Details about the capture process'
/
comment on column DBA_CAPTURE.CAPTURE_NAME is
'Name of the capture process'
/
comment on column DBA_CAPTURE.QUEUE_NAME is
'Name of queue used for holding captured changes'
/
comment on column DBA_CAPTURE.QUEUE_OWNER is
'Owner of the queue used for holding captured changes'
/
comment on column DBA_CAPTURE.RULE_SET_NAME is
'Rule set used by capture process for filtering'
/
comment on column DBA_CAPTURE.RULE_SET_OWNER is
'Owner of the rule set'
/
comment on column DBA_CAPTURE.CAPTURE_USER is
'Current user who is enqueuing captured messages'
/
comment on column DBA_CAPTURE.START_SCN is
'The SCN from which capturing will be resumed'
/
comment on column DBA_CAPTURE.STATUS is
'Status of the capture process: DISABLED, ENABLED, ABORTED'
/
comment on column DBA_CAPTURE.STATUS_CHANGE_TIME is
'The time that STATUS of the capture process was changed'
/
comment on column DBA_CAPTURE.ERROR_NUMBER is
'Error number if the capture process was aborted'
/
comment on column DBA_CAPTURE.ERROR_MESSAGE is
'Error message if the capture process was aborted'
/
comment on column DBA_CAPTURE.CAPTURED_SCN is
'Everything up to this SCN has been captured'
/
comment on column DBA_CAPTURE.APPLIED_SCN is
'Everything up to this SCN has been applied'
/
comment on column DBA_CAPTURE.USE_DATABASE_LINK is
'Can use database_link from downstream to source database'
/
comment on column DBA_CAPTURE.FIRST_SCN is
'SCN from which the capture process can be restarted'
/
comment on column DBA_CAPTURE.SOURCE_DATABASE is
'Global name of the source database'
/
comment on column DBA_CAPTURE.SOURCE_DBID is
'DBID of the source database'
/
comment on column DBA_CAPTURE.SOURCE_RESETLOGS_SCN is
'Resetlogs_SCN of the source database'
/
comment on column DBA_CAPTURE.SOURCE_RESETLOGS_TIME is
'Resetlogs time of the source database'
/
comment on column DBA_CAPTURE.LOGMINER_ID is
'Session ID of LogMiner session associated with the capture process'
/
comment on column DBA_CAPTURE.NEGATIVE_RULE_SET_NAME is
'Negative rule set used by capture process for filtering'
/
comment on column DBA_CAPTURE.NEGATIVE_RULE_SET_OWNER is
'Owner of the negative rule set'
/
comment on column DBA_CAPTURE.MAX_CHECKPOINT_SCN is
'SCN at which the last check point was taken by the capture process'
/
comment on column DBA_CAPTURE.REQUIRED_CHECKPOINT_SCN is
'the safe SCN at which the meta-data for the capture process can be purged'
/
comment on column DBA_CAPTURE.LOGFILE_ASSIGNMENT is
'The logfile assignment type for the capture process'
/
comment on column DBA_CAPTURE.VERSION is
'Version number of the capture process'
/
comment on column DBA_CAPTURE.CAPTURE_TYPE is
'Type of the capture process'
/
comment on column DBA_CAPTURE.LAST_ENQUEUED_SCN is
'SCN of the last message enqueued by the capture process'
/
comment on column DBA_CAPTURE.CHECKPOINT_RETENTION_TIME is
'Number of days checkpoints will be retained by the capture process'
/
comment on column DBA_CAPTURE.START_TIME is
'The time when the capture process was started'
/
comment on column DBA_CAPTURE.PURPOSE is
'Purpose of the capture process'
/
comment on column DBA_CAPTURE.SOURCE_ROOT_NAME is
'Global name of the source root database'
/
comment on column DBA_CAPTURE.CLIENT_NAME is
'Name of the client process of the capture'
/
comment on column DBA_CAPTURE.CLIENT_STATUS is
'Status of the client process of the capture'
/
comment on column DBA_CAPTURE.OLDEST_SCN is
'Oldest SCN of the transaction currently being applied'
/
comment on column DBA_CAPTURE.FILTERED_SCN is
'SCN of the low watermark transaction processed'
/
create or replace public synonym DBA_CAPTURE for DBA_CAPTURE
/
grant select on DBA_CAPTURE to select_catalog_role
/



execute CDBView.create_cdbview(false,'SYS','DBA_CAPTURE','CDB_CAPTURE');
grant select on SYS.CDB_CAPTURE to select_catalog_role
/
create or replace public synonym CDB_CAPTURE for SYS.CDB_CAPTURE
/

-- view of details of automatic split/merge jobs that are not complete yet.
-- Note that 
-- (1)the decoding of streams_type should be consistent with the
--    definitions of streams_type in dbms_streams_adm_utl (logrep/prvthstr.sql)
--    Other decodings should be consistent with constants definitions in
--    dbms_streams_sm (logrep/prvthssm.sql)
-- (2)the decoding of r.status should be consistent with
--    dba_recoverable_script view

create or replace view "_DBA_SXGG_SPLIT_MERGE"
  (original_capture_name,    cloned_capture_name,
   original_capture_status,  cloned_capture_status,
   original_streams_name,    cloned_streams_name,
   streams_type,
   recoverable_script_id,    script_status,
   action_type,              action_threshold,
   status,                   status_update_time,
   creation_time,
   lag,
   job_owner,                job_name,
   job_state,                job_next_run_date,
   error_number,             error_message,
   purpose)
as
select s.original_capture_name,   s.cloned_capture_name,
       decode(s.original_capture_name, NULL, NULL,
                                       NVL(c1.status, 'DROPPED')),
       decode(s.cloned_capture_name, NULL, NULL,
                                       NVL(c2.status, 'DROPPED')),
       s.original_streams_name,   s.cloned_streams_name,
       decode(s.streams_type, 2, 'PROPAGATION',
                              3, 'APPLY'),
       s.recoverable_script_id,   NVL(decode(r.status, 1, 'GENERATING',
                                                       2, 'NOT EXECUTED',
                                                       3, 'EXECUTING',
                                                       4, 'EXECUTED',
                                                       5, 'ERROR'),
                                      decode(s.recoverable_script_id,
                                                       NULL, NULL,
                                                       'DROPPED')),
       decode(s.action_type, 1, 'SPLIT',
                             2, 'MERGE',
                             3, 'MONITOR'),
       decode(s.action_threshold, 2147483647, 'INFINITE',
                                  s.action_threshold),
       decode(s.status, 1, 'NOTHING TO SPLIT',
                        2, 'ABOUT TO SPLIT',
                        3, 'SPLITTING',
                        4, 'SPLIT DONE',
                        5, 'NOTHING TO MERGE',
                        6, 'ABOUT TO MERGE',
                        7, 'MERGING',
                        8, 'MERGE DONE',
                        9, 'ERROR',
                       10, 'NONSPLITTABLE'),
       s.status_update_time,
       s.creation_time,
       s.lag,
       s.job_owner,               s.job_name,
       decode(s.job_name, NULL, NULL,
                          NVL(j.state, 'DROPPED')),
       decode(s.job_name, NULL, NULL,
                          j.next_run_date),
       s.error_number,            s.error_message,
       c1.purpose
  from sys.streams$_split_merge s, dba_capture c1, dba_capture c2,
       dba_scheduler_jobs j, sys.reco_script$ r
 where s.original_capture_name = c1.capture_name (+)
   and s.cloned_capture_name   = c2.capture_name (+)
   and s.job_name              =  j.job_name     (+)
   and s.job_owner             =  j.owner        (+)
   and s.recoverable_script_id =  r.oid          (+)
   and s.active               != 1
/

create or replace view DBA_STREAMS_SPLIT_MERGE
as 
select original_capture_name,    cloned_capture_name,
   original_capture_status,  cloned_capture_status,
   original_streams_name,    cloned_streams_name,
   streams_type,
   recoverable_script_id,    script_status,
   action_type,              action_threshold,
   status,                   status_update_time,
   creation_time,
   lag,
   job_owner,                job_name,
   job_state,                job_next_run_date,
   error_number,             error_message
from "_DBA_SXGG_SPLIT_MERGE"
where purpose NOT in ('XStream Out', 'GoldenGate Capture')
/

comment on table DBA_STREAMS_SPLIT_MERGE is
'view of details of split/merge jobs/status about streams'
/
comment on column DBA_STREAMS_SPLIT_MERGE.ORIGINAL_CAPTURE_NAME is
'name of the original capture'
/
comment on column DBA_STREAMS_SPLIT_MERGE.CLONED_CAPTURE_NAME is
'name of the cloned capture'
/
comment on column DBA_STREAMS_SPLIT_MERGE.ORIGINAL_CAPTURE_STATUS is
'status of the original capture'
/
comment on column DBA_STREAMS_SPLIT_MERGE.CLONED_CAPTURE_STATUS is
'status of the cloned capture'
/
comment on column DBA_STREAMS_SPLIT_MERGE.ORIGINAL_STREAMS_NAME is
'name of original streams (propagation or local apply)'
/
comment on column DBA_STREAMS_SPLIT_MERGE.CLONED_STREAMS_NAME is
'name of cloned streams (propagation or local apply)'
/
comment on column DBA_STREAMS_SPLIT_MERGE.STREAMS_TYPE is
'type of streams (propagation or local apply)'
/
comment on column DBA_STREAMS_SPLIT_MERGE.RECOVERABLE_SCRIPT_ID is
'unique oid of the script to split or merge streams'
/
comment on column DBA_STREAMS_SPLIT_MERGE.SCRIPT_STATUS is
'status of the script to split or merge streams'
/
comment on column DBA_STREAMS_SPLIT_MERGE.ACTION_TYPE is
'type of action performed on this streams (either split or merge)'
/
comment on column DBA_STREAMS_SPLIT_MERGE.ACTION_THRESHOLD is
'value of split_threshold or merge_threshold'
/
comment on column DBA_STREAMS_SPLIT_MERGE.STATUS is
'status of streams'
/
comment on column DBA_STREAMS_SPLIT_MERGE.STATUS_UPDATE_TIME is
'time when status was last updated'
/
comment on column DBA_STREAMS_SPLIT_MERGE.CREATION_TIME is
'time when this row was created'
/
comment on column DBA_STREAMS_SPLIT_MERGE.JOB_NAME is
'name of the job to split or merge streams'
/
comment on column DBA_STREAMS_SPLIT_MERGE.JOB_OWNER is
'name of the owner of the job'
/
comment on column DBA_STREAMS_SPLIT_MERGE.JOB_STATE is
'state of the job'
/
comment on column DBA_STREAMS_SPLIT_MERGE.JOB_NEXT_RUN_DATE is
'when will the job run next time'
/
comment on column DBA_STREAMS_SPLIT_MERGE.LAG is
'the time in seconds that the cloned capture lags behind the original capture'
/
comment on column DBA_STREAMS_SPLIT_MERGE.ERROR_NUMBER is
'Error number if the capture process was aborted'
/
comment on column DBA_STREAMS_SPLIT_MERGE.ERROR_MESSAGE is
'Error message if the capture process was aborted'
/
create or replace public synonym DBA_STREAMS_SPLIT_MERGE
  for DBA_STREAMS_SPLIT_MERGE
/
grant select on DBA_STREAMS_SPLIT_MERGE to select_catalog_role
/


execute CDBView.create_cdbview(false,'SYS','DBA_STREAMS_SPLIT_MERGE','CDB_STREAMS_SPLIT_MERGE');
grant select on SYS.CDB_STREAMS_SPLIT_MERGE to select_catalog_role
/
create or replace public synonym CDB_STREAMS_SPLIT_MERGE for SYS.CDB_STREAMS_SPLIT_MERGE
/

-- view of details of completed automatic split/merge jobs
-- Note that 
-- (1)the decoding of streams_type should be consistent with the
--    definitions of streams_type in dbms_streams_adm_utl (logrep/prvthstr.sql)
--    Other decodings should be consistent with constants definitions in
--    dbms_streams_sm (logrep/prvthssm.sql)
-- (2)the decoding of r.status should be consistent with
--    dba_recoverable_script view
create or replace view "_DBA_SXGG_SPLIT_MERGE_HIST"
  (original_capture_name,    cloned_capture_name,
   original_queue_owner,     original_queue_name,
   cloned_queue_owner,       cloned_queue_name,
   original_capture_status,  cloned_capture_status,
   original_streams_name,    cloned_streams_name,
   streams_type,
   recoverable_script_id,    script_status,
   action_type,              action_threshold,
   status,                   status_update_time,
   creation_time,
   lag,
   job_owner,                job_name,
   error_number,             error_message,
   purpose)
as
select s.original_capture_name,   s.cloned_capture_name,
       s.original_queue_owner,    s.original_queue_name,
       s.cloned_queue_owner,      s.cloned_queue_name,
       decode(s.original_capture_name, NULL, NULL,
                                       NVL(c1.status, 'DROPPED')),
       decode(s.cloned_capture_name, NULL, NULL,
                                       NVL(c2.status, 'DROPPED')),
       s.original_streams_name,   s.cloned_streams_name,
       decode(s.streams_type, 2, 'PROPAGATION',
                              3, 'APPLY'),
       s.recoverable_script_id,   NVL(decode(r.status, 1, 'GENERATING',
                                                       2, 'NOT EXECUTED',
                                                       3, 'EXECUTING',
                                                       4, 'EXECUTED',
                                                       5, 'ERROR'),
                                      decode(s.recoverable_script_id,
                                                       NULL, NULL,
                                                       'DROPPED')),
       decode(s.action_type, 1, 'SPLIT',
                             2, 'MERGE',
                             3, 'MONITOR'),
       decode(s.action_threshold, 2147483647, 'INFINITE',
                                  s.action_threshold),
       decode(s.status, 1, 'NOTHING TO SPLIT',
                        2, 'ABOUT TO SPLIT',
                        3, 'SPLITTING',
                        4, 'SPLIT DONE',
                        5, 'NOTHING TO MERGE',
                        6, 'ABOUT TO MERGE',
                        7, 'MERGING',
                        8, 'MERGE DONE',
                        9, 'ERROR',
                       10, 'NONSPLITTABLE'),
       s.status_update_time,
       s.creation_time,
       s.lag,
       s.job_owner,               s.job_name,
       s.error_number,            s.error_message,
       c1.purpose
  from sys.streams$_split_merge s, dba_capture c1, dba_capture c2,
       sys.reco_script$ r
 where c1.purpose = c2.purpose
   and s.original_capture_name = c1.capture_name (+)
   and s.cloned_capture_name   = c2.capture_name (+)
   and s.recoverable_script_id =  r.oid          (+)
   and s.active               != 2
/

create or replace view DBA_STREAMS_SPLIT_MERGE_HIST
as select
  original_capture_name,    cloned_capture_name,
  original_queue_owner,     original_queue_name,
  cloned_queue_owner,       cloned_queue_name,
  original_capture_status,  cloned_capture_status,
  original_streams_name,    cloned_streams_name,
  streams_type,
  recoverable_script_id,    script_status,
  action_type,              action_threshold,
  status,                   status_update_time,
  creation_time,
  lag,
  job_owner,                job_name,
  error_number,             error_message
from "_DBA_SXGG_SPLIT_MERGE_HIST"
where purpose NOT in ('XStream Out', 'GoldenGate Capture')
/

comment on table DBA_STREAMS_SPLIT_MERGE_HIST is
'history view of details of split/merge jobs/status about streams'
/
comment on column DBA_STREAMS_SPLIT_MERGE_HIST.ORIGINAL_CAPTURE_NAME is
'name of the original capture'
/
comment on column DBA_STREAMS_SPLIT_MERGE_HIST.CLONED_CAPTURE_NAME is
'name of the cloned capture'
/
comment on column DBA_STREAMS_SPLIT_MERGE_HIST.ORIGINAL_QUEUE_OWNER is
'name of original queue owner'
/
comment on column DBA_STREAMS_SPLIT_MERGE_HIST.ORIGINAL_QUEUE_NAME is
'name of original queue'
/
comment on column DBA_STREAMS_SPLIT_MERGE_HIST.CLONED_QUEUE_OWNER is
'name of cloned queue owner'
/
comment on column DBA_STREAMS_SPLIT_MERGE_HIST.CLONED_QUEUE_NAME is
'name of cloned queue'
/
comment on column DBA_STREAMS_SPLIT_MERGE_HIST.ORIGINAL_CAPTURE_STATUS is
'status of the original capture'
/
comment on column DBA_STREAMS_SPLIT_MERGE_HIST.CLONED_CAPTURE_STATUS is
'status of the cloned capture'
/
comment on column DBA_STREAMS_SPLIT_MERGE_HIST.ORIGINAL_STREAMS_NAME is
'name of original streams (propagation or local apply)'
/
comment on column DBA_STREAMS_SPLIT_MERGE_HIST.CLONED_STREAMS_NAME is
'name of cloned streams (propagation or local apply)'
/
comment on column DBA_STREAMS_SPLIT_MERGE_HIST.STREAMS_TYPE is
'type of streams (propagation or local apply)'
/
comment on column DBA_STREAMS_SPLIT_MERGE_HIST.RECOVERABLE_SCRIPT_ID is
'unique oid of the script to split or merge streams'
/
comment on column DBA_STREAMS_SPLIT_MERGE_HIST.SCRIPT_STATUS is
'status of the script to split or merge streams'
/
comment on column DBA_STREAMS_SPLIT_MERGE_HIST.ACTION_TYPE is
'type of action performed on this streams (either split or merge)'
/
comment on column DBA_STREAMS_SPLIT_MERGE_HIST.ACTION_THRESHOLD is
'value of split_threshold or merge_threshold'
/
comment on column DBA_STREAMS_SPLIT_MERGE_HIST.STATUS is
'status of streams'
/
comment on column DBA_STREAMS_SPLIT_MERGE_HIST.STATUS_UPDATE_TIME is
'time when status was last updated'
/
comment on column DBA_STREAMS_SPLIT_MERGE_HIST.CREATION_TIME is
'time when this row was created'
/
comment on column DBA_STREAMS_SPLIT_MERGE_HIST.JOB_NAME is
'name of the job to split or merge streams'
/
comment on column DBA_STREAMS_SPLIT_MERGE_HIST.JOB_OWNER is
'name of the owner of the job'
/
comment on column DBA_STREAMS_SPLIT_MERGE_HIST.LAG is
'the time in seconds that the cloned capture lags behind the original capture'
/
comment on column DBA_STREAMS_SPLIT_MERGE_HIST.ERROR_NUMBER is
'Error number if the capture process was aborted'
/
comment on column DBA_STREAMS_SPLIT_MERGE_HIST.ERROR_MESSAGE is
'Error message if the capture process was aborted'
/
create or replace public synonym DBA_STREAMS_SPLIT_MERGE_HIST
  for DBA_STREAMS_SPLIT_MERGE_HIST
/
grant select on DBA_STREAMS_SPLIT_MERGE_HIST to select_catalog_role
/


execute CDBView.create_cdbview(false,'SYS','DBA_STREAMS_SPLIT_MERGE_HIST','CDB_STREAMS_SPLIT_MERGE_HIST');
grant select on SYS.CDB_STREAMS_SPLIT_MERGE_HIST to select_catalog_role
/
create or replace public synonym CDB_STREAMS_SPLIT_MERGE_HIST for SYS.CDB_STREAMS_SPLIT_MERGE_HIST
/

create or replace view DBA_XSTREAM_SPLIT_MERGE
as select
  original_capture_name,    cloned_capture_name,
  original_capture_status,  cloned_capture_status,
  original_streams_name original_xstream_name,    
  cloned_streams_name cloned_xstream_name,
  streams_type xstream_type,
  recoverable_script_id,    script_status,
  action_type,              action_threshold,
  status,                   status_update_time,
  creation_time,
  lag,
  job_owner,                job_name,
  job_state,                job_next_run_date,
  error_number,             error_message
from "_DBA_SXGG_SPLIT_MERGE"
where purpose = 'XStream Out'
/

comment on table DBA_XSTREAM_SPLIT_MERGE is
'view of details of split/merge jobs/status about XStream'
/
comment on column DBA_XSTREAM_SPLIT_MERGE.ORIGINAL_CAPTURE_NAME is
'name of the original capture'
/
comment on column DBA_XSTREAM_SPLIT_MERGE.CLONED_CAPTURE_NAME is
'name of the cloned capture'
/
comment on column DBA_XSTREAM_SPLIT_MERGE.ORIGINAL_CAPTURE_STATUS is
'status of the original capture'
/
comment on column DBA_XSTREAM_SPLIT_MERGE.CLONED_CAPTURE_STATUS is
'status of the cloned capture'
/
comment on column DBA_XSTREAM_SPLIT_MERGE.ORIGINAL_XSTREAM_NAME is
'name of original XStream (propagation or local apply)'
/
comment on column DBA_XSTREAM_SPLIT_MERGE.CLONED_XSTREAM_NAME is
'name of cloned XStream (propagation or local apply)'
/
comment on column DBA_XSTREAM_SPLIT_MERGE.XSTREAM_TYPE is
'type of XStream (propagation or local apply)'
/
comment on column DBA_XSTREAM_SPLIT_MERGE.RECOVERABLE_SCRIPT_ID is
'unique oid of the script to split or merge XStream'
/
comment on column DBA_XSTREAM_SPLIT_MERGE.SCRIPT_STATUS is
'status of the script to split or merge XStream'
/
comment on column DBA_XSTREAM_SPLIT_MERGE.ACTION_TYPE is
'type of action performed on this XStream (either split or merge)'
/
comment on column DBA_XSTREAM_SPLIT_MERGE.ACTION_THRESHOLD is
'value of split_threshold or merge_threshold'
/
comment on column DBA_XSTREAM_SPLIT_MERGE.STATUS is
'status of XStream'
/
comment on column DBA_XSTREAM_SPLIT_MERGE.STATUS_UPDATE_TIME is
'time when status was last updated'
/
comment on column DBA_XSTREAM_SPLIT_MERGE.CREATION_TIME is
'time when this row was created'
/
comment on column DBA_XSTREAM_SPLIT_MERGE.JOB_NAME is
'name of the job to split or merge XStream'
/
comment on column DBA_XSTREAM_SPLIT_MERGE.JOB_OWNER is
'name of the owner of the job'
/
comment on column DBA_XSTREAM_SPLIT_MERGE.JOB_STATE is
'state of the job'
/
comment on column DBA_XSTREAM_SPLIT_MERGE.JOB_NEXT_RUN_DATE is
'when will the job run next time'
/
comment on column DBA_XSTREAM_SPLIT_MERGE.LAG is
'the time in seconds that the cloned capture lags behind the original capture'
/
comment on column DBA_XSTREAM_SPLIT_MERGE.ERROR_NUMBER is
'Error number if the capture process was aborted'
/
comment on column DBA_XSTREAM_SPLIT_MERGE.ERROR_MESSAGE is
'Error message if the capture process was aborted'
/
create or replace public synonym DBA_XSTREAM_SPLIT_MERGE
  for DBA_XSTREAM_SPLIT_MERGE
/
grant select on DBA_XSTREAM_SPLIT_MERGE to select_catalog_role
/



execute CDBView.create_cdbview(false,'SYS','DBA_XSTREAM_SPLIT_MERGE','CDB_XSTREAM_SPLIT_MERGE');
grant select on SYS.CDB_XSTREAM_SPLIT_MERGE to select_catalog_role
/
create or replace public synonym CDB_XSTREAM_SPLIT_MERGE for SYS.CDB_XSTREAM_SPLIT_MERGE
/

create or replace view DBA_XSTREAM_SPLIT_MERGE_HIST
as select
   original_capture_name,    cloned_capture_name,
   original_queue_owner,     original_queue_name,
   cloned_queue_owner,       cloned_queue_name,
   original_capture_status,  cloned_capture_status,
   original_streams_name original_xstream_name,    
   cloned_streams_name  cloned_xstream_name,
   streams_type xstream_type,
   recoverable_script_id,    script_status,
   action_type,              action_threshold,
   status,                   status_update_time,
   creation_time,
   lag,
   job_owner,                job_name,
   error_number,             error_message
from "_DBA_SXGG_SPLIT_MERGE_HIST"
where purpose = 'XStream Out'
/

comment on table DBA_XSTREAM_SPLIT_MERGE_HIST is
'history view of details of split/merge jobs/status about XStream'
/
comment on column DBA_XSTREAM_SPLIT_MERGE_HIST.ORIGINAL_CAPTURE_NAME is
'name of the original capture'
/
comment on column DBA_XSTREAM_SPLIT_MERGE_HIST.CLONED_CAPTURE_NAME is
'name of the cloned capture'
/
comment on column DBA_XSTREAM_SPLIT_MERGE_HIST.ORIGINAL_QUEUE_OWNER is
'name of original queue owner'
/
comment on column DBA_XSTREAM_SPLIT_MERGE_HIST.ORIGINAL_QUEUE_NAME is
'name of original queue'
/
comment on column DBA_XSTREAM_SPLIT_MERGE_HIST.CLONED_QUEUE_OWNER is
'name of cloned queue owner'
/
comment on column DBA_XSTREAM_SPLIT_MERGE_HIST.CLONED_QUEUE_NAME is
'name of cloned queue'
/
comment on column DBA_XSTREAM_SPLIT_MERGE_HIST.ORIGINAL_CAPTURE_STATUS is
'status of the original capture'
/
comment on column DBA_XSTREAM_SPLIT_MERGE_HIST.CLONED_CAPTURE_STATUS is
'status of the cloned capture'
/
comment on column DBA_XSTREAM_SPLIT_MERGE_HIST.ORIGINAL_XSTREAM_NAME is
'name of original XStream (propagation or local apply)'
/
comment on column DBA_XSTREAM_SPLIT_MERGE_HIST.CLONED_XSTREAM_NAME is
'name of cloned XStream (propagation or local apply)'
/
comment on column DBA_XSTREAM_SPLIT_MERGE_HIST.XSTREAM_TYPE is
'type of XStream (propagation or local apply)'
/
comment on column DBA_XSTREAM_SPLIT_MERGE_HIST.RECOVERABLE_SCRIPT_ID is
'unique oid of the script to split or merge XStream'
/
comment on column DBA_XSTREAM_SPLIT_MERGE_HIST.SCRIPT_STATUS is
'status of the script to split or merge XStream'
/
comment on column DBA_XSTREAM_SPLIT_MERGE_HIST.ACTION_TYPE is
'type of action performed on this XStream (either split or merge)'
/
comment on column DBA_XSTREAM_SPLIT_MERGE_HIST.ACTION_THRESHOLD is
'value of split_threshold or merge_threshold'
/
comment on column DBA_XSTREAM_SPLIT_MERGE_HIST.STATUS is
'status of XStream'
/
comment on column DBA_XSTREAM_SPLIT_MERGE_HIST.STATUS_UPDATE_TIME is
'time when status was last updated'
/
comment on column DBA_XSTREAM_SPLIT_MERGE_HIST.CREATION_TIME is
'time when this row was created'
/
comment on column DBA_XSTREAM_SPLIT_MERGE_HIST.JOB_NAME is
'name of the job to split or merge XStream'
/
comment on column DBA_XSTREAM_SPLIT_MERGE_HIST.JOB_OWNER is
'name of the owner of the job'
/
comment on column DBA_XSTREAM_SPLIT_MERGE_HIST.LAG is
'the time in seconds that the cloned capture lags behind the original capture'
/
comment on column DBA_XSTREAM_SPLIT_MERGE_HIST.ERROR_NUMBER is
'Error number if the capture process was aborted'
/
comment on column DBA_XSTREAM_SPLIT_MERGE_HIST.ERROR_MESSAGE is
'Error message if the capture process was aborted'
/
create or replace public synonym DBA_XSTREAM_SPLIT_MERGE_HIST
  for DBA_XSTREAM_SPLIT_MERGE_HIST
/
grant select on DBA_XSTREAM_SPLIT_MERGE_HIST to select_catalog_role
/


execute CDBView.create_cdbview(false,'SYS','DBA_XSTREAM_SPLIT_MERGE_HIST','CDB_XSTREAM_SPLIT_MERGE_HIST');
grant select on SYS.CDB_XSTREAM_SPLIT_MERGE_HIST to select_catalog_role
/
create or replace public synonym CDB_XSTREAM_SPLIT_MERGE_HIST for SYS.CDB_XSTREAM_SPLIT_MERGE_HIST
/

----------------------------------------------------------------------------

-- View of capture processes
create or replace view ALL_CAPTURE
as
select c.*
  from dba_capture c, all_queues q
 where c.queue_name = q.name
   and c.queue_owner = q.owner
   and ((c.rule_set_owner is null and c.rule_set_name is null) or
        ((c.rule_set_owner, c.rule_set_name) in 
          (select r.rule_set_owner, r.rule_set_name
             from all_rule_sets r)))
   and ((c.negative_rule_set_owner is null and 
         c.negative_rule_set_name is null) or
        ((c.negative_rule_set_owner, c.negative_rule_set_name) in 
          (select r.rule_set_owner, r.rule_set_name
             from all_rule_sets r)))
/
comment on table ALL_CAPTURE is
'Details about each capture process that stores the captured changes in a queue visible to the current user'
/
comment on column ALL_CAPTURE.CAPTURE_NAME is
'Name of the capture process'
/
comment on column ALL_CAPTURE.QUEUE_NAME is
'Name of queue used for holding captured changes'
/
comment on column ALL_CAPTURE.QUEUE_OWNER is
'Owner of the queue used for holding captured changes'
/
comment on column ALL_CAPTURE.RULE_SET_NAME is
'Rule set used by capture process for filtering'
/
comment on column ALL_CAPTURE.RULE_SET_OWNER is
'Owner of the rule set'
/
comment on column ALL_CAPTURE.START_SCN is
'The SCN from which capturing will be resumed'
/
comment on column ALL_CAPTURE.STATUS is
'Status of the capture process: DISABLED, ENABLED, ABORTED'
/
comment on column ALL_CAPTURE.STATUS_CHANGE_TIME is
'The time that STATUS of the capture process was changed'
/
comment on column ALL_CAPTURE.ERROR_NUMBER is
'Error number if the capture process was aborted'
/
comment on column ALL_CAPTURE.ERROR_MESSAGE is
'Error message if the capture process was aborted'
/
comment on column ALL_CAPTURE.CAPTURED_SCN is
'Everything up to this SCN has been captured'
/
comment on column ALL_CAPTURE.APPLIED_SCN is
'Everything up to this SCN has been applied'
/
comment on column ALL_CAPTURE.USE_DATABASE_LINK is
'Can use database_link from downstream to source database'
/
comment on column ALL_CAPTURE.FIRST_SCN is
'SCN from which the capture process can be restarted'
/
comment on column ALL_CAPTURE.SOURCE_DATABASE is
'Global name of the source database'
/
comment on column ALL_CAPTURE.SOURCE_DBID is
'DBID of the source database'
/
comment on column ALL_CAPTURE.SOURCE_RESETLOGS_SCN is
'Resetlogs_SCN of the source database'
/
comment on column ALL_CAPTURE.SOURCE_RESETLOGS_TIME is
'Resetlogs time of the source database'
/
comment on column ALL_CAPTURE.LOGMINER_ID is
'Session ID of LogMiner session associated with the capture process'
/
comment on column ALL_CAPTURE.NEGATIVE_RULE_SET_NAME is
'Negative rule set used by capture process for filtering'
/
comment on column ALL_CAPTURE.NEGATIVE_RULE_SET_OWNER is
'Owner of the negative rule set'
/
comment on column ALL_CAPTURE.MAX_CHECKPOINT_SCN is
'SCN at which the last check point was taken by the capture process'
/
comment on column ALL_CAPTURE.REQUIRED_CHECKPOINT_SCN is
'the safe SCN at which the meta-data for the capture process can be purged'
/
comment on column ALL_CAPTURE.LOGFILE_ASSIGNMENT is
'The logfile assignment type for the capture process'
/
comment on column ALL_CAPTURE.VERSION is
'Version number of the capture process'
/
comment on column ALL_CAPTURE.CAPTURE_TYPE is
'Type of the capture process'
/
comment on column ALL_CAPTURE.LAST_ENQUEUED_SCN is
'SCN of the last message enqueued by the capture process'
/
comment on column ALL_CAPTURE.CHECKPOINT_RETENTION_TIME is
'Number of days checkpoints will be retained by the capture process'
/
comment on column ALL_CAPTURE.SOURCE_ROOT_NAME is
'Global name of the source root database'
/
comment on column ALL_CAPTURE.CLIENT_NAME is
'Name of the client process of the capture'
/
comment on column ALL_CAPTURE.CLIENT_STATUS is
'Status of the client process of the capture'
/
comment on column ALL_CAPTURE.OLDEST_SCN is
'Oldest SCN of the transaction currently being applied'
/
comment on column ALL_CAPTURE.FILTERED_SCN is
'SCN of the low watermark transaction processed'
/
create or replace public synonym ALL_CAPTURE for ALL_CAPTURE
/
grant read on ALL_CAPTURE to public with grant option
/

----------------------------------------------------------------------------
-- view to get capture process parameters
--
--  Note: process_type = 2 corresponds to the package variable
--        dbms_streams_adm_utl.streams_type_capture (prvtbsdm.sql)
--        and the macro KNLU_CAPTURE_PROC (knlu.h). This *must* be
--        kept in sync with both of these.
----------------------------------------------------------------------------
create or replace view DBA_CAPTURE_PARAMETERS
  (CAPTURE_NAME, PARAMETER, VALUE, SET_BY_USER, SOURCE_DATABASE)
as
select q.capture_name, p.name, p.value,
       decode(p.user_changed_flag, 1, 'YES', 'NO'), p.source_database
  from sys.streams$_process_params p, sys.streams$_capture_process q
 where p.process_type = 2
   and p.process# = q.capture#
   and /* display internal parameters if the user changed them */
       (p.internal_flag = 0
        or
        (p.internal_flag = 1 and p.user_changed_flag = 1)
       )
/
comment on table DBA_CAPTURE_PARAMETERS is
'All parameters for capture process'
/
comment on column DBA_CAPTURE_PARAMETERS.CAPTURE_NAME is
'Name of the capture process'
/
comment on column DBA_CAPTURE_PARAMETERS.PARAMETER is
'Name of the parameter'
/
comment on column DBA_CAPTURE_PARAMETERS.VALUE is
'Either the default value or the value set by the user for the parameter'
/
comment on column DBA_CAPTURE_PARAMETERS.SET_BY_USER is
'YES if the value is set by the user, NO otherwise'
/
comment on column DBA_CAPTURE_PARAMETERS.SOURCE_DATABASE is
'The global name of the container for which the parameter is defined.'
/
create or replace public synonym DBA_CAPTURE_PARAMETERS
  for DBA_CAPTURE_PARAMETERS
/
grant select on DBA_CAPTURE_PARAMETERS to select_catalog_role
/


execute CDBView.create_cdbview(false,'SYS','DBA_CAPTURE_PARAMETERS','CDB_CAPTURE_PARAMETERS');
grant select on SYS.CDB_CAPTURE_PARAMETERS to select_catalog_role
/
create or replace public synonym CDB_CAPTURE_PARAMETERS for SYS.CDB_CAPTURE_PARAMETERS
/

----------------------------------------------------------------------------

create or replace view ALL_CAPTURE_PARAMETERS
  (CAPTURE_NAME, PARAMETER, VALUE, SET_BY_USER, SOURCE_DATABASE)
as
select cp.capture_name, cp.parameter, cp.value, cp.set_by_user, 
  cp.source_database
  from dba_capture_parameters cp, all_capture ac
 where cp.capture_name = ac.capture_name
/

comment on table ALL_CAPTURE_PARAMETERS is
'Details about parameters for each capture process that stores the captured changes in a queue visible to the current user'
/
/
comment on column ALL_CAPTURE_PARAMETERS.CAPTURE_NAME is
'Name of the capture process'
/
comment on column ALL_CAPTURE_PARAMETERS.PARAMETER is
'Name of the parameter'
/
comment on column ALL_CAPTURE_PARAMETERS.VALUE is
'Either the default value or the value set by the user for the parameter'
/
comment on column ALL_CAPTURE_PARAMETERS.SET_BY_USER is
'YES if the value is set by the user, NO otherwise'
/
comment on column ALL_CAPTURE_PARAMETERS.SOURCE_DATABASE is
'The global name of the container for which the parameter is defined.'
/
create or replace public synonym ALL_CAPTURE_PARAMETERS
  for ALL_CAPTURE_PARAMETERS
/
grant read on ALL_CAPTURE_PARAMETERS to public with grant option
/

----------------------------------------------------------------------------
-- view to check if a database is prepared for instantiation
----------------------------------------------------------------------------
create or replace view DBA_CAPTURE_PREPARED_DATABASE
  (TIMESTAMP, SUPPLEMENTAL_LOG_DATA_PK, SUPPLEMENTAL_LOG_DATA_UI,
   SUPPLEMENTAL_LOG_DATA_FK, SUPPLEMENTAL_LOG_DATA_ALL)
as
select s.timestamp,
       decode(v.supplemental_log_data_pk, 'YES',
              decode(bitand(s.flags, 1), 1, 'IMPLICIT', 'EXPLICIT'), 'NO'),
       decode(v.supplemental_log_data_ui, 'YES',
              decode(bitand(s.flags, 2), 2, 'IMPLICIT', 'EXPLICIT'), 'NO'),
       decode(v.supplemental_log_data_fk, 'YES',
              decode(bitand(s.flags, 4), 4, 'IMPLICIT', 'EXPLICIT'), 'NO'),
       decode(v.supplemental_log_data_all, 'YES',
              decode(bitand(s.flags, 8), 8, 'IMPLICIT', 'EXPLICIT'), 'NO')
 from streams$_prepare_ddl s, v$database v
 where usrid is NULL
   and global_flag = 1
/
comment on table DBA_CAPTURE_PREPARED_DATABASE is
'Is the local database prepared for instantiation?'
/
comment on column DBA_CAPTURE_PREPARED_DATABASE.TIMESTAMP is
'Time at which the database was ready to be instantiated'
/
comment on column DBA_CAPTURE_PREPARED_DATABASE.SUPPLEMENTAL_LOG_DATA_PK is
'Status of database-level PRIMARY KEY COLUMNS supplemental logging'
/
comment on column DBA_CAPTURE_PREPARED_DATABASE.SUPPLEMENTAL_LOG_DATA_UI is
'Status of database-level UNIQUE INDEX COLUMNS supplemental logging'
/
comment on column DBA_CAPTURE_PREPARED_DATABASE.SUPPLEMENTAL_LOG_DATA_FK is
'Status of database-level FOREIGN KEY COLUMNS supplemental logging'
/
comment on column DBA_CAPTURE_PREPARED_DATABASE.SUPPLEMENTAL_LOG_DATA_ALL is
'Status of database-level ALL COLUMNS supplemental logging'
/
create or replace public synonym DBA_CAPTURE_PREPARED_DATABASE
  for DBA_CAPTURE_PREPARED_DATABASE
/
grant select on DBA_CAPTURE_PREPARED_DATABASE to select_catalog_role
/


execute CDBView.create_cdbview(false,'SYS','DBA_CAPTURE_PREPARED_DATABASE','CDB_CAPTURE_PREPARED_DATABASE');
grant select on SYS.CDB_CAPTURE_PREPARED_DATABASE to select_catalog_role
/
create or replace public synonym CDB_CAPTURE_PREPARED_DATABASE for SYS.CDB_CAPTURE_PREPARED_DATABASE
/

----------------------------------------------------------------------------

create or replace view ALL_CAPTURE_PREPARED_DATABASE
  (TIMESTAMP, SUPPLEMENTAL_LOG_DATA_PK, SUPPLEMENTAL_LOG_DATA_UI,
   SUPPLEMENTAL_LOG_DATA_FK, SUPPLEMENTAL_LOG_DATA_ALL)
as
select * from DBA_CAPTURE_PREPARED_DATABASE
/
comment on table ALL_CAPTURE_PREPARED_DATABASE is
'Is the local database prepared for instantiation?'
/
comment on column ALL_CAPTURE_PREPARED_DATABASE.TIMESTAMP is
'Time at which the database was ready to be instantiated'
/
comment on column ALL_CAPTURE_PREPARED_DATABASE.SUPPLEMENTAL_LOG_DATA_PK is
'Status of database-level PRIMARY KEY COLUMNS supplemental logging'
/
comment on column ALL_CAPTURE_PREPARED_DATABASE.SUPPLEMENTAL_LOG_DATA_UI is
'Status of database-level UNIQUE INDEX COLUMNS supplemental logging'
/
comment on column ALL_CAPTURE_PREPARED_DATABASE.SUPPLEMENTAL_LOG_DATA_FK is
'Status of database-level FOREIGN KEY COLUMNS supplemental logging'
/
comment on column ALL_CAPTURE_PREPARED_DATABASE.SUPPLEMENTAL_LOG_DATA_ALL is
'Status of database-level ALL COLUMNS supplemental logging'
/
create or replace public synonym ALL_CAPTURE_PREPARED_DATABASE
  for ALL_CAPTURE_PREPARED_DATABASE
/
grant read on ALL_CAPTURE_PREPARED_DATABASE to public with grant option
/

----------------------------------------------------------------------------
-- view to get the schemas prepared for instantiation
----------------------------------------------------------------------------
create or replace view DBA_CAPTURE_PREPARED_SCHEMAS
  (SCHEMA_NAME, TIMESTAMP, SUPPLEMENTAL_LOG_DATA_PK, SUPPLEMENTAL_LOG_DATA_UI,
   SUPPLEMENTAL_LOG_DATA_FK, SUPPLEMENTAL_LOG_DATA_ALL)
as
select u.name, pd.timestamp,
       decode(bitand(u.spare1, 1), 1,
              decode(bitand(pd.flags, 1), 1, 'IMPLICIT', 'EXPLICIT'), 'NO'),
       decode(bitand(u.spare1, 2), 2,
              decode(bitand(pd.flags, 2), 2, 'IMPLICIT', 'EXPLICIT'), 'NO'),
       decode(bitand(u.spare1, 4), 4,
              decode(bitand(pd.flags, 4), 4, 'IMPLICIT', 'EXPLICIT'), 'NO'),
       decode(bitand(u.spare1, 8), 8,
              decode(bitand(pd.flags, 8), 8, 'IMPLICIT', 'EXPLICIT'), 'NO')
  from streams$_prepare_ddl pd, user$ u
 where u.user# = pd.usrid and global_flag = 0
/
comment on table DBA_CAPTURE_PREPARED_SCHEMAS is
'All schemas at the local database that are prepared for instantiation'
/
comment on column DBA_CAPTURE_PREPARED_SCHEMAS.SCHEMA_NAME is
'Name of schema prepared for instantiation'
/
comment on column DBA_CAPTURE_PREPARED_SCHEMAS.TIMESTAMP is
'Time at which the schema was ready to be instantiated'
/
comment on column DBA_CAPTURE_PREPARED_SCHEMAS.SUPPLEMENTAL_LOG_DATA_PK is
'Status of schema-level PRIMARY KEY COLUMNS supplemental logging'
/
comment on column DBA_CAPTURE_PREPARED_SCHEMAS.SUPPLEMENTAL_LOG_DATA_UI is
'Status of schema-level UNIQUE INDEX COLUMNS supplemental logging'
/
comment on column DBA_CAPTURE_PREPARED_SCHEMAS.SUPPLEMENTAL_LOG_DATA_FK is
'Status of schema-level FOREIGN KEY COLUMNS supplemental logging'
/
comment on column DBA_CAPTURE_PREPARED_SCHEMAS.SUPPLEMENTAL_LOG_DATA_ALL is
'Status of schema-level ALL COLUMNS supplemental logging'
/
create or replace public synonym DBA_CAPTURE_PREPARED_SCHEMAS
  for DBA_CAPTURE_PREPARED_SCHEMAS
/
grant select on DBA_CAPTURE_PREPARED_SCHEMAS to select_catalog_role
/


execute CDBView.create_cdbview(false,'SYS','DBA_CAPTURE_PREPARED_SCHEMAS','CDB_CAPTURE_PREPARED_SCHEMAS');
grant select on SYS.CDB_CAPTURE_PREPARED_SCHEMAS to select_catalog_role
/
create or replace public synonym CDB_CAPTURE_PREPARED_SCHEMAS for SYS.CDB_CAPTURE_PREPARED_SCHEMAS
/

----------------------------------------------------------------------------

create or replace view ALL_CAPTURE_PREPARED_SCHEMAS
  (SCHEMA_NAME, TIMESTAMP, SUPPLEMENTAL_LOG_DATA_PK, SUPPLEMENTAL_LOG_DATA_UI,
   SUPPLEMENTAL_LOG_DATA_FK, SUPPLEMENTAL_LOG_DATA_ALL)
as
select s.schema_name, s.timestamp, s.supplemental_log_data_pk,
       s.supplemental_log_data_ui, s.supplemental_log_data_fk,
       s.supplemental_log_data_all
  from dba_capture_prepared_schemas s, all_users u
 where s.schema_name = u.username
/

comment on table ALL_CAPTURE_PREPARED_SCHEMAS is
'All user schemas at the local database that are prepared for instantiation'
/
comment on column ALL_CAPTURE_PREPARED_SCHEMAS.SCHEMA_NAME is
'Name of schema prepared for instantiation'
/
comment on column ALL_CAPTURE_PREPARED_SCHEMAS.TIMESTAMP is
'Time at which the schema was ready to be instantiated'
/
comment on column ALL_CAPTURE_PREPARED_SCHEMAS.SUPPLEMENTAL_LOG_DATA_PK is
'Status of schema-level PRIMARY KEY COLUMNS supplemental logging'
/
comment on column ALL_CAPTURE_PREPARED_SCHEMAS.SUPPLEMENTAL_LOG_DATA_UI is
'Status of schema-level UNIQUE INDEX COLUMNS supplemental logging'
/
comment on column ALL_CAPTURE_PREPARED_SCHEMAS.SUPPLEMENTAL_LOG_DATA_FK is
'Status of schema-level FOREIGN KEY COLUMNS supplemental logging'
/
comment on column ALL_CAPTURE_PREPARED_SCHEMAS.SUPPLEMENTAL_LOG_DATA_ALL is
'Status of schema-level ALL COLUMNS supplemental logging'
/
create or replace public synonym ALL_CAPTURE_PREPARED_SCHEMAS
  for ALL_CAPTURE_PREPARED_SCHEMAS
/
grant read on ALL_CAPTURE_PREPARED_SCHEMAS to public with grant option
/

----------------------------------------------------------------------------
-- view to get the tables prepared for instantiation
----------------------------------------------------------------------------
-- using obj$ and user$ instead of dba_objects for better performance.
create or replace view DBA_CAPTURE_PREPARED_TABLES
  (TABLE_OWNER, TABLE_NAME, SCN, TIMESTAMP, SUPPLEMENTAL_LOG_DATA_PK,
   SUPPLEMENTAL_LOG_DATA_UI, SUPPLEMENTAL_LOG_DATA_FK,
   SUPPLEMENTAL_LOG_DATA_ALL)
as
select u.name, o.name, co.ignore_scn, co.timestamp,
       decode(bitand(cd.flags, 1), 1,
              decode(bitand(co.flags, 1), 1, 'IMPLICIT', 'EXPLICIT'), 'NO'),
       decode(bitand(cd.flags, 2), 2,
              decode(bitand(co.flags, 2), 2, 'IMPLICIT', 'EXPLICIT'), 'NO'),
       decode(bitand(cd.flags, 4), 4,
              decode(bitand(co.flags, 4), 4, 'IMPLICIT', 'EXPLICIT'), 'NO'),
       decode(bitand(cd.flags, 8), 8,
              decode(bitand(co.flags, 8), 8, 'IMPLICIT', 'EXPLICIT'), 'NO')
  from obj$ o, user$ u, streams$_prepare_object co,
       (select obj#, sum(DECODE(type#, 14, 1, 15, 2, 16, 4, 17, 8, 0)) flags
          from sys.cdef$ group by obj#) cd
  where o.obj# = co.obj# and o.owner# = u.user# and co.obj# = cd.obj#(+)
    and co.cap_type = 0 and bitand(o.flags,128) = 0 -- skip recyclebin obj
/
comment on table DBA_CAPTURE_PREPARED_TABLES is
'All tables prepared for instantiation'
/
comment on column DBA_CAPTURE_PREPARED_TABLES.TABLE_OWNER is
'Owner of the table prepared for instantiation'
/
comment on column DBA_CAPTURE_PREPARED_TABLES.TABLE_NAME is
'Name of the table prepared for instantiation'
/
comment on column DBA_CAPTURE_PREPARED_TABLES.SCN is
'SCN from which changes can be captured'
/
comment on column DBA_CAPTURE_PREPARED_TABLES.TIMESTAMP is
'Time at which the table was ready to be instantiated'
/
comment on column DBA_CAPTURE_PREPARED_TABLES.SUPPLEMENTAL_LOG_DATA_PK is
'Status of table-level PRIMARY KEY COLUMNS supplemental logging'
/
comment on column DBA_CAPTURE_PREPARED_TABLES.SUPPLEMENTAL_LOG_DATA_UI is
'Status of table-level UNIQUE INDEX COLUMNS supplemental logging'
/
comment on column DBA_CAPTURE_PREPARED_TABLES.SUPPLEMENTAL_LOG_DATA_FK is
'Status of table-level FOREIGN KEY COLUMNS supplemental logging'
/
comment on column DBA_CAPTURE_PREPARED_TABLES.SUPPLEMENTAL_LOG_DATA_ALL is
'Status of table-level ALL COLUMNS supplemental logging'
/
create or replace public synonym DBA_CAPTURE_PREPARED_TABLES
  for DBA_CAPTURE_PREPARED_TABLES
/
grant select on DBA_CAPTURE_PREPARED_TABLES to select_catalog_role
/


execute CDBView.create_cdbview(false,'SYS','DBA_CAPTURE_PREPARED_TABLES','CDB_CAPTURE_PREPARED_TABLES');
grant select on SYS.CDB_CAPTURE_PREPARED_TABLES to select_catalog_role
/
create or replace public synonym CDB_CAPTURE_PREPARED_TABLES for SYS.CDB_CAPTURE_PREPARED_TABLES
/

----------------------------------------------------------------------------

create or replace view ALL_CAPTURE_PREPARED_TABLES
  (TABLE_OWNER, TABLE_NAME, SCN, TIMESTAMP, SUPPLEMENTAL_LOG_DATA_PK,
   SUPPLEMENTAL_LOG_DATA_UI, SUPPLEMENTAL_LOG_DATA_FK,
   SUPPLEMENTAL_LOG_DATA_ALL)
as
select pt.table_owner, pt.table_name, pt.scn, pt.timestamp,
       pt.supplemental_log_data_pk, pt.supplemental_log_data_ui,
       pt.supplemental_log_data_fk, pt.supplemental_log_data_all
  from all_tables at, dba_capture_prepared_tables pt
  where pt.table_name = at.table_name
    and pt.table_owner = at.owner
/

comment on table ALL_CAPTURE_PREPARED_TABLES is
'All tables visible to the current user that are prepared for instantiation'
/
comment on column ALL_CAPTURE_PREPARED_TABLES.TABLE_OWNER is
'Owner of the table prepared for instantiation'
/
comment on column ALL_CAPTURE_PREPARED_TABLES.TABLE_NAME is
'Name of the table prepared for instantiation'
/
comment on column ALL_CAPTURE_PREPARED_TABLES.SCN is
'SCN from which changes can be captured'
/
comment on column ALL_CAPTURE_PREPARED_TABLES.TIMESTAMP is
'Time at which the table was ready to be instantiated'
/
comment on column ALL_CAPTURE_PREPARED_TABLES.SUPPLEMENTAL_LOG_DATA_PK is
'Status of table-level PRIMARY KEY COLUMNS supplemental logging'
/
comment on column ALL_CAPTURE_PREPARED_TABLES.SUPPLEMENTAL_LOG_DATA_UI is
'Status of table-level UNIQUE INDEX COLUMNS supplemental logging'
/
comment on column ALL_CAPTURE_PREPARED_TABLES.SUPPLEMENTAL_LOG_DATA_FK is
'Status of table-level FOREIGN KEY COLUMNS supplemental logging'
/
comment on column ALL_CAPTURE_PREPARED_TABLES.SUPPLEMENTAL_LOG_DATA_ALL is
'Status of table-level ALL COLUMNS supplemental logging'
/
create or replace public synonym ALL_CAPTURE_PREPARED_TABLES
  for ALL_CAPTURE_PREPARED_TABLES
/
grant read on ALL_CAPTURE_PREPARED_TABLES to public with grant option
/

----------------------------------------------------------------------------
-- view to get the tables prepared for sync capture instantiation
----------------------------------------------------------------------------
-- using obj$ and user$ instead of dba_objects for better performance.
create or replace view DBA_SYNC_CAPTURE_PREPARED_TABS
  (TABLE_OWNER, TABLE_NAME, SCN, TIMESTAMP)
as
select u.name, o.name, co.ignore_scn, co.timestamp
  from obj$ o, user$ u, streams$_prepare_object co
  where o.obj# = co.obj# and o.owner# = u.user#
    and co.cap_type = 1
/
comment on table DBA_SYNC_CAPTURE_PREPARED_TABS is
'All tables prepared for synchronous capture instantiation'
/
comment on column DBA_SYNC_CAPTURE_PREPARED_TABS.TABLE_OWNER is
'Owner of the table prepared for synchronous capture instantiation'
/
comment on column DBA_SYNC_CAPTURE_PREPARED_TABS.TABLE_NAME is
'Name of the table prepared for synchronous capture instantiation'
/
comment on column DBA_SYNC_CAPTURE_PREPARED_TABS.SCN is
'SCN from which changes can be captured'
/
comment on column DBA_SYNC_CAPTURE_PREPARED_TABS.TIMESTAMP is
'Time at which the table was ready to be instantiated'
/
create or replace public synonym DBA_SYNC_CAPTURE_PREPARED_TABS
  for DBA_SYNC_CAPTURE_PREPARED_TABS
/
grant select on DBA_SYNC_CAPTURE_PREPARED_TABS to select_catalog_role
/


execute CDBView.create_cdbview(false,'SYS','DBA_SYNC_CAPTURE_PREPARED_TABS','CDB_SYNC_CAPTURE_PREPARED_TABS');
grant select on SYS.CDB_SYNC_CAPTURE_PREPARED_TABS to select_catalog_role
/
create or replace public synonym CDB_SYNC_CAPTURE_PREPARED_TABS for SYS.CDB_SYNC_CAPTURE_PREPARED_TABS
/

----------------------------------------------------------------------------

create or replace view ALL_SYNC_CAPTURE_PREPARED_TABS
  (TABLE_OWNER, TABLE_NAME, SCN, TIMESTAMP)
as
select pt.table_owner, pt.table_name, pt.scn, pt.timestamp
  from all_tables at, dba_sync_capture_prepared_tabs pt
  where pt.table_name = at.table_name
    and pt.table_owner = at.owner
/

comment on table ALL_SYNC_CAPTURE_PREPARED_TABS is
'All tables prepared for synchronous capture instantiation'
/
comment on column ALL_SYNC_CAPTURE_PREPARED_TABS.TABLE_OWNER is
'Owner of the table prepared for synchronous capture instantiation'
/
comment on column ALL_SYNC_CAPTURE_PREPARED_TABS.TABLE_NAME is
'Name of the table prepared for synchronous capture instantiation'
/
comment on column ALL_SYNC_CAPTURE_PREPARED_TABS.SCN is
'SCN from which changes can be captured'
/
comment on column ALL_SYNC_CAPTURE_PREPARED_TABS.TIMESTAMP is
'Time at which the table was ready to be instantiated'
/
create or replace public synonym ALL_SYNC_CAPTURE_PREPARED_TABS
  for ALL_SYNC_CAPTURE_PREPARED_TABS
/
grant read on ALL_SYNC_CAPTURE_PREPARED_TABS to public with grant option
/


----------------------------------------------------------------------------
-- view to get capture process extra attributes
----------------------------------------------------------------------------
create or replace view DBA_CAPTURE_EXTRA_ATTRIBUTES
  (CAPTURE_NAME, ATTRIBUTE_NAME, INCLUDE, ROW_ATTRIBUTE, DDL_ATTRIBUTE)
as
select q.capture_name, a.name, substr(a.include, 1, 3),
       decode(bitand(a.flag, 1), 1, 'YES', 0, 'NO'),
       decode(bitand(a.flag, 2), 2, 'YES', 0, 'NO')
  from sys.streams$_extra_attrs a, sys.streams$_capture_process q
 where a.process# = q.capture#
/
comment on table DBA_CAPTURE_EXTRA_ATTRIBUTES is
'Extra attributes for a capture process'
/
comment on column DBA_CAPTURE_EXTRA_ATTRIBUTES.capture_name is
'Name of the capture process'
/
comment on column DBA_CAPTURE_EXTRA_ATTRIBUTES.attribute_name is
'Name of the extra attribute'
/
comment on column DBA_CAPTURE_EXTRA_ATTRIBUTES.include is
'YES if the extra attribute is included'
/

comment on column DBA_CAPTURE_EXTRA_ATTRIBUTES.row_attribute is
'YES if the extra attribute is a row LCR attribute'
/

comment on column DBA_CAPTURE_EXTRA_ATTRIBUTES.ddl_attribute is
'YES if the extra attribute is a DDL LCR attribute'
/

create or replace public synonym DBA_CAPTURE_EXTRA_ATTRIBUTES
  for DBA_CAPTURE_EXTRA_ATTRIBUTES
/
grant select on DBA_CAPTURE_EXTRA_ATTRIBUTES to select_catalog_role
/


execute CDBView.create_cdbview(false,'SYS','DBA_CAPTURE_EXTRA_ATTRIBUTES','CDB_CAPTURE_EXTRA_ATTRIBUTES');
grant select on SYS.CDB_CAPTURE_EXTRA_ATTRIBUTES to select_catalog_role
/
create or replace public synonym CDB_CAPTURE_EXTRA_ATTRIBUTES for SYS.CDB_CAPTURE_EXTRA_ATTRIBUTES
/

create or replace view ALL_CAPTURE_EXTRA_ATTRIBUTES
as
select e.*
  from dba_capture_extra_attributes e, all_capture c
 where e.capture_name = c.capture_name
/
comment on table ALL_CAPTURE_EXTRA_ATTRIBUTES is
'Extra attributes for a capture process that is visible to the current user'
/
comment on column ALL_CAPTURE_EXTRA_ATTRIBUTES.capture_name is
'Name of the capture process'
/
comment on column ALL_CAPTURE_EXTRA_ATTRIBUTES.attribute_name is
'Name of the extra attribute'
/
comment on column ALL_CAPTURE_EXTRA_ATTRIBUTES.include is
'YES if the extra attribute is included'
/

comment on column DBA_CAPTURE_EXTRA_ATTRIBUTES.row_attribute is
'YES if the extra attribute is a row LCR attribute'
/

comment on column DBA_CAPTURE_EXTRA_ATTRIBUTES.ddl_attribute is
'YES if the extra attribute is a DDL LCR attribute'
/

create or replace public synonym ALL_CAPTURE_EXTRA_ATTRIBUTES
  for ALL_CAPTURE_EXTRA_ATTRIBUTES
/
grant read on ALL_CAPTURE_EXTRA_ATTRIBUTES to public with grant option
/

create or replace view dba_registered_archived_log
  (consumer_name, source_database, thread#,
   sequence#, first_scn, next_scn, first_time, next_time,
   name, modified_time, dictionary_begin,
   dictionary_end, purgeable, resetlogs_change#, reset_timestamp)
as
select cp.capture_name, cp.source_dbname,
       l.thread#, l.sequence#, l.first_change#,
       l.next_change#, l.first_time, l.next_time,
       l.file_name, l.timestamp,
       l.dict_begin, l.dict_end, 
       decode(bitand(l.status, 2), 2, 'YES', 'NO'),
       l.resetlogs_change#, l.reset_timestamp
  from system.logmnr_log$ l, sys.streams$_capture_process cp
  where l.session# = cp.logmnr_sid
/

comment on table DBA_REGISTERED_ARCHIVED_LOG is
'Details about the registered log files'
/
comment on column DBA_REGISTERED_ARCHIVED_LOG.CONSUMER_NAME is
'consumer name of the archived logs'
/
comment on column DBA_REGISTERED_ARCHIVED_LOG.SOURCE_DATABASE is
'the name of the database which generated the redo logs'
/
comment on column DBA_REGISTERED_ARCHIVED_LOG.THREAD# is
'Thread ID of the archived redo log'
/
comment on column DBA_REGISTERED_ARCHIVED_LOG.SEQUENCE# is
'Sequence number of the archived redo log file'
/
comment on column DBA_REGISTERED_ARCHIVED_LOG.FIRST_SCN is
'SCN of the current archived redo log'
/
comment on column DBA_REGISTERED_ARCHIVED_LOG.NEXT_SCN is
'SCN of the next archived redo log'
/
comment on column DBA_REGISTERED_ARCHIVED_LOG.FIRST_TIME is
'Date of the current archived redo log'
/
comment on column DBA_REGISTERED_ARCHIVED_LOG.NEXT_TIME is
'Date of the next archived redo log'
/
comment on column DBA_REGISTERED_ARCHIVED_LOG.NAME is
'Name of the archived redo log'
/
comment on column DBA_REGISTERED_ARCHIVED_LOG.MODIFIED_TIME is
'Time when the archived redo log was registered'
/
comment on column DBA_REGISTERED_ARCHIVED_LOG.DICTIONARY_BEGIN is
'Indicates whether the beginning of the dictionary build is in this redo log'
/
comment on column DBA_REGISTERED_ARCHIVED_LOG.DICTIONARY_END is
'Indicates whether the end of the dictionary build is in this redo log'
/
comment on column DBA_REGISTERED_ARCHIVED_LOG.PURGEABLE is
'Indicates whether this redo log can be permanently removed'
/
comment on column DBA_REGISTERED_ARCHIVED_LOG.RESETLOGS_CHANGE# is
'Resetlogs change# of the database when the log was written'
/
comment on column DBA_REGISTERED_ARCHIVED_LOG.RESET_TIMESTAMP is
'Resetlogs time of the database when the log was written'
/
create or replace public synonym DBA_REGISTERED_ARCHIVED_LOG for
  DBA_REGISTERED_ARCHIVED_LOG
/
grant select on DBA_REGISTERED_ARCHIVED_LOG to select_catalog_role
/


execute CDBView.create_cdbview(false,'SYS','DBA_REGISTERED_ARCHIVED_LOG','CDB_REGISTERED_ARCHIVED_LOG');
grant select on SYS.CDB_registered_archived_log to select_catalog_role
/
create or replace public synonym CDB_registered_archived_log for SYS.CDB_registered_archived_log
/

----------------------------------------------------------------------------

create or replace view GV_$STREAMS_CAPTURE
as
select * from gv$streams_capture;
create or replace public synonym GV$STREAMS_CAPTURE for GV_$STREAMS_CAPTURE;
grant select on GV_$STREAMS_CAPTURE to select_catalog_role;

----------------------------------------------------------------------------

create or replace view V_$STREAMS_CAPTURE
as
select * from v$streams_capture;
create or replace public synonym V$STREAMS_CAPTURE for V_$STREAMS_CAPTURE;
grant select on V_$STREAMS_CAPTURE to select_catalog_role;

----------------------------------------------------------------------------

create or replace view GV_$XSTREAM_CAPTURE
as
select * from gv$xstream_capture;
create or replace public synonym GV$XSTREAM_CAPTURE for GV_$XSTREAM_CAPTURE;
grant select on GV_$XSTREAM_CAPTURE to select_catalog_role;

----------------------------------------------------------------------------

create or replace view V_$XSTREAM_CAPTURE
as
select * from v$xstream_capture;
create or replace public synonym V$XSTREAM_CAPTURE for V_$XSTREAM_CAPTURE;
grant select on V_$XSTREAM_CAPTURE to select_catalog_role;

----------------------------------------------------------------------------

create or replace view GV_$GOLDENGATE_CAPTURE
as
select * from gv$goldengate_capture;
create or replace public synonym GV$GOLDENGATE_CAPTURE for GV_$GOLDENGATE_CAPTURE;
grant select on GV_$GOLDENGATE_CAPTURE to select_catalog_role;

----------------------------------------------------------------------------

create or replace view V_$GOLDENGATE_CAPTURE
as
select * from v$goldengate_capture;
create or replace public synonym V$GOLDENGATE_CAPTURE for V_$GOLDENGATE_CAPTURE;
grant select on V_$GOLDENGATE_CAPTURE to select_catalog_role;

----------------------------------------------------------------------------

create or replace view "_V$SXGG_CAPTURE" container_data
as
select * from v$streams_capture
union all
select sid, serial#, capture#, capture_name, logminer_id,
startup_time, state, total_prefilter_discarded, total_prefilter_kept,
total_prefilter_evaluations, total_messages_captured, capture_time,
capture_message_number, capture_message_create_time,
total_messages_created, total_full_evaluations, total_messages_enqueued,
enqueue_time, enqueue_message_number, enqueue_message_create_time,
available_message_number, available_message_create_time,
elapsed_capture_time, elapsed_rule_time, elapsed_enqueue_time,
elapsed_lcr_time, elapsed_redo_wait_time, elapsed_pause_time,
state_changed_time, NULL, NULL, NULL, NULL, NULL, NULL, sga_used,
sga_allocated, bytes_of_redo_mined, session_restart_scn, con_id
from v$xstream_capture
union all
select sid, serial#, capture#, capture_name, logminer_id,
startup_time, state, total_prefilter_discarded, total_prefilter_kept,
total_prefilter_evaluations, total_messages_captured, capture_time,
capture_message_number, capture_message_create_time,
total_messages_created, total_full_evaluations, total_messages_enqueued,
enqueue_time, enqueue_message_number, enqueue_message_create_time,
available_message_number, available_message_create_time,
elapsed_capture_time, elapsed_rule_time, elapsed_enqueue_time,
elapsed_lcr_time, elapsed_redo_wait_time, elapsed_pause_time,
state_changed_time, NULL, NULL, NULL, NULL, NULL, NULL, sga_used,
sga_allocated, bytes_of_redo_mined, session_restart_scn, con_id
from v$goldengate_capture;

create or replace public synonym "_V$SXGG_CAPTURE" for "_V$SXGG_CAPTURE";
grant select on "_V$SXGG_CAPTURE" to select_catalog_role;

create or replace view "_GV$SXGG_CAPTURE" container_data
as
select * from gv$streams_capture
union all
select inst_id, sid, serial#, capture#, capture_name, logminer_id,
startup_time, state, total_prefilter_discarded, total_prefilter_kept,
total_prefilter_evaluations, total_messages_captured, capture_time,
capture_message_number, capture_message_create_time,
total_messages_created, total_full_evaluations, total_messages_enqueued,
enqueue_time, enqueue_message_number, enqueue_message_create_time,
available_message_number, available_message_create_time,
elapsed_capture_time, elapsed_rule_time, elapsed_enqueue_time,
elapsed_lcr_time, elapsed_redo_wait_time, elapsed_pause_time,
state_changed_time, NULL, NULL, NULL, NULL, NULL, NULL, sga_used,
sga_allocated, bytes_of_redo_mined, session_restart_scn, con_id
from gv$xstream_capture
union all
select inst_id, sid, serial#, capture#, capture_name, logminer_id,
startup_time, state, total_prefilter_discarded, total_prefilter_kept,
total_prefilter_evaluations, total_messages_captured, capture_time,
capture_message_number, capture_message_create_time,
total_messages_created, total_full_evaluations, total_messages_enqueued,
enqueue_time, enqueue_message_number, enqueue_message_create_time,
available_message_number, available_message_create_time,
elapsed_capture_time, elapsed_rule_time, elapsed_enqueue_time,
elapsed_lcr_time, elapsed_redo_wait_time, elapsed_pause_time,
state_changed_time, NULL, NULL, NULL, NULL, NULL, NULL, sga_used,
sga_allocated, bytes_of_redo_mined, session_restart_scn, con_id
from gv$goldengate_capture;

create or replace public synonym "_GV$SXGG_CAPTURE" for "_GV$SXGG_CAPTURE";
grant select on "_GV$SXGG_CAPTURE" to select_catalog_role;

----------------------------------------------------------------------------

create or replace view DBA_SYNC_CAPTURE
  (CAPTURE_NAME, QUEUE_NAME, QUEUE_OWNER, RULE_SET_NAME, RULE_SET_OWNER, 
   CAPTURE_USER)
as
select cp.capture_name, cp.queue_name, cp.queue_owner, cp.ruleset_name,
       cp.ruleset_owner, u.name
 from "_DBA_CAPTURE" cp, sys.user$ u
 where cp.capture_userid = u.user# (+)
   and bitand(cp.flags,512) = 512
/
comment on table DBA_SYNC_CAPTURE is
'Details about the sync capture process'
/
comment on column DBA_SYNC_CAPTURE.CAPTURE_NAME is
'Name of the capture process'
/
comment on column DBA_SYNC_CAPTURE.QUEUE_NAME is
'Name of queue used for holding captured changes'
/
comment on column DBA_SYNC_CAPTURE.QUEUE_OWNER is
'Owner of the queue used for holding captured changes'
/
comment on column DBA_SYNC_CAPTURE.RULE_SET_NAME is
'Rule set used by capture process for filtering'
/
comment on column DBA_SYNC_CAPTURE.RULE_SET_OWNER is
'Owner of the rule set'
/
comment on column DBA_SYNC_CAPTURE.CAPTURE_USER is
'Current user who is enqueuing captured messages'
/
create or replace public synonym DBA_SYNC_CAPTURE for 
    DBA_SYNC_CAPTURE
/
grant select on DBA_SYNC_CAPTURE to select_catalog_role
/


execute CDBView.create_cdbview(false,'SYS','DBA_SYNC_CAPTURE','CDB_SYNC_CAPTURE');
grant select on SYS.CDB_SYNC_CAPTURE to select_catalog_role
/
create or replace public synonym CDB_SYNC_CAPTURE for SYS.CDB_SYNC_CAPTURE
/

-- View of all sync capture processes
create or replace view ALL_SYNC_CAPTURE
as
select c.*
  from dba_sync_capture c, all_queues q
 where c.queue_name = q.name
   and c.queue_owner = q.owner
   and ((c.rule_set_owner is null and c.rule_set_name is null) or
        ((c.rule_set_owner, c.rule_set_name) in 
          (select r.rule_set_owner, r.rule_set_name
             from all_rule_sets r)))
/
comment on table ALL_SYNC_CAPTURE is
'Details about each sync capture process that stores the captured changes in a queue visible to the current user'
/
comment on column ALL_SYNC_CAPTURE.CAPTURE_NAME is
'Name of the capture process'
/
comment on column ALL_SYNC_CAPTURE.QUEUE_NAME is
'Name of queue used for holding captured changes'
/
comment on column ALL_SYNC_CAPTURE.QUEUE_OWNER is
'Owner of the queue used for holding captured changes'
/
comment on column ALL_SYNC_CAPTURE.RULE_SET_NAME is
'Rule set used by capture process for filtering'
/
comment on column ALL_SYNC_CAPTURE.RULE_SET_OWNER is
'Owner of the rule set'
/
comment on column ALL_SYNC_CAPTURE.CAPTURE_USER is
'Current user who is enqueuing captured messages'
/
create or replace public synonym ALL_SYNC_CAPTURE for
    ALL_SYNC_CAPTURE
/   
grant select on ALL_SYNC_CAPTURE to select_catalog_role
/

REM
REM gg$_supported_packages
REM
-- system packages that are supported for replication
-- For OGG only
create table sys.gg$_supported_packages
(
   owner                    varchar2(384)  not null,  
   name                     varchar2(384)  not null,     
   feature                  varchar2(384)  not null,     
   min_db_version           varchar2(100)  default '12.2',         
   max_db_version           varchar2(100)  default NULL,
   min_redo_compat_level    varchar2(100)  default '12.2',
   max_redo_compat_level    varchar2(100)  default NULL,
   supported_level          varchar2(100)  default 'ALWAYS',
   spare1                   number         default NULL,
   spare2                   number         default NULL,
   spare3                   varchar2(4000) default NULL,
   spare4                   varchar2(4000) default NULL,
   spare5                   timestamp      default NULL
)
/
delete from sys.gg$_supported_packages;
insert into sys.gg$_supported_packages(owner, name, feature)
       values ('SYS', 'DBMS_REDEFINITION', 'REDEFINITION');
insert into sys.gg$_supported_packages(owner, name, feature) 
       values ('SYS', 'DBMS_FGA', 'FGA');
insert into sys.gg$_supported_packages(owner, name, feature) 
       values ('SYS', 'DBMS_RLS', 'RLS');
insert into sys.gg$_supported_packages(owner, name, feature) 
       values ('SYS', 'DBMS_REDACT', 'REDACTION');
insert into sys.gg$_supported_packages(owner, name, feature) 
       values ('SYS', 'DBMS_DDL', 'DBMS_DDL');
insert into sys.gg$_supported_packages(owner, name, feature) 
       values ('SYS', 'DBMS_SQL_TRANSLATOR', 'SQL_TRANSLATOR');
insert into sys.gg$_supported_packages(owner, name, feature) 
       values ('XDB', 'DBMS_XMLSCHEMA', 'XDB');
insert into sys.gg$_supported_packages(owner, name, feature) 
       values ('XDB', 'DBMS_XMLSCHEMA_LSB', 'XDB');
insert into sys.gg$_supported_packages(owner, name, feature) 
       values ('XDB', 'DBMS_XMLINDEX', 'XDB');
insert into sys.gg$_supported_packages(owner, name, feature) 
       values ('MDSYS', 'SDO_META', 'SDO');
insert into sys.gg$_supported_packages(owner, name, feature) 
       values ('MDSYS', 'SDO_META_USER', 'SDO');
Rem We target to support all packages in 'ALWAYS' mode
Rem Will adjust based on the test result
insert into sys.gg$_supported_packages(owner, name, feature)
       values ('SYS', 'DBMS_AQ', 'AQ');
insert into sys.gg$_supported_packages(owner, name, feature)
       values ('SYS', 'DBMS_AQADM', 'AQ');
insert into sys.gg$_supported_packages(owner, name, feature)
       values ('SYS', 'DBMS_AQELM', 'AQ');
insert into sys.gg$_supported_packages(owner, name, feature)
       values ('SYS', 'DBMS_AQJMS', 'AQ');
insert into sys.gg$_supported_packages(owner, name, feature)
       values ('SYS', 'DBMS_RULE_ADM', 'RULE');
insert into sys.gg$_supported_packages(owner, name, feature)
       values ('SYS', 'DBMS_DBFS_CONTENT_ADMIN', 'DBFS');
insert into sys.gg$_supported_packages(owner, name, feature)
       values ('SYS', 'DBMS_DBFS_SFS', 'DBFS');
insert into sys.gg$_supported_packages(owner, name, feature)
       values ('SYS', 'DBMS_DBFS_SFS_ADMIN', 'DBFS');
insert into sys.gg$_supported_packages(owner, name, feature)
       values ('XDB', 'DBMS_RESCONFIG', 'XDB');
insert into sys.gg$_supported_packages(owner, name, feature)
       values ('XDB', 'DBMS_XDBZ', 'XDB');
insert into sys.gg$_supported_packages(owner, name, feature)
       values ('XDB', 'DBMS_XDB_VERSION', 'XDB');
insert into sys.gg$_supported_packages(owner, name, feature)
       values ('XDB', 'DBMS_XDB', 'XDB');
insert into sys.gg$_supported_packages(owner, name, feature)
       values ('XDB', 'DBMS_XDB_ADMIN', 'XDB');
insert into sys.gg$_supported_packages(owner, name, feature)
       values ('XDB', 'DBMS_XDB_CONFIG', 'XDB');
insert into sys.gg$_supported_packages(owner, name, feature)
       values ('XDB', 'DBMS_XDB_REPOS', 'XDB');
insert into sys.gg$_supported_packages(owner, name, feature)
       values ('XDB', 'DBMS_XDBRESOURCE', 'XDB');
insert into sys.gg$_supported_packages(owner, name, feature)
       values ('SYS', 'DBMS_GOLDENGATE_ADM', 'AUTOCDR');
insert into sys.gg$_supported_packages(owner, name, feature)
       values ('SYS', 'DBMS_GOLDENGATE_IMP', 'AUTOCDR');
insert into sys.gg$_supported_packages(owner, name, feature)
       values ('SYS', 'XS_ACL', 'RAS');
insert into sys.gg$_supported_packages(owner, name, feature)
       values ('SYS', 'XS_ADMIN_UTIL', 'RAS');
insert into sys.gg$_supported_packages(owner, name, feature)
       values ('SYS', 'XS_DATA_SECURITY', 'RAS');
insert into sys.gg$_supported_packages(owner, name, feature)
       values ('SYS', 'XS_DATA_SECURITY_UTIL', 'RAS');
insert into sys.gg$_supported_packages(owner, name, feature)
       values ('SYS', 'XS_NAMESPACE', 'RAS');
insert into sys.gg$_supported_packages(owner, name, feature)
       values ('SYS', 'XS_PRINCIPAL', 'RAS');
insert into sys.gg$_supported_packages(owner, name, feature)
       values ('SYS', 'XS_SECURITY_CLASS', 'RAS');
commit;

REM
REM gg$_procedure_annotation
REM
-- annotating schema/object argument positions for the procedures 
-- in the supported packages
-- For OGG only
create table sys.gg$_procedure_annotation
(
   package_owner                varchar2(384) not null,
   package_name                 varchar2(384) not null,
   procedure_name               varchar2(384) not null,
   object_owner_argpos          number not null,
   object_argpos                number not null,
   min_db_version               varchar2(100) default '12.2',
   max_db_version               varchar2(100) default NULL,
   min_redo_compat_level        varchar2(100) default '12.2',
   max_redo_compat_level        varchar2(100) default NULL,
   flags                        number default 0,
   spare1                       number default NULL,
   spare2                       number default NULL,
   spare3                       varchar2(4000) default NULL,
   spare4                       varchar2(4000) default NULL,
   spare5                       timestamp default NULL
)
/

delete from sys.gg$_procedure_annotation;
REM
REM DBMS_REDEFINITION 
REM
insert into sys.gg$_procedure_annotation
       (package_owner,package_name,procedure_name,
        object_owner_argpos,object_argpos)
       values ('SYS', 'DBMS_REDEFINITION', 'START_REDEF_TABLE', 0, 1);
insert into sys.gg$_procedure_annotation
       (package_owner,package_name,procedure_name,
        object_owner_argpos,object_argpos)
       values ('SYS', 'DBMS_REDEFINITION', 'START_REDEF_TABLE', 0, 2);
insert into sys.gg$_procedure_annotation
       (package_owner,package_name,procedure_name,
        object_owner_argpos,object_argpos)
       values ('SYS', 'DBMS_REDEFINITION', 'SYNC_INTERIM_TABLE', 0, 1);
insert into sys.gg$_procedure_annotation
       (package_owner,package_name,procedure_name,
        object_owner_argpos,object_argpos)
       values ('SYS', 'DBMS_REDEFINITION', 'SYNC_INTERIM_TABLE', 0, 2);
insert into sys.gg$_procedure_annotation
       (package_owner,package_name,procedure_name,
        object_owner_argpos,object_argpos)
       values ('SYS', 'DBMS_REDEFINITION', 'FINISH_REDEF_TABLE', 0, 1);
insert into sys.gg$_procedure_annotation
       (package_owner,package_name,procedure_name,
        object_owner_argpos,object_argpos)
       values ('SYS', 'DBMS_REDEFINITION', 'FINISH_REDEF_TABLE', 0, 2);
insert into sys.gg$_procedure_annotation
       (package_owner,package_name,procedure_name,
        object_owner_argpos,object_argpos)
       values ('SYS', 'DBMS_REDEFINITION', 'ABORT_REDEF_TABLE', 0, 1);
insert into sys.gg$_procedure_annotation
       (package_owner,package_name,procedure_name,
        object_owner_argpos,object_argpos)
       values ('SYS', 'DBMS_REDEFINITION', 'ABORT_REDEF_TABLE', 0, 2);
insert into sys.gg$_procedure_annotation
       (package_owner,package_name,procedure_name,
        object_owner_argpos,object_argpos)
       values ('SYS', 'DBMS_REDEFINITION', 'COPY_TABLE_DEPENDENTS', 0, 1);
insert into sys.gg$_procedure_annotation
       (package_owner,package_name,procedure_name,
        object_owner_argpos,object_argpos)
       values ('SYS', 'DBMS_REDEFINITION', 'COPY_TABLE_DEPENDENTS', 0, 2);
insert into sys.gg$_procedure_annotation
       (package_owner,package_name,procedure_name,
        object_owner_argpos,object_argpos)
       values ('SYS', 'DBMS_REDEFINITION', 'REGISTER_DEPENDENT_OBJECT', 0, 1);
insert into sys.gg$_procedure_annotation
       (package_owner,package_name,procedure_name,
        object_owner_argpos,object_argpos)
       values ('SYS', 'DBMS_REDEFINITION', 'REGISTER_DEPENDENT_OBJECT', 0, 2);
insert into sys.gg$_procedure_annotation
       (package_owner,package_name,procedure_name,
        object_owner_argpos,object_argpos)
       values ('SYS','DBMS_REDEFINITION','UNREGISTER_DEPENDENTS_OBJECT', 0, 1);
insert into sys.gg$_procedure_annotation
       (package_owner,package_name,procedure_name,
        object_owner_argpos,object_argpos)
       values ('SYS','DBMS_REDEFINITION','UNREGISTER_DEPENDENTS_OBJECT', 0, 2);

REM
REM DBMS_FGA 
REM
insert into sys.gg$_procedure_annotation
       (package_owner,package_name,procedure_name,
        object_owner_argpos,object_argpos)
       values ('SYS', 'DBMS_FGA', 'ADD_POLICY', 0, 1);
insert into sys.gg$_procedure_annotation
       (package_owner,package_name,procedure_name,
        object_owner_argpos,object_argpos)
       values ('SYS', 'DBMS_FGA', 'DISABLE_POLICY', 0, 1);
insert into sys.gg$_procedure_annotation
       (package_owner,package_name,procedure_name,
        object_owner_argpos,object_argpos)
       values ('SYS', 'DBMS_FGA', 'DROP_POLICY', 0, 1);
insert into sys.gg$_procedure_annotation
       (package_owner,package_name,procedure_name,
        object_owner_argpos,object_argpos)
       values ('SYS', 'DBMS_FGA', 'ENABLE_POLICY', 0, 1);

REM
REM DBMS_RLS
REM
insert into sys.gg$_procedure_annotation
       (package_owner,package_name,procedure_name,
        object_owner_argpos,object_argpos)
       values ('SYS', 'DBMS_RLS', 'ADD_POLICY', 0, 1);
insert into sys.gg$_procedure_annotation
       (package_owner,package_name,procedure_name,
        object_owner_argpos,object_argpos)
       values ('SYS', 'DBMS_RLS', 'ADD_GROUPED_POLICY', 0, 1);
insert into sys.gg$_procedure_annotation
       (package_owner,package_name,procedure_name,
        object_owner_argpos,object_argpos)
       values ('SYS', 'DBMS_RLS', 'ADD_POLICY_CONTEXT', 0, 1);
insert into sys.gg$_procedure_annotation
       (package_owner,package_name,procedure_name,
        object_owner_argpos,object_argpos)
       values ('SYS', 'DBMS_RLS', 'CREATE_POLICY_GROUP', 0, 1);
insert into sys.gg$_procedure_annotation
       (package_owner,package_name,procedure_name,
        object_owner_argpos,object_argpos)
       values ('SYS', 'DBMS_RLS', 'DELETE_POLICY_GROUP', 0, 1);
insert into sys.gg$_procedure_annotation
       (package_owner,package_name,procedure_name,
        object_owner_argpos,object_argpos)
        values ('SYS', 'DBMS_RLS', 'DISABLE_POLICY_GROUP', 0, 1);
insert into sys.gg$_procedure_annotation
       (package_owner,package_name,procedure_name,
        object_owner_argpos,object_argpos)
        values ('SYS', 'DBMS_RLS', 'DROP_POLICY_GROUP', 0, 1);
insert into sys.gg$_procedure_annotation
       (package_owner,package_name,procedure_name,
        object_owner_argpos,object_argpos)
       values ('SYS', 'DBMS_RLS', 'DROP_POLICY_CONTEXT', 0, 1);
insert into sys.gg$_procedure_annotation
       (package_owner,package_name,procedure_name,
        object_owner_argpos,object_argpos)
       values ('SYS', 'DBMS_RLS', 'ENABLE_POLICY', 0, 1);
insert into sys.gg$_procedure_annotation
       (package_owner,package_name,procedure_name,
        object_owner_argpos,object_argpos)
       values ('SYS', 'DBMS_RLS', 'ENABLE_GROUPED_POLICY', 0, 1);
insert into sys.gg$_procedure_annotation
       (package_owner,package_name,procedure_name,
        object_owner_argpos,object_argpos)
       values ('SYS', 'DBMS_RLS', 'REFRESH_GROUPED_POLICY', 0, 1);
insert into sys.gg$_procedure_annotation
       (package_owner,package_name,procedure_name,
        object_owner_argpos,object_argpos)
       values ('SYS', 'DBMS_RLS', 'REFRESH_POLICY', 0, 1);

REM
REM DBMS_RLS_INT
REM
insert into sys.gg$_procedure_annotation
       (package_owner,package_name,procedure_name,
        object_owner_argpos,object_argpos)
       values ('SYS', 'DBMS_RLS_INT', 'ADD_POLICY', 0, 1);
insert into sys.gg$_procedure_annotation
       (package_owner,package_name,procedure_name,
        object_owner_argpos,object_argpos)
       values ('SYS', 'DBMS_RLS_INT', 'ALTER_POLICY', 0, 1);
insert into sys.gg$_procedure_annotation
       (package_owner,package_name,procedure_name,
        object_owner_argpos,object_argpos)
       values ('SYS', 'DBMS_RLS_INT', 'ALTER_GROUPED_POLICY', 0, 1);
insert into sys.gg$_procedure_annotation
       (package_owner,package_name,procedure_name,
        object_owner_argpos,object_argpos)
       values ('SYS', 'DBMS_RLS_INT', 'ADD_GROUPED_POLICY', 0, 1);
insert into sys.gg$_procedure_annotation
       (package_owner,package_name,procedure_name,
        object_owner_argpos,object_argpos)
       values ('SYS', 'DBMS_RLS_INT', 'DROP_POLICY', 0, 1);
insert into sys.gg$_procedure_annotation
       (package_owner,package_name,procedure_name,
        object_owner_argpos,object_argpos)
       values ('SYS', 'DBMS_RLS_INT', 'DROP_GROUPED_POLICY', 0, 1);
insert into sys.gg$_procedure_annotation
       (package_owner,package_name,procedure_name,
        object_owner_argpos,object_argpos)
       values ('SYS', 'DBMS_RLS_INT', 'ADD_POLICY_CONTEXT', 0, 1);
insert into sys.gg$_procedure_annotation
       (package_owner,package_name,procedure_name,
        object_owner_argpos,object_argpos)
       values ('SYS', 'DBMS_RLS_INT', 'CREATE_POLICY_GROUP', 0, 1);
insert into sys.gg$_procedure_annotation
       (package_owner,package_name,procedure_name,
        object_owner_argpos,object_argpos)
       values ('SYS', 'DBMS_RLS_INT', 'DELETE_POLICY_GROUP', 0, 1);
insert into sys.gg$_procedure_annotation
       (package_owner,package_name,procedure_name,
        object_owner_argpos,object_argpos)
       values ('SYS', 'DBMS_RLS_INT', 'DROP_POLICY_CONTEXT', 0, 1);
insert into sys.gg$_procedure_annotation
       (package_owner,package_name,procedure_name,
        object_owner_argpos,object_argpos)
       values ('SYS', 'DBMS_RLS_INT', 'ENABLE_POLICY', 0, 1);
insert into sys.gg$_procedure_annotation
       (package_owner,package_name,procedure_name,
        object_owner_argpos,object_argpos)
       values ('SYS', 'DBMS_RLS_INT', 'ENABLE_GROUPED_POLICY', 0, 1);
insert into sys.gg$_procedure_annotation
       (package_owner,package_name,procedure_name,
        object_owner_argpos,object_argpos)
       values ('SYS', 'DBMS_RLS_INT', 'DISABLE_GROUPED_POLICY', 0, 1);
insert into sys.gg$_procedure_annotation
       (package_owner,package_name,procedure_name,
        object_owner_argpos,object_argpos)
       values ('SYS', 'DBMS_RLS_INT', 'REFRESH_GROUPED_POLICY', 0, 1);
insert into sys.gg$_procedure_annotation
       (package_owner,package_name,procedure_name,
        object_owner_argpos,object_argpos)
       values ('SYS', 'DBMS_RLS_INT', 'REFRESH_POLICY', 0, 1);


REM
REM DBMS_REDACT
REM
insert into sys.gg$_procedure_annotation
       (package_owner,package_name,procedure_name,
        object_owner_argpos,object_argpos)
       values ('SYS', 'DBMS_REDACT', 'ADD_POLICY', 0, 1);
insert into sys.gg$_procedure_annotation
       (package_owner,package_name,procedure_name,
        object_owner_argpos,object_argpos)
       values ('SYS', 'DBMS_REDACT', 'ALTER_POLICY', 0, 1);
insert into sys.gg$_procedure_annotation
       (package_owner,package_name,procedure_name,
        object_owner_argpos,object_argpos)
       values ('SYS', 'DBMS_REDACT', 'DISABLE_POLICY', 0, 1);
insert into sys.gg$_procedure_annotation
       (package_owner,package_name,procedure_name,
        object_owner_argpos,object_argpos)
       values ('SYS', 'DBMS_REDACT', 'DROP_POLICY', 0, 1);
insert into sys.gg$_procedure_annotation
       (package_owner,package_name,procedure_name,
        object_owner_argpos,object_argpos)
       values ('SYS', 'DBMS_REDACT', 'ENABLE_POLICY', 0, 1);

REM
REM DBMS_DDL
REM
insert into sys.gg$_procedure_annotation
       (package_owner,package_name,procedure_name,
        object_owner_argpos,object_argpos)
       values ('SYS', 'DBMS_DDL', 'ALTER_COMPILE', 1, 2);
insert into sys.gg$_procedure_annotation
       (package_owner,package_name,procedure_name,
        object_owner_argpos,object_argpos)
       values ('SYS', 'DBMS_DDL', 'ALTER_TABLE_NOT_REFERENCEABLE', 1, 0);
insert into sys.gg$_procedure_annotation
       (package_owner,package_name,procedure_name,
        object_owner_argpos,object_argpos)
       values ('SYS', 'DBMS_DDL', 'ALTER_TABLE_REFERENCEABLE', 1, 0);

REM
REM XS_DATA_SECURITY
REM
insert into sys.gg$_procedure_annotation
       (package_owner,package_name,procedure_name,
        object_owner_argpos,object_argpos)
       values ('SYS', 'XS_DATA_SECURITY', 'ENABLE_OBJECT_POLICY', 1, 2);
insert into sys.gg$_procedure_annotation
       (package_owner,package_name,procedure_name,
        object_owner_argpos,object_argpos)
       values ('SYS', 'XS_DATA_SECURITY', 'DISABLE_OBJECT_POLICY', 1, 2);
insert into sys.gg$_procedure_annotation
       (package_owner,package_name,procedure_name,
        object_owner_argpos,object_argpos)
       values ('SYS', 'XS_DATA_SECURITY', 'REMOVE_OBJECT_POLICY', 1, 2);
insert into sys.gg$_procedure_annotation
       (package_owner,package_name,procedure_name,
        object_owner_argpos,object_argpos)
       values ('SYS', 'XS_DATA_SECURITY', 'APPLY_OBJECT_POLICY', 1, 2);

REM
REM XS_DATA_SECURITY_UTIL
REM
insert into sys.gg$_procedure_annotation
       (package_owner,package_name,procedure_name,
        object_owner_argpos,object_argpos)
       values ('SYS', 'XS_DATA_SECURITY_UTIL', 'SCHEDULE_STATIC_ACL_REFRESH', 0, 1);
insert into sys.gg$_procedure_annotation
       (package_owner,package_name,procedure_name,
        object_owner_argpos,object_argpos)
       values ('SYS', 'XS_DATA_SECURITY_UTIL', 'ALTER_STATIC_ACL_REFRESH', 0, 1);

create index i_gg_procedure_annotation on 
       sys.gg$_procedure_annotation (package_owner,package_name,procedure_name)
/


REM
REM gg$_proc_object_exclusion
REM
-- the pl/sql procedures that are to be filtered if 
-- they apply on the specified objects
-- For OGG only
create table sys.gg$_proc_object_exclusion
(
   package_owner       varchar2(384) default '*',  /* means match all */
   package_name        varchar2(384) default '*',  /* means match all */
   procedure_name      varchar2(384) default '*',  /* means match all */
   object_owner        varchar2(384) default '*',  /* means match all */
   object_name         varchar2(384) default '*',  /* means match all */
   spare1              number default NULL,
   spare2              number default NULL,
   spare3              varchar2(4000) default NULL,
   spare4              varchar2(4000) default NULL,
   spare5              timestamp default NULL
)
/

delete from sys.gg$_proc_object_exclusion;
insert into sys.gg$_proc_object_exclusion
       (package_owner,package_name, object_owner)
       values('SYS', 'DBMS_REDEFINITION', 'SYS');
insert into sys.gg$_proc_object_exclusion
       (package_owner,package_name, object_owner)
       values('SYS', 'DBMS_FGA', 'SYS');
insert into sys.gg$_proc_object_exclusion
       (package_owner,package_name, object_owner)
       values('SYS', 'DBMS_RLS_INT', 'SYS');
insert into sys.gg$_proc_object_exclusion
       (package_owner,package_name, object_owner)
       values('SYS', 'DBMS_REDACT', 'SYS');
insert into sys.gg$_proc_object_exclusion
       (package_owner,package_name, object_owner)
       values('SYS', 'DBMS_DDL', 'SYS');
commit;

create index i_gg_proc_object_exclusion on
       sys.gg$_proc_object_exclusion(package_owner, package_name)
/

REM
REM gg$_package_mapping
REM
-- List of PLSQL mapping between external (user invokable) procedures to
-- the corresponding pragm-ed (supplemental log pragma) internal procedure.
create table sys.gg$_package_mapping
(
   ext_package_owner       varchar2(384) not NULL,  
   ext_package_name        varchar2(384) not NULL,  
   ext_procedure_name      varchar2(384) default NULL,  /* NULL means all */
   int_package_owner       varchar2(384) not NULL,  
   int_package_name        varchar2(384) not NULL,  
   int_procedure_name      varchar2(384) default NULL,  /* NULL means all */
   spare1                  number default NULL,
   spare2                  number default NULL,
   spare3                  varchar2(4000) default NULL,
   spare4                  varchar2(4000) default NULL,
   spare5                  timestamp default NULL
)
/

delete from sys.gg$_package_mapping;
insert into sys.gg$_package_mapping
       (ext_package_owner,ext_package_name,int_package_owner,int_package_name)
       values('SYS', 'DBMS_AQADM', 'SYS', 'DBMS_AQADM_SYS');
insert into sys.gg$_package_mapping
       (ext_package_owner,ext_package_name,int_package_owner,int_package_name)
       values('SYS', 'DBMS_AQADM', 'SYS', 'DBMS_PRVTAQIS');
insert into sys.gg$_package_mapping
       (ext_package_owner,ext_package_name,int_package_owner,int_package_name)
       values('SYS', 'DBMS_RULE_ADM',  'SYS', 'DBMS_RULEADM_INTERNAL');
insert into sys.gg$_package_mapping
       (ext_package_owner,ext_package_name, ext_procedure_name,
        int_package_owner,int_package_name,int_procedure_name)
       values('SYS', 'DBMS_AQ', 'ENQUEUE', 
              'SYS', 'DBMS_AQ', 'ENQUEUE_INT_UNSHARDED');
insert into sys.gg$_package_mapping
       (ext_package_owner,ext_package_name, ext_procedure_name,
        int_package_owner,int_package_name,int_procedure_name)
       values('SYS', 'DBMS_AQ', 'DEQUEUE',
              'SYS', 'DBMS_AQ', 'DEQUEUE_INTERNAL');
insert into sys.gg$_package_mapping
       (ext_package_owner,ext_package_name, ext_procedure_name,
        int_package_owner,int_package_name,int_procedure_name)
       values('SYS', 'DBMS_AQADM', 'ADD_SUBSCRIBER', 
              'SYS', 'DBMS_PRVTAQIS', 'SUBID_REPLICATE');
insert into sys.gg$_package_mapping
       (ext_package_owner,ext_package_name, ext_procedure_name,
        int_package_owner,int_package_name,int_procedure_name)
       values('SYS', 'DBMS_AQ', 'REGISTER',
              'SYS', 'DBMS_AQ', 'REGISTRATION_REPLICATION');
insert into sys.gg$_package_mapping
       (ext_package_owner,ext_package_name,int_package_owner,int_package_name)
       values('XDB', 'DBMS_XMLSCHEMA', 'XDB', 'DBMS_XMLSCHEMA_LSB');
insert into sys.gg$_package_mapping
       (ext_package_owner,ext_package_name,int_package_owner,int_package_name)
       values('SYS', 'DBMS_GOLDENGATE_ADM', 'SYS',
              'DBMS_GOLDENGATE_ADM_INT_INVOK');
insert into sys.gg$_package_mapping
       (ext_package_owner,ext_package_name,int_package_owner,int_package_name)
       values('SYS', 'DBMS_RLS', 'SYS', 'DBMS_RLS_INT');
commit;

-- Views of OGG plsql filtering support
create or replace view DBA_GG_SUPPORTED_PACKAGES
as
select owner, name, feature, min_db_version, max_db_version, 
       min_redo_compat_level, max_redo_compat_level, supported_level
       from sys.gg$_supported_packages
/

comment on table DBA_GG_SUPPORTED_PACKAGES is
'Details about supported procedure packages for GoldenGate replication'
/
comment on column DBA_GG_SUPPORTED_PACKAGES.OWNER is
'Procedure package owner'
/
comment on column DBA_GG_SUPPORTED_PACKAGES.NAME is
'Procedure package name'
/
comment on column DBA_GG_SUPPORTED_PACKAGES.FEATURE is
'DBMS Feature the Procedure package belongs to'
/
comment on column DBA_GG_SUPPORTED_PACKAGES.MIN_DB_VERSION is
'Minimum DB version for the supported package'
/
comment on column DBA_GG_SUPPORTED_PACKAGES.MAX_DB_VERSION is
'Maximum DB version for the supported package'
/
comment on column DBA_GG_SUPPORTED_PACKAGES.MIN_REDO_COMPAT_LEVEL is
'Minimum redo compatibility for the supported package'
/
comment on column DBA_GG_SUPPORTED_PACKAGES.MAX_REDO_COMPAT_LEVEL is
'Maximum redo compatibility for the supported package'
/
comment on column DBA_GG_SUPPORTED_PACKAGES.SUPPORTED_LEVEL is
'Supported level of the package'
/
create or replace public synonym DBA_GG_SUPPORTED_PACKAGES 
for sys.DBA_GG_SUPPORTED_PACKAGES
/
grant select on DBA_GG_SUPPORTED_PACKAGES to select_catalog_role
/

begin
SYS.CDBView.create_cdbview(false,'SYS','DBA_GG_SUPPORTED_PACKAGES', 
                                   'CDB_GG_SUPPORTED_PACKAGES');
end;
/
create or replace public synonym CDB_GG_SUPPORTED_PACKAGES 
  for sys.CDB_GG_SUPPORTED_PACKAGES;
grant select on CDB_GG_SUPPORTED_PACKAGES to select_catalog_role;

create or replace view DBA_GG_PROCEDURE_ANNOTATION
as
select package_owner, package_name, procedure_name, 
       object_owner_argpos, object_argpos,
       min_db_version, max_db_version, min_redo_compat_level,
       max_redo_compat_level, flags
       from sys.gg$_procedure_annotation
/
comment on table DBA_GG_PROCEDURE_ANNOTATION is
'Annotate the position of Owner and Object arguments in procedure calls'
/
comment on column DBA_GG_PROCEDURE_ANNOTATION.PACKAGE_OWNER is
'Procedure package owner'
/
comment on column DBA_GG_PROCEDURE_ANNOTATION.PACKAGE_NAME is
'Procedure package name'
/
comment on column DBA_GG_PROCEDURE_ANNOTATION.PROCEDURE_NAME is
'Procedure name'
/
comment on column DBA_GG_PROCEDURE_ANNOTATION.OBJECT_OWNER_ARGPOS is
'Object owner name position in argument list, -1 if not present'
/
comment on column DBA_GG_PROCEDURE_ANNOTATION.OBJECT_ARGPOS is
'Object name position in argument list, -1 if not present'
/
comment on column DBA_GG_PROCEDURE_ANNOTATION.MIN_DB_VERSION is
'Minimum DB version for the procedure'
/
comment on column DBA_GG_PROCEDURE_ANNOTATION.MAX_DB_VERSION is
'Maximum DB version for the procedure'
/
comment on column DBA_GG_PROCEDURE_ANNOTATION.MIN_REDO_COMPAT_LEVEL is
'Minimum redo compatibility for the procedure'
/
comment on column DBA_GG_PROCEDURE_ANNOTATION.MAX_REDO_COMPAT_LEVEL is
'Maximum redo compatibility for the procedure'
/
comment on column DBA_GG_PROCEDURE_ANNOTATION.FLAGS is
'Aditional information about procedure arguments'
/

create or replace public synonym DBA_GG_PROCEDURE_ANNOTATION 
for sys.DBA_GG_PROCEDURE_ANNOTATION
/
grant select on DBA_GG_PROCEDURE_ANNOTATION to select_catalog_role
/

begin
SYS.CDBView.create_cdbview(false,'SYS','DBA_GG_PROCEDURE_ANNOTATION', 
                           'CDB_GG_PROCEDURE_ANNOTATION');
end;
/
create or replace public synonym CDB_GG_PROCEDURE_ANNOTATION 
   for sys.CDB_GG_PROCEDURE_ANNOTATION;
grant select on CDB_GG_PROCEDURE_ANNOTATION to select_catalog_role;


create or replace view DBA_GG_PROC_OBJECT_EXCLUSION
as
select package_owner, package_name, object_owner, object_name
       from sys.gg$_proc_object_exclusion 
where object_owner not in ('SYS')
/
comment on table DBA_GG_PROC_OBJECT_EXCLUSION is
'Details all tables that should be filtered when operating on given objects'
/
comment on column DBA_GG_PROC_OBJECT_EXCLUSION.PACKAGE_OWNER is
'Procedure package owner'
/
comment on column DBA_GG_PROC_OBJECT_EXCLUSION.PACKAGE_NAME is
'Procedure package name'
/
comment on column DBA_GG_PROC_OBJECT_EXCLUSION.OBJECT_OWNER is
'Object owner to filter for the given procedure'
/
comment on column DBA_GG_PROC_OBJECT_EXCLUSION.OBJECT_NAME is
'Object name to filter for the given procedure'
/

create or replace public synonym DBA_GG_PROC_OBJECT_EXCLUSION 
for sys.DBA_GG_PROC_OBJECT_EXCLUSION
/
grant select on DBA_GG_PROC_OBJECT_EXCLUSION to select_catalog_role
/

begin
SYS.CDBView.create_cdbview(false,'SYS','DBA_GG_PROC_OBJECT_EXCLUSION', 
                           'CDB_GG_PROC_OBJECT_EXCLUSION');
end;
/
create or replace public synonym CDB_GG_PROC_OBJECT_EXCLUSION 
   for sys.CDB_GG_PROC_OBJECT_EXCLUSION;
grant select on CDB_GG_PROC_OBJECT_EXCLUSION to select_catalog_role;

/*
** This view lists all supported PLSQL procedures for procedural replication.
** Valid values for SUPPORTED_MODE are 
**     ALWAYS
**     DBMS_ROLLING
** Valid values for EXCLUSION_RULE_EXISTS
**     YES
**     NO
*/
create or replace view DBA_GG_SUPPORTED_PROCEDURES
  (OWNER, PACKAGE_NAME, PROCEDURE_NAME, MIN_DB_VERSION, MAX_DB_VERSION, 
   MIN_REDO_COMPAT_LEVEL, MAX_REDO_COMPAT_LEVEL, SUPPORTED_MODE, 
   EXCLUSION_RULE_EXISTS)
as
  select unique p.owner, p.object_name, p.procedure_name, 
    sp.min_db_version, sp.max_db_version, 
    sp.min_redo_compat_level, sp.max_redo_compat_level,
    case when bitand(i.properties, 33554432) != 0 /* pragma unsupported */ 
         then 'APPLY unsupported'
         when bitand(i.properties, 67108864) != 0 
         then 'CAPTURE unsupported'
         else sp.supported_level end,
    case when exists (
              select x.package_name from sys.gg$_proc_object_exclusion x
              where (x.package_owner=p.owner or x.package_owner is NULL) 
                    and
                    (x.package_name=p.object_name or x.package_name is NULL) 
                    and
                    (x.procedure_name=p.procedure_name or 
                     x.procedure_name is NULL)
                    and
                    /* exclude the case for obj belongs to SYS */
                    (x.object_owner not in ('SYS'))  
         ) 
         then 'YES' else 'NO' end
  from dba_procedures p, sys.gg$_supported_packages sp, procedureinfo$ i
  where p.owner = sp.owner and
        p.object_name = sp.name and
        p.procedure_name = i.procedurename and
        p.object_id = i.obj# and 
        bitand(i.properties, 503316480) != 0 and
        (bitand(i.properties, 33554432) != 0 or    /* unsupported */
         bitand(i.properties, 134217728) != 0 or   /* auto */
         bitand(i.properties, 67108864) != 0 or    /* manual */
         bitand(i.properties, 268435456) != 0)     /* 'NONE' */
/

comment on table DBA_GG_SUPPORTED_PROCEDURES is
'Details all procedures that are supported for replication'
/
comment on column DBA_GG_SUPPORTED_PROCEDURES.OWNER is
'Procedure package owner'
/
comment on column DBA_GG_SUPPORTED_PROCEDURES.PACKAGE_NAME is
'Procedure package name'
/
comment on column DBA_GG_SUPPORTED_PROCEDURES.PROCEDURE_NAME is
'Procedure name'
/
comment on column DBA_GG_SUPPORTED_PROCEDURES.MIN_DB_VERSION is
'Minimum DB version for the procedure'
/
comment on column DBA_GG_SUPPORTED_PROCEDURES.MAX_DB_VERSION is
'Maximum DB version for the procedure'
/
comment on column DBA_GG_SUPPORTED_PROCEDURES.MIN_REDO_COMPAT_LEVEL is
'Minimum redo compatibility for the procedure'
/
comment on column DBA_GG_SUPPORTED_PROCEDURES.MAX_REDO_COMPAT_LEVEL is
'Maximum redo compatibility for the procedure'
/
comment on column DBA_GG_SUPPORTED_PROCEDURES.SUPPORTED_MODE is
'Supported mode for the procedure: ALWAYS or DBMS_ROLLING'
/
comment on column DBA_GG_SUPPORTED_PROCEDURES.EXCLUSION_RULE_EXISTS is
'Exclusion rule exists for the procedure. Refer to DBA_GG_PROC_OBJECT_EXCLUSION'
/

create or replace public synonym DBA_GG_SUPPORTED_PROCEDURES 
for sys.DBA_GG_SUPPORTED_PROCEDURES
/
grant select on DBA_GG_SUPPORTED_PROCEDURES to select_catalog_role
/

begin
SYS.CDBView.create_cdbview(false,'SYS','DBA_GG_SUPPORTED_PROCEDURES', 
                           'CDB_GG_SUPPORTED_PROCEDURES');
end;
/
create or replace public synonym CDB_GG_SUPPORTED_PROCEDURES 
   for sys.CDB_GG_SUPPORTED_PROCEDURES;
grant select on CDB_GG_SUPPORTED_PROCEDURES to select_catalog_role;

@?/rdbms/admin/sqlsessend.sql
