Rem
Rem $Header: rdbms/admin/catilmtab.sql /st_rdbms_18.0/1 2017/12/08 14:50:20 hlakshma Exp $
Rem
Rem catilmtab.sql
Rem
Rem Copyright (c) 2011, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catilmtab.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catilmtab.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catilmtab.sql
Rem SQL_PHASE: CATILMTAB
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: ORA-00955, ORA-02261
Rem SQL_CALLING_FILE: rdbms/admin/catpstrt.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    hlakshma    11/14/17 - Bug 27119186: Default flag val for heat map row
Rem    hlakshma    07/22/17 - Add ignorable errors ora-02261, ora-00955 
Rem                           (bug-26442308)
Rem    hlakshma    04/19/17 - Add index to ilm_results$ (bug-25917073)
Rem    hlakshma    04/04/17 - Diagnostic columns for AIM tables (bug-25825879)
Rem    hlakshma    01/17/17 - Add dictionary table for AIM parameters (project
Rem                           68505)
Rem    hlakshma    01/10/17 - Add state column to IM task table (Project 68505)
Rem    prgaharw    03/04/16 - Proj 45958: Add IM policies cols to ADO dict
Rem    hlakshma    11/29/15 - Add dictionary tables for ADO DBIM diagnostics
Rem                           (bug 22258960)
Rem    raeburns    06/09/15 - Use FORCE for types with only table dependents
Rem    shrgauta    05/05/15 - Bug 9361105 Moved compression$ to dsqlddl.bsq
Rem    vinisubr    03/25/15 - Project 58876: Added support for querying kernel 
Rem                           column statistics in memory and on disk
Rem    hlakshma    02/10/15 - Project 45958: Add sequence for ADO IMC task 
Rem                           generation. Also add columns to heat_map_stat$ 
Rem                           table to record frequency of access
Rem    dhdhshah    08/05/14 - 18718931: add last_ilmdict_cleanup to
Rem                           ilm_concurrency$
Rem    ashrives    05/21/14 - 18543824: Create index on ilm_results$
Rem    hlakshma    02/18/14 - Reserve a bit in the FLAG for indicating all jobs
Rem                           for a task are scheduled
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    hlakshma    11/22/13 - Add last purge time to ilm_concurrency$
Rem    prgaharw    11/25/12 - 15865137 - Update ILM dict/create indexes
Rem    vraja       10/15/12 - ILM renamed to HEAT_MAP
Rem    smuthuli    09/28/12 - add tsn to ilm_stat$
Rem    amylavar    09/24/12 - Change 'OLTP' to 'ADVANCED'
Rem    prgaharw    09/19/12 - 13861386 - new type to build csv list
Rem    hlakshma    08/29/12 - Add support for EHCC row locking
Rem    hlakshma    05/22/12 - Add indexes for ILM dictionary tables
Rem    hlakshma    04/24/12 - Add column to record number of ILM job failures
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    liaguo      02/21/12 - ilm_extent_stat$
Rem    hlakshma    01/19/12 - Add Flags representing ILM task state in
Rem                           ilm_execution$
Rem    hlakshma    01/18/12 - Add constraint on sys.ilm_param$
Rem    apatthak    12/20/11 - Bug fix 9538366, adding unaligned cu count in
Rem                           compression_stat
Rem    liaguo      11/09/11 - Move ilm_stat$ to SYSAUX
Rem    hlakshma    11/06/11 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

Rem
Rem For review of changes to ILM related tables please contact the data layer
Rem manager

Rem
Rem ILM top level table - can be used by multiple ILM clients
Rem 
create table ilm$
(
  policy#       number,                               /* unique policy number*/
  name          varchar2(128) not null,                  /* policy name */
  owner#        number,                                      /* owner number */
  ts#           number,                                 /* tablespace number */
  ptype         number       not null,                      /* client number */
                                        /* 1-reserved for client comp/st.tier*/
  flag          number,                                        /* ilm$ flags */
                                             /* 0x0001 -     policy disabled */
                                             /* 0x0002 -        schema level */
                                             /* 0x0004 -              unused */
                                             /* 0x0008 -    tablespace level */
                                             /* 0x0010 -      default policy */
  flag2         number,                                             /* spare */
  spare1        number,                                             /* spare */
  spare2        number,                                             /* spare */
  spare3        number,                                             /* spare */
  spare4        varchar2(4000),                                     /* spare */
  spare5        varchar2(4000),                                     /* spare */
  spare6        timestamp                                           /* spare */
)
tablespace SYSAUX
/

