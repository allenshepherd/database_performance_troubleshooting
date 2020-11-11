Rem
Rem $Header: rdbms/admin/utlmmigtbls.sql /main/18 2017/08/03 17:44:03 wesmith Exp $
Rem
Rem utlmmigtbls.sql
Rem
Rem Copyright (c) 2012, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      utlmmigtbls.sql - create utlmmig TaBLeS
Rem
Rem    DESCRIPTION
Rem      Creates the new bootstrap and related objects. Should only be run
Rem    as part of utlmmig.sql.
Rem
Rem    NOTES
Rem      *** If new $mig replacememnt tables are created, they must be
Rem      *** added to the list of $mig tables to be dropped, in 
Rem      *** catuppst.sql
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    wesmith     08/07/17 - 22187143: fix dba_part/subpart_key_columns_v$
Rem    kquinn      11/30/16 - Bug 25092160: unlimited extents for obj indexes
Rem    anighosh    09/19/16 - Bug 24669189: Cleanup utlmmig replacement tables
Rem    thbaby      05/09/16 - Bug 23181611: add crepatchid/modpatchid to OBJ$
Rem    thbaby      10/30/15 - bug 21939181: support for app id/version
Rem    drosash     04/08/15 - Proj 47411: Local temporary tablespaces
Rem    smangala    03/07/15 - proj 58812: track auto cdr columns
Rem    thbaby      03/03/15 - Proj 47234: remove property2 column of tab$
Rem    huntran     02/09/15 - Project 58812: col$ and tab$ columns for auto cdr
Rem    traney      11/19/14 - 19607109: long tablespace names
Rem    wesmith     11/19/14 - call cdpart_mig.sql
Rem    wesmith     05/05/14 - Project 47511: data-bound collation
Rem    sanbhara    04/25/14 - Project 46816 - adding support for SYSRAC.
Rem    traney      02/06/13 - 16225123: defer index creation
Rem    traney      11/08/12 - 15848223: run utlmmigtbls separately
Rem    traney      09/26/12 - move view redefinitions to new files
Rem    ciyer       09/14/12 - move edition range from index to expression
Rem                           column
Rem    pyam        09/27/12 - incorporate new obj$ cols in exu81obj
Rem    traney      09/05/12 - 14407652: redefine metadata api views
Rem    traney      08/13/12 - Created
Rem

/*****************************************************************************/
/*
 * We need to exit immediately on any error.  If this script fails, the
 * script must be run again from the beginning.
 */
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

/*****************************************************************************/
/*
 * Step 0 - Logminer Dictionary Conditional Special Build
 *
 *    A Logminer Dictionary Build specific to utlmmig is conditionally
 *    invoked here.   If supplemental logging is not enabled for this
 *    database this will be a NOP.  If a prior invocation of utlmmig
 *    failed after the a complete, final build and before the successful
 *    swap of bootstrap$mig, Logminer will not have the correct obj#s for
 *    OBJ$ and USER$.  This build will communicate the these new obj#s to
 *    Logminer.
 */
/*****************************************************************************/

DECLARE
  LS_Special_2            CONSTANT NUMBER := 10;
  LOCbldlogid             VARCHAR2(22) := NULL;
  LOCLockDownScn          NUMBER;
  UpgradeErrorCount       NUMBER := 0;
  rowcnt                  NUMBER;
BEGIN
/*
 * We've started the bootstrap$ upgrade. Insert a row 'BOOTSTRAP_UPGRADE_ERROR'
 * into PROPS$ to indicate that. This row will be removed after we've completed
 * utlmmig. If something failed in between, we'll see this row when we bring up
 * the db. We'll instruct the user to startup in upgrade mode and rerun this
 * script if the row exists in PROPS$.
 */
  -- See if there is already a BOOTSTRAP_UPGRADE_ERROR in PROPS$
  select count(*) into UpgradeErrorCount
  from sys.props$
  where name = 'BOOTSTRAP_UPGRADE_ERROR';

  IF (0 = UpgradeErrorCount) THEN
    -- If no BOOTSTRAP_UPGRADE_ERROR in PROPS$, insert one.
    insert into props$ (name, value$, comment$)
    values ('BOOTSTRAP_UPGRADE_ERROR', NULL,
            'startup the db in upgrade mode and rerun utlmmig.sql');
  ELSE
    -- If there is a BOOTSTRAP_UPGRADE_ERROR in PROPS$ it means that this
    -- is a second try. We may need to undo the changes to dependency$ and
    -- objauth$.
    declare
      type vc_nst_type is table of varchar2(30);
      old_obj_num number;
      new_obj_num number;
      new_ts      timestamp;
      old_name    vc_nst_type;
      new_name    vc_nst_type;
    begin
      old_name := vc_nst_type('OBJ$',    'USER$',    'COL$',    'CLU$',
                              'CON$', 'BOOTSTRAP$',
                              'TAB$',    'IND$',    'ICOL$',    'LOB$',   
                              'COLTYPE$',    'SUBCOLTYPE$',    'NTAB$',   
                              'REFCON$',    'OPQTYPE$',    'ICOLDEP$',   
                              'VIEWTRCOL$',   'ATTRCOL$',     'TYPE_MISC$',
                              'LIBRARY$',    'ASSEMBLY$',
--                              'TS$', 'FET$',
                              'TSQ$', '_CURRENT_EDITION_OBJ',
                              '_ACTUAL_EDITION_OBJ',
                              'DBA_PART_KEY_COLUMNS_V$',
                              'DBA_SUBPART_KEY_COLUMNS_V$');
      new_name := vc_nst_type('OBJ$MIG', 'USER$MIG', 'COL$MIG','CLU$MIG',
                              'CON$MIG', 'BOOTSTRAP$MIG',
                              'TAB$MIG', 'IND$MIG', 'ICOL$MIG', 'LOB$MIG',
                              'COLTYPE$MIG', 'SUBCOLTYPE$MIG', 'NTAB$MIG',
                              'REFCON$MIG', 'OPQTYPE$MIG', 'ICOLDEP$MIG',
                              'VIEWTRCOL$MIG', 'ATTRCOL$MIG', 'TYPE_MISC$MIG',
                              'LIBRARY$MIG', 'ASSEMBLY$MIG',
--                              'TS$MIG', 'FET$MIG',
                              'TSQ$MIG', '_CURRENT_EDITION_OBJ_MIG',
                              '_ACTUAL_EDITION_OBJ_MIG',
                              'DBA_PART_KEY_COLUMNS_V$_MIG',
                              'DBA_SUBPART_KEY_COLUMNS_V$_MIG');

      for i in new_name.FIRST .. new_name.LAST
      loop
        select obj# into new_obj_num from obj$ 
          where owner#=0 and name=new_name(i) and namespace=1 and 
            linkname is null and subname is null;
        select obj#, stime into old_obj_num, new_ts from obj$
          where owner#=0 and name=old_name(i) and namespace=1 and 
            linkname is null  and subname is null;

        -- Undo Step 7
        update dependency$ 
          set p_obj#      = old_obj_num, 
              p_timestamp = new_ts
          where p_obj# = new_obj_num;

        -- Undo Step 8
        update objauth$ set obj# = old_obj_num where obj# = new_obj_num;

      end loop;

      commit;
    end;
    
    -- If there is a BOOTSTRAP_UPGRADE_ERROR in PROPS$ it means that this
    -- is a second try.  We may need a special Logminer Dictionary build
    -- to ensure that Logminer has correct obj# for obj$ and user$.
    SELECT COUNT(1) into rowcnt
    FROM SYS.V$DATABASE V
    WHERE V.LOG_MODE = 'ARCHIVELOG' and
          V.SUPPLEMENTAL_LOG_DATA_MIN != 'NO' and
          exists (select 1 from sys.props$
                  where name = 'LOGMNR_BOOTSTRAP_UPGRADE_ERROR');
    IF 0 != rowcnt THEN
      -- Logminer may be mining this redo stream, and we failed in a bad
      -- place on the first try, so we must build again.
      sys.dbms_logmnr_internal.DO_INT_BUILD(build_op=>LS_Special_2,
                                            dictionary_filename=>NULL,
                                            dictionary_location=>NULL,
                                            bldlogid_initxid=>LOCbldlogid,
                                            LockDownScn=>LOCLockDownScn,
                                            release_locks=>FALSE);
      delete from sys.props$
             where name = 'LOGMNR_BOOTSTRAP_UPGRADE_ERROR';
      commit;
    END IF;
  END IF;
