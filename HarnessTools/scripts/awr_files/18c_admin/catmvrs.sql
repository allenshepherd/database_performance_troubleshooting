Rem
Rem $Header: rdbms/admin/catmvrs.sql /main/3 2017/06/16 16:16:16 sramakri Exp $
Rem
Rem catmvrs.sql
Rem
Rem Copyright (c) 2014, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catmvrs.sql - MV refresh stats history
Rem
Rem    DESCRIPTION
Rem      Creates the base tables and views for mv refresh stats.
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/catmvrs.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/catmvrs.sql
Rem    SQL_PHASE: CATMVRS
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/catptabs.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    sramakri    05/23/17 - bug-23301765L set system default retention
Rem                           period to 31
Rem    sramakri    02/19/15 - move catalog views to catxmvrs.sql
Rem    sramakri    01/30/14 - project 50868 - mv refresh stats history
Rem    sramakri    01/30/14 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

-- MVREF$_STATS_SEQ
/* MV Refresh Stats seq for refresh_id */
create sequence mvref$_stats_seq
  start with 1
  increment by 1
  nomaxvalue
  minvalue 1
  nocycle
  cache 20
  noorder
/

--
-- mvref$_stats has the refresh_id associated with each refresh run of each
-- mv. It also contains some basic timing statistics related to that mv's 
-- refresh in that run.
create table mvref$_stats
(
  mv_obj#       number not null,                         /* MV object-number */
  refresh_id	number	not null,      /* the refresh-id of the refresh run. */
  atomic_refresh char not null,  /* a boolean (Y/N) indicating if the mv was */
                                              /* refreshed atomically or not */
  refresh_method varchar2(30),                 /* the refresh method used to */
                           /* refresh the mv. it can be fast, pct, complete, */
           /* out of place fast, out of place pct, or out of place complete. */
  refresh_optimizations	varchar2(4000),   /* the  refresh optimization e.g., */
          /* null refresh, pk/fk which  is applied during refresh of the mv. */
  additional_executions	varchar2(4000),   /* the additional executions, e.g. */
        /* index rebuild, log operations, involved during refresh of the mv. */
  start_time	timestamp,                 /* start-time of the refresh run. */
  end_time	timestamp,                   /* end-time of the refresh run. */
  elapsed_time	  number,               /* time to refresh the mv in seconds */
  log_setup_time  number,          /* log  setup  time in seconds for the mv */
    /* in the case of non-atomic refresh; null in the case of atomic refresh */
  log_purge_time  number,          /* log  purge  time in seconds for the mv */
    /* in the case of non-atomic refresh; null in the case of atomic refresh */
  initial_num_rows  number,              /* initial number of rows in the mv */
                                            /* (at the start of the refresh) */
  final_num_rows   number,                 /* final number of rows in the mv */
                                              /* (at the end of the refresh) */
  num_steps	number,	/* the number of steps to refresh the mv; the steps  */
                                        /*   are shown in mvref_stmt_stats.  */
  refmet	number,/* refresh_method - this is same as refmet_kkzfrshctx */
                                          /* See kkzf.h  for possible values */
  refflg	number  /* refresh_flags - this is same as refflg_kkzfrshctx */
                                          /* See kkzf.h  for possible values */
);