REM compression stats table
create table compression_stat$
( obj#            number not null,                                   /* OBJ# */
  dataobj#        number not null,                               /* DATAOBJ# */
  avgrowsize_nc   number(*, 2),           /* non-compressed average row size */
  avgrowsize_c    number(*, 2),                  /* on disk average row size */
  ts#             number,                                    /* tablespace # */
  file#           number,                           /* segment header file # */
  block#          number,                          /* segment header block # */
  nblk_nc         number,                 /* number of non compressed blocks */
  nblk_advanced   number,                /* number of oltp compressed blocks */
  nblk_ehcc       number,                /* number of ehcc compressed blocks */
  nblk_uahcc      number,           /* number of unaligned compressed blocks */
  nrows_nc        number,                   /* number of non-compressed rows */
  nrows_advanced  number,                       /* number of compressed rows */
  nrows_ehcc      number                   /* number of ehcc compressed rows */
)
tablespace SYSAUX
/

Rem
Rem Table mapping ILM policy attrs. to policy# in top level table
Rem
create table ilmpolicy$
(
  policy#       number,                                     /* policy number */
  actionc       varchar2(100),                              /* action clause */
  ctype         number,                                  /* compression type */
  clevel        number,                                 /* compression level */
  cindex        number,                        /*  Index compression level   */
                                               /*  0x0001 prefix compression */
                                          /*  0x0002 OLTP compression high   */
                                          /*  0x0003 OLTP compression low    */
  cprefix       number,   /* Number of columns in case of prefix compression */
  clevlob       number,                             /* LOB compression level */
                                                               /* 0x0001 LOW */
                                                            /* 0x0002 MEDIUM */
                                                              /* 0x0003 HIGH */
  tier_tbs      varchar2(128),                      /* Tablespace to tier to */
  action        number,                                       /* action code */
                                                        /* 1     Compression */
                                                        /* 2 Storage tiering */
                                                        /* 3         TIERing */
                                                        /* 4        EVICTion */
                                                        /* 5        ANNOTATE */
  type          number,                      /* add, delete etc. policy type */
  condition     number,                                    /* condition code */
  days          number,                                    /* number of days */
  scope         number,                                      /* policy scope */
  custfunc      varchar2(128),                           /* cust. func. name */
  flag          number,                                      /* policy flags */
                                                      /* 0x0001 -  READ-ONLY */
                                                         /* 0x0002 -  unused */
                                                         /* 0x0004 - inplace */
                                                         /* 0x0008 -  custom */
                                                           /* 0x0010 - GROUP */
                                               /* 0x0020 - Row level locking */
  flag2         number,                             /* flag2 - fields unused */
  spare1        number,                                             /* spare */
  spare2        number,                                             /* spare */
  spare3        number,                                             /* spare */
  spare4        varchar2(4000),                                     /* spare */
  spare5        varchar2(4000),                                     /* spare */
  spare6        timestamp,
  pol_subtype   number,                              /* policy sub-type code */
                                                             /* 0       DISK */
                                                             /* 1   INMEMORY */
                                                             /* 2 CELLMEMORY */
  /* need a clob because 100 is not enough in actionc */
  actionc_clob  clob,                                       /* action clause */
  tier_to       number                                     /* tiering format */
                                                             /* 0 TABLESPACE */
                                                             /* 1   INMEMORY */
                                                             /* 2 CELLMEMORY */
)
tablespace SYSAUX
/

