Rem
Rem $Header: rdbms/admin/catappcontainertab.sql /main/6 2017/09/26 10:16:01 pjulsaks Exp $
Rem
Rem catappcontainertab.sql
Rem
Rem Copyright (c) 2014, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catappcontainertab.sql - Application Container tables
Rem
Rem    DESCRIPTION
Rem      Create tables used by a Application Container
Rem
Rem    NOTES
Rem      
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/catappcontainertab.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/catappcontainertab.sql 
Rem    SQL_PHASE: UPGRADE
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/catappcontainer.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    pjulsaks    09/26/17 - Bug 21563855: add flag to fed$app$status
Rem    pyam        06/25/17 - Fix SQL_PHASE
Rem    pyam        05/16/17 - Bug 21503951 fwd merge, move app$system$seq here
Rem    pjulsaks    03/21/17 - Bug 25661716: Add comment on spare1 in patch/ver
Rem    pyam        12/14/16 - 25256116: remove commit
Rem    pyam        11/10/16 - move tables into catappcontainertab.sql
Rem    pyam        09/20/16 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

create sequence fed$stmt_seq start with 1 increment by 1 order;

create table fed$apps (
  app_name   varchar2(128),                              /* Application Name */
  appid#     number,                                       /* Application ID */
  ver#       number,      /* Internally generated application version number */
  app_status number,                                /* Status of Application */
/* 0x00000001 Disallow Sync of BEGIN block with no END */
/* 0x00000002 Propagate APP changes automatically */
/* 0x00000004 Enable rollback of APP changes */
/* 0x00000008 Internal App Container App */
/* 0x00000010 Internal CDB-wide System App */
/* 0x00000020 Internal CDB-wide Catalog App */
/* 0x00000040 Sync all */
/* 0x00000080 App is CDB-wide */
/* 0x00000100 App is in action */
/* 0x00000200 Reserved */
/* 0x00000400 Reserved */
/* 0x00000800 Reserved */
/* 0x00001000 Reserved */
/* 0x00002000 Reserved */
  flag       number,                                 /* Flag for application */
  srvn       varchar2(64),           /* service name for application capture */
  modn       varchar2(64),            /* module name for application capture */
  spare1     number,       /* default 0. UID of PDB if PDB's info is in Root */
  spare2     number,
  spare3     number,
  spare4     varchar2(1000),
  spare5     varchar2(1000),
  spare6     date
)
/

create index i_fed_apps$ on fed$apps(app_status);

create sequence fed$appid_seq
  start with 1
  increment by 1
/

create table fed$patches (
  appid#    number,                                        /* Application ID */
  patch#    number,                              /* Application patch number */
  minver#   number,       /* Internally generated application version number */
  status    number,                       /* 0 if installing, 1 if completed */
  cmnt      varchar2(4000),      /* comment describing the Application patch */
  spare1    number,                                        /* Checksum value */
  spare2    number,
  spare3    number,
  spare4    varchar2(1000),
  spare5    varchar2(1000),
  spare6    date
)
/
create unique index i_fed_patches$ on fed$patches(appid#, patch#);

create table fed$versions (
  appid#              number,                              /* Application ID */
  ver#                number,     /* Internally generated app version number */
  tgtver              varchar2(30),            /* Target Application Version */
  root_clone_con_uid# number,                   /* CON_UID of Fed Root Clone */
  cmnt                varchar2(4000), /* comment for the application version */
  spare1              number,                              /* Checksum value */
  spare2              number,
  spare3              number,
  spare4              varchar2(1000),
  spare5              varchar2(1000),
  spare6              date
)
/

create table fed$statement$errors (
  appid#     number,                                       /* Application ID */
  seq#       number,                 /* Internally generated sequence number */
  errornum   number,                      /* Error number when executing SQL */
  errormsg   varchar2(4000),             /* Error message when executing SQL */
  stime      date not null,                                     /* Sync time */
  spare1     number,
  spare2     number,
  spare3     number,
  spare4     varchar2(1000),
  spare5     varchar2(1000),
  spare6     date
)
/

create table fed$app$status (
  appid#    number,                                        /* Application ID */
  lastseq#  number,          /* Sequence number of "last" statement replayed */
  errorseq# number,        /* Sequence number of last statement before error */
  spare1    number,
  spare2    number,
  spare3    number,
  spare4    varchar2(1000),
  spare5    varchar2(1000),
  spare6    date,
  flag      number                            /* Flag for application status */
)
/

create table fed$binds (
  appid#     number,
  seq#       number,
  inc#       number,
  bind#      number,
  name       varchar2(128),
  datatype#  number,
  value      blob,
  spare1     number,
  spare2     number,
  spare3     number,
  spare4     varchar2(1000),
  spare5     varchar2(1000),
  spare6     date,
  spare7     blob,
  spare8     clob
)
/

create unique index i_fed_binds$ on fed$binds(appid#, seq#, inc#, bind#);

create table fed$editions (
  appid#        number,                                    /* Application ID */
  ver#          number,           /* Internally generated app version number */
  patch#        number,                          /* Application patch number */
  edition_name  varchar2(128),                               /* Edition name */
  edition_seq   number,    /* n-th edition associated with this app version,
                                                            counting from 0. */
  spare1        number,
  spare2        number,
  spare3        number,
  spare4        varchar2(1000),
  spare5        varchar2(1000),
  spare6        date
)
/

create sequence fed$sess_seq
  start with 1
  increment by 1
/

create table fed$dependency (
  appid#        number,                                    /* Application ID */
  parent_appid# number,                  /* Dependency parent Application ID */
  spare1        number,
  spare2        varchar2(1000),
  spare3        date
)
/

create sequence app$system$seq 
  start with 1 
  increment by 1 
  nocache
/

@?/rdbms/admin/sqlsessend.sql