--
--	mvref$_run_stats
--
-- mvref$_run_stats has information of each refresh-run, with each run being 
-- identified by the refresh_id. This information includes timing statistics 
-- related to the run and the parameters specified in that run.
create table mvref$_run_stats
(
  run_owner_user# number not null,              /* user# of the owner of the */
             /* refresh-operation - i.e. the user who launched the operation */
  refresh_id	  number not null,      /* the refresh-id of the refresh run */
  num_mvs_total	  number not null, /* the  number of mv's being refreshed in */
                                                                  /* the run */
  num_mvs_current number not null,          /* the  number of mv's currently */
                      /* present in mvref$_mv_stats associated with this run */
  mviews	  varchar2(4000),      /* list of mv's refreshed in this run */
  base_tables     varchar2(4000), /* list of tables whose mv's are refreshed */
                        /* in this run (for the REFRESH_DEPENDENTS api only) */
  method	  varchar2(4000),        /* the method specified for the run */
  rollback_seg	  varchar2(4000),          /* the rollback segment specified */
                                                              /* for the run */
  push_deferred_rpc    	char,           /* the push_deferred_rpc for the run */
  refresh_after_errors	char,        /* the refresh_after_errors for the run */
  purge_option	  number,                    /* the purge_option for the run */
  parallelism	  number, /* the parallelism parameter specified for the run */
  heap_size       number,   /* the heap_size parameter specified for the run */
  atomic_refresh  char,/* the atomic_refresh parameter specified for the run */
  nested          char,                  /* the nested parameter for the run */
  out_of_place    char,           /* the out-of-place parameter  for the run */
  number_of_failures number,  /* the number of failures that occurred in the */
                                                                      /* run */
  start_time	  timestamp,               /* start-time of the refresh run. */
  end_time	  timestamp,                 /* end-time of the refresh run. */
  elapsed_time	  number,                /* the refresh-run time in seconds. */
  log_setup_time  number,                 /* log  setup  time in seconds for */
                                    /* the mv in the case of atomic refresh; */
                                   /* null in the case of non-atomic refresh */
  log_purge_time  number	,             /* log  purge  time in seconds */
                                /* for the mv in the case of atomic refresh; */
                                   /* null in the case of non-atomic refresh */
  complete_stats_available  char,                   /* indicates whether all */
                   /* the complete refresh stats are  available for this run */
  txnflag         number,           /* txnflag parameter passed into kkzfrsh */
  on_commit_flag  number   /* flag set to TRUE if oncommit-context is passed */
                                                             /* into kkzfrsh */
);

-- mvref$_change_stats 
-- 
-- The mvref$_change_stats has the change-data-load information on the 
-- base-tables associated with a refresh run. 
--
create table mvref$_change_stats
(
  tbl_obj#        number not null,                    /* table object number */
  mv_obj#         number not null,                       /* MV object number */
  refresh_id      number not null,     /* the refresh-id of the refresh run. */
  num_rows_ins	  number,          /* the number of inserts in the mv-log of */
                /* that table. (applicable only if the table has an mv-log.) */
  num_rows_upd	  number,         /* the number of updates  in the mv-log of */
                /* that table. (applicable only if the table has an mv-log.) */
  num_rows_del	  number,             /* the number of deletes in the mv-log */
             /* of that table. (applicable only if the table has an mv-log.) */
  num_rows_dl_ins number,/* the number of direct-load inserts on that table. */
  pmops_occurred  char,                  /* indicates whether pmops occurred */
  pmop_details	  varchar2(4000),   /* details of the pmops in the following */
  /* format: truncate(low_bound,high_bound),  exchange(low_bound,high_bound) */
  num_rows	  number          /* the number of rows in that table at the */
                                           /* start of the refresh operation */
);

-- Note: mvref$_stmt_stats.execution_plan (xmltype column) 
-- is added later in catxmvrs.sql due to xmltype dependency. 
create table mvref$_stmt_stats
(
  mv_obj#         number not null,                       /* MV object number */
  refresh_id      number not null,     /* the refresh-id of the refresh run. */
  step	          number not null,    /* a number indicating the step in the */
           /* refresh process in which the statement is executed for the mv. */
                          /* Steps are numbered consecutively starting at 1. */
  sqlid	          varchar2(14) not null,       /* the sqlid of the statement */
  stmt	          clob not null,                /* the text of the statement */
  execution_time  number not null       /* the time to execute the statement */
                                                               /* in seconds */
);

-- mvref$_stats_sys_defaults
-- This table contains the system-wide defaults for the refresh history stats 
-- properties. 
--
-- These values can be altered with the SET_SYSTEM_DEFAULTS procedure by a DBA. 
--
-- The table contains one row with two columns COLLECTION_LEVEL and 
-- RETENTION_PERIOD:
-- 
-- The possible values of COLLECTION_LEVEL are 0 (NONE), 1 (TYPICAL), 2 (ADVANCED)
-- The possible values of RETENTION_PERIOD are -1 or in the range [1 - 3650000]
-- The significance of -1 for the RETENTION_PERIOD is retain forever or donot purge
--

create table mvref$_stats_sys_defaults
(
 collection_level number not null,
 retention_period number not null
);
insert into mvref$_stats_sys_defaults (collection_level, retention_period) values 
(1, 31);

-- This table records the refresh stats properties associated with each mv. 
-- These properties can be modified with the 
-- DBMS_MVIEW_STATS.SET_MVREF_STATS_PARAMS procedure.
--
create table mvref$_stats_params
(
 mv_owner varchar2(128) not null,
 mv_name varchar2(128) not null,
 collection_level number not null,
 retention_period number not null
);


--------------------------------------
@?/rdbms/admin/sqlsessend.sql