Rem
Rem Table mapping ILM policies to objects
Rem
create table ilmobj$
(
  policy#       number not null,                            /* policy number */
  obj#          number not null,                            /* object number */
  dataobj#      number,                                /* data object number */
  last_chk_time timestamp,           /* Time the ILM policy was last checked */
  last_exe_time timestamp,          /* Time the ILM policy was last executed */
  obj_typ       number,                 /* object type (see KQD.H for types) */
  obj_typ_orig  number,    /* object type on which policy originally defined */
  pobjn_orig    number,    /* objn of obj on which policy originally defined */
  flag          number,                                             /* flags */
                                       /* 0x0001 - policy on object disabled */
                                       /* 0x0002 -     inherited from schema */
                                       /* 0x0004 -                    unused */
                                       /* 0x0008 - inherited from tablespace */
  last_job_status number,                      /* Status of the last ILM job */
                                             /*  2 - Last completion Success */
                                              /* 3 - Last completion Failure */
                                                     /* 4 - Last job stopped */
                                    /* 5 - Last job killed by ILM Frame work */
  n_fail        number default 0,    /* Num of times policy execution failed */
  n_aft_nofilt  number default 0,   /* # of jobs after cold blocks !filtered */
  spare1        number,                                             /* spare */
  spare2        number,                                             /* spare */
  spare3        number,                                             /* spare */
  spare4        varchar2(4000),                                     /* spare */
  spare5        varchar2(4000),                                     /* spare */
  spare6        timestamp                                           /* spare */
)
tablespace SYSAUX
/

Rem 
Rem ILM table for information on a particular ILM execution 
Rem
create table ilm_execution$
(
 execution_id    number,                   /* Identify a particular ILM task */
 owner           number,                           /* Owner of this ILM task */
 creation_time   timestamp,                              /* Time of creation */
 start_time      timestamp,                            /* Time of task start */
 completion_time timestamp,                       /* Time of task completion */
 execution_state number,           /* Identifies the state of the ILM task   */
                                   /* 0x0001 - Task created and policies     */
                                   /*          evaluated but jobs not created*/
                                   /* 0x0002 - Task created. Policies        */
                                   /*          evaluated and jobs created    */
                                   /*          for execution                 */
 flag          number,                           /* ILM execution properties */
                                       /* 0x0001 - Heavy jobs in ILM  window */
                                       /* 0x0002 - Job scheduling completed  */
 spare1        number,                                             /* spare */ 
 spare2        number,                                             /* spare */
 spare3        number,                                             /* spare */
 spare4        varchar2(4000),                                     /* spare */
 spare5        varchar2(4000),                                     /* spare */
 spare6        timestamp,                                          /* spare */
 constraint    pk_taskid
   primary key (execution_id)
)
tablespace SYSAUX
/ 

Rem
Rem ILM table for information on jobs created for policy on an object for 
Rem a particular execution of ILM
Rem 
create table ilm_executiondetails$
(
  policy#       number,                             /* unique policy number */
  obj#          number,                                    /* object number */
  execution_id  number,                              /* unique execution id */
  jobscheduled  number,             /* flag to identify job creation status */
                              /* 0x0001 - job created                       */
                              /* 0x0002 - job not created, policy overruled */
                              /* 0x0005 - job creation failed               */
  jobname       varchar2(128),     /* name of the scheduled job if any */
  comments      varchar2(4000),            /* additional information if any */
  spare1        number,                                            /* spare */
  spare2        number,                                            /* spare */
  spare3        number,                                            /* spare */
  spare4        varchar2(4000),                                    /* spare */
  spare5        varchar2(4000),                                    /* spare */
  spare6        timestamp                                          /* spare */,
  constraint    fk_execdet 
    foreign key (execution_id)
    references  ilm_execution$(execution_id)
    on delete cascade
)
tablespace SYSAUX
/