END;
/

/*****************************************************************************/
/*
 * Step 0.5 - Recreate views that depend on new bootstrap table columns.
 *
 * These views must be created FORCE because the new columns do not exist until
 * after the swap. They will be created with errors and will revalidate on use
 * post swap.
 */
/*****************************************************************************/

-- metadata api view redefinitions
@@catmetviews_mig.sql

-- cdcore view redefinitions
@@cdcore_mig.sql

-- cdpart view redefinitions
@@cdpart_mig.sql

-- catapp view redefinitions
@@catapp_mig.sql

-- catlmnr view redefinitions
@@catlmnr_mig.sql

-- cdenv view redefinitions
@@cdenv_mig.sql

declare
  success_with_error exception;
  pragma exception_init(success_with_error, -24344);
begin
  execute immediate
q'!CREATE OR REPLACE FORCE VIEW exu81obj AS
        SELECT  o$.OBJ#, o$.DATAOBJ#, o$.OWNER#, o$.NAME, o$.NAMESPACE,
                o$.SUBNAME, o$.TYPE#, o$.CTIME, o$.MTIME, o$.STIME, o$.STATUS,
                o$.REMOTEOWNER, o$.LINKNAME, o$.FLAGS, o$.OID$, o$.SPARE1,
                o$.SPARE2, o$.SPARE3, o$.SPARE4, o$.SPARE5, o$.SPARE6,
                o$.SIGNATURE, o$.SPARE7, o$.SPARE8, o$.SPARE9, 
                o$.DFLCOLLID, o$.CREAPPID, o$.CREVERID, o$.CREPATCHID, 
                o$.MODAPPID, o$.MODVERID, o$.MODPATCHID, o$.SPARE10, 
                o$.SPARE11, o$.SPARE12, o$.SPARE13, o$.SPARE14
        FROM    sys.obj$ o$, sys.user$ u$
        WHERE   BITAND(o$.flags, 16) != 16 AND
                /* Ignore recycle bin objects */
                BITAND(o$.flags, 128) != 128 AND 
                o$.owner# = u$.user# AND
                u$.name NOT IN ('ORDSYS',  'MDSYS', 'CTXSYS', 'ORDPLUGINS',
                                'LBACSYS', 'XDB',   'SI_INFORMTN_SCHEMA',
                                'DIP', 'DBSNMP', 'EXFSYS', 'WMSYS','ORACLE_OCM',
                                'ANONYMOUS', 'XS$NULL', 'APPQOSSYS', 'OJVMSYS',
                                'SYSBACKUP', 'SYSDG', 'SYSKM', 'SYSRAC', 'DVSYS',
                                'DVF', 'GSMADMIN_INTERNAL', 'GSMUSER', 'GSMCATUSER',
                                'ORDDATA', 'LOGSTDBY_ADMINISTRATOR')!';
exception
  when success_with_error then null;
end;
/


/*****************************************************************************/
/*
 * Step 1 - Create the new replacement tables for the existing bootstrap tables.
 *
 * Currently, we're creating replacement tables for:
 *   OBJ$
 *   USER$
 *   COL$
 *   CLU$
 *   IND$
 *   CON$
 *   TAB$
 * We'll create indexes for each of the table we created. Note that existing
 * indexes on the old table won't carry over to the new tables.
 *
 * We're also recreating the clusters these tables were part of. The clusters
 * are created here and the remaining tables are created in Step 1B.
 */