Rem
Rem ILM table for job results
Rem
create table ilm_results$
(
  execution_id     number,                           /* Unique execution id */
  jobname          varchar2(128),            /* name of the ilm related job */
  jobtype          number,                   /* Type of the ilm related job */
                                                        /* 0x0001 - Light   */
                                                        /* 0x0002 - Heavy   */ 
  jobtype1         number,        /* ILM job type based on objects affected */
                                              /* 0x0001 - ILM Object        */
                                              /* 0x0002 - Rebuild dependant */ 
  job_status       number,                   /* flag to identify job status */
                                          /* 0x0000 - job to be created now */
                                        /* 0x0001 - job to be created later */ 
                                                    /* 0x0002 - job created */
                                                 /* 0x0003 - job successful */
                                                 /* 0x0004 - job failed     */
                                                 /* 0x0005 - job stopped    */
                                            /* 0x0006 - job creation failed */
                                                 /* 0x0007 - job scheduled  */
                                                 /* 0x0008 - job disabled   */
                                                    /* 0x0009 - job running */
  start_time       timestamp,          /* Start time of the ILM related job */ 
  completion_time  timestamp,     /* completion time of the ilm related job */
  payload          varchar2(4000),               /* Payload for the ILM job */ 
  comments         varchar2(4000),         /* additional information if any */
  statistics       clob,                              /* ILM job statistics */ 
  spare1           number,                                         /* spare */
  spare2           number,                                         /* spare */
  spare3           number,                                         /* spare */
  spare4           varchar2(4000),                                 /* spare */
  spare5           varchar2(4000),                                 /* spare */
  spare6           timestamp,                                      /* spare */
  constraint    pk_res primary key (jobname),
  constraint    fk_res 
    foreign key (execution_id)
    references  ilm_execution$(execution_id)
    on delete cascade
)
tablespace SYSAUX
/

Rem
Rem ILM table for storing configuration parameters
Rem

create table ilm_param$
(
 param#          number,                               /* ILM parameter ID  */
 param_name      varchar2(128),                 /* ILM parameter Name  */
 param_value     number                             /* ILM parameter value  */ 
)
tablespace SYSAUX
/

Rem
Rem ILM table for storing ILM job result statistics
Rem

create table ilm_result_stat$
(
 jobname           varchar2(128),                    /* Name of ILM job */
 statistic#        number,                      /* Corresponds to v$statname */
 value             number,             /* Value of the statistic for the job */
 constraint        fk_resst 
   foreign key     (jobname)
   references      ilm_results$(jobname)
   on delete cascade
)
tablespace SYSAUX
/

create table ilm_dependant_obj$
(
 execution_id   number,                               /* Unique Execution id */
 par_jobname    varchar2(128),        /* ILM Job that necessitates rebuilding*/
 obj#           number,                                /* Name of the object */
 state          number,                     /* State of the dependant object */
                                        /*  0 - No job currently scheduled   */
                                        /*  1 - Job Scheduled for rebuild    */
                                        /*  2 - Index successfully rebuilt   */
                                        /*  3 - object already valid         */
 cur_jobname    varchar2(128),     /* ILM job for rebuilding the object */
 n_rebuild_att  number,                /* Number of failed rebuild attempts */
   constraint    fk_depobj 
    foreign key (execution_id)
    references  ilm_execution$(execution_id)
    on delete cascade,
   constraint   fk_depobjjobn
    foreign key (par_jobname)
    references  ilm_results$(jobname)
)
tablespace SYSAUX
/

create table ilm_dep_executiondetails$
(
  execution_id  number,                               /* unique execution id */
  obj#          number,                            /* Dependant object number*/
  par_jobname   varchar2(128),                     /* ILM Job that necessitated
                                                   * dependant obj rebuild   */
  jobname       varchar2(128),       /* ILM job for rebuilding dependant obj */
  constraint    fk_depdet 
    foreign key (execution_id)
    references  ilm_execution$(execution_id)
    on delete cascade,
  constraint    fk_depdetjobn
    foreign key (par_jobname)
    references  ilm_results$(jobname)
    on delete cascade
)
tablespace SYSAUX
/

create table ilm_concurrency$
(
  last_exec_time   timestamp,                  /* last execution time of ILM */
  attribute        number                      /* last_exec_time of attibute */
                                                    /* 1 - ILM Execution */
                                                    /* 2 - ILM Cleanup   */
                                                    /* 3 - ILM purge     */
                                                    /* 4 - ILM Dict Cleanup */
)
tablespace SYSAUX
/ 