/*****************************************************************************/
drop table obj$mig
/
create table obj$mig                                         /* object table */
( obj#          number not null,                            /* object number */
  dataobj#      number,                          /* data layer object number */
  owner#        number not null,                        /* owner user number */
  name          varchar2(128) not null,                  /* object name */
  namespace     number not null,         /* namespace of object (see KQD.H): */
 /* 1 = TABLE/PROCEDURE/TYPE, 2 = BODY, 3 = TRIGGER, 4 = INDEX, 5 = CLUSTER, */
                                                  /* 8 = LOB, 9 = DIRECTORY, */
  /* 10 = QUEUE, 11 = REPLICATION OBJECT GROUP, 12 = REPLICATION PROPAGATOR, */
                                     /* 13 = JAVA SOURCE, 14 = JAVA RESOURCE */
                                                 /* 58 = (Data Mining) MODEL */
  subname       varchar2(128),               /* subordinate to the name */
  type#         number not null,                 /* object type (see KQD.H): */
  /* 1 = INDEX, 2 = TABLE, 3 = CLUSTER, 4 = VIEW, 5 = SYNONYM, 6 = SEQUENCE, */
             /* 7 = PROCEDURE, 8 = FUNCTION, 9 = PACKAGE, 10 = NON-EXISTENT, */
              /* 11 = PACKAGE BODY, 12 = TRIGGER, 13 = TYPE, 14 = TYPE BODY, */
      /* 19 = TABLE PARTITION, 20 = INDEX PARTITION, 21 = LOB, 22 = LIBRARY, */
                                             /* 23 = DIRECTORY , 24 = QUEUE, */
    /* 25 = IOT, 26 = REPLICATION OBJECT GROUP, 27 = REPLICATION PROPAGATOR, */
    /* 28 = JAVA SOURCE, 29 = JAVA CLASS, 30 = JAVA RESOURCE, 31 = JAVA JAR, */
                 /* 32 = INDEXTYPE, 33 = OPERATOR , 34 = TABLE SUBPARTITION, */
                                                  /* 35 = INDEX SUBPARTITION */
                                                 /* 82 = (Data Mining) MODEL */
                             /* 92 = OLAP PRIMARY DIMENSION,  93 = OLAP CUBE */
                          /* 94 = OLAP MEASURE FOLDER, 95 = OLAP INTERACTION */
  ctime         date not null,                       /* object creation time */
  mtime         date not null,                      /* DDL modification time */
  stime         date not null,          /* specification timestamp (version) */
  status        number not null,            /* status of object (see KQD.H): */
                                     /* 1 = VALID/AUTHORIZED WITHOUT ERRORS, */
                          /* 2 = VALID/AUTHORIZED WITH AUTHORIZATION ERRORS, */
                            /* 3 = VALID/AUTHORIZED WITH COMPILATION ERRORS, */
                         /* 4 = VALID/UNAUTHORIZED, 5 = INVALID/UNAUTHORIZED */
  remoteowner   varchar2(128),     /* remote owner name (remote object) */
  linkname      varchar2(128),             /* link name (remote object) */
  flags         number,               /* 0x01 = extent map checking required */
                                      /* 0x02 = temporary object             */
                                      /* 0x04 = system generated object      */
                                      /* 0x08 = unbound (invoker's rights)   */
                                      /* 0x10 = secondary object             */
                                      /* 0x20 = in-memory temp table         */
                                      /* 0x80 = dropped table (RecycleBin)   */
                                      /* 0x100 = synonym VPD policies        */
                                      /* 0x200 = synonym VPD groups          */
                                      /* 0x400 = synonym VPD context         */
  oid$          raw(16),        /* OID for typed table, typed view, and type */
  spare1        number,                      /* sql version flag: see kpul.h */
  spare2        number,                             /* object version number */
  spare3        number,                                        /* base user# */
  spare4        varchar2(1000),
  spare5        varchar2(1000),
  spare6        date,
  signature     raw(16),
  spare7        number,
  spare8        number,
  spare9        number,
  dflcollid     number,                   /* unit-level default collation id */
  creappid      number,         /* App ID of Application that created object */
  creverid      number,        /* Version of Application that created object */
  crepatchid    number,       /* Patch ID of Application that created object */
  modappid      number,   /* App ID of Application that last modified object */
  modverid      number,  /* Version of Application that last modified object */
  modpatchid    number, /* Patch ID of Application that last modified object */
  spare10       number,
  spare11       number,
  spare12       varchar2(1000),
  spare13       varchar2(1000),
  spare14       timestamp
)
  tablespace system
  storage (initial 10k next 100k maxextents unlimited pctincrease 0)
/

create unique index i_obj_mig1 on obj$mig(obj#, owner#, type#)
 tablespace system 
 storage (maxextents unlimited)
/
create unique index i_obj_mig2 on obj$mig(owner#, name, namespace, remoteowner,
linkname, subname, type#, spare3, obj#)
tablespace system
storage (maxextents unlimited)
/
create index i_obj_mig3 on obj$mig(oid$) tablespace system
storage (maxextents unlimited)
/
create index i_obj_mig4 on obj$mig(dataobj#, type#, owner#) tablespace system
storage (maxextents unlimited)
/
create unique index i_obj_mig5 on obj$mig(spare3, name, namespace, type#,
owner#, remoteowner, linkname, subname, obj#) tablespace system
storage (maxextents unlimited)
/

/* Recreate the c_obj#, c_user#, and c_ts# clusters. */
drop cluster c_obj#mig including tables;
create cluster c_obj#mig (obj# number)
  pctfree 5 size 800                           /* don't waste too much space */
  /* A table of 32 cols, 2 index, 2 col per index requires about 2K.
   * A table of 10 cols, 2 index, 2 col per index requires about 750.
   */
  storage (initial 130K next 200k maxextents unlimited pctincrease 0) 
  /* avoid space management during IOR I */
/
create index i_obj#mig on cluster c_obj#mig
storage (maxextents unlimited)
/

drop cluster c_user#mig including tables;
create cluster c_user#mig(user# number) 
  size  372 /* cluster key ~ 20, sizeof(user$) ~ 227, 5 * sizeof(tsq$) ~ 125 */
/
create index i_user#mig on cluster c_user#mig
/

drop cluster c_ts#mig including tables;
create cluster c_ts#mig(ts# number)         /* use entire block for each ts# */
/
create index i_ts#mig on cluster c_ts#mig
/

drop table user$mig
/
create table user$mig                                          /* user table */
( user#         number not null,                   /* user identifier number */
  name          varchar2(128) not null,                      /* name of user */
  type#         number not null,                       /* 0 = role, 1 = user */
  password      varchar2(4000),                        /* encrypted password */
  datats#       number not null, /* default tablespace for permanent objects */
  tempts#       number not null,  /* default tablespace for temporary tables */
  ctime         date not null,                 /* user account creation time */
  ptime         date,                                /* password change time */
  exptime       date,                     /* actual password expiration time */
  ltime         date,                         /* time when account is locked */
  resource$     number not null,                        /* resource profile# */
  audit$        varchar2(38),                          /* user audit options */
  defrole       number not null,                  /* default role indicator: */
               /* 0 = no roles, 1 = all roles granted, 2 = roles in defrole$ */
  defgrp#       number,                                /* default undo group */
  defgrp_seq#   number,               /* global sequence number for  the grp */
  astatus       number default 0 not null,          /* status of the account */
                /* 1 = Locked, 2 = Expired, 3 = Locked and Expired, 0 - open */
  lcount        number default 0 not null, /* count of failed login attempts */
  defschclass   varchar2(128),                     /* initial consumer group */
  ext_username  varchar2(4000),                         /* external username */
                             /* also as base schema name for adjunct schemas */
  spare1        number, /* used for schema level supp. logging: see ktscts.h */
  spare2        number,      /* used to store edition id for adjunct schemas */
  spare3        number,
  spare4        varchar2(1000),
  spare5        varchar2(1000),
  spare6        date,
  spare7        varchar2(4000),
  spare8        varchar2(4000),
  spare9        number,
  spare10       number,
  spare11       timestamp
)
cluster c_user#mig(user#)
/

drop table col$mig
/
create table col$mig                                         /* column table */
( obj#          number not null,             /* object number of base object */
  col#          number not null,                 /* column number as created */
  segcol#       number not null,                 /* column number in segment */
  segcollength  number not null,             /* length of the segment column */
  offset        number not null,                         /* offset of column */
  name          varchar2(128) not null,                    /* name of column */
  type#         number  not null,                     /* data type of column */
                                           /* for ADT column, type# = DTYADT */
  length        number  not null,               /* length of column in bytes */
  fixedstorage  number  not null,   /* flags: 0x01 = fixed, 0x02 = read-only */
  precision#    number,                                         /* precision */
  scale         number,                                             /* scale */
  null$         number not null,                     /* 0 = NULLs permitted, */
                                                /* > 0 = no NULLs permitted  */
  deflength     number,              /* default value expression text length */
  default$      long,                       /* default value expression text */
  intcol#       number not null,                   /* internal column number */
  property      number not null,           /* column properties (bit flags): */
  charsetid     number,                              /* NLS character set id */
  charsetform   number,
  evaledition#  number,                                /* evaluation edition */
  unusablebefore#    number,                      /* unusable before edition */
  unusablebeginning# number,              /* unusable beginning with edition */
  spare1        number,                      /* fractional seconds precision */
  spare2        number,                  /* interval leading field precision */
  spare3        number,            /* maximum number of characters in string */
  spare4        varchar2(1000),          /* NLS settings for this expression */
  spare5        varchar2(1000),
  spare6        date,
  spare7        number,
  spare8        number,
  collid        number,                                      /* collation id */
  collintcol#   number,           /* reference to the actual collated column */
  spare9        number,
  spare10       number,
  spare11       varchar2(1000),
  spare12       varchar2(1000),
  spare13       timestamp,
  acdrrescol#   number                        /* auto cdr resolution intcol# */
)
cluster c_obj#mig(obj#)
/

drop table clu$mig
/
create table clu$mig
( obj#          number not null,                            /* object number */
  dataobj#      number,                          /* data layer object number */
  ts#           number not null,                        /* tablespace number */
  file#         number not null,               /* segment header file number */
  block#        number not null,              /* segment header block number */
  cols          number not null,                        /* number of columns */
  pctfree$      number not null, /* minimum free space percentage in a block */
  pctused$      number not null, /* minimum used space percentage in a block */
  initrans      number not null,            /* initial number of transaction */
  maxtrans      number not null,            /* maximum number of transaction */
  size$         number,
  hashfunc      varchar2(128),        /* if hashed, function identifier */
  hashkeys      number,                                    /* hash key count */
  func          number, /* function: 0 (key is function), 1 (system default) */
  extind        number,             /* extent index value of fixed hash area */
  flags         number,                                      /* 0x08 = CACHE */
  degree        number,      /* number of parallel query slaves per instance */
  instances     number,       /*  number of OPS instances for parallel query */
  avgchn        number,          /* average chain length - previously spare4 */
  spare1        number,                /* used for trigger non-trigger flags */
  spare2        number,
  spare3        number,
  spare4        number,
  spare5        varchar2(1000),
  spare6        varchar2(1000),
  spare7        date
)
cluster c_obj#mig(obj#)
/

drop table con$mig
/
create table con$mig
( owner#        number not null,                        /* owner user number */
  name          varchar2(128) not null,              /* constraint name */
  con#          number not null,                        /* constraint number */
  spare1        number,         /* used for online add constraint. see kqd.h */
  spare2        number,
  spare3        number,
  spare4        varchar2(1000),
  spare5        varchar2(1000),
  spare6        date
)
/

drop table bootstrap$mig
/
create table bootstrap$mig
( line#         number not null,                       /* statement order id */
  obj#          number not null,                            /* object number */
  sql_text      varchar2(4000) not null)                        /* statement */
tablespace system
/

drop table tab$mig
/
create table tab$mig                                          /* table table */
( obj#          number not null,                            /* object number */
  /* DO NOT CREATE INDEX ON DATAOBJ#  AS IT WILL BE UPDATED IN A SPACE
   * TRANSACTION DURING TRUNCATE */
  dataobj#      number,                          /* data layer object number */
  ts#           number not null,                        /* tablespace number */
  file#         number not null,               /* segment header file number */
  block#        number not null,              /* segment header block number */
  bobj#         number,                /* base object number (cluster / iot) */
  tab#          number,    /* table number in cluster, NULL if not clustered */
  cols          number not null,                        /* number of columns */
  clucols       number,/* number of clustered columns, NULL if not clustered */
  pctfree$      number not null, /* minimum free space percentage in a block */
  pctused$      number not null, /* minimum used space percentage in a block */
  initrans      number not null,            /* initial number of transaction */
  maxtrans      number not null,            /* maximum number of transaction */
  flags         number not null, /* 0x00     = unmodified since last backup 
                                    0x01     = modified since then 
                                    0x02     = DML locks restricted to <= SX 
                                    0x04     = DML locks <= SX not acquired
                                    0x08     = CACHE  
                                    0x10     = table has been analyzed
                                    0x20     = table has no logging
                                    0x40     = 7.3 -> 8.0 data object
                                               migration required    
                                    0x0080   = current summary dependency
                                    0x0100   = user-specified stats
                                    0x0200   = global stats           
                                    0x0800   = table has security policy 
                                    0x020000 = Move Partitioned Rows 
                                   0x0400000 = table has sub tables
                                  0x00800000 = row dependencies enabled */
                /* 0x10000000 = this IOT has a  physical rowid mapping table */
                /* 0x20000000 = mapping table of an IOT(with physical rowid) */
  audit$        varchar2(38) not null,             /* auditing options */
  rowcnt        number,                                    /* number of rows */
  blkcnt        number,                                  /* number of blocks */
  empcnt        number,                            /* number of empty blocks */
  avgspc        number,       /* average available free space/iot ovfl stats */
  chncnt        number,                            /* number of chained rows */
  avgrln        number,                                /* average row length */
  avgspc_flb    number,       /* avg avail free space of blocks on free list */
  flbcnt        number,                             /* free list block count */
  analyzetime   date,                        /* timestamp when last analyzed */
  samplesize    number,                 /* number of rows sampled by Analyze */
/* 
 * Legal values for degree, instances: 
 *     NULL (used to represent 1 on disk/dictionary and implies noparallel), or
 *     2 thru EB2MAXVAL-1 (user supplied values), or
 *     EB2MAXVAL (implies use default value) 
 */
  degree        number,      /* number of parallel query slaves per instance */
  instances     number,        /* number of OPS instances for parallel query */
/* <intcols> => the number of dictionary columns => the number of columns 
 * that have dictionary meta-data associated with them. This is a superset of 
 * <usercols> and <kernelcols>. 
 *    <intcols> = <kernelcols> + <number_of_virtual_columns>
 */
  intcols       number not null,               /* number of internal columns */
/* <kernelcols> => the number of REAL columns (ie) columns that actually
 * store data.
 */
  kernelcols    number not null,          /* number of REAL (kernel) columns */
  property      number not null,            /* table properties (bit flags): */
                              /* 0x01 = typed table, 0x02 = has ADT columns, */
                 /* 0x04 = has nested-TABLE columns, 0x08 = has REF columns, */
                      /* 0x10 = has array columns, 0x20 = partitioned table, */
               /* 0x40 = index-only table (IOT), 0x80 = IOT w/ row OVerflow, */
             /* 0x100 = IOT w/ row CLustering, 0x200 = IOT OVeRflow segment, */
               /* 0x400 = clustered table, 0x800 = has internal LOB columns, */
        /* 0x1000 = has primary key-based OID$ column, 0x2000 = nested table */
                    /* 0x4000 = View is Read Only, 0x8000 = has FILE columns */
       /* 0x10000 = obj view's OID is system-gen, 0x20000 = used as AQ table */
                                   /* 0x40000 = has user-defined lob columns */
                               /* 0x00080000 = table contains unused columns */
                            /* 0x100000 = has an on-commit materialized view */
                             /* 0x200000 = has system-generated column names */
                                      /* 0x00400000 = global temporary table */
                            /* 0x00800000 = session-specific temporary table */
                                        /* 0x08000000 = table is a sub table */
                                        /*   0x20000000 = pdml itl invariant */
                                          /* 0x80000000 = table is external  */
                          /* PFLAGS2: 0x400000000 = delayed segment creation */
  /* PFLAGS2: 0x20000000000 = result cache mode FORCE enabled on this table  */
  /* PFLAGS2: 0x40000000000 = result cache mode MANUAL enabled on this table */
  /* PFLAGS2: 0x80000000000 = result cache mode AUTO enabled on this table   */
  /* PFLAGS2: 0x400000000000000 = has identity column                        */
  trigflag      number,   /* first two bytes for trigger flags, the rest for */
                   /* general use, check tflags_kqldtvc in kqld.h for detail */
                                            /* 0x00000001 deferred RPC Queue */
                                                  /* 0x00000002 snapshot log */
                                        /* 0x00000004 updatable snapshot log */
                                             /* 0x00000008 = context trigger */
                                    /* 0x00000010 = synchronous change table */
                                             /* 0x00000020 = Streams trigger */
                                        /* 0x00000040 = Content Size Trigger */
                                         /* 0x00000080 = audit vault trigger */
                           /* 0x00000100 = Streams Auxiliary Logging trigger */
                     /* 0x00010000 = server-held key encrypted columns exist */
                       /* 0x00020000 = user-held key encrypted columns exist */
                                          /* 0x00200000 = table is read only */
                                     /* 0x00400000 = lobs use shared segment */
                                                 /* 0x00800000 = queue table */
                                   /* 0x10000000 = streams unsupported table */
                                            /* enabled at some point in past */
                            /* 0x80000000 = Versioning enabled on this table */
  spare1        number,                       /* used to store hakan_kqldtvc */
  spare2        number,         /* committed partition # used by drop column */
  spare3        number,                           /* summary sequence number */
  spare4        varchar2(1000),         /* committed RID used by drop column */
  spare5        varchar2(1000),      /* summary related information on table */
  spare6        date,                                 /* flashback timestamp */
  spare7        number,
  spare8        number,
  spare9        varchar2(1000),
  spare10       varchar2(1000),
  acdrflags     number,                                    /* auto cdr flags */
                                         /* 0x00000001 = auto cdr configured */
                                     /* 0x00000002 = column-level resolution */
                          /* 0x00000004 = delete tombstone enabled for table */
                       /* 0x00000008 = table is a delete tombstone log table */
  acdrtsobj#    number,                              /* tombstone table obj$ */
  acdrdefaulttime  timestamp,                       /* auto cdr default time */
  acdrrowtsintcol# number                 /* intcol# for row-level timestamp */
)
cluster c_obj#mig(obj#)
/

create index i_tab1mig on tab$mig(bobj#)
/

drop table ts$mig
/
create table ts$mig                                      /* tablespace table */
( ts#           number not null,             /* tablespace identifier number */
  name          varchar2(30) not null,                 /* name of tablespace */
  owner#        number not null,                      /* owner of tablespace */
  online$       number not null,                      /* status (see KTT.H): */
                                     /* 1 = ONLINE, 2 = OFFLINE, 3 = INVALID */
  contents$     number not null,     /* TEMPORARY/PERMANENT                  */
  undofile#     number,  /* undo_off segment file number (status is OFFLINE) */
  undoblock#    number,               /* undo_off segment header file number */
  blocksize     number not null,                   /* size of block in bytes */
  inc#          number not null,             /* incarnation number of extent */
  scnwrp        number,     /* clean offline scn - zero if not offline clean */
  scnbas        number,              /* scnbas - scn base, scnwrp - scn wrap */
  dflminext     number not null,       /*  default minimum number of extents */
  dflmaxext     number not null,        /* default maximum number of extents */
  dflinit       number not null,              /* default initial extent size */
  dflincr       number not null,                 /* default next extent size */
  dflminlen     number not null,              /* default minimum extent size */
  dflextpct     number not null,     /* default percent extent size increase */
  dflogging     number not null,
      /* lowest bit: default logging attribute: clear=NOLOGGING, set=LOGGING */
                                    /* second lowest bit: force logging mode */
  affstrength   number not null,                        /* Affinity strength */
  bitmapped     number not null,       /* If not bitmapped, 0 else unit size */
                                                                /* in blocks */
  plugged       number not null,                               /* If plugged */
  directallowed number not null,   /* Operation which invalidate standby are */
                                                                  /* allowed */
  flags         number not null,                /* various flags: see ktt3.h */
                                         /* 0x01 = system managed allocation */
                                         /* 0x02 = uniform allocation        */
                                /* if above 2 bits not set then user managed */
                                         /* 0x04 = migrated tablespace       */
                                         /* 0x08 = tablespace being migrated */
                                         /* 0x10 = undo tablespace           */
                                     /* 0x20 = auto segment space management */
                       /* if above bit not set then freelist segment managed */
                                                          /* 0x40 = COMPRESS */
                                                      /* 0x80 = ROW MOVEMENT */
                                                              /* 0x100 = SFT */
                                         /* 0x200 = undo retention guarantee */
                                    /* 0x400 = tablespace belongs to a group */
                                  /* 0x800 = this actually describes a group */
                                      /* 0x10000 = OLTP Compression          */
                                      /* 0x20000 = Columnar Low Compression  */
                                      /* 0x40000 = Columnar High Compression */
                                      /* 0x80000 = Archive Compression       */
                                        /* 0x100000 = 12g bigfile tablespace */
                                        /* 0x200000 = DB Consol. Shared TS   */
                                        /* 0x800000 =     ILM policy present */
                                   /* 0x1000000 = bad transport of ts in pdb */
                                 /* 0x2000000 = ILM segment access tracking  */
                                 /* 0x4000000 = ILM row access tracking      */
                                 /* 0x8000000 = ILM update activity tracking */
                                /* 0x10000000 = ILM create activity tracking */
  pitrscnwrp    number,                      /* scn wrap when ts was created */
  pitrscnbas    number,                      /* scn base when ts was created */
  ownerinstance varchar(30),                          /* Owner instance name */
  backupowner   varchar(30),                   /* Backup owner instance name */
  groupname     varchar(30),                                   /* Group name */
  spare1        number,                                  /* plug-in SCN wrap */
  spare2        number,                                  /* plug-in SCN base */
  spare3        varchar2(1000),
  spare4        date
)
cluster c_ts#mig(ts#)
/


/*****************************************************************************/
/*
 * Step 1B - Recreate the remaining tables in the c_obj# and c_user# clusters.
 */
/*****************************************************************************/
drop table ind$mig
/
create table ind$mig                                          /* index table */
( obj#          number not null,                            /* object number */
  /* DO NOT CREATE INDEX ON DATAOBJ#  AS IT WILL BE UPDATED IN A SPACE
   * TRANSACTION DURING TRUNCATE */
  dataobj#      number,                          /* data layer object number */
  ts#           number not null,                        /* tablespace number */
  file#         number not null,               /* segment header file number */
  block#        number not null,              /* segment header block number */
  bo#           number not null,              /* object number of base table */
  indmethod#    number not null,    /* object # for cooperative index method */
  cols          number not null,                        /* number of columns */
  pctfree$      number not null, /* minimum free space percentage in a block */
  initrans      number not null,            /* initial number of transaction */
  maxtrans      number not null,            /* maximum number of transaction */
  pctthres$     number,           /* iot overflow threshold, null if not iot */
  type#         number not null,              /* what kind of index is this? */
                                                               /* normal : 1 */
                                                               /* bitmap : 2 */
                                                              /* cluster : 3 */
                                                            /* iot - top : 4 */
                                                         /* iot - nested : 5 */
                                                            /* secondary : 6 */
                                                                 /* ansi : 7 */
                                                                  /* lob : 8 */
                                             /* cooperative index method : 9 */
  flags         number not null,      
                /* mutable flags: anything permanent should go into property */
                                                    /* unusable (dls) : 0x01 */
                                                    /* analyzed       : 0x02 */
                                                    /* no logging     : 0x04 */
                                    /* index is currently being built : 0x08 */
                                     /* index creation was incomplete : 0x10 */
                                           /* key compression enabled : 0x20 */
                                              /* user-specified stats : 0x40 */
                                            /* secondary index on IOT : 0x80 */
                                      /* index is being online built : 0x100 */
                                    /* index is being online rebuilt : 0x200 */
                                                /* index is disabled : 0x400 */
                                                     /* global stats : 0x800 */
                                            /* fake index(internal) : 0x1000 */
                                       /* index on UROWID column(s) : 0x2000 */
                                            /* index with large key : 0x4000 */
                             /* move partitioned rows in base table : 0x8000 */
                                 /* index usage monitoring enabled : 0x10000 */
                      /* 4 bits reserved for bitmap index version : 0x1E0000 */
                                            /* index is invisible : 0x200000 */
                                       /* Delayed Segment Creation: 0x400000 */
                                              /* index is partial : 0x800000 */
                                                   /* 2 free bits: 0x3000000 */
                                      /* Delayed Segment Creation: 0x4000000 */
                                    /* online index cleanup phase: 0x8000000 */
                                   /* index has orphaned entries: 0x10000000 */
                                 /* index is going to be dropped: 0x20000000 */
                                 /* oltp high index compression : 0x40000000 */
                                   /* oltp low index compression: 0x80000000 */
  property      number not null,    /* immutable flags for life of the index */
                                                            /* unique : 0x01 */
                                                       /* partitioned : 0x02 */
                                                           /* reverse : 0x04 */
                                                        /* compressed : 0x08 */
                                                        /* functional : 0x10 */
                                              /* temporary table index: 0x20 */
                             /* session-specific temporary table index: 0x40 */
                                              /* index on embedded adt: 0x80 */
                         /* user said to check max length at runtime: 0x0100 */
                                              /* domain index on IOT: 0x0200 */
                                                      /* join index : 0x0400 */
                                     /* system managed domain index : 0x0800 */
                           /* The index was created by a constraint : 0x1000 */
                              /* The index was created by create MV : 0x2000 */
                                          /* composite domain index : 0x8000 */
  /* The following columns are used for index statistics such
   * as # btree levels, # btree leaf blocks, # distinct keys, 
   * # distinct values of first key column, average # leaf blocks per key,
   * clustering info, and # blocks in index segment.
   */
  blevel        number,                                       /* btree level */
  leafcnt       number,                                  /* # of leaf blocks */
  distkey       number,                                   /* # distinct keys */
  lblkkey       number,                          /* avg # of leaf blocks/key */
  dblkkey       number,                          /* avg # of data blocks/key */
  clufac        number,                                 /* clustering factor */
  analyzetime   date,                        /* timestamp when last analyzed */
  samplesize    number,                 /* number of rows sampled by Analyze */
  rowcnt        number,                       /* number of rows in the index */
  intcols       number not null,               /* number of internal columns */
         /* The following two columns are only valid for partitioned indexes */
/* 
 * Legal values for degree, instances: 
 *     NULL (used to represent 1 on disk/dictionary and implies noparallel), or
 *     2 thru EB2MAXVAL-1 (user supplied values), or
 *     EB2MAXVAL (implies use default value) 
 */
  degree        number,      /* number of parallel query slaves per instance */
  instances     number,       /*  number of OPS instances for parallel query */
  trunccnt      number,                        /* re-used for iots 'inclcol' */
  evaledition#  number,                                /* evaluation edition */
  unusablebefore#    number,                      /* unusable before edition */
  unusablebeginning# number,              /* unusable beginning with edition */
  spare1        number,         /* number of columns depended on, >= intcols */
  spare2        number,        /* number of key columns in compressed prefix */
  spare3        number,
  spare4        varchar2(1000),     /* used for parameter str for domain idx */
  spare5        varchar2(1000),
  spare6        date                                  /* flashback timestamp */
)
cluster c_obj#mig(bo#)
/

create unique index i_ind1mig on ind$mig(obj#)
/

drop table icol$mig
/
create table icol$mig                                  /* index column table */
( obj#          number not null,                      /* index object number */
  bo#           number not null,                       /* base object number */
  col#          number not null,                            /* column number */
  pos#          number not null,        /* column position number as created */
  segcol#       number not null,                 /* column number in segment */
  segcollength  number not null,             /* length of the segment column */
  offset        number not null,                         /* offset of column */
  intcol#       number not null,                   /* internal column number */
  spare1        number,                                              /* flag */
                                              /* 0x01: this is an expression */
                                                  /* 0x02: desc index column */
                                          /* 0x04: filter by col for dom idx */
                                           /* 0x08: order by col for dom idx */
  spare2        number,            /* dimension table internal column number */
  spare3        number,           /* pos# of col in order by list of dom idx */
  spare4        varchar2(1000),
  spare5        varchar2(1000),
  spare6        date
)
cluster c_obj#mig(bo#)
/

create index i_icol1mig on icol$mig(obj#)
/

drop table lob$mig
/
create table lob$mig                                /* LOB information table */
( obj#          number not null,          /* object number of the base table */
  col#          number not null,                            /* column number */
  intcol#       number not null,                   /* internal column number */
  lobj#         number not null,                /* object number for the LOB */
  part#         number not null,                  /* this column is not used */
  ind#          number not null,                  /* LOB index object number */
  ts#           number not null,         /* segment header tablespace number */
  file#         number not null,               /* segment header file number */
  block#        number not null,              /* segment header block number */
  chunk         number not null,           /* oracle blocks in one lob chunk */
  pctversion$   number not null,                             /* version pool */
  flags         number not null,                           /* 0x0000 = CACHE */
                                                 /* 0x0001 = NOCACHE LOGGING */
                                               /* 0x0002 = NOCACHE NOLOGGING */
                                             /* 0x0008 = CACHE READS LOGGING */
                                           /* 0x0010 = CACHE READS NOLOGGING */
                                          /* 0x0020 = retention is specified */
                                       /* 0x0040 = Index key holds timestamp */
                                      /* 0x0080 = need to drop the freelists */
                                                 /* 0x0100 = CACHE NOLOGGING */
                                                   /* 0x0200 = CACHE LOGGING */
                                                            /* 0x0400 = SYNC */
                                                           /* 0x0800 = ASYNC */
                                                      /* 0x1000 = Encryption */
                                               /* 0x2000 = Compression - Low */
                                            /* 0x4000 = Compression - Medium */
                                              /* 0x8000 = Compression - High */
                                             /* 0x10000 = Sharing: LOB level */
                                          /* 0x20000 = Sharing: Object level */
                                              /* 0x40000 = Sharing: Validate */
  property      number not null,           /* 0x00 = user defined lob column */
                                    /* 0x01 = kernel column(s) stored as lob */
                                     /* 0x02 = user lob column with row data */
                                            /* 0x04 = partitioned LOB column */
                                   /* 0x0008 = LOB In Global Temporary Table */
                                          /* 0x0010 = Session-specific table */
                                      /* 0x0020 = lob with compressed header */ 
                                        /* 0x0040 = lob using shared segment */
                                  /* 0x0080 = first lob using shared segment */
                                   /* 0x0100 = klob and inline image coexist */
                                /* 0x0200 = LOB data in little endian format */
                                                   /* 0x0800 = 11g LOCAL lob */
                                        /* 0x1000 = Delayed Segment Creation */
  retention     number not null,         /* retention value = UNDO_RETENTION */
  freepools     number not null,      /* number of freepools for LOB segment */
  spare1        number,
  spare2        number,
  spare3        varchar2(255)
)
cluster c_obj#mig(obj#)
/

drop table coltype$mig
/
create table coltype$mig                     /* additional column info table */
( obj#          number not null,             /* object number of base object */
  col#          number not null,                            /* column number */
  intcol#       number not null,                   /* internal column number */
  toid          raw(16) not null,                   /* column's ADT type OID */
  version#      number not null,             /* internal type version number */
  packed        number not null,                 /* 0 = unpacked, 1 = packed */
  intcols       number,                        /* number of internal columns */
                                          /* storing the exploded ADT column */
  intcol#s      raw(2000),        /* list of intcol#s of columns storing */
                          /* the unpacked ADT column; stored in packed form; */
                                          /* each intcol# is stored as a ub2 */
  flags         number,
                     /* flags to indicate whether column type is ADT, Array, */
                                                      /* REF or Nested table */
                           /* 0x02 - adt column                              */
                           /* 0x04 - nested table column                     */
                           /* 0x08 - varray column                           */
                           /* 0x10 - ref column                              */
                           /* 0x20 - retrieve collection out-of-line         */
                           /* 0x20 - don't strip the null image              */
                           /* 0x40 - don't chop null image                   */
                           /* 0x40 - collection storage specified            */
                           /* 0x80 - column stores an old (8.0) format image */
                          /* 0x100 - data for this column not yet upgraded   */
                          /* 0x200 - ADT column is substitutable             */
                          /* 0x400 - NOT SUBSTITUTABLE specified explicitly  */
                          /* 0x800 - SUBSTITUTABLE specified explicitly      */
                         /* 0x1000 - implicitly not substitutable            */
                         /* 0x2000 - The typeid column stores the toid       */
                         /* 0x4000 - The column is an opaque type column     */ 
                         /* 0x8000 - nested table name is system generated   */
  typidcol#     number,           /* intcol# of the type discriminant column */
  synobj#       number)              /* obj# of type synonym of the col type */
cluster c_obj#mig(obj#)
/

drop table subcoltype$mig
/
create table subcoltype$mig
( obj#          number not null,             /* object number of base object */
  intcol#       number not null,                   /* internal column number */
  toid          raw(16) not null,                   /* column's ADT type OID */
  version#      number not null,             /* internal type version number */
  intcols       number,                        /* number of internal columns */
                                          /* storing the exploded ADT column */
  intcol#s      raw(2000),        /* list of intcol#s of columns storing */
                          /* the unpacked ADT column; stored in packed form; */
                                          /* each intcol# is stored as a ub2 */
  flags         number,
                          /* 0x01 - This type was stated in the IS OF clause */
                          /* 0x02 - This type has ONLY in the IS OF clause   */
  synobj#       number)  /* obj# of synonym specified for substitutable type */
cluster c_obj#mig(obj#)
/

drop table ntab$mig
/
create table ntab$mig                      /* nested table information table */
( obj#          number not null,             /* object number of base object */
  col#          number not null,                            /* column number */
  intcol#       number not null,                   /* internal column number */
  ntab#         number not null,     /* object number of nested table object */
  name          varchar2(4000) default 'NT$' not null 
                                    /* qualified name of the nested table col*/
)
cluster c_obj#mig(obj#)
/

drop table refcon$mig
/
create table refcon$mig                             /* REF CONstraints table */
( obj#          number not null,             /* object number of base object */
  col#          number not null,                            /* column number */
  intcol#       number not null,                   /* internal column number */
  reftyp        number not null,                            /* REF type flag */
                                                     /* 0x01 = REF is scoped */
                                             /* 0x02 = REF stored with rowid */
                                             /* 0x04 = Primary key based ref */
           /* 0x08 = Primary key based ref allowed in an unscoped ref column */
  stabid        raw(16),                   /* OID of scope table (if scoped) */
  expctoid      raw(16) /* TOID of exploded columns when ref is user-defined */
)
cluster c_obj#mig(obj#)
/

drop table opqtype$mig
/
create table opqtype$mig                      /* extra info for opaque types */
(
  obj#        number not null,                /* object number of base table */
  intcol#     number not null,                     /* internal column number */
  type        number,                              /* The opaque type - type */
                                                       /* 0x01 - XMLType */
  flags       number,                          /* flags for the opaque type */
                              /* -------------- XMLType flags ---------
                               * 0x0001 (1) -- XMLType stored as object
                               * 0x0002 (2) -- XMLType schema is specified
                               * 0x0004 (4) -- XMLType stored as lob 
                               * 0x0008 (8) -- XMLType stores extra column
                               * 
                               * 0x0020 (32)-- XMLType table is out-of-line 
                               * 0x0040 (64)-- XMLType stored as binary
                               * 0x0080 (128)- XMLType binary ANYSCHEMA
                               * 0x0100 (256)- XMLType binary NO non-schema
                               * 0x0200 (512)- Table is hierarchy enabled
                               * 0x0400 (1024)- XMLType table
                               * 0x0800 (2048)- Varray stored as LOB
                               * 0x1000 (4096)- Varray stored as Table
                               * 0x2000 (8192)- Doc fidelity
                               * 0x4000 (16384)- Has XML tree index
                               */
  /* Flags for XMLType (type == 0x01). Override them when necessary  */
  lobcol      number,                                          /* lob column */
  objcol      number,                                      /* obj rel column */
  extracol    number,                                      /* extra info col */
  schemaoid   raw(16),                                     /* schema oid col */
  elemnum     number,                                      /* element number */
  schemaurl   varchar2(4000)                       /* The name of the schema */
)
cluster c_obj#mig(obj#)
/

drop table icoldep$mig
/
create table icoldep$mig                /* which columns an index depends on */
( obj#          number not null,                                 /* index id */
  bo#           number not null,                                 /* table id */
  intcol#       number not null    /* intcol# in table that index depends on */
)
cluster c_obj#mig(bo#)
/
create index i_icoldep$_objmig on icoldep$mig (obj#)
/

drop table viewtrcol$mig
/
create table viewtrcol$mig                   /* triggering view column table */
( obj#          number not null,             /* object number of base object */
  intcol#       number not null,                   /* internal column number */
  attribute#    number not null,          /* attribute# inside col for views */
  name          varchar2(4000) not null)         /* fully-qualified name */
cluster c_obj#mig(obj#)
/

drop table attrcol$mig
/
create table attrcol$mig                       /* ADT attribute column table */
( obj#          number not null,             /* object number of base object */
  intcol#       number not null,                   /* internal column number */
  name          varchar2(4000) not null)         /* fully-qualified name */
cluster c_obj#mig(obj#)
/

drop table type_misc$mig
/
create table type_misc$mig           /* type miscellaneous information table */
( obj#          number not null,                       /* type object number */
  audit$        varchar2(38) not null,             /* auditing options */
  properties    number not null)                               /* properties */
                        /* 0x01 = (flag PRP) potential REF-dependency parent */
                        /* 0x02 = invoker's rights                           */
                        /* 0x04 = Repeeatable                                */
                        /* 0x08 = TO8 Trusted                                */
                        /* 0x10 = SQLJ type                                  */
                        /* 0x20 = SQLJ type with helper class                */
                        /* 0x40 = Natively compiled                          */
                        /* 0x80 = Shrink-wrapped type                        */
                        /* 0x100 = Compiled with debug info                  */
cluster c_obj#mig(obj#)
/

drop table library$mig
/
create table library$mig
( obj#          number not null,             /* object number of the library */
  filespec      varchar2(2000),
                        /* the actual file spec - NULL if property is STATIC */
  property      number,                     /* 0x01 = STATIC, 0x02 = TRUSTED */
  audit$        varchar2(38) not null,              /* auditing options */
  agent         varchar2(128),              /* external procedure agent name */
  leaf_filename varchar2(2000) /* leaf filename if directory object was used */
)
cluster c_obj#mig(obj#)
/

drop table assembly$mig
/
create table assembly$mig
( obj#          number not null,            /* object number of the assembly */
  filespec      varchar2(4000),              /* filename of the assembly */
  security_level number,                          /* assembly security level */
  identity      varchar2(4000),                     /* assembly identity */
  property      number,                                  /* Currently unused */
  audit$        varchar2(38) not null              /* auditing options */
)
cluster c_obj#mig(obj#)
/

/* c_user# cluster */
drop table tsq$mig
/
create table tsq$mig                               /* tablespace quota table */
( ts#           number not null,                        /* tablespace number */
  user#         number not null,                              /* user number */
  grantor#      number not null,                               /* grantor id */
  blocks        number not null,         /* number of blocks charged to user */
  maxblocks     number,     /* user's maximum number of blocks, NULL if none */
  priv1         number not null,            /* reserved for future privilege */
  priv2         number not null,            /* reserved for future privilege */
  priv3         number not null)            /* reserved for future privilege */
cluster c_user#mig (user#)
/

/* c_ts# cluster */
drop table fet$mig
/
create table fet$mig                                    /* free extent table */
( ts#           number not null,        /* tablespace containing free extent */
  file#         number not null,              /* file containing free extent */
  block#        number not null,              /* starting dba of free extent */
  length        number not null           /* length in blocks of free extent */
)
cluster c_ts#mig(ts#)
/