Rem Unique key constraint on ilm_concurrency$
alter table ilm_concurrency$ add constraint c_ilm_attribute unique(attribute)
/

Rem Add constraint on ilm_param$
alter table ilm_param$ add constraint c_ilm_param unique(param#)
/

Rem Index on ilm$
create unique index i_ilm$ on ilm$(name, owner#)
tablespace SYSAUX
/

Rem Index on ilmpolicy$
create unique index i_ilmpolicy$ on ilmpolicy$(policy#)
tablespace SYSAUX
/

Rem Index on ilmobj$
create unique index i_ilmobj$ on ilmobj$(obj#, policy#)
tablespace SYSAUX
/

Rem Index on obj# column of ilmobj$
create index i_ilmobj_obj$ on ilmobj$(obj#)
tablespace SYSAUX
/

Rem Index on policy# column of ilmobj$
create index i_ilmobj_pol$ on ilmobj$(policy#)
tablespace SYSAUX
/

Rem Index on execution_id column of ilm_executiondetails$
create index i_ilmexecdet_execid on ilm_executiondetails$(execution_id)
tablespace SYSAUX
/

Rem Index on obj# column of ilm_executiondetails$
create index i_ilmexecdet_obj on ilm_executiondetails$(obj#)
tablespace SYSAUX
/

Rem Index on policy# column of ilm_executiondetails$
create index i_ilmexecdet_pol on ilm_executiondetails$(policy#)
tablespace SYSAUX
/

Rem Index on ilm_executiondetails$
create index i_ilmexecdet_jobname on ilm_executiondetails$(jobname)
tablespace SYSAUX
/

Rem Index on ilm_results$
create index i_ilmresults_status on ilm_results$(job_status)
tablespace SYSAUX
/

Rem Index on ilm_results$ using column execution_id
create index i_ilm_results_execution_id on ilm_results$(execution_id)
tablespace SYSAUX
/

Rem Create sequence for policy#
create sequence ilm_seq$ increment by 1 start with 1 nocycle
/

Rem Create sequence for execution id
create sequence ilm_executionid
/

create or replace type objrank FORCE is object(
                             rank number,
                             obj# number) 
/ 

Rem Create type for storing obj#
create or replace type tabobj# as table of objrank
/

Rem Create type for storing CSV strings
create or replace type csvlist as table of varchar2(300)
/
    
REM
REM Segment heat map tables. Related views are located in 
REM catilm.sql. Please contact owner of catilm.sql for changes.
REM

Rem HEAT MAP - segment level activity stats
create table heat_map_stat$
(
  obj#            number not null,                                   /* OBJ# */
  dataobj#        number not null,                               /* DATAOBJ# */
  ts#             number not null,                     /* segment header TS# */
  track_time      date   not null,                    /* segment access time */
  segment_access  number,                          /* segment access summary */
                                                     /* segment write 0x0001 */
                                                      /* segment read 0x0002 */
                                                         /* full scan 0x0004 */
                                                       /* lookup scan 0x0008 */
  flag            number default 0,      /* tracked when heat_map_off 0x0001 */
  spare1          number,
  spare2          number,
  spare3          varchar2(1000),
  n_write         number default 0,                      /* Number of writes */
  n_fts           number default 0,                         /* Number of FTS */
  n_lookup        number default 0               /* Number of index look ups */
)
tablespace SYSAUX
/
create index i_heatmapstat$ on heat_map_stat$(obj#, dataobj#)
tablespace SYSAUX
/
create index i2_heatmapstat$ on heat_map_stat$(ts#, dataobj#)
tablespace SYSAUX
/

Rem HEAT MAP - extent level activity
create table heat_map_extent_stat$
(
  obj#            number not null,                                   /* OBJ# */
  dataobj#        number not null,                               /* DATAOBJ# */
  track_time      date   not null,                     /* extent access time */
  extent_dba      number not null,         /* extent first data block number */
  extent_blocks   number,                                /* number of blocks */
  extent_access   number,                           /* extent access summary */
                                                     /* segment write 0x0001 */
                                                      /* segment read 0x0002 */
                                                         /* full scan 0x0004 */
  flag            number,                                          /* unused */
  rowmap_size     number,                   /* extent row access bitmap size */
  rowmap_block    number,                        /* number of rows per block */
  rowmap          blob,                          /* extent row access bitmap */
  spare1          number,
  spare2          number,
  spare3          varchar2(1000)
)
tablespace SYSAUX
lob(rowmap) store as securefile (tablespace SYSAUX)
/
create index i_heatmapextstat$ on heat_map_extent_stat$(obj#, dataobj#)
/

Rem Create sequence for ADO IMC task id
create sequence ado_imcseq$ increment by 1 start with 1 nocycle
/
REM
REM Column Level Statistics Table for kernel layer column statistics. 
REM Related views are located in catilm.sql. 
REM Please contact owner of catilm.sql for changes.
REM

Rem COLUMN_STAT - column-level statistics for the kernel layer
create table column_stat$
(
  obj#         number not null,                                      /* OBJ# */
  ts#          number not null,                         /* tablespace number */
  colid        number not null,                                /* column id  */
  stat_type    number not null,                           /* statistic enum  */
  stat_val_int number default 0,                          /* statistic value */
  stat_val_str varchar(1000) default null,                /* statistic value */
  track_time   timestamp not null                     /* segment access time */
)
tablespace SYSAUX
/
create index i_columnstat$ on column_stat$(obj#, colid, stat_type)
tablespace SYSAUX
/

Rem ADO DBIM element store statistics table
create table ado_imsegstat$
(
  obj#        number not null,                   /* IM object tracked by ADO */
  stat#       number not null,        /* Corresponds to stats in ado_imstat$ */
  value       number not null,
  tracktime   timestamp not null
)
tablespace SYSAUX
/

Rem ADO DBIM stats table
create table ado_imstat$
(
  stat#       number not null,                          /* ADO DBIM stat id */ 
  statname    varchar2(128)
)
tablespace SYSAUX
/

Rem ADO DBIM tasks 
create table ado_imtasks$
(
  task_id        number not null,
  creation_time  timestamp not null,
  task_type      number,
  im_size        number not null,
  flag           number,
  spare1         number,
  spare2         number,
  spare3         number,
  spare4         varchar2(128),
  spare5         varchar2(128),
  spare6         timestamp,
  state          number
)
tablespace SYSAUX
/

Rem Index on task_id column of ado_imtasks$
create index i_adoimtasks_id on ado_imtasks$(task_id)
tablespace SYSAUX
/ 

Rem ADO DBIM task details 
create table ado_imsegtaskdetails$
(  
  task_id        number not null,
  obj#           number not null,
  action         number not null,
  est_imsize     number,
  val            number,
  im_pop_state   number,   /* Please see the structure kdmado_pop_state in 
                            * kdmado0.h for allowable enumerations for this 
                            * flag.*/
  state          number,
  imbytes        number,            /* IM bytes at the time of task creation */
  blocksinmem    number,  /* Num of data blocks whose blocks are populated in 
                           * IM Store */
  datablocks     number,               /* Num of data blocks for the segment */
  spare1         number, 
  spare2         number,
  spare3         number,
  spare4         varchar2(128),
  spare5         varchar2(128),
  spare6         timestamp
)
tablespace SYSAUX
/
Rem Index on task_id column of ado_imsegtaskdetails$
create index i_adoimsegtd_id on ado_imsegtaskdetails$(task_id)
tablespace SYSAUX
/ 

Rem Index on obj# column of ado_imsegtaskdetails$
create index i_adoimsegtd_obj on ado_imsegtaskdetails$(obj#)
tablespace SYSAUX
/ 

Rem
Rem AIM table for storing configuration parameters
Rem

create table ado_imparam$
(
 param#          number,                                /* AIM parameter ID  */
 param_name      varchar2(128),                       /* AIM parameter Name  */
 param_value     number,                             /* AIM parameter value  */
 constraint c_ado_imparam unique (param#)
)
tablespace SYSAUX
/

@?/rdbms/admin/sqlsessend.sql
