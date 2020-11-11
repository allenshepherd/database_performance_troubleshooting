Rem
Rem $Header: rdbms/admin/catlsby.sql /st_rdbms_18.0/1 2018/04/24 05:00:10 tchorma Exp $
Rem
Rem catlsby.sql
Rem
Rem Copyright (c) 2000, 2018, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catlsby.sql - Logical Standby tables and views
Rem
Rem    DESCRIPTION
Rem      This file implements the following:
Rem      Tables:
Rem         logstdby$parameters
Rem         logstdby$events
Rem         logstdby$apply_progress
Rem         logstdby$apply_milestone
Rem         logstdby$event_options
Rem         logstdby$scn
Rem         logstdby$skip_transaction
Rem         logstdby$skip
Rem         logstdby$skip_support
Rem         logstdby$eds_tables
Rem
Rem    NOTES
Rem      Must be run when connected as SYS
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catlsby.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catlsby.sql
Rem SQL_PHASE: CATLSBY
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdeps.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    apfwkr      04/13/18 - Backport tchorma_bug-27445330 from main
Rem    tchorma     02/20/18 - bug 27445330 - correct handling of sharded queues
Rem    tchorma     08/30/17 - lrg 20558238 - 12.2.0.2 is still valid compat
Rem    tchorma     08/14/17 - bug 26589711: multi-byte charset issues for views
Rem    tchorma     06/28/17 - Update lsby/rolling views for 18.1
Rem    pjulsaks    06/26/17 - Bug 25688154: Uppercase create_cdbview's input
Rem    tchorma     06/07/17 - bug 26234638 - remove unneccesary grant to SYS
Rem    tchorma     05/10/17 - bug 26006667 - OLAP AW$ tables are unsupported
Rem    tchorma     02/06/17 - bug 25098160 - sdo_rdf_triple_s should be unsupp
Rem    tchorma     01/30/17 - bug 25142454 - ogg: bfile adt attr unsupported
Rem    tchorma     12/16/16 - Proj 47075 - Identity column support for rolling
Rem    ygu         12/02/16 - mark BFILE/UROWID column supported for rolling
Rem    bidu        10/03/16 - bug 22545933: add XS_DATA_SECURITY_UTIL
Rem    tchorma     09/08/16 - bug 24600375 - Support view fix for REF subtype
Rem    anupkk      08/20/16 - XbranchMerge anupkk_bug-24372897 from
Rem                           st_rdbms_12.2.0.1.0
Rem    anupkk      08/19/16 - Bug 24372897: Add dbms_rls_int
Rem    tchorma     07/28/16 - bug 24368389: UROWID has FULL support_mode in OGG
Rem    ssubrama    03/21/16 - bug 22968143 add rules to mapping
Rem    tchorma     02/29/16 - bug 22674912 - unique index on 32k is unsupp
Rem    tchorma     12/17/15 - bug 22288309 - long identifiers unsupp for lsby
Rem    tchorma     12/08/15 - lrg 18834552 - ogg support view internal objects
Rem    tchorma     11/24/15 - bug 20395746 - add ogg supported views
Rem    risgupta    10/19/15 - Lrg 15372645: Add entries for replication of
Rem                           procedures in SA_USER_ADMIN package
Rem    smangala    10/09/15 - bug 21192807: CDB non-unique xid
Rem    sravada     08/27/15 - add new MDSYS package
Rem    dvoss       08/18/15 - bug 21281961 remerge - support view perf fix
Rem    tchorma     07/24/15 - bug 21281961 - rewrite of supported views
Rem    tchorma     04/15/15 - bug 20788531 - PKREF/ REF integrity unsupported
Rem    dvoss       04/14/15 - bug 20845840 - supported view token table check
Rem    bnnguyen    04/11/15 - bug 20860190: Rename 'EXADIRECT' to 'DBSFWUSER'
Rem    tchorma     04/01/15 - bug 20703661: REF attributes of ADTs should be
Rem                           unsupported in 12.1
Rem    dvoss       03/31/15 - bug 20474936: token tab/seq internally maintained
Rem    jingliu     03/27/15 - add GGSYS to skip list
Rem    tchorma     03/25/15 - bug 20771412 - remove skip rules for sdo_topo,
Rem                           georaster in 12.2
Rem    ssubrama    03/09/15 - bug 20588591 add sharded table _l to unsupported
Rem    tchorma     02/24/15 - Bug 19696268: restrict new datatypes to ru
Rem    bnnguyen    01/22/15 - bug 19697038: Add user EXADIRECT 
Rem    svivian     01/09/15 - bug 20309181: long identifier support for
Rem                           logstdby$srec
Rem    ssubrama    11/14/14 - project 38553 procedural replication of AQ
Rem    yanchuan    11/10/14 - Project 36761: Procedural Replication support
Rem                           for Database Vault admin APIs
Rem    tchorma     10/03/14 - Introduce 12.2 supported views
Rem    jlingow     09/05/14 - proj-58146 adding exception to 
Rem                           remote_scheduler_agent schema
Rem    spapadom    08/25/14 - Project 47321: Added user SYS$UMF.
Rem    ssubrama    08/18/14 - bug 18453251 add _p to unsupported
Rem    yanlili     08/08/14 - Proj 46907: Add XS_AMDIN_UTIL package
Rem    risgupta    04/07/14 - Proj 36685 - Add entries for replication of
Rem                           LBACSYS.ols$lab_sequence, PLSQL mappings &
Rem                           marked PLSQL packages
Rem    arjusing    05/27/14 - Bug 18783224: Changes to LOGSTDBY_SUPPORT_TAB_10_1
Rem                           and LOGSTDBY_SUPPORT_TAB_10_2
Rem    sanbhara    04/23/14 - Project 46816 - adding support for SYSRAC.
Rem    tchorma     01/24/14 - Bug 18118559-Temporal Validity tables unsupp in 12
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    dvoss       12/27/13 - add dba_rolling_unsupported
Rem    dvoss       11/25/13 - bug 17526597: add missing grants/comments, move
Rem                           cdb view creation to after dba view completion
Rem    praghuna    11/20/13 - Added pto recovery fields to apply milestone
Rem    sslim       11/11/13 - Bug 17638117: Define CDB_PTC_APPLY_PROGRESS view
Rem    mincwang    10/17/13 - Bug 17336570: update XS package info 
Rem    maba        10/10/13 - added AQ packages for procedural replication
Rem    ygu         09/20/13 - bug 17478554: dbms_xds should be RU only
Rem    maba        09/17/13 - register dbms_aq_sys_imp_internal package
Rem    talliu      06/28/13 - Add CDB view for DBA view
Rem    svivian     06/27/13 - bug 16848187: add src_con_id
Rem    dvoss       01/28/13 - bug 16087735: add missing spatial schemas
Rem    tchorma     01/15/13 - XbranchMerge tchorma_bug-16104863 from
Rem                           st_rdbms_12.1.0.1
Rem    praghuna    13/01/11 - Add lwm_upd_time to logstdby$apply_milestone
Rem    gkulkarn    12/09/12 - 12c: Unsupport RNW - Replace null with columns
Rem    rkadwe      11/29/12 - Map external to internal CTX procedures
Rem    ygu         11/15/12 - fix plsql_support view
Rem    tchorma     11/09/12 - Bug 14495785 - AQ queue tables only supported
Rem                           during rolling upgrade
Rem                           Bug 14661140 - identity columns are unsupported
Rem    tchorma     09/23/12 - Bug 14524646: non-XML, non-ANYDATA opaque types 
Rem                           are unsupported
Rem    tchorma     08/01/12 - bug13999322-all typed tabs with pkeys are
Rem                           supported
Rem    svivian     07/12/12 - Bug 14231927: add src_con_name
Rem    ssubrama    06/15/12 - bug 14160220 logical standby aq support
Rem    tchorma     06/20/12 - bug 13645162 - supported view mods for objects
Rem    ygu         05/30/12 - bug 12991643: plsql proc name mapping
Rem    svivian     05/22/12 - Bug 13591992: add container name to 
Rem                           logstdby$events
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    sslim       03/23/12 - Add sequence support for dbms_rolling
Rem    sdball      03/21/12 - Add gsm users
Rem    svivian     01/27/12 - bug 13636261: sql injection in ddl trigger
Rem    dvoss       01/11/12 - bug 13367585, internal sequences
Rem    tchorma     11/01/11 - lrg 5944404 - hierarchically enabled tables should
Rem                           still be unsupported
Rem    svivian     08/22/11 - Project 30582: EDS DDL support
Rem    gkulkarn    08/19/11 - bug: 12897813 - support_tab_112b/12_1 perf
Rem                           regression
Rem    dvoss       08/17/11 - get compat from x$krvslvst
Rem    tchorma     08/15/11 - dba_logstdby_ views to support ADTs/Varrays
Rem    praghuna    08/15/11 - 12879207: added flags to logstdby$apply_milestone
Rem    sanbhara    07/20/11 - Project 24121 - adding DVSYS and DVF to list of
Rem                           schemas skipped for logical standby.
Rem    jgalanes    07/05/11 - 32kVarchar/Raw support
Rem    abrown      04/20/11 - abrown_bug-10639723: Fix compatibility check.
Rem                           Full XML support in 11.2.0.3
Rem    traney      03/28/11 - 35209: long identifiers dictionary upgrade
Rem    dvoss       02/28/11 - make 12 compat work like 11.2 for now
Rem    jibyun      02/28/11 - Project 5687: Add new schemas, SYSBACKUP, SYSDG,
Rem                           and SYSKM
Rem    amunnoli    02/24/11 - Proj 26873:Introducing 'AUDSYS' user
Rem    mcusson     02/04/11 - Add LogMiner dedup support
Rem    gkulkarn    10/12/10 - bug-10155004: Allow xml-OR typed tables with
Rem    svivian     11/03/10 - allow lobs in eds
Rem    mjungerm    10/18/10 - add OJVMSYS schema
Rem    abrown      04/29/10 - bug-9479009: correct supported view for xmlor
Rem    abrown      04/08/10 - enable csx in 11.2.0.2b views
Rem    abrown      03/23/10 - bug-9501098: XMLOR support
Rem    svivian     10/20/09 - EDS object and varray support
Rem    dvoss       01/29/10 - bug 9271131 - xml on securefile clob unsupported
Rem    svivian     08/31/09 - bug 8846666: dba_logstdby_eds_supported expanded 
Rem                           to include XMLTYPE and more scalars.
Rem    svivian     04/22/09 - refine dba_logstdby_eds_supported
Rem    dvoss       04/16/09 - skip indexes belong in sysaux
Rem    dvoss       04/08/09 - bug 8235260 - skip indexes
Rem    svivian     03/26/09 - add EDS infrastructure
Rem    jkundu      02/17/09 - logstdby$events.spare1 records start_scn of the
Rem                           txn (bug 8260837)
Rem    dvoss       02/05/09 - logstdby$events.event_time should be not null
Rem    dvoss       02/04/09 - add indexes to logstdby$events
Rem    preilly     11/14/08 - Bug 7630082: Check for SecureFiles with Dedup option
Rem    bpwang      09/19/08 - 11.2 supports SecureFiles
Rem    rlong       09/25/08 - 
Rem    nkgopal     08/11/08 - Bug 6830207: Add Alter Database Link changes
Rem    rlong       08/07/08 - 
Rem    myalavar    07/07/08 - 
Rem    svivian     06/10/08 - bug 6487578: add JAVA to logstdby$skip_support
Rem    jkundu      04/23/08 - dba_logstdby_log update for APPLIED column
Rem    myalavar    04/08/08 - add orddata(bug 6759944) to logstdby skip
Rem    rmacnico    03/25/08 - Bug 2931832: support ODCI
Rem    svivian     03/19/08 - add blocks, block_size to dba_logstdby_log
Rem    rmacnico    02/25/08 - Add 11.2 redo compat to supported view
Rem    tchorma     02/08/08 - Remove compression from unsupported views
Rem    dsemler     02/06/08 - Add APPQOSSYS user to exclusion list
Rem    rmacnico    11/26/07 - bug 6528315: support edition in 11.2
Rem    rmacnico    09/14/07 - bug 6406689: unsupported DMLs
Rem    ineall      07/23/07 - Bug 5889516: Disqualify function based index in
Rem                           dba_logstdby_not_unique
Rem    rmacnico    06/14/07 - lrg 3015662: add logstdby$ tabs to noexp$
Rem    rmacnico    05/24/07 - bug 5666482: map primary scn
Rem    rmacnico    05/01/07 - bug 6019939: flashback archive support
Rem    sslim       03/27/07 - Bug 5947235: SBP and Processed SCNs in history
Rem                           table
Rem    rmacnico    03/26/07 - bug 5496852: validate skip on user ddls
Rem    rmacnico    04/11/07 - lrg 2916540: iot overflow tables
Rem    rmacnico    04/04/07 - bug 5971328: increase col width for plsql skip
Rem    rmacnico    03/12/07 - bug 5906232: virtual column primary key
Rem    rmacnico    02/05/07 - bug 5726264: xml store as OR marked sys maint
Rem    rmacnico    01/24/07 - bug 5790970: xml store as csx (binary xml)
Rem    jmzhang     12/20/06 - 5700499: skip table with securefile column
Rem    abrown      10/02/06 - Hierarchically enabled XML tables unsupported in
Rem                           V11
Rem    dvoss       10/12/06 - skip XS$NULL
Rem    rmacnico    09/11/06 - bug 5472731: system, reference partitioned tables
Rem    rmacnico    09/01/06 - lrg 2531243: required synonym
Rem    rmacnico    08/17/06 - 5172550: include AQ in unsupported view
Rem    dvoss       08/01/06 - add xml typed table support
Rem    mtao        07/07/06 - proj 17789: dba_logstdby_log dont show dummy log
Rem    dkapoor     06/16/06 - add ORACLE_OCM in LOGSTDBY30498SKIP_SUPPORT 
Rem    rmacnico    04/20/06 - Add kernal PL/SQL support
Rem    preilly     05/23/06 - Fix UNSUPPORTED view for schema based XML CLOB 
Rem    smangala    05/22/06 - project17789: extend parameters table 
Rem    ineall      03/21/06 - 4601343: Modify view logstdby_support to 
Rem                           avoid ORA-01425 
Rem    rmacnico    03/02/06 - 3584308: handle change in redo compat in lsby
Rem    rmacnico    03/03/06 - 5074345: fix cdef$ flags check
Rem    rmacnico    11/08/05 - cleanup skipped schemas (dglsms)
Rem    sslim       05/26/05 - Reveal corruption state in dba_logstdby_log 
Rem    rmacnico    05/19/05 - Update skip_support categories
Rem    jmzhang     03/23/05 - change default ts for parameter table
Rem    jmzhang     03/29/05 - update dba_logstdby_unsupported
Rem    jmzhang     08/26/04 - remove logstdby_status
Rem                         - remove logstdby_thread
Rem    jmzhang     08/17/04 - add logstdby_status
Rem                           add logstdby_thread
Rem    clei        06/10/04 - disallow encrypted columns
Rem    ajadams     06/15/04 - add index to logstdby events table 
Rem    rgupta      04/23/04 - create tables in SYSAUX tablespace
Rem    ajadams     05/13/04 - add logstdby_transaction 
Rem    jmzhang     05/05/04 - add timestamp to apply_milestone
Rem    jnesheiw    03/11/04 - fix LOGSTDBY_PROGRESS view to show correct 
Rem                           thread# for RAC 
Rem    mcusson     01/15/04 - LogMiner 10g IOT support 
Rem    jnesheiw    12/18/03 - Re-enable partition check 
Rem    raguzman    11/12/03 - use dba_server_registry not dba_registry 
Rem    raguzman    10/29/03 - add list of schema names to skip 
Rem    raguzman    09/24/03 - fix bit check for table_compression
Rem    jmzhang     09/11/03 - fix newest_scn in dba_logstdby_progress
Rem    raguzman    08/28/03 - add column to logstdby_support to support new
Rem                           view logstdby_unsupported_tables for GUI
Rem    jnesheiw    08/28/03 - DBA_LOGSTDBY_PARAMETERS only displays type < 2 
Rem    jmzhang     07/28/03 - fix logstdby_support by adding s.ts#
Rem    gkulkarn    07/09/03 - IOT with mapping table is supported
Rem    jnesheiw    05/19/03 - increase objname size in logstdby$scn
Rem    raguzman    05/27/03 - support view are missing object tables
Rem    raguzman    05/31/03 - real time apply and views
Rem    smangala    05/05/03 - fix bug#2691312: ignore gaps for newest_scn
Rem    narora      03/19/03 - bug 2842797: default value of fetchlwm_scn
Rem    narora      01/13/03 - add fetchlwm_scn to apply_milestone
Rem    raguzman    12/19/02 - add logstdby_support internal use view
Rem    sslim       12/02/02 - lrg 1112873: should not drop tables
Rem    raguzman    11/18/02 - Simply supported queries
Rem    rguzman     07/19/02 - update views for data type support
Rem    rguzman     07/19/02 - do not drop tables, needed for upgrades
Rem    rguzman     10/25/02 - Fix PARAMETERS view and UNSUPPORTED attributes
Rem    jmzhang     10/10/02 - modify the comments of logstdby$parameters 
Rem    rguzman     10/11/02 - Attributes column for DBA_LOGSTDBY_UNSUPPORTED
Rem    jmzhang     09/23/02 - Update system.logstdby$scn
Rem    rguzman     07/07/02 - DBA_LOGSTDBY_PROGRESS must work on RAC
Rem    rguzman     10/01/02 - skip using like feature
Rem    sslim       09/26/02 - Log Stream History Table
Rem    jmzhang     08/12/02 - UPdate DBA_LOGSTDBY_PROGRESS
Rem    jmzhang     08/12/02 - Update DBA_LOGSTDBY_LOG
Rem    gviswana    01/29/02 - CREATE OR REPLACE SYNONYM
Rem    narora      01/17/02 - milestone.spare1 = oldest scn,
Rem                         - spare2=primary syncpoint scn
Rem    rguzman     01/24/02 - Modify UNSUPPORTED view, no ADTs
Rem    cfreiwal    11/14/01 - move logstby views to catlsby.sql
Rem    rguzman     10/12/01 - New columns for logstdby$paramters.
Rem    narora      09/21/01 - remove logstdby_coordinator/slave
Rem    dcassine    08/27/01 - 
Rem    rguzman     09/12/01 - PROGRESS view to report better progress
Rem    dcassine    08/27/01 - LOGSTDBY$APPLY_MILESTONE.PROCESSED_SCN
Rem    jnesheiw    08/02/01 - skip_transaction spare1 name change.
Rem    rguzman     05/18/01 - Fix skip default.
Rem    rguzman     05/17/01 - No Long/Lob support for Alpha kit.
Rem    sslim       05/11/01 - Drop tables before creating them
Rem    jdavison    10/12/00 - Change varchar sizes to 2000.
Rem    narora      08/01/00 - make apply progress a partitioned table
Rem    rguzman     08/11/00 - Views: synonyms, snapshot logs & functional index
Rem    narora      06/20/00 - grant select on v$logstdby_coordinator, 
Rem                         - v$logstdby_apply
Rem    rguzman     05/26/00 - Add views
Rem    rguzman     04/11/00 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

create table system.logstdby$parameters (
  name            varchar2(30),                 /* The name of the parameter */
  value           varchar2(2000),              /* The value of the parameter */
  type            number,  /* null = internal, 1 = persistent, 2 = sessional */
  scn             number,                          /* null or meaningful scn */
  spare1          number,                                /* Future expansion */
  spare2          number,                                /* Future expansion */
  spare3          varchar2(2000)                         /* Future expansion */
) tablespace SYSTEM
/

-- Upgrade may change the set of supported objects, so invalidate the guard 
-- here to force re-validation of all objects
Update system.logstdby$parameters set value = 'NOT READY'
  where name='GUARD_STANDBY';
commit;

create table system.logstdby$events (
  event_time      timestamp not null,  /* The timetamp the event took effect */
  current_scn     number,            /* The change vector SCN for the change */
  commit_scn      number,     /* SCN of commit record for failed transaction */
  xidusn          number,      /* Trans id component of a failed transaction */
  xidslt          number,      /* Trans id component of a failed transaction */
  xidsqn          number,      /* Trans id component of a failed transaction */
  errval          number,                                    /* Error number */
  event           varchar2(2000),      /* first 2000 characters of statement */
  full_event      clob,                            /* The complete statement */
  error           varchar2(2000),      /* error text associated with failure */
  spare1          number,              /* 11.2 (start_scn of the failed txn) */
  spare2          number,                                /* Future expansion */
  spare3          varchar2(2000),                        /* Future expansion */
  con_name        varchar2(30),                            /* container name */
  con_id          number                                     /* container id */
) LOB (full_event) STORE AS (TABLESPACE SYSAUX CACHE PCTVERSION 0
                             CHUNK 16k STORAGE (INITIAL 16K NEXT 16K))
TABLESPACE SYSAUX LOGGING 
/

create index system.logstdby$events_ind
      on system.logstdby$events (event_time asc) tablespace SYSAUX LOGGING;

create index system.logstdby$events_ind_scn
      on system.logstdby$events (commit_scn asc) tablespace SYSAUX LOGGING;

create index system.logstdby$events_ind_xid
      on system.logstdby$events (xidusn, xidslt, xidsqn asc)
      tablespace SYSAUX LOGGING;

-- Turns off partition check --
alter session set events  '14524 trace name context forever, level 1';

create table system.logstdby$apply_progress (
  xidusn          number,    /* Trans id component of an applied transaction */
  xidslt          number,    /* Trans id component of an applied transaction */
  xidsqn          number,    /* Trans id component of an applied transaction */
  commit_scn      number,    /* SCN of commit record for applied transaction */
  commit_time     date,     /* The timestamp corresponding to the commit scn */
  spare1          number,                                /* Future expansion */
  spare2          number,                                /* Future expansion */
  spare3          varchar2(2000)                         /* Future expansion */
) tablespace SYSAUX 
partition by range (commit_scn) (partition P0 values less than (0))
/

-- Turns on partition check --
alter session set events  '14524 trace name context off';

create table system.logstdby$apply_milestone (
  session_id      number not null,                   /* Log miner session id */
  commit_scn      number not null,                         /* low-water mark */
  commit_time     date,                                /* low-water mark time*/
  synch_scn       number not null,                       /* Synch-point SCN. */
  epoch           number not null,    /* Incarnation number for apply engine */
  processed_scn   number not null, /* all comp txn<processed_scn are applied */
  processed_time  date,             /*timestamp corresponding to process_scn */
  fetchlwm_scn    number default(0) not null,    /* maximum SCN ever fetched */
  spare1          number,                                /* oldest_scn       */
  spare2          number,                           /* primary syncpoint scn */
  spare3          varchar2(2000),                        /* Future expansion */
  flags           number,                             /* pto flags (for now) */
--  KNAHA_PTO_USED      0x00000001              Progress table optmization used 
--  KNAHA_PTO_RECOVERED 0x00000002         Progress table optmization recovered
  lwm_upd_time    date,                         /* low-water mark update time*/
  spare4          number,
  spare5          number,
  spare6          number,
  spare7          date,
  pto_recovery_scn               number,  /* local scn when PT was recovered */
  pto_recovery_incarnation       number      /* DB inc when PT was recovered */
) tablespace SYSAUX
/

Rem   Logical Instantiation, beginning scn for each table.
create table system.logstdby$scn (
  obj#      number,
  objname   varchar2(4000),
  schema    varchar2(128),
  type      varchar2(20),
  scn       number,
  spare1          number,                                /* Future expansion */
  spare2          number,                                /* Future expansion */
  spare3          varchar2(2000)                         /* Future expansion */
) tablespace SYSAUX
/

Rem   Logical flashback scn for equivalent primary scn 
create table system.logstdby$flashback_scn (
primary_scn     number not null primary key,
primary_time    date,
standby_scn     number,
standby_time    date,
spare1          number,
spare2          number,
spare3          date
) tablespace SYSAUX
/

Rem TODO remove obsolete table
create table system.logstdby$plsql (
  session_id      number,               /* Id of session issuing the command */
  start_finish    number,        /* Boolean, 0 = 1st record, 1 = last record */
  call_text       clob,                   /* Text of call to pl/sql routine. */
  spare1          number,                                /* Future expansion */
  spare2          number,                                /* Future expansion */
  spare3          varchar2(2000)                         /* Future expansion */
) tablespace SYSAUX
/

create table system.logstdby$skip_transaction (
  xidusn          number,    /* Trans id component of an applied transaction */
  xidslt          number,    /* Trans id component of an applied transaction */
  xidsqn          number,    /* Trans id component of an applied transaction */
  active          number,           /* Boolean to indicate current or active */
  commit_scn      number,                    /* SCN at which tx commited at  */
  spare2          number,                                /* Future expansion */
  spare3          varchar2(2000),                        /* Future expansion */
  con_name        varchar2(384)                            /* container name */
) tablespace SYSAUX
/

create table system.logstdby$skip (
  error           number,            /* Should statement or error be skipped */
  statement_opt   varchar2(128),                /* name from audit_actions or */
                                               /*      logstdby$skip_support */
  schema          varchar2(128),     /* schema name for object being skipped */
  name            varchar2(261),       /* name of object or pack.proc skipped */
  use_like        number, /* 0 = exact match, 1 = like, 2 = like with escape */
  esc             varchar2(1),             /* Escape character if using like */
  proc            varchar2(392),      /* schema.package.proc to call for skip */
  active          number,                                        /* not used */
  spare1          number,         /* 1 if internally generated, null if user */
  spare2          number,                                /* Future expansion */
  spare3          varchar2(2000)                         /* Future expansion */
) tablespace SYSAUX
/

create index system.logstdby$skip_idx1 on
          system.logstdby$skip (use_like, schema, name)
       tablespace SYSAUX LOGGING;

create index system.logstdby$skip_idx2 on
          system.logstdby$skip (statement_opt)
       tablespace SYSAUX LOGGING;

Rem   Statement auditting options for objects encoded here for skip support,
Rem   also contains skip rules for internal schemas and negative skip rules
Rem   for certain internal objects for which replication should take place.
Rem
Rem   In releases where this table changes, the upgrade downgrade scripts
Rem   can simply drop the table since we always delete all the data here
Rem   whenever this script runs.

create table system.logstdby$skip_support (
  action          number not null,    /* number as seen in sys.audit_actions */
                   /* reserving actions 0 & -1 for internal skip schema list */
                   /* -2 is for replicated internal sequences                */
  name            varchar2(128) not null,        /* action to skip or schema */
  name2           varchar2(128),           /* optional secondary/object name */
  name3           varchar2(128),                   /* optional name (future) */
  name4           varchar2(128),    /* plsql mapping - internal package name */
  name5           varchar2(128),    /* plsql mapping - internal proc name    */
  reg             smallint,                            /* from dbms_registry */
  spare1          number,                                /* Future expansion */
  spare2          number,                                /* Future expansion */
  spare3          varchar2(2000)                         /* Future expansion */
) tablespace SYSAUX
/

/* previously we dropped and recreated to control contents */
delete from system.logstdby$skip_support;

insert into system.logstdby$skip_support                           /* INSERT */
             (action, name, reg) values (2, 'DML', 0);
insert into system.logstdby$skip_support                           /* UPDATE */
             (action, name, reg) values (6, 'DML', 0);
insert into system.logstdby$skip_support                           /* DELETE */
             (action, name, reg) values (7, 'DML', 0);

/* SCHEMA_DDL & NONSCHEMA_DDL determined by null/non-null owner and name */

insert into system.logstdby$skip_support                   /* CREATE CLUSTER */
             (action, name, reg) values (4, 'CLUSTER', 0);
insert into system.logstdby$skip_support                    /* ALTER CLUSTER */
             (action, name, reg) values (5, 'CLUSTER', 0);
insert into system.logstdby$skip_support                     /* DROP CLUSTER */
             (action, name, reg) values (8, 'CLUSTER', 0);
insert into system.logstdby$skip_support                 /* TRUNCATE CLUSTER */
             (action, name, reg) values (86, 'CLUSTER', 0);

insert into system.logstdby$skip_support                   /* CREATE CONTEXT */
             (action, name, reg) values (177, 'CONTEXT', 0);
insert into system.logstdby$skip_support                     /* DROP CONTEXT */
             (action, name, reg) values (178, 'CONTEXT', 0);

insert into system.logstdby$skip_support             /* CREATE DATABASE LINK */
             (action, name, reg) values (32, 'DATABASE LINK', 0);
insert into system.logstdby$skip_support               /* DROP DATABASE LINK */
             (action, name, reg) values (33, 'DATABASE LINK', 0);
insert into system.logstdby$skip_support              /* ALTER DATABASE LINK */
             (action, name, reg) values (225, 'DATABASE LINK', 0);

insert into system.logstdby$skip_support                 /* CREATE DIMENSION */
             (action, name, reg) values (174, 'DIMENSION', 0);
insert into system.logstdby$skip_support                  /* ALTER DIMENSION */
             (action, name, reg) values (175, 'DIMENSION', 0);
insert into system.logstdby$skip_support                   /* DROP DIMENSION */
             (action, name, reg) values (176, 'DIMENSION', 0);

insert into system.logstdby$skip_support                 /* CREATE DIRECTORY */
             (action, name, reg) values (157, 'DIRECTORY', 0);
insert into system.logstdby$skip_support                   /* DROP DIRECTORY */
             (action, name, reg) values (158, 'DIRECTORY', 0);

insert into system.logstdby$skip_support                     /* CREATE INDEX */
             (action, name, reg) values (9, 'INDEX', 0);
insert into system.logstdby$skip_support                      /* ALTER INDEX */
             (action, name, reg) values (11, 'INDEX', 0);
insert into system.logstdby$skip_support                       /* DROP INDEX */
             (action, name, reg) values (10, 'INDEX', 0);

insert into system.logstdby$skip_support                 /* CREATE PROCEDURE */
             (action, name, reg) values (24, 'PROCEDURE', 0);
insert into system.logstdby$skip_support                  /* ALTER PROCEDURE */
             (action, name, reg) values (25, 'PROCEDURE', 0);
insert into system.logstdby$skip_support                   /* DROP PROCEDURE */
             (action, name, reg) values (68, 'PROCEDURE', 0);
insert into system.logstdby$skip_support                  /* CREATE FUNCTION */
             (action, name, reg) values (91, 'PROCEDURE', 0);
insert into system.logstdby$skip_support                   /* ALTER FUNCTION */
             (action, name, reg) values (92, 'PROCEDURE', 0);
insert into system.logstdby$skip_support                    /* DROP FUNCTION */
             (action, name, reg) values (93, 'PROCEDURE', 0);
insert into system.logstdby$skip_support                   /* CREATE PACKAGE */
             (action, name, reg) values (94, 'PROCEDURE', 0);
insert into system.logstdby$skip_support                    /* ALTER PACKAGE */
             (action, name, reg) values (95, 'PROCEDURE', 0);
insert into system.logstdby$skip_support                     /* DROP PACKAGE */
             (action, name, reg) values (96, 'PROCEDURE', 0);
insert into system.logstdby$skip_support              /* CREATE PACKAGE BODY */
             (action, name, reg) values (97, 'PROCEDURE', 0);
insert into system.logstdby$skip_support               /* ALTER PACKAGE BODY */
             (action, name, reg) values (98, 'PROCEDURE', 0);
insert into system.logstdby$skip_support                /* DROP PACKAGE BODY */
             (action, name, reg) values (99, 'PROCEDURE', 0);
insert into system.logstdby$skip_support                   /* CREATE LIBRARY */
             (action, name, reg) values (159, 'PROCEDURE', 0);
insert into system.logstdby$skip_support                    /* ALTER LIBRARY */
             (action, name, reg) values (196, 'PROCEDURE', 0);
insert into system.logstdby$skip_support                     /* DROP LIBRARY */
             (action, name, reg) values (84, 'PROCEDURE', 0);

insert into system.logstdby$skip_support                   /* CREATE PROFILE */
             (action, name, reg) values (65, 'PROFILE', 0);
insert into system.logstdby$skip_support                    /* ALTER PROFILE */
             (action, name, reg) values (67, 'PROFILE', 0);
insert into system.logstdby$skip_support                     /* DROP PROFILE */
             (action, name, reg) values (66, 'PROFILE', 0);

insert into system.logstdby$skip_support                      /* CREATE ROLE */
             (action, name, reg) values (52, 'ROLE', 0);
insert into system.logstdby$skip_support                       /* ALTER ROLE */
             (action, name, reg) values (79, 'ROLE', 0);
insert into system.logstdby$skip_support                        /* DROP ROLE */
             (action, name, reg) values (54, 'ROLE', 0);
insert into system.logstdby$skip_support                         /* SET ROLE */
             (action, name, reg) values (55, 'ROLE', 0);

insert into system.logstdby$skip_support          /* CREATE ROLLBACK SEGMENT */
             (action, name, reg) values (36, 'ROLLBACK STATEMENT', 0);
insert into system.logstdby$skip_support           /* ALTER ROLLBACK SEGMENT */
             (action, name, reg) values (37, 'ROLLBACK STATEMENT', 0);
insert into system.logstdby$skip_support            /* DROP ROLLBACK SEGMENT */
             (action, name, reg) values (38, 'ROLLBACK STATEMENT', 0);

insert into system.logstdby$skip_support                  /* CREATE SEQUENCE */
             (action, name, reg) values (13, 'SEQUENCE', 0);
insert into system.logstdby$skip_support                   /* ALTER SEQUENCE */
             (action, name, reg) values (14, 'SEQUENCE', 0);
insert into system.logstdby$skip_support                    /* DROP SEQUENCE */
             (action, name, reg) values (16, 'SEQUENCE', 0);

insert into system.logstdby$skip_support                   /* CREATE SYNONYM */
             (action, name, reg) values (19, 'SYNONYM', 0);
insert into system.logstdby$skip_support                     /* DROP SYNONYM */
             (action, name, reg) values (20, 'SYNONYM', 0);
insert into system.logstdby$skip_support            /* CREATE PUBLIC SYNONYM */
             (action, name, reg) values (110, 'SYNONYM', 0);
insert into system.logstdby$skip_support              /* DROP PUBLIC SYNONYM */
             (action, name, reg) values (111, 'SYNONYM', 0);

insert into system.logstdby$skip_support                     /* CREATE TABLE */
             (action, name, reg) values (1, 'TABLE', 0);
insert into system.logstdby$skip_support                      /* ALTER TABLE */
             (action, name, reg) values (15, 'TABLE', 0);
insert into system.logstdby$skip_support                       /* DROP TABLE */
             (action, name, reg) values (12, 'TABLE', 0);
insert into system.logstdby$skip_support                   /* TRUNCATE TABLE */
             (action, name, reg) values (85, 'TABLE', 0);
                                                /* COMMENT ON TABLE included */

insert into system.logstdby$skip_support                /* CREATE TABLESPACE */
             (action, name, reg) values (39, 'TABLESPACE', 0);
insert into system.logstdby$skip_support                 /* ALTER TABLESPACE */
             (action, name, reg) values (40, 'TABLESPACE', 0);
insert into system.logstdby$skip_support                  /* DROP TABLESPACE */
             (action, name, reg) values (41, 'TABLESPACE', 0);

insert into system.logstdby$skip_support                   /* CREATE TRIGGER */
             (action, name, reg) values (59, 'TRIGGER', 0);
insert into system.logstdby$skip_support                    /* ALTER TRIGGER */
             (action, name, reg) values (60, 'TRIGGER', 0);
insert into system.logstdby$skip_support                     /* DROP TRIGGER */
             (action, name, reg) values (61, 'TRIGGER', 0);
insert into system.logstdby$skip_support                   /* ENABLE TRIGGER */
             (action, name, reg) values (118, 'TRIGGER', 0);
insert into system.logstdby$skip_support                  /* DISABLE TRIGGER */
             (action, name, reg) values (119, 'TRIGGER', 0);
insert into system.logstdby$skip_support              /* ENABLE ALL TRIGGERS */
             (action, name, reg) values (120, 'TRIGGER', 0);
insert into system.logstdby$skip_support             /* DISABLE ALL TRIGGERS */
             (action, name, reg) values (121, 'TRIGGER', 0);

insert into system.logstdby$skip_support                      /* CREATE TYPE */
             (action, name, reg) values (77, 'TYPE', 0);
insert into system.logstdby$skip_support                        /* DROP TYPE */
             (action, name, reg) values (78, 'TYPE', 0);
insert into system.logstdby$skip_support                       /* ALTER TYPE */
             (action, name, reg) values (80, 'TYPE', 0);
insert into system.logstdby$skip_support                 /* CREATE TYPE BODY */
             (action, name, reg) values (81, 'TYPE', 0);
insert into system.logstdby$skip_support                  /* ALTER TYPE BODY */
             (action, name, reg) values (82, 'TYPE', 0);
insert into system.logstdby$skip_support                   /* DROP TYPE BODY */
             (action, name, reg) values (83, 'TYPE', 0);

insert into system.logstdby$skip_support                      /* CREATE USER */
             (action, name, reg) values (51, 'USER', 0);
insert into system.logstdby$skip_support                       /* ALTER USER */
             (action, name, reg) values (43, 'USER', 0);
insert into system.logstdby$skip_support                        /* DROP USER */
             (action, name, reg) values (53, 'USER', 0);

insert into system.logstdby$skip_support                      /* CREATE VIEW */
             (action, name, reg) values (21, 'VIEW', 0);
insert into system.logstdby$skip_support                        /* DROP VIEW */
             (action, name, reg) values (22, 'VIEW', 0);

insert into system.logstdby$skip_support                            /* GRANT */
             (action, name, reg) values (17, 'GRANT', 0);
insert into system.logstdby$skip_support                           /* REVOKE */
             (action, name, reg) values (18, 'REVOKE', 0);

insert into system.logstdby$skip_support                            /* AUDIT */
             (action, name, reg) values (30, 'AUDIT', 0);
insert into system.logstdby$skip_support                          /* NOAUDIT */
             (action, name, reg) values (31, 'AUDIT', 0);

insert into system.logstdby$skip_support                   /* CREATE EDITION */
             (action, name, reg) values (212, 'EDITION', 0);
insert into system.logstdby$skip_support                    /* ALTER EDITION */
             (action, name, reg) values (213, 'EDITION', 0);
insert into system.logstdby$skip_support                     /* DROP EDITION */
             (action, name, reg) values (214, 'EDITION', 0);

insert into system.logstdby$skip_support                      /* CREATE JAVA */
             (action, name, reg) values (160, 'JAVA', 0);
insert into system.logstdby$skip_support                       /* ALTER JAVA */
             (action, name, reg) values (161, 'JAVA', 0);
insert into system.logstdby$skip_support                        /* DROP JAVA */
             (action, name, reg) values (162, 'JAVA', 0);

-- These placeholders do not correspond to valid octdef's
insert into system.logstdby$skip_support                /* EXECUTE PROCEDURE */
             (action, name, reg) values (1000000, 'PL/SQL', 0);
insert into system.logstdby$skip_support         /* DDL in EXECUTE PROCEDURE */
             (action, name, reg) values (1000001, 'PL/SQL_DDL', 0);

commit;


Rem
Rem   List of schemas that ship with database
Rem   This list should match select username from dba_users on a shiphome.
Rem   action = 0  means we will skip acitivity in that schema
Rem   action = -1 means we will not skip acitivity in that schema
Rem   reg = 0 means we already know about this internal schema
Rem   reg = 1 means schema was registered by dbms_registry.loading
Rem

insert into system.logstdby$skip_support                    /* Sample Schema */
                  (action, name, reg) values (-1, 'ADAMS', 0);
insert into system.logstdby$skip_support               /* HTTP access to XDB */
                  (action, name, reg) values (0, 'ANONYMOUS', 0);
insert into system.logstdby$skip_support                  /* QOS system user */
                  (action, name, reg) values (0, 'APPQOSSYS', 0);
insert into system.logstdby$skip_support                /* audit super user */
                  (action, name, reg) values (0, 'AUDSYS', 0);
insert into system.logstdby$skip_support            /* Business Intelligence */
                  (action, name, reg) values (0, 'BI', 0);
insert into system.logstdby$skip_support                    /* Sample Schema */
                  (action, name, reg) values (-1, 'BLAKE', 0);
insert into system.logstdby$skip_support                    /* Sample Schema */
                  (action, name, reg) values (-1, 'CLARK', 0);
insert into system.logstdby$skip_support                             /* Text */
                  (action, name, reg) values (0, 'CTXSYS', 0);
insert into system.logstdby$skip_support         /* DB Service FireWall USER */
                  (action, name, reg) values (0, 'DBSFWUSER', 0);
insert into system.logstdby$skip_support   /* Directory Integration Platform */
                  (action, name, reg) values (0, 'DIP', 0);
insert into system.logstdby$skip_support               /* SNMP agent for OEM */
                  (action, name, reg) values (0, 'DBSNMP', 0);
insert into system.logstdby$skip_support                      /* Data Mining */
                  (action, name, reg) values (0, 'DMSYS', 0);
insert into system.logstdby$skip_support           /* Database Vault - DVSYS */
                  (action, name, reg) values (0, 'DVSYS', 0);
insert into system.logstdby$skip_support             /* Database Vault - DVF */
                  (action, name, reg) values (0, 'DVF', 0);
insert into system.logstdby$skip_support        /* External ODCI System User */
                  (action, name, reg) values (0, 'EXDSYS', 0);
insert into system.logstdby$skip_support                /* Expression Filter */
                  (action, name, reg) values (0, 'EXFSYS', 0);
insert into system.logstdby$skip_support              /* GG sharding support */
                  (action, name, reg) values (0, 'GGSYS', 0);
insert into system.logstdby$skip_support           /* Global Service Manager */
                  (action, name, reg) values (0, 'GSMCATUSER', 0);
insert into system.logstdby$skip_support           /* Global Service Manager */
                  (action, name, reg) values (0, 'GSMUSER', 0);
insert into system.logstdby$skip_support           /* Global Service Manager */
                  (action, name, reg) values (0, 'GSMADMIN_INTERNAL', 0);
insert into system.logstdby$skip_support                    /* Sample Schema */
                  (action, name, reg) values (-1, 'HR', 0);
insert into system.logstdby$skip_support                    /* Sample Schema */
                  (action, name, reg) values (-1, 'IX', 0);
insert into system.logstdby$skip_support                    /* Sample Schema */
                  (action, name, reg) values (-1, 'JONES', 0);
insert into system.logstdby$skip_support                   /* Label Security */
                  (action, name, reg) values (0, 'LBACSYS', 0);
insert into system.logstdby$skip_support                /* Spatial user data */
                  (action, name, reg) values (-1, 'MDDATA', 0);
insert into system.logstdby$skip_support                          /* Spatial */
                  (action, name, reg) values (0, 'MDSYS', 0);
insert into system.logstdby$skip_support             /* OEM Database Control */
                  (action, name, reg) values (0, 'MGMT_VIEW', 0);
insert into system.logstdby$skip_support            /* MS Transaction Server */
                  (action, name, reg) values (0, 'MTSSYS', 0);
insert into system.logstdby$skip_support                      /* Data Mining */
                  (action, name, reg) values (0, 'ODM', 0);
insert into system.logstdby$skip_support           /* Data Mining Repository */
                  (action, name, reg) values (0, 'ODM_MTR', 0);
insert into system.logstdby$skip_support                    /* Sample Schema */
                  (action, name, reg) values (-1, 'OE', 0);
insert into system.logstdby$skip_support           /* Java Policy SRO Schema */
                  (action, name, reg) values (0, 'OJVMSYS', 0);
insert into system.logstdby$skip_support                    /* OLAP catalogs */
                  (action, name, reg) values (0, 'OLAPSYS', 0);
insert into system.logstdby$skip_support  /* Oracle Configuration Manager User*/
                  (action, name, reg) values (0, 'ORACLE_OCM', 0);
insert into system.logstdby$skip_support                       /* Intermedia */
                  (action, name, reg) values (0, 'ORDDATA', 0);
insert into system.logstdby$skip_support                       /* Intermedia */
                  (action, name, reg) values (0, 'ORDPLUGINS', 0);
insert into system.logstdby$skip_support                       /* Intermedia */
                  (action, name, reg) values (0, 'ORDSYS', 0);
insert into system.logstdby$skip_support        /* Outlines (Plan Stability) */
                  (action, name, reg) values (0, 'OUTLN', 0);
insert into system.logstdby$skip_support                    /* Sample Schema */
                  (action, name, reg) values (-1, 'PM', 0);
insert into system.logstdby$skip_support    /* Remote Jobs Schema proj-58146 */
                  (action, name, reg) values (0, 'REMOTE_SCHEDULER_AGENT', 0);
insert into system.logstdby$skip_support                    /* Sample Schema */
                  (action, name, reg) values (-1, 'SCOTT', 0);
insert into system.logstdby$skip_support               /* SQL/MM Still Image */
                  (action, name, reg) values (0, 'SI_INFORMTN_SCHEMA', 0);
insert into system.logstdby$skip_support                    /* Sample Schema */
                  (action, name, reg) values (-1, 'SH', 0);
insert into system.logstdby$skip_support
                  (action, name, reg) values (0, 'SPATIAL_CSW_ADMIN', 0);
insert into system.logstdby$skip_support
                  (action, name, reg) values (0, 'SPATIAL_CSW_ADMIN_USR', 0);
insert into system.logstdby$skip_support
                  (action, name, reg) values (0, 'SPATIAL_WFS_ADMIN', 0);
insert into system.logstdby$skip_support
                  (action, name, reg) values (0, 'SPATIAL_WFS_ADMIN_USR', 0);
insert into system.logstdby$skip_support
                  (action, name, reg) values (0, 'SYS', 0);
insert into system.logstdby$skip_support
                  (action, name, reg) values (0, 'SYSBACKUP', 0);
insert into system.logstdby$skip_support
                  (action, name, reg) values (0, 'SYSDG', 0);
insert into system.logstdby$skip_support
                  (action, name, reg) values (0, 'SYSKM', 0);
insert into system.logstdby$skip_support
                  (action, name, reg) values (0, 'SYSRAC', 0);
insert into system.logstdby$skip_support
                  (action, name, reg) values (0, 'SYS$UMF', 0);
insert into system.logstdby$skip_support
                  (action, name, reg) values (0, 'SYSTEM', 0);
insert into system.logstdby$skip_support                /* Adminstrator OEM */
                  (action, name, reg) values (0, 'SYSMAN', 0);
insert into system.logstdby$skip_support    /* Transparent Session Migration */
                  (action, name, reg) values (0, 'TSMSYS', 0);
insert into system.logstdby$skip_support                      /* Ultrasearch */
                  (action, name, reg) values (0, 'WKPROXY', 0);
insert into system.logstdby$skip_support                      /* Ultrasearch */
                  (action, name, reg) values (0, 'WKSYS', 0);
insert into system.logstdby$skip_support
                  (action, name, reg) values (0, 'WK_TEST', 0);
insert into system.logstdby$skip_support                /* Workspace Manager */
                  (action, name, reg) values (0, 'WMSYS', 0);
insert into system.logstdby$skip_support                           /* XML DB */
                  (action, name, reg) values (0, 'XDB', 0);
insert into system.logstdby$skip_support
                  (action, name, reg) values (0, 'XS$NULL', 0);
insert into system.logstdby$skip_support                       /* Time Index */
                  (action, name, reg) values (0, 'XTISYS', 0);
commit;


Rem
Rem   List of internal sequences that need to be replicated
Rem   action = -2 means we will replicate this sequence even though it
Rem   is owned by an internal schema
Rem
insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-2, 'SYS', 'SCHEDULER$_INSTANCE_S', 0);
insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-2, 'SYS', 'SCHEDULER$_JOBSUFFIX_S', 0);
insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-2, 'SYSTEM', 'ROLLING_EVENT_SEQ$', 0);
insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-2, 'LBACSYS', 'OLS$LAB_SEQUENCE', 0);
commit;

Rem
Rem   List of PLSQL mapping between external (user invokable) procedures to
Rem   the corresponding pragm-ed (supplemental log pragma) internal procedure.
Rem   action = -3 means this row is used for PLSQL procedure mapping.
Rem
Rem   Note:
Rem   . When supplemental log pragma is directly added to the external
Rem     procedure, no mapping is needed and no row needs to be added to
Rem     logstdby$skip_support for this procedure.
Rem
Rem   . When supplemental log pragma is added to internal package/procedure,
Rem     a row with action = -3 should be added.
Rem     The mapping is represented as: 
Rem         (action, name, name2, name3, name4, name5).
Rem     Where
Rem       action: must be -3, 
Rem       name : schema name of the external procedure.
Rem       name2: package name of the external procedure.
Rem       name3: procedure name of the external procedure.
Rem       name4: package name of the internal pragma-d procedure
Rem       name5: procedure name of the internal pragma-d procedure
Rem
Rem  . We assume that external procedure and the corrsponding
Rem    pragma-d procedure belong to the same schema.
Rem
Rem  . If package/procedure names are case sensitive, these names inserted
Rem    for the mapping should be case sensitive, otherwise, the names should
Rem    be capitalized.
Rem
Rem  . 1->many mapping
Rem    1 user invokable procedure may map to multiple pragma-d internal
Rem    procedures. In this case, there should be 1 row for each internal
Rem    pragma-d procedure in system.logstdby$skip_support.
Rem
Rem  . We currently can not support many -> 1/many mapping
Rem    If multiple external procedures maps to the same internal
Rem    pragm-ed procedures, when skip rule is set for any of these external
Rem    procedures, all the external procedure will be skipped.
Rem
Rem  . Entire package mapping
Rem    When all the procedures of the external package are mapped to
Rem    procedures of an internal package, and procedures in different
Rem    packages use the same name or procedure level skip rule is not allowed,
Rem    then we can add a single row to system.logstdby$skip_support for
Rem    this entire package mapping.
Rem    name3 and name5 of this row should be NULL.
Rem    
Rem    Example:
Rem    . 1-1 mapping:  u1.pkg1.proc1 -> u1.pkg1_int.proc1_int
Rem      insert into system.logstdby$skip_support
Rem      (action, name, name2, name3, name4, name5, reg)
Rem      values (-3, 'U1', 'PKG1', 'PROC1', 'PKG1_INT', 'PROC1_INT', 0);
Rem
Rem    . 1-2 mapping: u1.pkg2.proc1 -> u1.pkg2_int.proc11_int
Rem                                    u1.pkg2_int.proc12_int
Rem      insert into system.logstdby$skip_support
Rem      (action, name, name2, name3, name4, name5, reg)
Rem      values (-3, 'U1', 'PKG2', 'PROC1', 'PKG2_INT', 'PROC11_INT', 0);
Rem      insert into system.logstdby$skip_support
Rem      (action, name, name2, name3, name4, name5, reg)
Rem      values (-3, 'U1', 'PKG2', 'PROC1', 'PKG2_INT', 'PROC12_INT', 0);
Rem
Rem    . Entire package mapping:
Rem        u1.pkg3 has proc1, proc2 and proc3. They map to proc1, proc2, proc3
Rem        of u1.pkg3_int
Rem     insert into system.logstdby$skip_support
Rem      (action, name, name2, name4, reg)
Rem      values (-3, 'U1', 'PKG3', 'PKG3_INT', 0);
Rem     
Rem   Mapping for procedures in XDB.DBMS_XMLSCHEMA
Rem   ----------------------------------------------------------------------
Rem     User visible proceudre         |       Pragma-d internal procedure
Rem     in (dbms_xmlschema package)    |       in dbms_xmlschemalsb package
Rem   ----------------------------------------------------------------------
Rem    registerSchema(varchar2)        | registerSchema_Str
Rem                  (clob)            | registerSchema_oid
Rem                  (blob)            | registerSchema_blob
Rem                  (bfile)           | registerSchema_blob *
Rem                  (xmltype)         | registerSchema_xml
Rem                  (UriType)         | registerSchema_oid  *
Rem    registerURI                     | registerSchema_oid  **
Rem    compileSchema                   | compileSchema
Rem    compileSchema                   | CopyEvolve
Rem   ----------------------------------------------------------------------
Rem   *  : the mapping is covered earlier
Rem   ** : Cause multi-one mapping, can not support at this point.
Rem        No row is added to skip_support.
Rem

insert into system.logstdby$skip_support
       (action, name, name2, name4, reg)
       values (-3, 'SYS', 'DBMS_AQ_IMP_INTERNAL', 
       'DBMS_AQ_SYS_IMP_INTERNAL', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name4, reg)
       values (-3, 'SYS', 'DBMS_AQADM',
       'DBMS_AQADM_SYS', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name4, reg)
       values (-3, 'SYS', 'DBMS_RULE_ADM',
       'DBMS_RULEADM_INTERNAL', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'XDB', 'DBMS_XMLSCHEMA','REGISTERSCHEMA',
       'DBMS_XMLSCHEMA_LSB', 'REGISTERSCHEMA_STR', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'XDB', 'DBMS_XMLSCHEMA','REGISTERSCHEMA',
       'DBMS_XMLSCHEMA_LSB', 'REGISTERSCHEMA_OID', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'XDB', 'DBMS_XMLSCHEMA','REGISTERSCHEMA',
       'DBMS_XMLSCHEMA_LSB', 'REGISTERSCHEMA_BLOB', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'XDB', 'DBMS_XMLSCHEMA','REGISTERSCHEMA',
       'DBMS_XMLSCHEMA_LSB', 'REGISTERSCHEMA_XML', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'XDB', 'DBMS_XMLSCHEMA','COMPILESCHEMA',
       'DBMS_XMLSCHEMA_LSB', 'COMPILESCHEMA', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'XDB', 'DBMS_XMLSCHEMA','COPYEVOLVE',
       'DBMS_XMLSCHEMA_LSB', 'COPYEVOLVE', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'LBACSYS', 'SA_SYSDBA','CREATE_POLICY',
       'LBAC_LGSTNDBY_UTIL', 'CREATE_POLICY', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'LBACSYS', 'SA_USER_ADMIN','SET_USER_LABELS',
       'LBAC_LGSTNDBY_UTIL', 'SET_USER_LABELS', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'LBACSYS', 'SA_SESSION','SAVE_DEFAULT_LABELS',
       'LBAC_LGSTNDBY_UTIL', 'SAVE_DEFAULT_LABELS', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name4, reg)
       values (-3, 'LBACSYS', 'SA_POLICY_ADMIN',
       'LBAC_POLICY_ADMIN', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'LBACSYS', 'SA_USER_ADMIN','SET_LEVELS',
       'LBAC_LGSTNDBY_UTIL', 'SET_LEVELS', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'LBACSYS', 'SA_USER_ADMIN','SET_COMPARTMENTS',
       'LBAC_LGSTNDBY_UTIL', 'SET_COMPARTMENTS', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'LBACSYS', 'SA_USER_ADMIN','ALTER_COMPARTMENTS',
       'LBAC_LGSTNDBY_UTIL', 'ALTER_COMPARTMENTS', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'LBACSYS', 'SA_USER_ADMIN','SET_GROUPS',
       'LBAC_LGSTNDBY_UTIL', 'SET_GROUPS', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'LBACSYS', 'SA_USER_ADMIN','ALTER_GROUPS',
       'LBAC_LGSTNDBY_UTIL', 'ALTER_GROUPS', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'LBACSYS', 'SA_USER_ADMIN','ADD_COMPARTMENTS',
       'LBAC_LGSTNDBY_UTIL', 'ADD_COMPARTMENTS', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'LBACSYS', 'SA_USER_ADMIN','DROP_COMPARTMENTS',
       'LBAC_LGSTNDBY_UTIL', 'DROP_COMPARTMENTS', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'LBACSYS', 'SA_USER_ADMIN','DROP_ALL_COMPARTMENTS',
       'LBAC_LGSTNDBY_UTIL', 'DROP_ALL_COMPARTMENTS', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'LBACSYS', 'SA_USER_ADMIN','ADD_GROUPS',
       'LBAC_LGSTNDBY_UTIL', 'ADD_GROUPS', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'LBACSYS', 'SA_USER_ADMIN','DROP_GROUPS',
       'LBAC_LGSTNDBY_UTIL', 'DROP_GROUPS', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'LBACSYS', 'SA_USER_ADMIN','DROP_ALL_GROUPS',
       'LBAC_LGSTNDBY_UTIL', 'DROP_ALL_GROUPS', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'LBACSYS', 'SA_USER_ADMIN','SET_DEFAULT_LABEL',
       'LBAC_LGSTNDBY_UTIL', 'SET_DEFAULT_LABEL', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'LBACSYS', 'SA_USER_ADMIN','SET_ROW_LABEL',
       'LBAC_LGSTNDBY_UTIL', 'SET_ROW_LABEL', 0);

Rem   Mapping for DBMS_XDB, DBMS_XDB_CONFIG, DBMS_XDB_REPOS, 
Rem   and DBMS_XDBRESOURCE.
Rem
Rem   Procedures in these packages maps to procedures in DBMS_XLSB. But it is a 
Rem   many-to-many mapping. Based on XDB group, that is part of the design
Rem   for repository rolling upgrade because they want to reuse the dbms_xlsb
Rem   procedures for different repository operations. They suggest to
Rem   document this, and only allow skip rule for entire package.
Rem   So we do not need to add procedure level mapping for XDB,
Rem   instead, package level mapping is added for these packages.
Rem   ----------------------------------------------------------------------
Rem     User visible package           |       Pragma-d internal package
Rem   ----------------------------------------------------------------------
Rem        XDB.DBMS_XDB                |         XDB.DBMS_XLSB
Rem        XDB.DBMS_XDB_CONFIG         |         XDB.DBMS_XLSB
Rem        XDB.DBMS_XDB_REPOS          |         XDB.DBMS_XLSB
Rem        XDB.DBMS_XDBRESOURCE        |         XDB.DBMS_XLSB
Rem   ----------------------------------------------------------------------

insert into system.logstdby$skip_support
       (action, name, name2, name4, reg)
       values (-3, 'XDB', 'DBMS_XDB','DBMS_XLSB', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name4, reg)
       values (-3, 'XDB', 'DBMS_XDB_CONFIG','DBMS_XLSB', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name4, reg)
       values (-3, 'XDB', 'DBMS_XDB_REPOS','DBMS_XLSB', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name4, reg)
       values (-3, 'XDB', 'DBMS_XDBRESOURCE','DBMS_XLSB', 0);

Rem  Procedure level skip for XS
Rem  set_password -> set_verifier_helper
Rem  set_verifier -> set_verifier_helper
Rem  Currently logical standby does not support "many to one" mapping, 
Rem  so we do package level skip in -4 section.
Rem  According to logical standby team, we still need to put this 
Rem  for informational purpose
insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'SYS', 'XS_PRINCIPAL','SET_PASSWORD',
       'XS_PRINCIPAL_INT', 'SET_VERIFIER_HELPER', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'SYS', 'XS_PRINCIPAL','SET_VERIFIER',
       'XS_PRINCIPAL_INT', 'SET_VERIFIER_HELPER', 0);

commit;

Rem   Mapping for CTX external procedures.
insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','CREATE_PREFERENCE',
       'DRVLSB', 'CREATE_PREFERENCE_C', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','CREATE_PREFERENCE',
       'DRVLSB', 'CREATE_PREFERENCE_NC', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','DROP_PREFERENCE',
       'DRVLSB', 'DROP_PREFERENCE_C', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','DROP_PREFERENCE',
       'DRVLSB', 'DROP_PREFERENCE_NC', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','SET_ATTRIBUTE',
       'DRVLSB', 'SET_ATTRIBUTE_C', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','SET_ATTRIBUTE',
       'DRVLSB', 'SET_ATTRIBUTE_NC', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','UNSET_ATTRIBUTE',
       'DRVLSB', 'UNSET_ATTRIBUTE_C', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','UNSET_ATTRIBUTE',
       'DRVLSB', 'UNSET_ATTRIBUTE_NC', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','CREATE_SECTION_GROUP',
       'DRVLSB', 'CREATE_SECTION_GROUP_C', 0);

insert into system.logstdby$skip_support 
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','CREATE_SECTION_GROUP',
       'DRVLSB', 'CREATE_SECTION_GROUP_NC', 0);

insert into system.logstdby$skip_support 
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','DROP_SECTION_GROUP',
       'DRVLSB', 'DROP_SECTION_GROUP_C', 0);

insert into system.logstdby$skip_support 
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','DROP_SECTION_GROUP',
       'DRVLSB', 'DROP_SECTION_GROUP_NC', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','ADD_ZONE_SECTION',
       'DRVLSB', 'ADD_ZONE_SECTION_C', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','ADD_ZONE_SECTION',
       'DRVLSB', 'ADD_ZONE_SECTION_NC', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','ADD_FIELD_SECTION',
       'DRVLSB', 'ADD_FIELD_SECTION_C', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','ADD_FIELD_SECTION',
       'DRVLSB', 'ADD_FIELD_SECTION_NC', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','ADD_SPECIAL_SECTION',
       'DRVLSB', 'ADD_SPECIAL_SECTION_C', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','ADD_SPECIAL_SECTION',
       'DRVLSB', 'ADD_SPECIAL_SECTION_NC', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','ADD_STOP_SECTION',
       'DRVLSB', 'ADD_STOP_SECTION_C', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','ADD_STOP_SECTION',
       'DRVLSB', 'ADD_STOP_SECTION_NC', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','ADD_ATTR_SECTION',
       'DRVLSB', 'ADD_ATTR_SECTION_C', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','ADD_ATTR_SECTION',
       'DRVLSB', 'ADD_ATTR_SECTION_NC', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','ADD_XML_SECTION',
       'DRVLSB', 'ADD_XML_SECTION_C', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','ADD_XML_SECTION',
       'DRVLSB', 'ADD_XML_SECTION_NC', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','ADD_MDATA_SECTION',
       'DRVLSB', 'ADD_MDATA_SECTION_C', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','ADD_MDATA_SECTION',
       'DRVLSB', 'ADD_MDATA_SECTION_NC', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','ADD_NDATA_SECTION',
       'DRVLSB', 'ADD_NDATA_SECTION_C', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','ADD_NDATA_SECTION',
       'DRVLSB', 'ADD_NDATA_SECTION_NC', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','ADD_MVDATA_SECTION',
       'DRVLSB', 'ADD_MVDATA_SECTION_C', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','ADD_MVDATA_SECTION',
       'DRVLSB', 'ADD_MVDATA_SECTION_NC', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','ADD_SDATA_SECTION',
       'DRVLSB', 'ADD_SDATA_SECTION_C', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','ADD_SDATA_SECTION',
       'DRVLSB', 'ADD_SDATA_SECTION_NC', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','ADD_SDATA_COLUMN',
       'DRVLSB', 'ADD_SDATA_COLUMN_C', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','ADD_SDATA_COLUMN',
       'DRVLSB', 'ADD_SDATA_COLUMN_NC', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','ADD_MDATA_COLUMN',
       'DRVLSB', 'ADD_MDATA_COLUMN_C', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','ADD_MDATA_COLUMN',
       'DRVLSB', 'ADD_MDATA_COLUMN_NC', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','REMOVE_SECTION',
       'DRVLSB', 'REMOVE_SECTION_C', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','REMOVE_SECTION',
       'DRVLSB', 'REMOVE_SECTION_NC', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','CREATE_STOPLIST',
       'DRVLSB', 'CREATE_STOPLIST_C', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','CREATE_STOPLIST',
       'DRVLSB', 'CREATE_STOPLIST_NC', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','DROP_STOPLIST',
       'DRVLSB', 'DROP_STOPLIST_C', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','DROP_STOPLIST',
       'DRVLSB', 'DROP_STOPLIST_NC', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','ADD_STOPWORD',
       'DRVLSB', 'ADD_STOPWORD_C', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','ADD_STOPWORD',
       'DRVLSB', 'ADD_STOPWORD_NC', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','ADD_STOPTHEME',
       'DRVLSB', 'ADD_STOPTHEME_C', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','ADD_STOPTHEME',
       'DRVLSB', 'ADD_STOPTHEME_NC', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','ADD_STOPCLASS',
       'DRVLSB', 'ADD_STOPCLASS_C', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','ADD_STOPCLASS',
       'DRVLSB', 'ADD_STOPCLASS_NC', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','ADD_INDEX',
       'DRVLSB', 'ADD_INDEX_C', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','ADD_INDEX',
       'DRVLSB', 'ADD_INDEX_NC', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','CREATE_INDEX_SET',
       'DRVLSB', 'CREATE_INDEX_SET_C', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','CREATE_INDEX_SET',
       'DRVLSB', 'CREATE_INDEX_SET_NC', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','REMOVE_INDEX',
       'DRVLSB', 'REMOVE_INDEX_C', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','REMOVE_INDEX',
       'DRVLSB', 'REMOVE_INDEX_NC', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','ADD_SUB_LEXER',
       'DRVLSB', 'ADD_SUB_LEXER_C', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','ADD_SUB_LEXER',
       'DRVLSB', 'ADD_SUB_LEXER_NC', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','REMOVE_SUB_LEXER',
       'DRVLSB', 'REMOVE_SUB_LEXER_C', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','REMOVE_SUB_LEXER',
       'DRVLSB', 'REMOVE_SUB_LEXER_NC', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','UPDATE_SUB_LEXER',
       'DRVLSB', 'UPDATE_SUB_LEXER_C', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','UPDATE_SUB_LEXER',
       'DRVLSB', 'UPDATE_SUB_LEXER_NC', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','SET_SECTION_ATTRIBUTE',
       'DRVLSB', 'SET_SECTION_ATTRIBUTE_C', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','SET_SECTION_ATTRIBUTE',
       'DRVLSB', 'SET_SECTION_ATTRIBUTE_NC', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','UNSET_SECTION_ATTRIBUTE',
       'DRVLSB', 'UNSET_SECTION_ATTRIBUTE_C', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','UNSET_SECTION_ATTRIBUTE',
       'DRVLSB', 'UNSET_SECTION_ATTRIBUTE_NC', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','ADD_MDATA',
       'DRVLSB', 'ADD_MDATA', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','REMOVE_MDATA',
       'DRVLSB', 'REMOVE_MDATA', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','INSERT_MVDATA_VALUES',
       'DRVLSB', 'INSERT_MVDATA_VALUES', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','DELETE_MVDATA_VALUES',
       'DRVLSB', 'DELETE_MVDATA_VALUES', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','ADD_SDATA',
       'DRVLSB', 'ADD_SDATA', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','REMOVE_SDATA',
       'DRVLSB', 'REMOVE_SDATA', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','UPDATA_MVDATA_SET',
       'DRVLSB', 'UPDATA_MVDATA_SET', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','UPDATE_SDATA',
       'DRVLSB', 'UPDATE_SDATA', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','POPULATE_PENDING',
       'DRVLSB', 'POPULATE_PENDING', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','RECREATE_INDEX_ONLINE',
       'DRVLSB', 'RECREATE_INDEX_ONLINE', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','CREATE_SHADOW_INDEX',
       'DRVLSB', 'CREATE_SHADOW_INDEX', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','EXCHANGE_SHADOW_INDEX',
       'DRVLSB', 'EXCHANGE_SHADOW_INDEX', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','DROP_SHADOW_INDEX',
       'DRVLSB', 'DROP_SHADOW_INDEX', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','SYNC_INDEX',
       'DRVLSB', 'SYNC_INDEX', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','OPTIMIZE_INDEX',
       'DRVLSB', 'OPTIMIZE_INDEX', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DOC','FILTER',
       'DRVLSB', 'FILTER', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DOC','GIST',
       'DRVLSB', 'GIST', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DOC','MARKUP',
       'DRVLSB', 'MARKUP', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DOC','TOKENS',
       'DRVLSB', 'TOKENS', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DOC','THEMES',
       'DRVLSB', 'THEMES', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DOC','HIGHLIGHT',
       'DRVLSB', 'HIGHLIGHT', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DOC','MARKUP_CLOB_QUERY',
       'DRVLSB', 'MARKUP_CLOB_QUERY', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DOC','HIGHLIGHT_CLOB_QUERY',
       'DRVLSB', 'HIGHLIGHT_CLOB_QUERY', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_ANL','ADD_DICTIONARY',
       'DRVLSB', 'ADD_DICTIONARY_C', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_ANL','ADD_DICTIONARY',
       'DRVLSB', 'ADD_DICTIONARY_NC', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_ANL','DROP_DICTIONARY',
       'DRVLSB', 'DROP_DICTIONARY_C', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_ANL','DROP_DICTIONARY',
       'DRVLSB', 'DROP_DICTIONARY_NC', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','SET_SEC_GRP_ATTR',
       'DRVLSB', 'SET_SEC_GRP_ATTR_C', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','SET_SEC_GRP_ATTR',
       'DRVLSB', 'SET_SEC_GRP_ATTR_NC', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','ADD_SEC_GRP_ATTR_VAL',
       'DRVLSB', 'ADD_SEC_GRP_ATTR_VAL_C', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_DDL','ADD_SEC_GRP_ATTR_VAL',
       'DRVLSB', 'ADD_SEC_GRP_ATTR_VAL_NC', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_THES','CREATE_THESAURUS',
       'DRITHSC', 'CREATE_THESAURUS_LSB', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_THES','CREATE_PHRASE',
       'DRITHSC', 'CREATE_PHRASE_LSB', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_THES','ALTER_PHRASE',
       'DRITHS', 'PARSE_PHRASE', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_THES','CREATE_PHRASE',
       'DRITHS', 'PARSE_PHRASE', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_THES','HAS_RELATION',
       'DRITHS', 'PARSE_PHRASE', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_THES','SYN',
       'DRITHS', 'PARSE_PHRASE', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_THES','SN',
       'DRITHS', 'PARSE_PHRASE', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_THES','PT',
       'DRITHS', 'PARSE_PHRASE', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_THES','TT',
       'DRITHS', 'PARSE_PHRASE', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_THES','RT',
       'DRITHS', 'PARSE_PHRASE', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_THES','BT',
       'DRITHS', 'PARSE_PHRASE', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_THES','BTP',
       'DRITHS', 'PARSE_PHRASE', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_THES','BTI',
       'DRITHS', 'PARSE_PHRASE', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_THES','BTG',
       'DRITHS', 'PARSE_PHRASE', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_THES','NT',
       'DRITHS', 'PARSE_PHRASE', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_THES','NTP',
       'DRITHS', 'PARSE_PHRASE', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_THES','NTI',
       'DRITHS', 'PARSE_PHRASE', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_THES','NTG',
       'DRITHS', 'PARSE_PHRASE', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_THES','TRSYN',
       'DRITHS', 'PARSE_PHRASE', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name3, name4, name5, reg)
       values (-3, 'CTXSYS', 'CTX_THES','TR',
       'DRITHS', 'PARSE_PHRASE', 0);

Rem BUG 24372897: Entire package mapping for dbms_rls and dbms_rls_int

insert into system.logstdby$skip_support
       (action, name, name2, name4, reg)
       values (-3, 'SYS', 'DBMS_RLS', 'DBMS_RLS_INT', 0);
commit;

Rem  Use action = -4 to indicate the package listed in this row can only
Rem  have package level skip rules. Procedure level skip rules are disallowed
Rem  for this package.
Rem  For each external package where only package level skip rule is allowed,
Rem  a row of the following shape needs to be inserted:
Rem     (action, name, name2, name4).
Rem  Where
Rem    action : must be -4 to indicate procedure level skip rule is disallowed
Rem    name   : schema name of the external package.
Rem    name2  : package name of the external procedure.
Rem    name4  : package name of the corresponding internal pragma-d package
Rem             (null if internal package does not exist)
Rem
Rem  Currently, procedure level skip rules are disallowed for the following
Rem  packages:
Rem      XDB.DBMS_XDB           (-> DBMS_XLSB)
Rem      XDB.DBMS_XDB_CONFIG    (-> DBMS_XLSB)
Rem      XDB.DBMS_XDB_REPOS     (-> DBMS_XLSB)
Rem      XDB.DBMS_XDBRESOURCE   (-> DBMS_XLSB)

insert into system.logstdby$skip_support
       (action, name, name2, name4, reg)
       values (-4, 'XDB', 'DBMS_XDB', 'DBMS_XLSB', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name4, reg)
       values (-4, 'XDB', 'DBMS_XDB_CONFIG','DBMS_XLSB', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name4, reg)
       values (-4, 'XDB', 'DBMS_XDB_REPOS','DBMS_XLSB', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name4, reg)
       values (-4, 'XDB', 'DBMS_XDBRESOURCE','DBMS_XLSB', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name4, reg)
       values (-4, 'SYS', 'DBMS_AQ_IMP_INTERNAL',
       'DBMS_AQ_SYS_IMP_INTERNAL', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name4, reg)
       values (-4, 'SYS', 'DBMS_RULE_ADM',
       'DBMS_RULEADM_INTERNAL', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name4, reg)
       values (-4, 'SYS', 'DBMS_AQADM',
       '', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name4, reg)
       values (-4, 'SYS', 'DBMS_AQADM',
       'DBMS_AQADM_SYS', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name4, reg)
       values (-4, 'SYS', 'DBMS_AQJMS',
       '', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name4, reg)
       values (-4, 'SYS', 'DBMS_PRVTAQIS',
       '', 0);

Rem  package level skip for XS
insert into system.logstdby$skip_support
       (action, name, name2, name4, reg)
       values (-4, 'SYS', 'XS_PRINCIPAL','XS_PRINCIPAL_INT', 0);

Rem  package level skip for OLS
insert into system.logstdby$skip_support
       (action, name, name2, name4, reg)
       values (-4, 'LBACSYS', 'LBAC_EVENTS',
       '', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name4, reg)
       values (-4, 'LBACSYS', 'SA_AUDIT_ADMIN',
       '', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name4, reg)
       values (-4, 'LBACSYS', 'SA_COMPONENTS','', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name4, reg)
       values (-4, 'LBACSYS', 'SA_LABEL_ADMIN','', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name4, reg)
       values (-4, 'LBACSYS', 'SA_POLICY_ADMIN',
       'LBAC_POLICY_ADMIN', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name4, reg)
       values (-4, 'LBACSYS', 'SA_SESSION',
       'LBAC_LGSTNDBY_UTIL', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name4, reg)
       values (-4, 'LBACSYS', 'SA_SYSDBA',
       'LBAC_LGSTNDBY_UTIL', 0);

insert into system.logstdby$skip_support
       (action, name, name2, name4, reg)
       values (-4, 'LBACSYS', 'SA_USER_ADMIN',
       'LBAC_LGSTNDBY_UTIL', 0);

commit;

Rem   Use action = -5 to indicate internal types that are not supported in 
Rem   compat 12.1.  These could be built-in opaque, ADT, or varray types 
Rem   (dty code = 58, 121, 123) which cannot be supported for any reason. 
Rem   action : -5
Rem   name   : owner name of the unsupported type
Rem   name2  : type name of the unsupported type
Rem   
Rem   NOTE:  THESE SKIP RULES ARE ONLY CHECKED FOR THE 12.1 SUPPORTED VIEWS.
insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-5, 'MDSYS', 'SDO_GEORASTER', 0);
insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-5, 'MDSYS', 'SDO_TOPO_GEOMETRY', 0);


Rem   Use action = -11 to indicate internal types that are not supported in 
Rem   compat 12%.  These could be built-in opaque, ADT, or varray types 
Rem   (dty code = 58, 121, 123) which cannot be supported for any reason.
Rem   These types will be UNSUPPORTED for Rolling Upgrade, Logical Standby,
Rem   and support_mode NONE for OGG.
Rem   action : -11
Rem   name   : owner name of the unsupported type
Rem   name2  : type name of the unsupported type
Rem   
Rem   NOTE:  THESE SKIP RULES ARE CHECKED FOR THE 12.1, 12.2, AND
Rem          12.2.0.2 views
insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-11, 'MDSYS', 'SDO_RDF_TRIPLE_S', 0);

Rem   Use action = -6, -7, -8, -9 to indicate PLSQL package support
Rem   level, whether they are internal packages or not.
Rem     This is represented as: 
Rem         (action, name, name2)
Rem     Where
Rem       action: -6 => external package, only supported for DBMS_ROLLING,
Rem               -7 => internal package, only supported for DBMS_ROLLING,
Rem               -8 => external package, always supported.
Rem               -9 => internal package, always supported.
Rem       name : schema name of the package.
Rem       name2: package name.
Rem
Rem   The list of packages are:
Rem   owner    package                 Internal    support_level
Rem   ---------------------------------------------------------
Rem   SYS      DBMS_RLS                            always
Rem   SYS      DBMS_RLS_INT            internal    always
Rem   SYS      DBMS_FGA                            always
Rem   XDB      DBMS_XMLSCHEMA                      always
Rem   XDB      DBMS_XMLSCHEMA_LSB                  always
Rem   XDB      DBMS_XMLINDEX                       always
Rem   XDB      DBMS_XDBZ0              internal    dbms_rolling
Rem   XDB      DBMS_RESCONFIG                      dbms_rolling
Rem   XDB      DBMS_XDBZ                           dbms_rolling
Rem   XDB      DBMS_XDB_VERSION                    dbms_rolling
Rem   XDB      DBMS_XDB                            dbms_rolling
Rem   XDB      DBMS_XDB_ADMIN                      dbms_rolling (unsupported)
Rem   XDB      DBMS_XLSB               internal    dbms_rolling
Rem   XDB      DBMS_XDB_CONFIG                     dbms_rolling
Rem   XDB      DBMS_XDB_REPOS                      dbms_rolling (C-API)
Rem   XDB      DBMS_XDBRESOURCE                    dbms_rolling (C-API)
Rem   SYS      DBMS_XDS                internal    dbms_rolling
Rem   SYS      DBMS_DDL                            always
Rem   SYS      DBMS_SCHEDULER                      dbms_rolling
Rem   SYS      DBMS_ISCHED             internal    dbms_rolling
Rem   SYS      DBMS_AQADM_SYS          internal    dbms_rolling
Rem   SYS      DBMS_AQADM                          dbms_rolling
Rem   SYS      DBMS_PRVTAQIS           internal    dbms_rolling
Rem   SYS      DBMS_AQ_SYS_IMP_INTERNALinternal    dbms_rolling
Rem   SYS      DBMS_AQ                             dbms_rolling
Rem   SYS      DBMS_AQELM                          dbms_rolling (unsupported)
Rem   SYS      DBMS_AQJMS                          dbms_rolling
Rem   SYS      DBMS_RULE_ADM                       dbms_rolling
Rem   SYS      DBMS_RULEADM_INTERNAL               dbms_rolling
Rem   SYS      DBMS_REDEFINITION                   always
Rem   SYS      DBMS_LOGSTDBY_INTERNAL  internal    always
Rem   SYS      DBMS_DBFS_CONTENT_ADMIN             dbms_rolling
Rem   SYS      DBMS_DBFS_SFS                       dbms_rolling
Rem   SYS      DBMS_DBFS_SFS_ADMIN                 dbms_rolling
Rem   SYS      DBMS_SQL_TRANSLATOR                 always
Rem   SYS      XS_PRINCIPAL                        dbms_rolling
Rem   SYS      XS_PRINCIPAL_INT        internal    dbms_rolling
Rem   SYS      XS_ACL                              dbms_rolling
Rem   SYS      XS_ROLESET                          dbms_rolling
Rem   SYS      XS_SECURITY_CLASS                   dbms_rolling
Rem   SYS      XS_DATA_SECURITY                    dbms_rolling
Rem   SYS      XS_DATA_SECURITY_UTIL               dbms_rolling
Rem   SYS      XS_NAMESPACE                        dbms_rolling
Rem   SYS      XS_ADMIN_UTIL                       dbms_rolling
Rem   CTXSYS   CTX_DDL                             dbms_rolling
Rem   CTXSYS   CTX_TREE                            dbms_rolling
Rem   CTXSYS   CTX_ENTITY                          dbms_rolling
Rem   CTXSYS   DRITHSL                 internal    dbms_rolling
Rem   CTXSYS   DRITHSC                 internal    dbms_rolling
Rem   CTXSYS   DRITHS                  internal    dbms_rolling
Rem   CTXSYS   DRIENTL                 internal    dbms_rolling
Rem   CTXSYS   CTX_ADM                             dbms_rolling
Rem   CTXSYS   CTX_QUERY                           dbms_rolling
Rem   CTXSYS   CTX_CLS                             dbms_rolling
Rem   CTXSYS   CTX_THES                            dbms_rolling
Rem   CTXSYS   CTX_OUTPUT                          dbms_rolling
Rem   CTXSYS   CTX_DOC                             dbms_rolling
Rem   CTXSYS   DRVXMD                  internal    dbms_rolling
Rem   CTXSYS   DRVLSB                  internal    dbms_rolling
Rem   SYS      DBMS_INTERNAL_LOGSTDBY  internal    always
Rem   SYS      DBMS_INTERNAL_ROLLING   internal    always
Rem   SYS      DBMS_REDACT                         always
Rem   MDSYS    SDO_META                            always
Rem   MDSYS    SDO_META_USER                       dbms_rolling
Rem   LBACSYS  LBAC_EVENTS             internal    dbms_rolling
Rem   LBACSYS  LBAC_LGSTNDBY_UTIL      internal    dbms_rolling
Rem   LBACSYS  LBAC_POLICY_ADMIN       internal    dbms_rolling
Rem   LBACSYS  SA_AUDIT_ADMIN                      dbms_rolling
Rem   LBACSYS  SA_COMPONENTS                       dbms_rolling
Rem   LBACSYS  SA_LABEL_ADMIN                      dbms_rolling
Rem   LBACSYS  SA_SYSDBA                           dbms_rolling
Rem   LBACSYS  SA_USER_ADMIN                       dbms_rolling
Rem   DVSYS    DBMS_MACOUT                         dbms_rolling
Rem   DVSYS    DBMS_MACUTL                         dbms_rolling
Rem   DVSYS    DBMS_MACADM                         dbms_rolling
Rem   DVSYS    DBMS_MACAUD                         dbms_rolling
Rem   DVSYS    EVENT                               dbms_rolling
Rem   DVSYS    DBMS_MACSEC_RULES                   dbms_rolling
Rem   DVSYS    DBMS_MACSEC                         dbms_rolling
Rem   DVSYS    DBMS_MACOLS                         dbms_rolling
Rem   DVSYS    DBMS_MACSEC_ROLES                   dbms_rolling
Rem   DVSYS    DBMS_MACOLS_SESSION                 dbms_rolling
Rem
Rem From AQ group: In 12c, DBMS_AQELM is unsupported because no tests are
Rem added, otherwise we have plans of supporting them in patch set 1.

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-8, 'SYS', 'DBMS_RLS', 0);

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-9, 'SYS', 'DBMS_RLS_INT', 0);

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-8, 'SYS', 'DBMS_FGA', 0);

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-8, 'XDB', 'DBMS_XMLSCHEMA', 0);

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-9, 'XDB', 'DBMS_XMLSCHEMA_LSB', 0);

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-8, 'XDB', 'DBMS_XMLINDEX', 0);

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-7, 'XDB', 'DBMS_XDBZ0', 0);

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-6, 'XDB', 'DBMS_RESCONFIG', 0);

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-6, 'XDB', 'DBMS_XDBZ', 0);

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-6, 'XDB', 'DBMS_XDB_VERSION', 0);

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-6, 'XDB', 'DBMS_XDB', 0);

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-7, 'XDB', 'DBMS_XLSB', 0);

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-6, 'XDB', 'DBMS_XDB_CONFIG', 0);

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-6, 'XDB', 'DBMS_XDB_REPOS', 0);

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-6, 'XDB', 'DBMS_XDBRESOURCE', 0);

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-7, 'SYS', 'DBMS_XDS', 0);

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-6, 'SYS', 'DBMS_SCHEDULER', 0);

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-7, 'SYS', 'DBMS_ISCHED', 0);

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-7, 'SYS', 'DBMS_AQADM_SYS', 0);

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-7, 'SYS', 'DBMS_AQ_SYS_IMP_INTERNAL', 0);  

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-6, 'SYS', 'DBMS_AQADM', 0);

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-6, 'SYS', 'DBMS_AQELM', 0);

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-6, 'SYS', 'DBMS_RULE_ADM', 0);

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-7, 'SYS', 'DBMS_RULEADM_INTERNAL', 0);

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-7, 'SYS', 'DBMS_PRVTAQIS', 0);

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-6, 'SYS', 'DBMS_AQ', 0);

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-6, 'SYS', 'DBMS_AQJMS', 0);

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-6, 'SYS', 'DBMS_DBFS_CONTENT_ADMIN', 0);

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-6, 'SYS', 'DBMS_DBFS_SFS', 0);

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-6, 'SYS', 'DBMS_DBFS_SFS_ADMIN', 0);

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-6, 'SYS', 'XS_PRINCIPAL', 0);

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-7, 'SYS', 'XS_PRINCIPAL_INT', 0);

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-6, 'SYS', 'XS_ACL', 0);

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-6, 'SYS', 'XS_ROLESET', 0);

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-6, 'SYS', 'XS_SECURITY_CLASS', 0);

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-6, 'SYS', 'XS_DATA_SECURITY', 0);

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-6, 'SYS', 'XS_DATA_SECURITY_UTIL', 0);

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-6, 'SYS', 'XS_NAMESPACE', 0);

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-6, 'SYS', 'XS_ADMIN_UTIL', 0);

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-6, 'CTXSYS', 'CTX_ANL', 0);

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-6, 'CTXSYS', 'CTX_DDL', 0);

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-6, 'CTXSYS', 'CTX_TREE', 0);

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-6, 'CTXSYS', 'CTX_ENTITY', 0);

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-7, 'CTXSYS', 'DRITHSL', 0);

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-7, 'CTXSYS', 'DRITHSC', 0);

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-7, 'CTXSYS', 'DRITHS', 0);

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-7, 'CTXSYS', 'DRIENTL', 0);

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-6, 'CTXSYS', 'CTX_ADM', 0);

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-6, 'CTXSYS', 'CTX_QUERY', 0);

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-6, 'CTXSYS', 'CTX_CLS', 0);

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-6, 'CTXSYS', 'CTX_THES', 0);

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-6, 'CTXSYS', 'CTX_OUTPUT', 0);

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-6, 'CTXSYS', 'CTX_DOC', 0);

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-7, 'CTXSYS', 'DRVXMD', 0);

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-7, 'CTXSYS', 'DRVLSB', 0);

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-8, 'SYS', 'DBMS_DDL', 0);

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-8, 'SYS', 'DBMS_REDEFINITION', 0);

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-8, 'SYS', 'DBMS_SQL_TRANSLATOR', 0);

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-9, 'SYS', 'LOGSTDBY_INTERNAL', 0);

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-9, 'SYS', 'DBMS_INTERNAL_LOGSTDBY', 0);

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-9, 'SYS', 'DBMS_INTERNAL_ROLLING', 0);

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-8, 'SYS', 'DBMS_REDACT', 0);

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-8, 'MDSYS', 'SDO_META', 0);

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-6, 'MDSYS', 'SDO_META_USER', 0);

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-7, 'LBACSYS', 'LBAC_EVENTS', 0);

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-7, 'LBACSYS', 'LBAC_LGSTNDBY_UTIL', 0);

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-7, 'LBACSYS', 'LBAC_POLICY_ADMIN', 0);

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-6, 'LBACSYS', 'SA_AUDIT_ADMIN', 0);

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-6, 'LBACSYS', 'SA_COMPONENTS', 0);

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-6, 'LBACSYS', 'SA_LABEL_ADMIN', 0);

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-6, 'LBACSYS', 'SA_SYSDBA', 0);

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-6, 'LBACSYS', 'SA_USER_ADMIN', 0);

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-10, 'DVSYS', 'DBMS_MACOUT', 0);

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-10, 'DVSYS', 'DBMS_MACUTL', 0);

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-6, 'DVSYS', 'DBMS_MACADM', 0);

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-6, 'DVSYS', 'DBMS_MACAUD', 0);

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-10, 'DVSYS', 'EVENT', 0);

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-10, 'DVSYS', 'DBMS_MACSEC_RULES', 0);

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-10, 'DVSYS', 'DBMS_MACSEC', 0);

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-6, 'DVSYS', 'DBMS_MACOLS', 0);

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-10, 'DVSYS', 'DBMS_MACSEC_ROLES', 0);

insert into system.logstdby$skip_support (action, name, name2, reg)
       values (-10, 'DVSYS', 'DBMS_MACOLS_SESSION', 0);

create index system.logstdby$skip_ind
      on system.logstdby$skip_support (name, action) tablespace SYSAUX;

Rem
Rem   Additional schemas created during installation of oracle supplied
Rem   features.  These are all presumed to be internal/unsupported.
Rem

insert into system.logstdby$skip_support (action, name, reg)
  select distinct 0, d.schema, 1 from dba_server_registry d
  where not exists (select name from system.logstdby$skip_support s
                    where d.schema = s.name and s.action in (-1,0));
commit;


Rem   Maintains history of log streams processed.
create table system.logstdby$history (
  stream_sequence#  number,                             /* Stream identifier */
  lmnr_sid          number,                           /* LogMiner session id */
  dbid              number,                                          /* DBID */
  first_change#     number,                  /* Starting scn for this stream */
  last_change#      number,                      /* Last scn for this stream */
  source            number,                            /* Stream info source */
  status            number,                             /* Processing status */
  first_time        date,             /* Time corresponding to first_change# */
  last_time         date,              /* Time corresponding to last_change# */
  dgname            varchar2(255),                  /* Dataguard name string */
  spare1            number,                    /* standby became primary scn */
  spare2            number,                                 /* processed scn */
  spare3            varchar2(2000)                       /* Future expansion */
) tablespace SYSAUX
/

        
Rem
Rem EDS support
Rem
create table system.logstdby$eds_tables (
  owner                 varchar2(128),                         /* table owner */
  table_name            varchar2(128),                     /* base table name */
  shadow_table_name     varchar2(128),                   /* shadow table name */
  base_trigger_name     varchar2(128),             /* base table trigger name */
  shadow_trigger_name   varchar2(128),           /* shadow table trigger name */
  dblink                varchar2(255),                        /* dblink name */
  flags                 number,                                     /* flags */
  state                 varchar2(255),          /* BEGUN, EVOLVING, COMPLETE */
  objv                  number,        /* local object version of base table */
  obj#                  number,               /* local object# of base table */
  sobj#                 number,             /* local object# of shadow table */
  ctime                 timestamp,     /* timestamp when table support added */
  spare1                number,                        /* spare number field */
  spare2                varchar2(255),                /* spare varchar field */
  spare3                number,                        /* spare number field */
  mview_name            varchar2(128),              /* materialized view name */
  mview_log_name        varchar2(128),          /* materialized view log name */
  mview_trigger_name    varchar2(128),  /* materialized view log trigger name */
  constraint logstdby$eds_tables_pkey primary key (owner, table_name)
) tablespace SYSAUX
/

Rem
Rem  Create views over the metadata tables.
Rem

---------------------------------------------------------------------
-- LOGSTDBY_SUPPORT View for internal use only
-- This view makes up the basis for a number of queries made by logical
-- standby to make decisions about what tables to support.  This view along
-- with the dba_logstdby_unsupported view must be modified when ever the
-- collection of data types or table support changes.  If you make a change
-- here, you'll almost certainly need a change there.  All the tables and 
-- sequences are displayed here, but only those with generated_sby == 1
-- will be maintained by logical standby.
--
-- this view is a union of two views:
--  logstdby_support_stab - supported tables
--  logstdby_support_seq  - supported sequences

---------------------------------------------------------------------
-- LOGSTDBY_SUPPORT_TAB_10_1
-- This view encapsulates 10.1 compatibility support
--   gensby:       1 supported, 
--                 -1 internal so not supported   
--                 0 user data not supported because of features     
--   current_sby:  1 if lsby bit set in tab$ else 0
--
create or replace view logstdby_support_tab_10_1
as
  select u.name owner, o.name name, o.type#, o.obj#,
         decode(bitand(t.flags, 1073741824), 1073741824, 1, 0) current_sby,
 (case 
    /* The following are tables that are system maintained */
  when ( exists (select 1 from system.logstdby$skip_support s
                 where s.name = u.name and action = 0))
    or bitand(o.flags,
                2                                       /* temporary object */
              + 16                                      /* secondary object */
              + 32                                  /* in-memory temp table */
              + 128                           /* dropped table (RecycleBin) */
             ) != 0
    or bitand(t.flags,
                262144     /* 0x00040000        Summary Container Table, MV */ 
              + 134217728  /* 0x08000000          in-memory temporary table */
              + 536870912  /* 0x20000000  Mapping Tab for Phys rowid of IOT */
             ) != 0
    or bitand(t.property,
                512        /* 0x00000200               iot OVeRflow segment */
              + 8192       /* 0x00002000                       nested table */
              + 4194304    /* 0x00400000             global temporary table */
              + 8388608    /* 0x00800000   session-specific temporary table */
              + 33554432   /* 0x02000000        Read Only Materialized View */
              + 67108864   /* 0x04000000            Materialized View table */
              + 134217728  /* 0x08000000                    Is a Sub object */
              + 2147483648 /* 0x80000000                     eXternal TaBle */
             ) != 0
    or bitand(t.trigflag,
                536870912  /* 0x20000000                  DDLs autofiltered */
               ) != 0
    or exists (select 1 from sys.mlog$ ml                    /* MVLOG table */
               where ml.mowner = u.name and ml.log = o.name) 
    or exists (select 1 from sys.secobj$ so           /* ODCI storage table */
               where o.obj# = so.secobj#) 
  then -1
    /* The following tables are user visible tables that we choose to 
     * skip because of some unsupported attribute of the table or column */
  when bitand(t.property, 262208) = 262208   /* 0x40+0x40000 IOT + user LOB */
    or bitand(t.property, 2112) = 2112     /* 0x40+0x800 IOT + internal LOB */
    or                                           /* IOT with "Row Movement" */
      (bitand(t.property, 64) = 64 and bitand(t.flags, 131072) = 131072)
    or bitand(t.trigflag,
                65536      /* 0X10000           Table has encrypted columns */
             ) != 0
    or                                                       /* Compression */
       (bitand(nvl(s.spare1,0), 2048) = 2048 and bitand(t.property, 32) != 32) 
    or o.oid$ is not null
    or bitand(t.property,
                  1        /* 0x00000001                        typed table */
                + 2        /* 0x00000002                    has ADT columns */
                + 4        /* 0x00000004           has nested-TABLE columns */
                + 8        /* 0x00000008                    has REF columns */
               + 16        /* 0x00000010                  has array columns */
              + 128        /* 0x00000080              IOT with row overflow */
              + 256        /* 0x00000100            IOT with row clustering */
            + 32768        /* 0x00008000                   has FILE columns */
           + 131072        /* 0x00020000 table is used as an AQ queue table */
             ) != 0
    or (bitand(t.property, 32) = 32)                         /* Partitioned */
      and exists (select 1 from partobj$ po
                  where po.obj#=o.obj#
                  and  (po.parttype in (3,             /* System partitioned */
                                        5)))        /* Reference partitioned */
    or exists (select 1 from sys.col$ c 
               where t.obj# = c.obj#
               and bitand(c.property, 32) != 32                /* Not hidden */
               and ((c.type# not in ( 
                                  1,                             /* VARCHAR2 */
                                  2,                               /* NUMBER */
                                  8,                                 /* LONG */
                                  12,                                /* DATE */
                                  24,                            /* LONG RAW */
                                  96,                                /* CHAR */
                                  100,                       /* BINARY FLOAT */
                                  101,                      /* BINARY DOUBLE */
                                  112,                     /* CLOB and NCLOB */
                                  113,                               /* BLOB */
                                  180,                     /* TIMESTAMP (..) */
                                  181,       /* TIMESTAMP(..) WITH TIME ZONE */
                                  182,         /* INTERVAL YEAR(..) TO MONTH */
                                  183,     /* INTERVAL DAY(..) TO SECOND(..) */
                                  231) /* TIMESTAMP(..) WITH LOCAL TIME ZONE */
               and (c.type# != 23                         /* RAW not RAW OID */
               or  (c.type# = 23 and bitand(c.property, 2) = 2))) 
             -----------------------------------------
             or (c.type# in (8,24,112,113)
             and 0 = (select count(*) from sys.col$ c2
               where t.obj# = c2.obj#
               and bitand(c2.property, 32) != 32               /* Not hidden */
               and (c2.type# in ( 1,                             /* VARCHAR2 */
                                  2,                               /* NUMBER */
                                  12,                                /* DATE */
                                  23,                                 /* RAW */
                                  96,                                /* CHAR */
                                  100,                       /* BINARY FLOAT */
                                  101,                      /* BINARY DOUBLE */
                                  180,                     /* TIMESTAMP (..) */
                                  181,       /* TIMESTAMP(..) WITH TIME ZONE */
                                  182,         /* INTERVAL YEAR(..) TO MONTH */
                                  183,     /* INTERVAL DAY(..) TO SECOND(..) */
                                  231) /* TIMESTAMP(..) WITH LOCAL TIME ZONE */
                          )))))
             -----------------------------------------
   then 0 else 1 end) gensby
   from sys.obj$ o, sys.user$ u, sys.tab$ t, sys.seg$ s
   where o.owner# = u.user#
   and o.obj# = t.obj#
   and t.file# = s.file# (+)
   and t.block# = s.block# (+)
   and t.ts# = s.ts# (+)
   and t.obj# = o.obj#
/

---------------------------------------------------------------------
-- LOGSTDBY_SUPPORT_TAB_10_2
-- This view encapsulates 10.2 compatibility support
--   gensby:       1 supported, 
--                 -1 internal so not supported   
--                 0 user data not supported because of features     
--   current_sby:  1 if lsby bit set in tab$ else 0
--
create or replace view logstdby_support_tab_10_2
as
  select u.name owner, o.name name, o.type#, o.obj#,
         decode(bitand(t.flags, 1073741824), 1073741824, 1, 0) current_sby,
 (case 
    /* The following are tables that are system maintained */
  when ( exists (select 1 from system.logstdby$skip_support s
                 where s.name = u.name and action = 0))
    or bitand(o.flags,
                2                                       /* temporary object */
              + 16                                      /* secondary object */
              + 32                                  /* in-memory temp table */
              + 128                           /* dropped table (RecycleBin) */
             ) != 0
    or bitand(t.flags,
                262144     /* 0x00040000        Summary Container Table, MV */ 
              + 134217728  /* 0x08000000          in-memory temporary table */
              + 536870912  /* 0x20000000  Mapping Tab for Phys rowid of IOT */
             ) != 0
    or bitand(t.property,
                512        /* 0x00000200               iot OVeRflow segment */
              + 8192       /* 0x00002000                       nested table */
              + 4194304    /* 0x00400000             global temporary table */
              + 8388608    /* 0x00800000   session-specific temporary table */
              + 33554432   /* 0x02000000        Read Only Materialized View */
              + 67108864   /* 0x04000000            Materialized View table */
              + 134217728  /* 0x08000000                    Is a Sub object */
              + 2147483648 /* 0x80000000                     eXternal TaBle */
             ) != 0
    or bitand(t.trigflag,
                536870912  /* 0x20000000                  DDLs autofiltered */
               ) != 0
    or exists (select 1 from sys.mlog$ ml                    /* MVLOG table */
               where ml.mowner = u.name and ml.log = o.name) 
    or exists (select 1 from sys.secobj$ so           /* ODCI storage table */
               where o.obj# = so.secobj#) 
  then -1
    /* The following tables are user visible tables that we choose to 
     * skip because of some unsupported attribute of the table or column */
  when bitand(t.trigflag,
                65536      /* 0X10000           Table has encrypted columns */
             ) != 0
    or                                                       /* Compression */
       (bitand(nvl(s.spare1,0), 2048) = 2048 and bitand(t.property, 32) != 32) 
    or o.oid$ is not null
    or bitand(t.property,
             /* The following column properties are not checked in the
              * common section because they are reflected in the column
              * definitions and we want to see just those columns */
                  1        /* 0x00000001                        typed table */
                + 2        /* 0x00000002                    has ADT columns */
                + 4        /* 0x00000004           has nested-TABLE columns */
                + 8        /* 0x00000008                    has REF columns */
               + 16        /* 0x00000010                  has array columns */
            + 32768        /* 0x00008000                   has FILE columns */
           + 131072        /* 0x00020000 table is used as an AQ queue table */
             ) != 0
    or (bitand(t.property, 32) = 32)                         /* Partitioned */
      and exists (select 1 from partobj$ po
                  where po.obj#=o.obj#
                  and  (po.parttype in (3,             /* System partitioned */
                                        5)))        /* Reference partitioned */
    or exists (select 1 from sys.col$ c 
               where t.obj# = c.obj#
               and bitand(c.property, 32) != 32                /* Not hidden */
               and ((c.type# not in ( 
                                  1,                             /* VARCHAR2 */
                                  2,                               /* NUMBER */
                                  8,                                 /* LONG */
                                  12,                                /* DATE */
                                  24,                            /* LONG RAW */
                                  96,                                /* CHAR */
                                  100,                       /* BINARY FLOAT */
                                  101,                      /* BINARY DOUBLE */
                                  112,                     /* CLOB and NCLOB */
                                  113,                               /* BLOB */
                                  180,                     /* TIMESTAMP (..) */
                                  181,       /* TIMESTAMP(..) WITH TIME ZONE */
                                  182,         /* INTERVAL YEAR(..) TO MONTH */
                                  183,     /* INTERVAL DAY(..) TO SECOND(..) */
                                  231) /* TIMESTAMP(..) WITH LOCAL TIME ZONE */
                  and (c.type# != 23                      /* RAW not RAW OID */
                  or (c.type# = 23 and bitand(c.property, 2) = 2))) 
             -----------------------------------------
             or (c.type# in (8,24,112,113)
             and 0 = (select count(*) from sys.col$ c2
               where t.obj# = c2.obj#
               and bitand(c2.property, 32) != 32               /* Not hidden */
               and (c2.type# in ( 1,                             /* VARCHAR2 */
                                  2,                               /* NUMBER */
                                  12,                                /* DATE */
                                  23,                                 /* RAW */
                                  96,                                /* CHAR */
                                  100,                       /* BINARY FLOAT */
                                  101,                      /* BINARY DOUBLE */
                                  180,                     /* TIMESTAMP (..) */
                                  181,       /* TIMESTAMP(..) WITH TIME ZONE */
                                  182,         /* INTERVAL YEAR(..) TO MONTH */
                                  183,     /* INTERVAL DAY(..) TO SECOND(..) */
                                  231) /* TIMESTAMP(..) WITH LOCAL TIME ZONE */
                          )))))
             -----------------------------------------
  then 0 else 1 end) gensby
  from sys.obj$ o, sys.user$ u, sys.tab$ t, sys.seg$ s
  where o.owner# = u.user#
  and o.obj# = t.obj#
  and t.file# = s.file# (+)
  and t.block# = s.block# (+)
  and t.ts# = s.ts# (+)
  and t.obj# = o.obj#
/

-----------------------------------------------------------------------
-- LOGSTDBY_SUPPORT_11LOB
-- This is a help view for logstdby_support_11_1. Eventually, we want to
-- move all the logic here to logstdby_support_11_1 inline.
-- NOTE:
-- THis view indicates whether a lob is a securefile or has at least one
-- securefile partition. The dedupsecurefile indicates that the securefile
-- has the deduplicte option enabled.
------------------------------------------------------------------------
create or replace view logstdby_support_11lob
as
 select lb.obj#, lb.lobj#, lb.col#, 
    (case 
     when (bitand(lb.property, 4) = 4) /* the lob colum is partitioned */
     then 
       case
       when (exists       /* composite partitioned lob */
                   (select 1 
                    from sys.lobfrag$ lf1, sys.lobcomppart$ cm  
                    where lb.lobj# = cm.lobj#
                    and cm.partobj# = lf1.parentobj#
                    and bitand(lf1.fragpro, 2048) = 2048)
            or
             exists       /* regular partitioned lob */
                  (select 1
                   from sys.lobfrag$ lf2
                   where lb.lobj# = lf2.parentobj#
                   and bitand(lf2.fragpro, 2048) = 2048))
       then 1 else 0 end
     else                               /* non-partitioned lob */
       case
       when bitand(lb.property, 2048) = 2048 /* this is a securefile column */
       then 1 else 0 end   
     end) securefile,
    (case 
     when (bitand(lb.property, 4) = 4) /* the lob colum is partitioned */
     then 
       case
       when (exists       /* composite partitioned lob */
                   (select 1
                    from sys.lobfrag$ lf1, sys.lobcomppart$ cm  
                    where lb.lobj# = cm.lobj#
                    and cm.partobj# = lf1.parentobj#
                    and bitand(lf1.fragflags, 
                                 65536    /* 0x10000 = Sharing: LOB level */
                               + 131072   /* 0x20000 = Sharing: Object level */
                               + 262144   /* 0x40000 = Sharing: Validate */
                               ) != 0)    /* this is a dedup securefile */
            or
             exists       /* regular partitioned lob */
                  (select 1
                   from sys.lobfrag$ lf2
                   where lb.lobj# = lf2.parentobj#
                   and bitand(lf2.fragflags, 
                                 65536    /* 0x10000 = Sharing: LOB level */
                              + 131072    /* 0x20000 = Sharing: Object level */
                              + 262144    /* 0x40000 = Sharing: Validate */
                              ) != 0))     /* this is a dedup securefile */
       then 1 else 0 end
     else                               /* non-partitioned lob */
       case
       when bitand(lb.property, 2048) = 2048
            and bitand(lb.flags, 
                         65536    /* 0x10000 = Sharing: LOB level */
                       + 131072   /* 0x20000 = Sharing: Object level */
                       + 262144   /* 0x40000 = Sharing: Validate */
                       ) != 0     /* this is a dedup securefile */
       then 1 else 0 end   
     end) dedupsecurefile       
from sys.lob$ lb
/


---------------------------------------------------------------------
-- LOGSTDBY_SUPPORT_TAB_11_2
-- This view encapsulates 11.2 compatibility support
--   gensby:       1 supported, 
--                 -1 internal so not supported   
--                 0 user data not supported because of features     
--   current_sby:  1 if lsby bit set in tab$ else 0
--
create or replace view logstdby_support_tab_11_2
as
  select u.name owner, o.name name, o.type#, o.obj#,
         decode(bitand(t.flags, 1073741824), 1073741824, 1, 0) current_sby,
 (case 
    /* The following are tables that are system maintained */
  when ( exists (select 1 from system.logstdby$skip_support s
                 where s.name = u.name and action = 0))
    or bitand(o.flags,
                2                                       /* temporary object */
              + 16                                      /* secondary object */
              + 32                                  /* in-memory temp table */
              + 128                           /* dropped table (RecycleBin) */
             ) != 0
    or bitand(t.flags,
                262144     /* 0x00040000        Summary Container Table, MV */ 
              + 134217728  /* 0x08000000          in-memory temporary table */
              + 536870912  /* 0x20000000  Mapping Tab for Phys rowid of IOT */
             ) != 0
    or bitand(t.property,
                512        /* 0x00000200               iot OVeRflow segment */
              + 8192       /* 0x00002000                       nested table */
              + 4194304    /* 0x00400000             global temporary table */
              + 8388608    /* 0x00800000   session-specific temporary table */
              + 33554432   /* 0x02000000        Read Only Materialized View */
              + 67108864   /* 0x04000000            Materialized View table */
              + 134217728  /* 0x08000000                    Is a Sub object */
              + 2147483648 /* 0x80000000                     eXternal TaBle */
              + 4294967296 /* 0x100000000                              Cube */
              + 8589934592 /* 0x200000000                      FBA Internal */
             ) != 0
    or bitand(t.trigflag,
                536870912  /* 0x20000000                  DDLs autofiltered */
               ) != 0
    or exists (select 1 from sys.mlog$ ml                    /* MVLOG table */
               where ml.mowner = u.name and ml.log = o.name) 
    or exists (select 1 from sys.secobj$ so           /* ODCI storage table */
               where o.obj# = so.secobj#) 
  then -1
    /* The following tables are user visible tables that we choose to 
     * skip because of some unsupported attribute of the table or column */
  when (bitand(t.property, 1 ) = 1    /* 0x00000001             typed table */
        AND not exists                /* Only XML Typed Tables Are Supported */
          (select 1
             from  sys.col$ cc, sys.opqtype$ opq
             where cc.name = 'SYS_NC_ROWINFO$' and cc.type# = 58 and
                   opq.obj# = cc.obj# and opq.intcol# = cc.intcol# and
                   opq.type = 1 and cc.obj# = t.obj# 
                   and bitand(opq.flags,4) = 4             /* stored as lob */
                   and bitand(opq.flags,64) = 0     /* not stored as binary */
                   and bitand(opq.flags,512) = 0))     /* not hierarch enab */
    or (bitand(t.property, 32) = 32)                         /* Partitioned */
      and exists (select 1 from partobj$ po
                  where po.obj#=o.obj#
                  and  (po.parttype in (3,             /* System partitioned */
                                        5)))        /* Reference partitioned */
    or bitand(t.property,
             /* This clause is only for performance; they could be
                excluded by the column datatype checks below */
                  4        /* 0x00000004           has nested-TABLE columns */
                + 8        /* 0x00000008                    has REF columns */
               + 16        /* 0x00000010                  has array columns */
            + 32768        /* 0x00008000                   has FILE columns */
           + 131072        /* 0x00020000 table is used as an AQ queue table */
             ) != 0
             -----------------------------------------
             /* unsupp view joins col$, here we subquery it */
    or exists (select 1 from sys.col$ c 
               where t.obj# = c.obj#
             -----------------------------------------
             /*  ignore any hidden columns in this subquery */
               and bitand(c.property, 32) != 32                /* Not hidden */
             -----------------------------------------
             /* table has an unsupported datatype */
               and ((c.type# not in ( 
                                  1,                             /* VARCHAR2 */
                                  2,                               /* NUMBER */
                                  8,                                 /* LONG */
                                  12,                                /* DATE */
                                  24,                            /* LONG RAW */
                                  96,                                /* CHAR */
                                  100,                       /* BINARY FLOAT */
                                  101,                      /* BINARY DOUBLE */
                                  112,                     /* CLOB and NCLOB */
                                  113,                               /* BLOB */
                                  180,                     /* TIMESTAMP (..) */
                                  181,       /* TIMESTAMP(..) WITH TIME ZONE */
                                  182,         /* INTERVAL YEAR(..) TO MONTH */
                                  183,     /* INTERVAL DAY(..) TO SECOND(..) */
                                  231) /* TIMESTAMP(..) WITH LOCAL TIME ZONE */
                  and (c.type# != 23                      /* RAW not RAW OID */
                  or (c.type# = 23 and bitand(c.property, 2) = 2))
                  and (c.type# != 58                               /* OPAQUE */
                  or (c.type# = 58                        /* XMLTYPE as CLOB */
                      and not exists (select 1 from opqtype$ opq
                                       where opq.type=1 
                                         and bitand(opq.flags, 4) = 4
                                         and bitand(opq.flags,64) = 0
                                         and bitand(opq.flags,512) = 0
                                         and opq.obj#=c.obj# 
                                         and opq.intcol#=c.intcol#))))
             -----------------------------------------
             /* table doesn't have at least one scalar column */
             or (c.type# in (8,24,58,112,113)
             and bitand(t.property, 1) = 0         /* typed table has an OID */
             and 0 = (select count(*) from sys.col$ c2
               where t.obj# = c2.obj#
               and bitand(c2.property, 32) != 32               /* Not hidden */
               and (c2.type# in ( 1,                             /* VARCHAR2 */
                                  2,                               /* NUMBER */
                                  12,                                /* DATE */
                                  23,                                 /* RAW */
                                  96,                                /* CHAR */
                                  100,                       /* BINARY FLOAT */
                                  101,                      /* BINARY DOUBLE */
                                  180,                     /* TIMESTAMP (..) */
                                  181,       /* TIMESTAMP(..) WITH TIME ZONE */
                                  182,         /* INTERVAL YEAR(..) TO MONTH */
                                  183,     /* INTERVAL DAY(..) TO SECOND(..) */
                                  231) /* TIMESTAMP(..) WITH LOCAL TIME ZONE */
                )))
             -----------------------------------------
             /* table has a dedup securefile column */
             or  (c.type# in (112, 113)
             and exists (select 1 from logstdby_support_11lob lb
                          where lb.obj# = o.obj# 
                            and lb.col# = c.col#
                            and lb.dedupsecurefile = 1))
             -----------------------------------------
             /* table has a virtual column candidate key */
             or (bitand(c.property, 65544) != 0            /* Virtual Column */
             and bitand(c.property, 256) = 0                /* Sys Generated */
             and c.obj# = t.obj#
             and exists (select 1 from icol$ ic, ind$ i
                          where ic.bo# = t.obj# and ic.col# = c.col#
                            and i.bo# = t.obj# and i.obj# = ic.obj#
                            and bitand(i.property, 1) = 1))) /* Unique Index */
             ) /* end col$ exists subquery */
----------------------------------------------
  then 0 else 1 end) gensby
  from sys.obj$ o, sys.user$ u, sys.tab$ t, sys.seg$ s
  where o.owner# = u.user#
  and o.obj# = t.obj#
  and t.file# = s.file# (+)
  and t.block# = s.block# (+)
  and t.ts# = s.ts# (+)
  and t.obj# = o.obj#
/

---------------------------------------------------------------------
-- OGG_SUPPORT_TAB_11_2
-- This view encapsulates 11.2 compatibility support for OGG
--   gensby:       1 SUPPORT_MODE=FULL supported
--                   includes BFILE (non-ADT), REF/Sys partitioning
--                 0 SUPPORT_MODE=ID KEY (Fetch)
--                   e.g. ADTs, XML/OR, XML/CSX
--                -1 internal, so not supported
--                   e.g. IOT overflow, nested table storage tab
--                 3 SUPPORT_MODE=NONE, table not supportable by OGG
--                   e.g. AQ queue tables; tables with no usable key,
--                   BFILE attrs of ADT
--
create or replace view ogg_support_tab_11_2
as
  select u.name owner, o.name name, o.type#, o.obj#,
 (case 
  /* INTERNAL - The following are tables that are system maintained */
  when ( exists (select 1 from system.logstdby$skip_support s
                 where s.name = u.name and action = 0))
    or bitand(o.flags,
                2                                       /* temporary object */
              + 16                                      /* secondary object */
              + 32                                  /* in-memory temp table */
              + 128                           /* dropped table (RecycleBin) */
             ) != 0
    or bitand(t.flags,
                134217728  /* 0x08000000          in-memory temporary table */
              + 536870912  /* 0x20000000  Mapping Tab for Phys rowid of IOT */
             ) != 0
    or bitand(t.property,
                512        /* 0x00000200               iot OVeRflow segment */
              + 8192       /* 0x00002000                       nested table */
              + 4194304    /* 0x00400000             global temporary table */
              + 8388608    /* 0x00800000   session-specific temporary table */
              + 134217728  /* 0x08000000                    Is a Sub object */
              + 2147483648 /* 0x80000000                     eXternal TaBle */
              + 4294967296 /* 0x100000000                              Cube */
              + 8589934592 /* 0x200000000                      FBA Internal */
             ) != 0
    or bitand(t.trigflag,
                536870912  /* 0x20000000                  DDLs autofiltered */
               ) != 0
    or exists (select 1 from sys.secobj$ so           /* ODCI storage table */
               where o.obj# = so.secobj#) 
    or exists (select 1 from sys.opqtype$ opq       /* XML OR storage table */
               where o.obj# = opq.obj# 
                 and bitand(opq.flags, 32) = 32) 
  then -1
  ----------------------------------------------
  /* SUPPORT_MODE "NONE" */
  when exists (
    select 1 from sys.col$ c 
             where t.obj# = c.obj#
             /* ADT typed table with BFILE attribute */
             and ((bitand(t.property, 1) = 1 and
                   c.type# = 114 /* BFILE */ and
                   exists(select 1 
                          from sys.col$ c1
                          where c1.obj#=t.obj# and
                                c1.name = 'SYS_NC_ROWINFO$' and
                                c1.type# = 121))
             /* Relational table with ADT column having BFILE attribute */
             or (bitand(t.property, 1) = 0 and 
                 c.type# = 114 /* BFILE */ and
                 bitand(c.property, 32) = 32 /* hidden */ and
                 exists (select 1 
                         from sys.col$ c1 
                         where c1.obj#=t.obj# and
                               c1.col# = c.col# and
                               bitand(c1.property, 32) = 0 /* not hidden */ and
                               c1.type# = 121))
             /* table doesnt have at least one scalar column */
             or ((c.type# in (8,24,58,112,113,114,115,121,123) 
                  or bitand(c.property, 128) = 128)
               and (bitand(t.property, 1) = 0        /* not a typed table or */
                 and 0 = (select count(*) from sys.col$ c2
                 where t.obj# = c2.obj#
                 and bitand(c2.property, 32)  != 32            /* Not hidden */
                 and bitand(c2.property, 8)   != 8            /* Not virtual */
                 and bitand(c2.property, 128) != 128    /* not stored in lob */
                 and (c2.type# in ( 1,                           /* VARCHAR2 */
                                    2,                             /* NUMBER */
                                    12,                              /* DATE */
                                    23,                               /* RAW */
                                    96,                              /* CHAR */
                                    100,                     /* BINARY FLOAT */
                                    101,                    /* BINARY DOUBLE */
                                    180,                   /* TIMESTAMP (..) */
                                    181,     /* TIMESTAMP(..) WITH TIME ZONE */
                                    182,       /* INTERVAL YEAR(..) TO MONTH */
                                    183,   /* INTERVAL DAY(..) TO SECOND(..) */
                                    208,                           /* UROWID */
                                    231)      /* TIMESTAMP(..) WITH LOCAL TZ */
                  ))))))
    or bitand(t.property, 131072) != 0                    /* AQ queue tables */
  then 3
  --------------------------------------
  /* SUPPORT_MODE "ID KEY" */
  when (bitand(t.property, 1 ) = 1    /* 0x00000001             typed table */
        AND not exists          /* Only XML/CLOB Typed Tables Are Supported */
          (select 1
             from  sys.col$ cc, sys.opqtype$ opq
             where cc.name = 'SYS_NC_ROWINFO$' and cc.type# = 58 and
                   opq.obj# = cc.obj# and opq.intcol# = cc.intcol# and
                   opq.type = 1 and cc.obj# = t.obj# 
                   and bitand(opq.flags,4) = 4             /* stored as lob */
                   and bitand(opq.flags,64) = 0     /* not stored as binary */
                   and bitand(opq.flags,512) = 0))     /* not hierarch enab */
    or bitand(t.property,
             /* This clause is only for performance; they could be
                excluded by the column datatype checks below */
                  4        /* 0x00000004           has nested-TABLE columns */
                + 8        /* 0x00000008                    has REF columns */
               + 16        /* 0x00000010                  has array columns */
             ) != 0
             -----------------------------------------
             /* unsupp view joins col$, here we subquery it */
    or exists (select 1 from sys.col$ c 
               where t.obj# = c.obj#
             -----------------------------------------
             /*  ignore any hidden columns in this subquery */
               and bitand(c.property, 32) != 32                /* Not hidden */
             -----------------------------------------
             /* table has an unsupported datatype */
               and ((c.type# not in ( 
                                  1,                             /* VARCHAR2 */
                                  2,                               /* NUMBER */
                                  8,                                 /* LONG */
                                  12,                                /* DATE */
                                  24,                            /* LONG RAW */
                                  96,                                /* CHAR */
                                  100,                       /* BINARY FLOAT */
                                  101,                      /* BINARY DOUBLE */
                                  112,                     /* CLOB and NCLOB */
                                  113,                               /* BLOB */
                                  114,                              /* BFILE */
                                  115,                              /* CFILE */
                                  180,                     /* TIMESTAMP (..) */
                                  181,       /* TIMESTAMP(..) WITH TIME ZONE */
                                  182,         /* INTERVAL YEAR(..) TO MONTH */
                                  183,     /* INTERVAL DAY(..) TO SECOND(..) */
                                  208,                             /* UROWID */
                                  231) /* TIMESTAMP(..) WITH LOCAL TIME ZONE */
                  and (c.type# != 23                      /* RAW not RAW OID */
                  or (c.type# = 23 and bitand(c.property, 2) = 2))
                  and (c.type# != 58                               /* OPAQUE */
                  or (c.type# = 58                        /* XMLTYPE as CLOB */
                      and not exists (select 1 from opqtype$ opq
                                       where opq.type=1 
                                         and bitand(opq.flags, 4) = 4
                                         and bitand(opq.flags,64) = 0
                                         and bitand(opq.flags,512) = 0
                                         and opq.obj#=c.obj# 
                                         and opq.intcol#=c.intcol#))))
             -----------------------------------------
             /* table has a dedup securefile column */
             or  (c.type# in (112, 113)
             and exists (select 1 from logstdby_support_11lob lb
                          where lb.obj# = o.obj# 
                            and lb.col# = c.col#
                            and lb.dedupsecurefile = 1)))
             ) /* end col$ exists subquery */
  then 0 
  ----------------------------------------------
  /* SUPPORT_MODE "FULL" */
  else 1 end) gensby
  from sys.obj$ o, sys.user$ u, sys.tab$ t
  where o.owner# = u.user#
  and o.obj# = t.obj#
/

---------------------------------------------------------------------
-- LOGSTDBY_SUPPORT_TAB_11_1
-- This view encapsulates 11.1 compatibility support
--   gensby:       1 supported, 
--                 -1 internal so not supported   
--                 0 user data not supported because of features     
--   current_sby:  1 if lsby bit set in tab$ else 0
--
create or replace view logstdby_support_tab_11_1
as
  select u.name owner, o.name name, o.type#, o.obj#,
         decode(bitand(t.flags, 1073741824), 1073741824, 1, 0) current_sby,
 (case 
    /* The following are tables that are system maintained */
  when ( exists (select 1 from system.logstdby$skip_support s
                 where s.name = u.name and action = 0))
    or bitand(o.flags,
                2                                       /* temporary object */
              + 16                                      /* secondary object */
              + 32                                  /* in-memory temp table */
              + 128                           /* dropped table (RecycleBin) */
             ) != 0
    or bitand(t.flags,
                262144     /* 0x00040000        Summary Container Table, MV */ 
              + 134217728  /* 0x08000000          in-memory temporary table */
              + 536870912  /* 0x20000000  Mapping Tab for Phys rowid of IOT */
             ) != 0
    or bitand(t.property,
                512        /* 0x00000200               iot OVeRflow segment */
              + 8192       /* 0x00002000                       nested table */
              + 4194304    /* 0x00400000             global temporary table */
              + 8388608    /* 0x00800000   session-specific temporary table */
              + 33554432   /* 0x02000000        Read Only Materialized View */
              + 67108864   /* 0x04000000            Materialized View table */
              + 134217728  /* 0x08000000                    Is a Sub object */
              + 2147483648 /* 0x80000000                     eXternal TaBle */
              + 4294967296 /* 0x100000000                              Cube */
              + 8589934592 /* 0x200000000                      FBA Internal */
             ) != 0
    or bitand(t.trigflag,
                536870912  /* 0x20000000                  DDLs autofiltered */
               ) != 0
    or exists (select 1 from sys.mlog$ ml                    /* MVLOG table */
               where ml.mowner = u.name and ml.log = o.name) 
    or exists (select 1 from sys.secobj$ so           /* ODCI storage table */
               where o.obj# = so.secobj#) 
  then -1
    /* The following tables are user visible tables that we choose to 
     * skip because of some unsupported attribute of the table or column */
  when (bitand(t.property, 1 ) = 1    /* 0x00000001             typed table */
        AND not exists                /* Only XML Typed Tables Are Supported */
          (select 1
             from  sys.col$ cc, sys.opqtype$ opq
             where cc.name = 'SYS_NC_ROWINFO$' and cc.type# = 58 and
                   opq.obj# = cc.obj# and opq.intcol# = cc.intcol# and
                   opq.type = 1 and cc.obj# = t.obj# 
                   and bitand(opq.flags,4) = 4             /* stored as lob */
                   and bitand(opq.flags,64) = 0     /* not stored as binary */
                   and bitand(opq.flags,512) = 0       /* not hierarch enab */
                   and not exists (select 1 from logstdby_support_11lob lb
                                    where lb.obj# = o.obj# 
                                      and lb.securefile = 1)))
    or (bitand(nvl(s.spare1,0), 2048) = 2048                 /* Compression */
        and bitand(t.property, 32) != 32) 
    or (bitand(t.property, 32) = 32)                         /* Partitioned */
      and exists (select 1 from partobj$ po
                  where po.obj#=o.obj#
                  and  (po.parttype in (3,             /* System partitioned */
                                        5)))        /* Reference partitioned */
    or bitand(t.property,
             /* This clause is only for performance; they could be
                excluded by the column datatype checks below */
                  4        /* 0x00000004           has nested-TABLE columns */
                + 8        /* 0x00000008                    has REF columns */
               + 16        /* 0x00000010                  has array columns */
            + 32768        /* 0x00008000                   has FILE columns */
           + 131072        /* 0x00020000 table is used as an AQ queue table */
             ) != 0
             -----------------------------------------
             /* unsupp view joins col$, here we subquery it */
    or exists (select 1 from sys.col$ c 
               where t.obj# = c.obj#
             -----------------------------------------
             /*  ignore any hidden columns in this subquery */
               and bitand(c.property, 32) != 32                /* Not hidden */
             -----------------------------------------
             /* table has an unsupported datatype */
               and ((c.type# not in ( 
                                  1,                             /* VARCHAR2 */
                                  2,                               /* NUMBER */
                                  8,                                 /* LONG */
                                  12,                                /* DATE */
                                  24,                            /* LONG RAW */
                                  96,                                /* CHAR */
                                  100,                       /* BINARY FLOAT */
                                  101,                      /* BINARY DOUBLE */
                                  112,                     /* CLOB and NCLOB */
                                  113,                               /* BLOB */
                                  180,                     /* TIMESTAMP (..) */
                                  181,       /* TIMESTAMP(..) WITH TIME ZONE */
                                  182,         /* INTERVAL YEAR(..) TO MONTH */
                                  183,     /* INTERVAL DAY(..) TO SECOND(..) */
                                  231) /* TIMESTAMP(..) WITH LOCAL TIME ZONE */
                  and (c.type# != 23                      /* RAW not RAW OID */
                  or (c.type# = 23 and bitand(c.property, 2) = 2))
                  and (c.type# != 58                               /* OPAQUE */
                  or (c.type# = 58                        /* XMLTYPE as CLOB */
                      and not exists
                              (select 1 from opqtype$ opq
                                where opq.type=1 
                                  and bitand(opq.flags, 4) = 4
                                  and bitand(opq.flags,64) = 0
                                  and bitand(opq.flags,512) = 0
                                  and opq.obj#=c.obj# 
                                  and opq.intcol#=c.intcol#
                                  and not exists 
                                          (select 1
                                             from logstdby_support_11lob lb
                                            where lb.obj# = c.obj# 
                                              and lb.col# = c.col#
                                              and lb.securefile = 1)))))
             -----------------------------------------
             /* table doesn't have at least one scalar column */
             or (c.type# in (8,24,58,112,113)
             and bitand(t.property, 1) = 0         /* typed table has an OID */
             and 0 = (select count(*) from sys.col$ c2
               where t.obj# = c2.obj#
               and bitand(c2.property, 32) != 32               /* Not hidden */
               and (c2.type# in ( 1,                             /* VARCHAR2 */
                                  2,                               /* NUMBER */
                                  12,                                /* DATE */
                                  23,                                 /* RAW */
                                  96,                                /* CHAR */
                                  100,                       /* BINARY FLOAT */
                                  101,                      /* BINARY DOUBLE */
                                  180,                     /* TIMESTAMP (..) */
                                  181,       /* TIMESTAMP(..) WITH TIME ZONE */
                                  182,         /* INTERVAL YEAR(..) TO MONTH */
                                  183,     /* INTERVAL DAY(..) TO SECOND(..) */
                                  231) /* TIMESTAMP(..) WITH LOCAL TIME ZONE */
                   )))
             -----------------------------------------
             /* table has a securefile column */
             or  (c.type# in (112, 113)
             and exists (select 1 from logstdby_support_11lob lb
                          where lb.obj# = o.obj# 
                            and lb.col# = c.col#
                            and lb.securefile = 1))
             -----------------------------------------
             /* table has a virtual column candidate key */
             or (bitand(c.property, 65544) != 0            /* Virtual Column */
             and bitand(c.property, 256) = 0                /* Sys Generated */
             and c.obj# = t.obj#
             and exists (select 1 from icol$ ic, ind$ i
                          where ic.bo# = t.obj# and ic.col# = c.col#
                            and i.bo# = t.obj# and i.obj# = ic.obj#
                            and bitand(i.property, 1) = 1))) /* Unique Index */
             ) /* end col$ exists subquery */
----------------------------------------------
  then 0 else 1 end) gensby
  from sys.obj$ o, sys.user$ u, sys.tab$ t, sys.seg$ s
  where o.owner# = u.user#
  and o.obj# = t.obj#
  and t.file# = s.file# (+)
  and t.block# = s.block# (+)
  and t.ts# = s.ts# (+)
  and t.obj# = o.obj#
/

---------------------------------------------------------------------
-- LOGSTDBY_SUPPORT_TAB_11_2b
--   Adds support for XML OR
--
-- This view encapsulates 11.2.0.3 compatibility support
--   gensby:       1 supported, 
--                 -1 internal so not supported   
--                 0 user data not supported because of features     
--   current_sby:  1 if lsby bit set in tab$ else 0
--
create or replace view logstdby_support_tab_11_2b
as
  select u.name owner, o.name name, o.type#, o.obj#,
         decode(bitand(t.flags, 1073741824), 1073741824, 1, 0) current_sby,
 (case 
    /* The following are tables that are system maintained */
  when ( exists (select 1 from system.logstdby$skip_support s
                 where s.name = u.name and action = 0))
    or bitand(o.flags,
                2                                       /* temporary object */
              + 16                                      /* secondary object */
              + 32                                  /* in-memory temp table */
              + 128                           /* dropped table (RecycleBin) */
             ) != 0
    or bitand(t.flags,
                262144     /* 0x00040000        Summary Container Table, MV */ 
              + 134217728  /* 0x08000000          in-memory temporary table */
              + 536870912  /* 0x20000000  Mapping Tab for Phys rowid of IOT */
             ) != 0
    or bitand(t.property,
                512        /* 0x00000200               iot OVeRflow segment */
              + 8192       /* 0x00002000                       nested table */
              + 4194304    /* 0x00400000             global temporary table */
              + 8388608    /* 0x00800000   session-specific temporary table */
              + 33554432   /* 0x02000000        Read Only Materialized View */
              + 67108864   /* 0x04000000            Materialized View table */
              + 134217728  /* 0x08000000                    Is a Sub object */
              + 2147483648 /* 0x80000000                     eXternal TaBle */
              + 4294967296 /* 0x100000000                              Cube */
              + 8589934592 /* 0x200000000                      FBA Internal */
             ) != 0
    or bitand(t.trigflag,
                536870912  /* 0x20000000                  DDLs autofiltered */
               ) != 0
    or exists (select 1 from sys.mlog$ ml                    /* MVLOG table */
               where ml.mowner = u.name and ml.log = o.name) 
    or exists (select 1 from sys.secobj$ so           /* ODCI storage table */
               where o.obj# = so.secobj#) 
    or exists (select 1 from sys.opqtype$ opq       /* XML OR storage table */
               where o.obj# = opq.obj# 
                 and bitand(opq.flags, 32) = 32) 
  then -1
    /* The following tables are user visible tables that we choose to 
     * skip because of some unsupported attribute of the table or column */
  when (bitand(t.property, 1 ) = 1    /* 0x00000001             typed table */
        AND ((bitand(t.property, 4096) = 4096)                     /* pk oid */
             OR not exists            /* Only XML Typed Tables Are Supported */
                (select 1
                 from  sys.col$ cc, sys.opqtype$ opq
                 where cc.name = 'SYS_NC_ROWINFO$' and cc.type# = 58 and
                   opq.obj# = cc.obj# and opq.intcol# = cc.intcol# and
                   opq.type = 1 and cc.obj# = t.obj# 
                   and (bitand(opq.flags,1) = 1 or      /* stored as object */
                        bitand(opq.flags,68) = 4 or      /* stored as lob */
                        bitand(opq.flags,68) = 68)      /*  stored as binary */
                   and bitand(opq.flags,512) = 0 )))   /* not hierarch enab */
    or (bitand(t.property, 32) = 32)                         /* Partitioned */
      and exists (select 1 from partobj$ po
                  where po.obj#=o.obj#
                  and  (po.parttype in (3,             /* System partitioned */
                                        5)))        /* Reference partitioned */
    or bitand(t.property,
             /* This clause is only for performance; they could be
                excluded by the column datatype checks below. */
              32768        /* 0x00008000                   has FILE columns */
           + 131072        /* 0x00020000 table is used as an AQ queue table */
             ) != 0
             -----------------------------------------
             /* unsupp view joins col$, here we subquery it */
    or exists (select 1 from sys.col$ c 
               where t.obj# = c.obj#
             -----------------------------------------
             /*  ignore any hidden columns in this subquery */
               and bitand(c.property, 32) != 32                /* Not hidden */
             -----------------------------------------
             /* table has an unsupported datatype */
               and ((c.type# not in ( 
                                  1,                             /* VARCHAR2 */
                                  2,                               /* NUMBER */
                                  8,                                 /* LONG */
                                  12,                                /* DATE */
                                  24,                            /* LONG RAW */
                                  96,                                /* CHAR */
                                  100,                       /* BINARY FLOAT */
                                  101,                      /* BINARY DOUBLE */
                                  112,                     /* CLOB and NCLOB */
                                  113,                               /* BLOB */
                                  180,                     /* TIMESTAMP (..) */
                                  181,       /* TIMESTAMP(..) WITH TIME ZONE */
                                  182,         /* INTERVAL YEAR(..) TO MONTH */
                                  183,     /* INTERVAL DAY(..) TO SECOND(..) */
                                  231) /* TIMESTAMP(..) WITH LOCAL TIME ZONE */
                  and (c.type# != 23                      /* RAW not RAW OID */
                  or (c.type# = 23 and bitand(c.property, 2) = 2))
                  and (c.type# != 58                               /* OPAQUE */
                    or (c.type# = 58                   /* XMLTYPE as CLOB */
                        and 
                         (not exists
                          (select 1 from opqtype$ opq
                            where opq.type=1 
                            and (bitand(opq.flags,1) = 1 or /* stored as obj */
                                 bitand(opq.flags,68) = 4 or /* stored a lob */
                                 bitand(opq.flags,68) = 68) /* store binary */
                            and bitand(opq.flags,512) = 0    /* not hierarch */
                            and opq.obj#=c.obj# 
                            and opq.intcol#=c.intcol#)))))
             -----------------------------------------
             /* table doesn't have at least one scalar column */
             or (c.type# in (8,24,58,112,113)
             and (bitand(t.property, 1) = 0          /* not a typed table or */
             and 0 = (select count(*) from sys.col$ c2
               where t.obj# = c2.obj#
               and bitand(c2.property, 32) != 32               /* Not hidden */
               and bitand(c2.property, 8) != 8                /* Not virtual */
               and (c2.type# in ( 1,                             /* VARCHAR2 */
                                  2,                               /* NUMBER */
                                  12,                                /* DATE */
                                  23,                                 /* RAW */
                                  96,                                /* CHAR */
                                  100,                       /* BINARY FLOAT */
                                  101,                      /* BINARY DOUBLE */
                                  180,                     /* TIMESTAMP (..) */
                                  181,       /* TIMESTAMP(..) WITH TIME ZONE */
                                  182,         /* INTERVAL YEAR(..) TO MONTH */
                                  183,     /* INTERVAL DAY(..) TO SECOND(..) */
                                  231) /* TIMESTAMP(..) WITH LOCAL TIME ZONE */
                ))))
             -----------------------------------------
             /* table has a dedup securefile column */
             or  (c.type# in (112, 113)
             and exists (select 1 from logstdby_support_11lob lb
                      where lb.obj# = o.obj# 
                      and lb.col# = c.col#
                      and dedupsecurefile = 1)))
	 ) /* end col$ exists subquery */
----------------------------------------------
  then 0 else 1 end) gensby
  from sys.obj$ o, sys.user$ u, sys.tab$ t, sys.seg$ s
  where o.owner# = u.user#
  and o.obj# = t.obj#
  and t.file# = s.file# (+)
  and t.block# = s.block# (+)
  and t.ts# = s.ts# (+)
  and t.obj# = o.obj#
/

---------------------------------------------------------------------
-- OGG_SUPPORT_TAB_11_2b
-- This view encapsulates 11.2.0.3 compatibility support for OGG
--   gensby:       1 SUPPORT_MODE=FULL supported
--                   includes BFILE(non-ADT), REF/Sys partitioning
--                 0 SUPPORT_MODE=ID KEY (Fetch)
--                   e.g. ADTs, nested table columns
--                -1 internal, so not supported
--                   e.g. IOT overflow, nested table storage tab
--                 3 SUPPORT_MODE=NONE, table not supportable by OGG
--                   e.g. AQ queue tables; tables with no usable key;
--                        ADT with BFILE attr
--
create or replace view ogg_support_tab_11_2b
as
  select u.name owner, o.name name, o.type#, o.obj#,
 (case 
    /* INTERNAL - The following are tables that are system maintained 
       These are internal, so no SUPPORT_MODE given */
  when ( exists (select 1 from system.logstdby$skip_support s
                 where s.name = u.name and action = 0))
    or bitand(o.flags,
                2                                       /* temporary object */
              + 16                                      /* secondary object */
              + 32                                  /* in-memory temp table */
              + 128                           /* dropped table (RecycleBin) */
             ) != 0
    or bitand(t.flags,
                134217728  /* 0x08000000          in-memory temporary table */
              + 536870912  /* 0x20000000  Mapping Tab for Phys rowid of IOT */
             ) != 0
    or bitand(t.property,
                512        /* 0x00000200               iot OVeRflow segment */
              + 8192       /* 0x00002000                       nested table */
              + 4194304    /* 0x00400000             global temporary table */
              + 8388608    /* 0x00800000   session-specific temporary table */
              + 134217728  /* 0x08000000                    Is a Sub object */
              + 2147483648 /* 0x80000000                     eXternal TaBle */
              + 4294967296 /* 0x100000000                              Cube */
              + 8589934592 /* 0x200000000                      FBA Internal */
             ) != 0
    or bitand(t.trigflag,
                536870912  /* 0x20000000                  DDLs autofiltered */
               ) != 0
    or exists (select 1 from sys.secobj$ so           /* ODCI storage table */
               where o.obj# = so.secobj#) 
    or exists (select 1 from sys.opqtype$ opq       /* XML OR storage table */
               where o.obj# = opq.obj# 
                 and bitand(opq.flags, 32) = 32) 
  then -1
  ----------------------------------------------
  /* SUPPORT_MODE "NONE" */
  when exists (
    select 1 from sys.col$ c 
             where t.obj# = c.obj#
             /* ADT typed table with BFILE attribute */
             and ((bitand(t.property, 1) = 1 and 
                   c.type# = 114 /* BFILE */ and
                   exists(select 1 
                          from sys.col$ c1
                          where c1.obj#=t.obj# and
                                c1.name = 'SYS_NC_ROWINFO$' and
                                c1.type# = 121))
             /* Relational table with ADT column having BFILE attribute */
             or (bitand(t.property, 1) = 0 and 
                 c.type# = 114 /* BFILE */ and
                 bitand(c.property, 32) = 32 /* hidden */ and
                 exists (select 1 
                         from sys.col$ c1 
                         where c1.obj#=t.obj# and
                               c1.col# = c.col# and
                               bitand(c1.property, 32) = 0 /* not hidden */ and
                               c1.type# = 121))
             /* table doesnt have at least one scalar column */
             or ((c.type# in (8,24,58,112,113,114,115,121,123) 
                  or bitand(c.property, 128) = 128)
               and (bitand(t.property, 1) = 0        /* not a typed table or */
               and 0 = (select count(*) from sys.col$ c2
                 where t.obj# = c2.obj#
                 and bitand(c2.property, 32)  != 32            /* Not hidden */
                 and bitand(c2.property, 8)   != 8            /* Not virtual */
                 and bitand(c2.property, 128) != 128    /* not stored in lob */
                 and (c2.type# in ( 1,                           /* VARCHAR2 */
                                    2,                             /* NUMBER */
                                    12,                              /* DATE */
                                    23,                               /* RAW */
                                    96,                              /* CHAR */
                                    100,                     /* BINARY FLOAT */
                                    101,                    /* BINARY DOUBLE */
                                    180,                   /* TIMESTAMP (..) */
                                    181,     /* TIMESTAMP(..) WITH TIME ZONE */
                                    182,       /* INTERVAL YEAR(..) TO MONTH */
                                    183,   /* INTERVAL DAY(..) TO SECOND(..) */
                                    208,                           /* UROWID */
                                    231)      /* TIMESTAMP(..) WITH LOCAL TZ */
                  ))))))
    or bitand(t.property, 131072) != 0                    /* AQ queue tables */
  then 3
  --------------------------------------
  /* SUPPORT_MODE "ID KEY" */
  when (bitand(t.property, 1 ) = 1    /* 0x00000001              typed table */
        AND ((bitand(t.property, 4096) = 4096)                     /* pk oid */
             OR not exists            /* Only XML Typed Tables Are Supported */
                (select 1
                 from  sys.col$ cc, sys.opqtype$ opq
                 where cc.name = 'SYS_NC_ROWINFO$' and cc.type# = 58 and
                   opq.obj# = cc.obj# and opq.intcol# = cc.intcol# and
                   opq.type = 1 and cc.obj# = t.obj# 
                   and (bitand(opq.flags,1) = 1 or       /* stored as object */
                        bitand(opq.flags,68) = 4 or         /* stored as lob */
                        bitand(opq.flags,68) = 68)      /*  stored as binary */
                   and bitand(opq.flags,512) = 0 )))    /* not hierarch enab */
             -----------------------------------------
             /* unsupp view joins col$, here we subquery it */
    or exists (select 1 from sys.col$ c 
               where t.obj# = c.obj#
             -----------------------------------------
             /*  ignore any hidden columns in this subquery */
               and bitand(c.property, 32) != 32                /* Not hidden */
             -----------------------------------------
             /* table has an unsupported datatype */
               and ((c.type# not in ( 
                                  1,                             /* VARCHAR2 */
                                  2,                               /* NUMBER */
                                  8,                                 /* LONG */
                                  12,                                /* DATE */
                                  24,                            /* LONG RAW */
                                  96,                                /* CHAR */
                                  100,                       /* BINARY FLOAT */
                                  101,                      /* BINARY DOUBLE */
                                  112,                     /* CLOB and NCLOB */
                                  113,                               /* BLOB */
                                  114,                              /* BFILE */
                                  115,                              /* CFILE */
                                  180,                     /* TIMESTAMP (..) */
                                  181,       /* TIMESTAMP(..) WITH TIME ZONE */
                                  182,         /* INTERVAL YEAR(..) TO MONTH */
                                  183,     /* INTERVAL DAY(..) TO SECOND(..) */
                                  208,                             /* UROWID */
                                  231) /* TIMESTAMP(..) WITH LOCAL TIME ZONE */
                  and (c.type# != 23                      /* RAW not RAW OID */
                  or (c.type# = 23 and bitand(c.property, 2) = 2))
                  and (c.type# != 58                               /* OPAQUE */
                    or (c.type# = 58                   /* XMLTYPE as CLOB */
                        and 
                         (not exists
                          (select 1 from opqtype$ opq
                            where opq.type=1 
                            and (bitand(opq.flags,1) = 1 or /* stored as obj */
                                 bitand(opq.flags,68) = 4 or /* stored a lob */
                                 bitand(opq.flags,68) = 68) /* store binary */
                            and bitand(opq.flags,512) = 0    /* not hierarch */
                            and opq.obj#=c.obj# 
                            and opq.intcol#=c.intcol#)))))
             -----------------------------------------
             /* table has a dedup securefile column */
             or  (c.type# in (112, 113)
             and exists (select 1 from logstdby_support_11lob lb
                      where lb.obj# = o.obj# 
                      and lb.col# = c.col#
                      and dedupsecurefile = 1)))
      ) /* end col$ exists subquery */
  then 0 
  ----------------------------------------------
  /* SUPPORT_MODE "FULL" */
  else 1 end) gensby
  from sys.obj$ o, sys.user$ u, sys.tab$ t
  where o.owner# = u.user#
  and o.obj# = t.obj#
/

/* 12.1 SUPPORTED/UNSUPPORTED VIEW DEFINITIONS */
DECLARE
  unsupported_varray_c     varchar2(1000);
  unsupported_varray_c1    varchar2(1000);
  unsupported_varray_c2    varchar2(1000);
  unsupported_opaque_c     varchar2(1000);
  unsupported_opaque_c1    varchar2(1000);
  unsupported_opaque_c2    varchar2(1000);
  unsupp_built_in_type_c   varchar2(4000);
  unsupp_built_in_type_c1  varchar2(4000);
  unsupp_built_in_type_c2  varchar2(4000);
  sm_none_built_in_type_c   varchar2(4000);
  sm_none_built_in_type_c1  varchar2(4000);
  sm_none_built_in_type_c2  varchar2(4000);
  unsupported_adt_c        varchar2(8000);
  unsupported_adt_ogg_c    varchar2(8000);
  unsupported_vc           varchar2(4000);
  unsup_tab_12_1_a        varchar2(32000);
  unsup_tab_12_1_b        varchar2(32000);
  unsup_tab_12_1          varchar2(32000);
  ru_unsup_tab_12_1       varchar2(32000);
  support_tab_12_1        varchar2(32000);
  ogg_support_tab_12_1    varchar2(32000);
BEGIN 

 /* VARRAY stored as table (= varray with Nested Table bit set) */
 /* and top-level (non-hidden) varrays arent supported  */
  unsupported_varray_c := 
'(c.type# = 123 and 
  (bitand(c.property, 4) = 4 or bitand(c.property, 32)!=32))';

  unsupported_varray_c1 := replace(unsupported_varray_c, 'c.', 'c1.');
  unsupported_varray_c2 := replace(unsupported_varray_c, 'c.', 'c2.');

 /* Unsupported OPAQUE types include:
  * - XMLType columns that are hierarchy enabled.
  * - Any opaque column which is not a SYS.XMLType or a SYS.ANYDATA type.
  */
  unsupported_opaque_c :=
'(c.type# = 58 and
 (exists (select 1 from opqtype$ opq
                   where opq.type=1 
                   and bitand(opq.flags,512) = 512      /* hierarchy enabled */
                   and opq.obj#=c.obj# 
                   and opq.intcol#=c.intcol#) or
  exists (select 1 from coltype$ ct
                   where ct.obj#=c.obj#
                   and   ct.intcol# = c.intcol#
                   and /* SYS.XMLTYPE */ 
                   ct.toid != ''00000000000000000000000000020100''
                   and /* SYS.ANYDATA */
                   ct.toid != ''00000000000000000000000000020011'')))';

  unsupported_opaque_c1 := replace(unsupported_opaque_c, 'c.', 'c1.');
  unsupported_opaque_c2 := replace(unsupported_opaque_c, 'c.', 'c2.');

 /* SUPPORT_MODE NONE (OGG) BUILT-IN TYPE LIST:
  * Check list of support_mode NONE datatypes maintained in
  * skip_support.  These could be built-in opaque, ADT or varray
  * types that are singled out as being completely unsupported for OGG.
  */
  sm_none_built_in_type_c :=
'(c.type# in (58, 121, 123) and
 (exists 
  (select 1 from obj$ o3, coltype$ ct3, user$ u3
    where u3.user# = o3.owner#
      and c.obj# = ct3.obj#
      and c.intcol# = ct3.intcol#
      and ct3.toid = o3.oid$  
      and exists (select 1 from system.logstdby$skip_support sk
                   where sk.action in (-11)
                     and sk.name = u3.name   /* type owner */
                     and sk.name2 = o3.name  /* type name  */))))';

  sm_none_built_in_type_c1 := replace(sm_none_built_in_type_c, 'c.', 'c1.');
  sm_none_built_in_type_c2 := replace(sm_none_built_in_type_c, 'c.', 'c2.');

 /* UNSUPPORTED(Lsby/RU), ID KEY (OGG) BUILT-IN TYPE LIST:
  * Check list of unsupported datatypes maintained in
  * skip_support.  These could be built-in opaque, ADT or varray
  * types that are singled out as being unsupported.
  * This check is made in the ID KEY support_mode portion of the OGG view.
  * This check is redundant for (action=-11), since those types were already
  * checked by the earlier support_mode NONE check.
  */
  unsupp_built_in_type_c :=
'(c.type# in (58, 121, 123) and
 (exists 
  (select 1 from obj$ o3, coltype$ ct3, user$ u3
    where u3.user# = o3.owner#
      and c.obj# = ct3.obj#
      and c.intcol# = ct3.intcol#
      and ct3.toid = o3.oid$  
      and exists (select 1 from system.logstdby$skip_support sk
                   where sk.action in (-5, -11)
                     and sk.name = u3.name   /* type owner */
                     and sk.name2 = o3.name  /* type name  */))))';

  unsupp_built_in_type_c1 := replace(unsupp_built_in_type_c, 'c.', 'c1.');
  unsupp_built_in_type_c2 := replace(unsupp_built_in_type_c, 'c.', 'c2.');

 /* ADT ATTRIBUTE check:
  * In a subquery, we check for any unsupported datatypes in the attributes
  * of this ADT.  These are BFILEs, Nested Tables, or any opaque, varray, or
  * skipped datatypes passing the above checks.
  * Note that the sys.col$ subquery is necessary so that we don't return any 
  * hidden columns from the unsupported query.  When an ADT attribute is
  * unsupported, the parent (non-hidden) ADT column should be identified as
  * the culprit.                                                             
  */
  unsupported_adt_c :=
'(c.type#=121 and
 (exists
   (select 1 from sys.col$ c2  
     where t.obj# = c2.obj#
       and c.col# = c2.col#
       and (c2.type# in (114, 122, 111) or       /* BFILE/Nested Table/REF */
           ' || unsupported_varray_c2 || ' or                    /* Varray */
           ' || unsupported_opaque_c2 || ' or                    /* Opaque */
           ' || unsupp_built_in_type_c2 || '      /* Built-in type in Skip */
           ))))';

  unsupported_adt_ogg_c :=
'(c.type#=121 and
 (exists
   (select 1 from sys.col$ c2  
     where t.obj# = c2.obj#
       and c.col# = c2.col#
       and (c2.type# in (122, 111) or                  /* Nested Table/REF */
           ' || unsupported_varray_c2 || ' or                    /* Varray */
           ' || unsupported_opaque_c2 || ' or                    /* Opaque */
           ' || unsupp_built_in_type_c2 || '      /* Built-in type in Skip */
           ))))';

  /* UNSUPPORTED 32k column
   * A long varchar (>4k) having a unique index or constraint defined on it
   * is unsupported.  Note: unique keys cannot be defined for columns longer
   * than 6398.
   */
  unsupported_vc := 
   '(bitand(c.property, 128) = 128                 /* column stored in LOB */
     and c.length between 4001 and 6398
     and (exists                                  /* Unique index on vc32k */
          (select null
           from ind$ i, icol$ ic
           where i.bo# = t.obj#
             and ic.obj# = i.obj#
             and c.intcol# = ic.intcol#
             and bitand(i.property, 1) = 1                       /* Unique */
          )
         or exists                  /* Primary or unique constraint on 32k */
          (select null
           from cdef$ cd, ccol$ ccol 
           where cd.obj# = t.obj#
             and cd.obj# = ccol.obj#
             and cd.con# = ccol.con#
             and cd.type# in (2,3)
             and ccol.intcol# = c.intcol#
          )))';

 /* Leading section of unsupported view definition:
  * View was broken in half to support creating peer rolling upgrade view. 
  * As of 12.1 the only difference is in handling of queue tables.
  */
 unsup_tab_12_1_a := 
'as
  select u.name owner, o.name table_name, c.name column_name, 
         c.scale, c.precision#, c.charsetform, c.type#,
   (case when bitand(t.flags, 536870912) = 536870912
         then ''Mapping table for physical rowid of IOT''
         else null end) attributes,
    (case 
    /* The following are tables that are system maintained */
    when bitand(o.flags,
                2                                       /* temporary object */
              + 16                                      /* secondary object */
              + 32                                  /* in-memory temp table */
              + 128                           /* dropped table (RecycleBin) */
             ) != 0
    or bitand(t.flags,
                262144     /* 0x00040000        Summary Container Table, MV */ 
              + 134217728  /* 0x08000000          in-memory temporary table */
              + 536870912  /* 0x20000000  Mapping Tab for Phys rowid of IOT */
             ) != 0
    or bitand(t.property,
                512        /* 0x00000200               iot OVeRflow segment */
              + 8192       /* 0x00002000                       nested table */
              + 4194304    /* 0x00400000             global temporary table */
              + 8388608    /* 0x00800000   session-specific temporary table */
              + 33554432   /* 0x02000000        Read Only Materialized View */
              + 67108864   /* 0x04000000            Materialized View table */
              + 134217728  /* 0x08000000                    Is a Sub object */
              + 2147483648 /* 0x80000000                     eXternal TaBle */
              + 4294967296 /* 0x100000000                              Cube */
              + 8589934592 /* 0x200000000                      FBA Internal */
             ) != 0
    or bitand(t.trigflag,
                536870912  /* 0x20000000                  DDLs autofiltered */
               ) != 0
    or exists                                                /* MVLOG table */
       (select 1 
        from sys.mlog$ ml where ml.mowner = u.name and ml.log = o.name) 
    or exists (select 1 from sys.secobj$ so           /* ODCI storage table */
               where o.obj# = so.secobj#) 
    or exists (select 1 from sys.opqtype$ opq       /* XML OR storage table */
               where o.obj# = opq.obj# 
                 and bitand(opq.flags, 32) = 32) 
    or (bitand(t.property, 131072) != 0 and               /* AQ spill table */
        o.name like ''AQ$\_%\_P'' escape ''\'')
    or (bitand(t.property, 131072) != 0 and            /* AQ commit q table */
        o.name like ''AQ$\_%\_C'' escape ''\'')
  then -1
    /* The following tables are data tables in internal schemata *
     * that are not secondary objects                            */
  when (exists (select 1 from system.logstdby$skip_support s
                where s.name = u.name and action = 0))
  then -2
    /* The following tables are user visible tables that we choose to       *
     * skip because of some unsupported attribute of the table or column    */
  when (bitand(t.property, 1) = 1       /* 0x00000001            typed table */
    AND((bitand(t.property, 4096) = 4096) /* PK OID */
        OR exists                                
            (select 1
              from  sys.col$ c1
              where c1.obj# = t.obj# and
                    (' || unsupported_opaque_c1 || '               /* Opaque */
                     or (c1.type# = 114)                            /* BFILE */
                        /* Non-hidden varray or varray stored in table in an */
                        /* ADT typed table.                                  */
                     or (' || unsupported_varray_c1 || ' and
                         (exists
                          (select 1 from sys.col$ c2
                             where c2.obj# = t.obj# and
                                   c2.name = ''SYS_NC_ROWINFO$'' and
                                   c2.type# = 121))) 
                     or ' || unsupp_built_in_type_c1 || '        /* Built-in */
                                       /* Nested table in an ADT typed table */
                     or (c1.type#=122 and
                         (exists 
                          (select 1 from sys.col$ c2
                             where c2.obj# = t.obj# and
                                   c2.name = ''SYS_NC_ROWINFO$'' and
                                   c2.type# = 121))))))) ';

 /* Trailing section of unsupported view definition */
 unsup_tab_12_1_b := 
  /* Table has a Temporal Validity column */
' or (bitand(t.property, 4611686018427387904) != 0) 
  or (bitand(t.property, 32) = 32) 
    and exists (select 1 from partobj$ po
                where po.obj#=o.obj#
                and  (po.parttype in (3,             /* System partitioned */
                                      5)))        /* Reference partitioned */
  or (c.type# not in ( 
                  2,                               /* NUMBER */
                  8,                                 /* LONG */
                  12,                                /* DATE */
                  24,                            /* LONG RAW */
                  96,                                /* CHAR */
                  100,                       /* BINARY FLOAT */
                  101,                      /* BINARY DOUBLE */
                  112,                     /* CLOB and NCLOB */
                  113,                               /* BLOB */
                  180,                     /* TIMESTAMP (..) */
                  181,       /* TIMESTAMP(..) WITH TIME ZONE */
                  182,         /* INTERVAL YEAR(..) TO MONTH */
                  183,     /* INTERVAL DAY(..) TO SECOND(..) */
                  231) /* TIMESTAMP(..) WITH LOCAL TIME ZONE */
  and (c.type# != 1
  or  (c.type# = 1 and ' || unsupported_vc || '))             /* 32k varchar */
  and (c.type# != 23                      /* RAW not RAW OID */
  or  (c.type# = 23 and (bitand(c.property, 2) = 2 or ' 
       || unsupported_vc || ')))                              /* 32k varchar */
  and (c.type# != 58                                               /* Opaque */
  or  ' || unsupported_opaque_c || ')
  and (c.type# != 121                                                 /* ADT */
  or  ( '|| unsupported_adt_c ||' or 
       (c.type#=121 and
       /* For non-typed tables, Primary keys on ADT attrs are disallowed.    */
       /* Primary keys should be supported on typed tables.                  */
       (bitand(t.property, 1) = 0
         and exists 
         (select 1 from 
           sys.ccol$ ccol, sys.col$ c2, sys.cdef$ cd
           where c.obj# = c2.obj#
             and c.obj# = cd.obj#
             and c.obj# = ccol.obj#
             and c.col# = c2.col#
             and ccol.con# = cd.con#
             and ccol.intcol# = c2.intcol#
             and bitand(c2.property, 32) = 32    /* Hidden */
             and cd.type# = 2)))))          /* Primary key */
  and (c.type# != 123                                              /* Varray */
  or '||unsupported_varray_c || '))
  ----------------------------------------------------------
  /* table must have at least one scalar column to use as the id key */
  or ((c.type# in (8,24,58,112,113,121,123) or bitand(c.property, 128) = 128)
      and bitand(t.property, 1) = 0                  /* not a typed table or */
      and 0 = (select count(*) from sys.col$ c2
               where t.obj# = c2.obj#
               and bitand(c2.property, 32)  != 32              /* Not hidden */
	       and bitand(c2.property, 8)   != 8              /* Not virtual */
               and bitand(c2.property, 128) != 128      /* not stored in lob */
               and (c2.type# in ( 1,                             /* VARCHAR2 */
                                  2,                               /* NUMBER */
                                  12,                                /* DATE */
                                  23,                                 /* RAW */
                                  96,                                /* CHAR */
                                  100,                       /* BINARY FLOAT */
                                  101,                      /* BINARY DOUBLE */
                                  180,                     /* TIMESTAMP (..) */
                                  181,       /* TIMESTAMP(..) WITH TIME ZONE */
                                  182,         /* INTERVAL YEAR(..) TO MONTH */
                                  183,     /* INTERVAL DAY(..) TO SECOND(..) */
                                  231) /* TIMESTAMP(..) WITH LOCAL TIME ZONE */
      )))
  /* UNSUPPORTED BUILT-IN TYPE List:                                         */
  /* Check list of unsupported datatypes maintained in skip_support.  These  */
  /* could be built-in opaque, ADT or varray types that are singled out as   */
  /* being unsupported.                                                      */
  or ' || unsupp_built_in_type_c || '
  /* Identity column + RNW (Replace null with) column */
  or bitand(c.property, 137438953472 + 274877906944 + 1099511627776) != 0
  ----------------------------------------------------------
  then 0 else 1 end) gensby
  from sys.obj$ o, sys.user$ u, sys.tab$ t, sys.col$ c
  where o.owner# = u.user#
  and o.obj# = t.obj#
  and o.obj# = c.obj#
  and t.obj# = o.obj#
  and bitand(c.property, 32) != 32                         /* Not hidden */';

---------------------------------------------------------------------
-- LOGSTDBY_UNSUPPORT_TAB_12_1
-- This view encapsulates the rules for support of 12.1 redo.
-- This view is sensitive to if a rolling upgrade is in progress.
-- Queue tables are only supported during a rolling upgrade.

unsup_tab_12_1 := 
'create or replace view logstdby_unsupport_tab_12_1 ' 
|| unsup_tab_12_1_a
|| '    /* 0x00020000 table is used as an AQ queue table */
     or (bitand(t.property, 131072) != 0 and 
         sys_context( ''userenv'', ''IS_DG_ROLLING_UPGRADE'' ) = ''FALSE'') '
|| unsup_tab_12_1_b;

 
---------------------------------------------------------------------
-- LOGSTDBY_RU_UNSUPPORT_TAB_12_1
-- This view encapsulates the rules for rolling upgrade support of
-- 12.1 redo. This view is NOT sensitive to if a rolling upgrade is 
-- in progress, rather it shows what is unsupported even in a rolling
-- upgrade.

ru_unsup_tab_12_1 := 
'create or replace view logstdby_ru_unsupport_tab_12_1 ' 
|| unsup_tab_12_1_a
|| unsup_tab_12_1_b;

 
---------------------------------------------------------------------
-- LOGSTDBY_SUPPORT_TAB_12_1
--   Adds support for ADTs, ANYDATA, and non-top-level varrays
--
-- This view encapsulates 12.1.0.0 compatibility support
--   gensby:       1 supported, 
--                 -1 internal so not supported   
--                 0 user data not supported because of features     
--   current_sby:  1 if lsby bit set in tab$ else 0
--

support_tab_12_1 :=
'create or replace view logstdby_support_tab_12_1
as
  select u.name owner, o.name name, o.type#, o.obj#,
         decode(bitand(t.flags, 1073741824), 1073741824, 1, 0) current_sby,
 (case 
    /* The following are tables that are system maintained */
  when ( exists (select 1 from system.logstdby$skip_support s
                 where s.name = u.name and action = 0))
    or bitand(o.flags,
                2                                       /* temporary object */
              + 16                                      /* secondary object */
              + 32                                  /* in-memory temp table */
              + 128                           /* dropped table (RecycleBin) */
             ) != 0
    or bitand(t.flags,
                262144     /* 0x00040000        Summary Container Table, MV */ 
              + 134217728  /* 0x08000000          in-memory temporary table */
              + 536870912  /* 0x20000000  Mapping Tab for Phys rowid of IOT */
             ) != 0
    or bitand(t.property,
                512        /* 0x00000200               iot OVeRflow segment */
              + 8192       /* 0x00002000                       nested table */
              + 4194304    /* 0x00400000             global temporary table */
              + 8388608    /* 0x00800000   session-specific temporary table */
              + 33554432   /* 0x02000000        Read Only Materialized View */
              + 67108864   /* 0x04000000            Materialized View table */
              + 134217728  /* 0x08000000                    Is a Sub object */
              + 2147483648 /* 0x80000000                     eXternal TaBle */
              + 4294967296 /* 0x100000000                              Cube */
              + 8589934592 /* 0x200000000                      FBA Internal */
             ) != 0
    or bitand(t.trigflag,
                536870912  /* 0x20000000                  DDLs autofiltered */
               ) != 0
    or exists (select 1 from sys.mlog$ ml                    /* MVLOG table */
               where ml.mowner = u.name and ml.log = o.name) 
    or exists (select 1 from sys.secobj$ so           /* ODCI storage table */
               where o.obj# = so.secobj#) 
    or exists (select 1 from sys.opqtype$ opq       /* XML OR storage table */
               where o.obj# = opq.obj# 
                 and bitand(opq.flags, 32) = 32) 
    or (bitand(t.property, 131072) != 0 and              /* AQ spill table */
        o.name like ''AQ$\_%\_P'' escape ''\'')
    or (bitand(t.property, 131072) != 0 and           /* AQ commit q table */
        o.name like ''AQ$\_%\_C'' escape ''\'')
  then -1
    /* The following tables are user visible tables that we choose to 
     * skip because of some unsupported attribute of the table or column */
  when (bitand(t.property, 1 ) = 1    /* 0x00000001             typed table */
        AND ((bitand(t.property, 4096) = 4096)                     /* pk oid */
             OR exists                                
              (select 1
               from  sys.col$ c1
               where c1.obj# = t.obj# and
                     (' || unsupported_opaque_c1 || '              /* Opaque */ 
                      or (c1.type# = 114)                           /* BFILE */
                        /* Non-hidden varray or varray stored in table in an */
                        /* ADT typed table.                                  */
                      or (' || unsupported_varray_c1 || ' and
                          (exists
                           (select 1 from sys.col$ c2
                              where c2.obj# = t.obj# and
                                    c2.name = ''SYS_NC_ROWINFO$'' and
                                    c2.type# = 121))) 
                      or ' || unsupp_built_in_type_c1 || '       /* Built-in */
                                      /* Nested table in an ADT typed table  */
                      or (c1.type#=122 and
                       (exists 
                          (select 1 from sys.col$ c2
                             where c2.obj# = t.obj# and
                                   c2.name = ''SYS_NC_ROWINFO$'' and
                                   c2.type# = 121)))))))
    /* Table has a Temporal Validity column */
    or (bitand(t.property, 4611686018427387904) != 0) 
    or (bitand(t.property, 32) = 32)                         /* Partitioned */
      and exists (select 1 from partobj$ po
                  where po.obj#=o.obj#
                  and  (po.parttype in (3,             /* System partitioned */
                                        5)))        /* Reference partitioned */
    or bitand(t.property,
             /* This clause is only for performance; they could be
                excluded by the column datatype checks below. */
              32768        /* 0x00008000                   has FILE columns */
             ) != 0
    /* AQ Queue tables are not supported, unless we are in rolling upgrade */
    or (bitand(t.property, 131072) != 0 and 
        sys_context( ''userenv'', ''IS_DG_ROLLING_UPGRADE'' ) = ''FALSE'')
             -----------------------------------------
             /* unsupp view joins col$, here we subquery it */
    or exists (select 1 from sys.col$ c 
               where t.obj# = c.obj#
               -----------------------------------------
               /*  ignore any hidden columns in this subquery */
               and bitand(c.property, 32) != 32                /* Not hidden */
               -----------------------------------------
               /* table has an unsupported datatype */
               and ((c.type# not in ( 
                                  2,                               /* NUMBER */
                                  8,                                 /* LONG */
                                  12,                                /* DATE */
                                  24,                            /* LONG RAW */
                                  96,                                /* CHAR */
                                  100,                       /* BINARY FLOAT */
                                  101,                      /* BINARY DOUBLE */
                                  112,                     /* CLOB and NCLOB */
                                  113,                               /* BLOB */
                                  180,                     /* TIMESTAMP (..) */
                                  181,       /* TIMESTAMP(..) WITH TIME ZONE */
                                  182,         /* INTERVAL YEAR(..) TO MONTH */
                                  183,     /* INTERVAL DAY(..) TO SECOND(..) */
                                  231) /* TIMESTAMP(..) WITH LOCAL TIME ZONE */
                  and (c.type# != 1
                  or  (c.type# = 1 and ' || unsupported_vc || '))  /* 32k vc */
                  and (c.type# != 23                      /* RAW not RAW OID */
                  or (c.type# = 23 and (bitand(c.property, 2) = 2 or ' ||
                      unsupported_vc || ')))                /* vc/binary 32k */
                  and (c.type# != 58                               /* OPAQUE */
                    or ' || unsupported_opaque_c || ')
                  and (c.type# != 121                                 /* ADT */
                    or ( '|| unsupported_adt_c ||' or
                         (c.type#=121 and
                          /* For non-typed tables, Primary keys on ADT attrs */
                          /* are disallowed.  Pkeys should be supported on   */
                          /* typed tables.                                   */
                          (bitand(t.property, 1 ) = 0 and exists 
                            (select 1 from 
                              sys.ccol$ ccol, sys.col$ c2, sys.cdef$ cd
                              where c.obj# = c2.obj#
                                and c.obj# = cd.obj#
                                and c.obj# = ccol.obj#
                                and c.col# = c2.col#
                                and ccol.con# = cd.con#
                                and ccol.intcol# = c2.intcol#
                                and bitand(c2.property, 32) = 32   /* Hidden */
                                and cd.type# = 2)))))         /* Primary key */
                  and (c.type# != 123                              /* Varray */
                       or ' ||unsupported_varray_c || '))
             -----------------------------------------
             /* table doesnt have at least one scalar column */
             or ((c.type# in (8,24,58,112,113,121,123) 
                  or bitand(c.property, 128) = 128)
             and (bitand(t.property, 1) = 0          /* not a typed table or */
             and 0 = (select count(*) from sys.col$ c2
               where t.obj# = c2.obj#
               and bitand(c2.property, 32)  != 32              /* Not hidden */
               and bitand(c2.property, 8)   != 8              /* Not virtual */
               and bitand(c2.property, 128) != 128      /* not stored in lob */
               and (c2.type# in ( 1,                             /* VARCHAR2 */
                                  2,                               /* NUMBER */
                                  12,                                /* DATE */
                                  23,                                 /* RAW */
                                  96,                                /* CHAR */
                                  100,                       /* BINARY FLOAT */
                                  101,                      /* BINARY DOUBLE */
                                  180,                     /* TIMESTAMP (..) */
                                  181,       /* TIMESTAMP(..) WITH TIME ZONE */
                                  182,         /* INTERVAL YEAR(..) TO MONTH */
                                  183,     /* INTERVAL DAY(..) TO SECOND(..) */
                                  231) /* TIMESTAMP(..) WITH LOCAL TIME ZONE */
                ))))
            /* UNSUPPORTED BUILT-IN TYPE List:                                         */
            /* Check list of unsupported datatypes maintained in                       */
            /* skip_support.  These could be built-in opaque, ADT or varray types      */
            /* that are singled out as being unsupported.                              */
            or ' || unsupp_built_in_type_c || '
            /* Identity column + RNW (Replace null with) column */
            or bitand(c.property, 137438953472 + 274877906944 
                                               + 1099511627776) != 0)
	) /* end col$ exists subquery */
----------------------------------------------
  then 0 else 1 end) gensby
  from sys.obj$ o, sys.user$ u, sys.tab$ t
  where o.owner# = u.user#
  and o.obj# = t.obj#
  and t.obj# = o.obj#';

---------------------------------------------------------------------
-- OGG_SUPPORT_TAB_12_1
-- This view encapsulates 12.1.0.0 compatibility support for OGG
--   gensby:      -1 internal, so not supported
--                   e.g. IOT overflow, nested table storage tab
--                 1 SUPPORT_MODE=FULL supported
--                   includes BFILE(non-ADT), REF/Sys partitioning
--                 0 SUPPORT_MODE=ID KEY (Fetch)
--                   e.g. nested table columns, top-level varray
--                 3 SUPPORT_MODE=NONE, table not supportable by OGG
--                   e.g. AQ queue tables; tables with no usable key; 
--                        ADT with BFILE attr
--
ogg_support_tab_12_1 :=
'create or replace view ogg_support_tab_12_1
as
  select u.name owner, o.name name, o.type#, o.obj#,
 (case 
    /* The following are tables that are system maintained.  
       These are internal, so no SUPPORT_MODE given */
  when ( exists (select 1 from system.logstdby$skip_support s
                 where s.name = u.name and action = 0))
    or bitand(o.flags,
                2                                       /* temporary object */
              + 16                                      /* secondary object */
              + 32                                  /* in-memory temp table */
              + 128                           /* dropped table (RecycleBin) */
             ) != 0
    or bitand(t.flags,
                134217728  /* 0x08000000          in-memory temporary table */
              + 536870912  /* 0x20000000  Mapping Tab for Phys rowid of IOT */
             ) != 0
    or bitand(t.property,
                512        /* 0x00000200               iot OVeRflow segment */
              + 8192       /* 0x00002000                       nested table */
              + 4194304    /* 0x00400000             global temporary table */
              + 8388608    /* 0x00800000   session-specific temporary table */
              + 134217728  /* 0x08000000                    Is a Sub object */
              + 2147483648 /* 0x80000000                     eXternal TaBle */
              + 4294967296 /* 0x100000000                              Cube */
              + 8589934592 /* 0x200000000                      FBA Internal */
             ) != 0
    or bitand(t.trigflag,
                536870912  /* 0x20000000                  DDLs autofiltered */
               ) != 0
    or exists (select 1 from sys.secobj$ so           /* ODCI storage table */
               where o.obj# = so.secobj#) 
    or exists (select 1 from sys.opqtype$ opq       /* XML OR storage table */
               where o.obj# = opq.obj# 
                 and bitand(opq.flags, 32) = 32) 
    or (bitand(t.property, 131072) != 0 and               /* AQ spill table */
        o.name like ''AQ$\_%\_P'' escape ''\'')
    or (bitand(t.property, 131072) != 0 and            /* AQ commit q table */
        o.name like ''AQ$\_%\_C'' escape ''\'')
  then -1
  ----------------------------------------------
  /* SUPPORT_MODE "NONE" */
  when exists (
    select 1 from sys.col$ c 
             where t.obj# = c.obj#
       /* Table has a 32k column with a unique idx/constraint on it */
       and ((c.type# in (1, 23) and ' || unsupported_vc || ')
             /* ADT typed table with BFILE attribute */
             or (bitand(t.property, 1) = 1 and
                 c.type# = 114 /* BFILE */ and
                 exists(select 1 
                        from sys.col$ c1
                        where c1.obj# = t.obj# and
                              c1.name = ''SYS_NC_ROWINFO$'' and
                              c1.type# = 121))
             /* Relational table with ADT column having BFILE attribute */
             or (bitand(t.property, 1) = 0 and 
                 c.type# = 114 /* BFILE */ and
                 bitand(c.property, 32)=32 /* hidden */ and
                 exists (select 1 
                         from sys.col$ c1 
                         where c1.obj# = t.obj# and
                               c1.col# = c.col# and
                               bitand(c1.property, 32) = 0 /* not hidden */ and
                               c1.type# = 121))
             /* Any table (relational or typed) that has an unsupported */
             /* built-in ADT */
             or ' || sm_none_built_in_type_c || '
             /* table doesnt have at least one scalar column */
             or  ((c.type# in (8,24,58,112,113,114,115,121,123) 
                  or bitand(c.property, 128) = 128)
             and (bitand(t.property, 1) = 0          /* not a typed table or */
             and 0 = (select count(*) from sys.col$ c2
               where t.obj# = c2.obj#
               and bitand(c2.property, 32)  != 32              /* Not hidden */
               and bitand(c2.property, 8)   != 8              /* Not virtual */
               and bitand(c2.property, 128) != 128      /* not stored in lob */
               and (c2.type# in ( 1,                             /* VARCHAR2 */
                                  2,                               /* NUMBER */
                                  12,                                /* DATE */
                                  23,                                 /* RAW */
                                  96,                                /* CHAR */
                                  100,                       /* BINARY FLOAT */
                                  101,                      /* BINARY DOUBLE */
                                  180,                     /* TIMESTAMP (..) */
                                  181,       /* TIMESTAMP(..) WITH TIME ZONE */
                                  182,         /* INTERVAL YEAR(..) TO MONTH */
                                  183,     /* INTERVAL DAY(..) TO SECOND(..) */
                                  208,                             /* UROWID */
                                  231) /* TIMESTAMP(..) WITH LOCAL TIME ZONE */
                ))))))
    or bitand(t.property, 131072) != 0                    /* AQ queue tables */
  then 3
  --------------------------------------
  /* SUPPORT_MODE "ID KEY" */
  when (bitand(t.property, 1 ) = 1    /* 0x00000001             typed table */
        AND ((bitand(t.property, 4096) = 4096)                    /* pk oid */
             OR exists                                
              (select 1
               from  sys.col$ c1
               where c1.obj# = t.obj# and
                     (' || unsupported_opaque_c1 || '              /* Opaque */ 
                      or (c1.type# = 114)                           /* BFILE */
                        /* Non-hidden varray or varray stored in table in an */
                        /* ADT typed table.                                  */
                      or (' || unsupported_varray_c1 || ' and
                          (exists
                           (select 1 from sys.col$ c2
                              where c2.obj# = t.obj# and
                                    c2.name = ''SYS_NC_ROWINFO$'' and
                                    c2.type# = 121))) 
                      or ' || unsupp_built_in_type_c1 || '       /* Built-in */
                                      /* Nested table in an ADT typed table  */
                      or (c1.type#=122 and
                       (exists 
                          (select 1 from sys.col$ c2
                             where c2.obj# = t.obj# and
                                   c2.name = ''SYS_NC_ROWINFO$'' and
                                   c2.type# = 121)))))))
    /* Table has a Temporal Validity column */
    or (bitand(t.property, 4611686018427387904) != 0) 
             -----------------------------------------
             /* unsupp view joins col$, here we subquery it */
    or exists (select 1 from sys.col$ c 
               where t.obj# = c.obj#
               -----------------------------------------
               /*  ignore any hidden columns in this subquery */
               and bitand(c.property, 32) != 32                /* Not hidden */
               -----------------------------------------
               /* table has an unsupported datatype */
               and ((c.type# not in ( 
                                  1,                             /* VARCHAR2 */
                                  2,                               /* NUMBER */
                                  8,                                 /* LONG */
                                  12,                                /* DATE */
                                  24,                            /* LONG RAW */
                                  96,                                /* CHAR */
                                  100,                       /* BINARY FLOAT */
                                  101,                      /* BINARY DOUBLE */
                                  112,                     /* CLOB and NCLOB */
                                  113,                               /* BLOB */
                                  114,                              /* BFILE */
                                  115,                              /* CFILE */
                                  180,                     /* TIMESTAMP (..) */
                                  181,       /* TIMESTAMP(..) WITH TIME ZONE */
                                  182,         /* INTERVAL YEAR(..) TO MONTH */
                                  183,     /* INTERVAL DAY(..) TO SECOND(..) */
                                  208,                             /* UROWID */
                                  231) /* TIMESTAMP(..) WITH LOCAL TIME ZONE */
                  and (c.type# != 23                      /* RAW not RAW OID */
                  or (c.type# = 23 and bitand(c.property, 2) = 2))
                  and (c.type# != 58                               /* OPAQUE */
                    or ' || unsupported_opaque_c || ')
                  and (c.type# != 121                                 /* ADT */
                    or ( '|| unsupported_adt_ogg_c ||' or
                         (c.type#=121 and
                          /* For non-typed tables, Primary keys on ADT attrs */
                          /* are disallowed.  Pkeys should be supported on   */
                          /* typed tables.                                   */
                          (bitand(t.property, 1 ) = 0 and exists 
                            (select 1 from 
                              sys.ccol$ ccol, sys.col$ c2, sys.cdef$ cd
                              where c.obj# = c2.obj#
                                and c.obj# = cd.obj#
                                and c.obj# = ccol.obj#
                                and c.col# = c2.col#
                                and ccol.con# = cd.con#
                                and ccol.intcol# = c2.intcol#
                                and bitand(c2.property, 32) = 32   /* Hidden */
                                and cd.type# = 2)))))         /* Primary key */
                  and (c.type# != 123                              /* Varray */
                       or ' ||unsupported_varray_c || '))
                 /* Identity column + RNW (Replace null with) column */
                 or bitand(c.property, 137438953472 + 274877906944 
                                                  + 1099511627776) != 0
                 /* UNSUPPORTED BUILT-IN TYPE List:                          */
                 /* Check list of unsupported datatypes maintained in        */
                 /* skip_support.  These could be built-in opaque, ADT or    */
                 /* varray types that are singled out as being unsupported.  */
                 or ' || unsupp_built_in_type_c || '))
  then 0
  ----------------------------------------------
  /* SUPPORT_MODE "FULL" */
  else 1 end) gensby
  from sys.obj$ o, sys.user$ u, sys.tab$ t
  where o.owner# = u.user#
  and o.obj# = t.obj#';

execute immediate unsup_tab_12_1;
execute immediate ru_unsup_tab_12_1;
execute immediate support_tab_12_1;
execute immediate ogg_support_tab_12_1;
end;
/

/* 12.2 SUPPORTED/UNSUPPORTED VIEW DEFINITIONS */
DECLARE
  unsup_tab_12_2           varchar2(32000);
  ru_unsup_tab_12_2        varchar2(32000);
  support_tab_12_2         varchar2(32000);
  ogg_support_tab_12_2     varchar2(32000);

  /* UNSUPPORTED VARRAY is a:
   *  - varray stored as table (= varray with Nested Table bit set) 
   *  - A non-hidden varray column (except during rolling upgrade)
   * 
   * RETURNS:
   *   TRUE for an unsupported column (or ID KEY for OGG)
   *   FALSE for a supported column   (or FULL for OGG)
   */
  FUNCTION varray_check(view_type VARCHAR2, alias VARCHAR2)
  RETURN VARCHAR2 IS
    unsupported_varray    varchar2(1000);
  BEGIN

    if (view_type = 'unsupported' or view_type = 'supported') THEN
      unsupported_varray := 
      '(c.type# = 123 and 
        (bitand(c.property, 4) = 4 or 
          (bitand(c.property, 32)!=32 
           and sys_context( ''userenv'', ''IS_DG_ROLLING_UPGRADE'' ) 
               = ''FALSE'')))';
    else  /* view_type = 'ru_unsupported' or 'ogg'*/
      unsupported_varray :=  '(c.type# = 123 and bitand(c.property, 4) = 4)';
    end if;

    if (alias is not null and alias != 'c') THEN
      unsupported_varray := replace(unsupported_varray, 'c.', alias || '.');
    end if;
    return unsupported_varray;
  END varray_check;

  /* UNSUPPORTED REF 
   *   - refs are unsupported, unless this is rolling upgrade
   *     Only non-virtual REFs are supportable.
   *     Examples of virtual REF columns are PK-REFs and referential 
   *     integrity constraints.
   * RETURNS:
   *   TRUE for an unsupported column (or ID KEY for OGG)
   *   FALSE for a supported column   (or FULL for OGG)
   */
  FUNCTION ref_check(view_type VARCHAR2, alias VARCHAR2)
  RETURN VARCHAR2 IS
    unsupported_ref    varchar2(1000);
  BEGIN
    if (view_type = 'unsupported' or view_type = 'supported') THEN
      unsupported_ref := 
      '(c.type# = 111 and 
         (bitand(c.property, 8) = 8
          or sys_context( ''userenv'', ''IS_DG_ROLLING_UPGRADE'' )
             = ''FALSE''))';
    else  /* view_type = 'ru_unsupported' || 'ogg' */
      -- REFs are only supported in rolling upgrade when they are not virtual
      unsupported_ref :=  
       '(c.type# = 111 and bitand(c.property, 8) = 8)';
    end if;

    if (alias is not null and alias != 'c') THEN
      unsupported_ref := replace(unsupported_ref, 'c.', alias || '.');
    end if;
    return unsupported_ref;
  END ref_check;

  /* UNSUPPORTED OPAQUE types include:
   * - XMLType columns that are hierarchy enabled (except during rolling upgrd)
   * - Any opaque column which is not a SYS.XMLType or a SYS.ANYDATA type.
   * RETURNS:
   *   TRUE for an unsupported column (or ID KEY for OGG)
   *   FALSE for a supported column   (or FULL for OGG)
   */
  FUNCTION opaque_check(view_type VARCHAR2, alias VARCHAR2)
  RETURN VARCHAR2 IS
    unsupported_opaque varchar2(1000);
    opaque_preamble    varchar2(100);
    opaque_hierarchy   varchar2(1000);
    opaque_others      varchar2(1000);
  BEGIN 
    opaque_preamble :=
    '(c.type# = 58 and (';
    opaque_hierarchy := 
    ' (exists (select 1 from opqtype$ opq
                where opq.type=1 
                  and bitand(opq.flags,512) = 512      /* hierarchy enabled */
                  and opq.obj#=c.obj# 
                  and opq.intcol#=c.intcol#) 
      and sys_context( ''userenv'', ''IS_DG_ROLLING_UPGRADE'' ) = ''FALSE'') ';
    opaque_others := 
    ' exists (select 1 from coltype$ ct
                    where ct.obj#=c.obj#
                    and   ct.intcol# = c.intcol#
                    and /* SYS.XMLTYPE */ 
                    ct.toid != ''00000000000000000000000000020100''
                    and /* SYS.ANYDATA */
                    ct.toid != ''00000000000000000000000000020011''))) ';


    if (view_type = 'unsupported' or view_type = 'supported') THEN
      -- [UN]SUPPORTED views need to check if rolling upgrade is in progress
      unsupported_opaque := 
        opaque_preamble || opaque_hierarchy || ' or ' || opaque_others;

    else /* view_type = 'ru_unsupported' or 'ogg' */
      -- RU_UNSUPPORTED view reports as if rolling upgrade IS in progress
      unsupported_opaque := 
        opaque_preamble || opaque_others;
    end if;

    if (alias is not null and alias != 'c') THEN
      unsupported_opaque := replace(unsupported_opaque, 'c.', alias || '.');
    end if;

    return unsupported_opaque;
  end opaque_check;

 /* UNSUPPORTED BUILT-IN type:
  * Check list of unsupported datatypes maintained in
  * skip_support.  These could be built-in opaque, ADT or varray
  * types that are singled out as being unsupported.
  *
  * RETURNS:
  *   TRUE for an unsupported column
  *   FALSE for a supported column
  *
  * NOTE:  Action=-11 indicates that a type is unsupported in all 
  *  12.% support views (12.1, 12.2, and 12.2.0.2).
  *  Action=-5 indicates that a type is unsupported in only the
  *  12.1 support views, and so it is not checked here.
  */
  FUNCTION built_in_check(view_type VARCHAR2, alias VARCHAR2)
  RETURN VARCHAR2 IS
    unsupp_built_in_type VARCHAR2(4000);
  BEGIN
    unsupp_built_in_type :=
   '(c.type# in (58, 121, 123) and
     (exists 
      (select 1 from obj$ o3, coltype$ ct3, user$ u3
       where u3.user# = o3.owner#
         and c.obj# = ct3.obj#
         and c.intcol# = ct3.intcol#
         and ct3.toid = o3.oid$  
         and exists (select 1 from system.logstdby$skip_support sk
                      where sk.action=-11
                        and sk.name = u3.name   /* type owner */
                        and sk.name2 = o3.name  /* type name  */))))';

    if (alias is not null and alias != 'c') THEN
      unsupp_built_in_type := replace(unsupp_built_in_type, 'c.', alias || '.');
    end if;

    return unsupp_built_in_type;
  END built_in_check;

  /* UNSUPPORTED ADT ATTRIBUTE check:
   * In a subquery, we check for any unsupported (Lsby/Rolling), or 
   * ID KEY (OGG) datatypes in the attributes of this ADT.  These are: 
   * Nested Tables, or any opaque, varray, or built-in datatypes failing 
   * the above checks.  For Lsby/Rolling, BFILE columns are unsupported.
   * For OGG, BFILE columns are supported FULL (unless in an ADT).
   * Note that the sys.col$ subquery is necessary so that we don't return any 
   * hidden columns from the unsupported query.  When an ADT attribute is
   * unsupported, the parent (non-hidden) ADT column should be identified as
   * the culprit.             
   *
   * RETURNS:
   *   TRUE for an unsupported column (or ID KEY for OGG)
   *   FALSE for a supported column   (or FULL for OGG)
   */
  FUNCTION adt_check(view_type VARCHAR2, alias VARCHAR2)
  RETURN VARCHAR2 IS
    unsupp_adt VARCHAR2(4000);
    bfile_unsupport VARCHAR2(100);
  BEGIN

    IF (view_type = 'ogg') THEN
      bfile_unsupport := ' ';
    ELSE
      bfile_unsupport := ' c2.type# = 114  or ';
    END IF;

    unsupp_adt :=
      '(c.type#=121 and
       (exists
         (select 1 from sys.col$ c2  
           where t.obj# = c2.obj#
             and c.col# = c2.col#
             and (c2.type# = 122         or                  /* Nested Table */
                 ' || bfile_unsupport || '                          /* BFILE */
                 ' || varray_check(view_type, 'c2') || ' or        /* Varray */
                 ' || opaque_check(view_type, 'c2') || ' or        /* Opaque */
                 ' || ref_check(view_type, 'c2');                     /* REF */

    -- For the Lsby/RU views, we do the built-in type check here.
    -- For the OGG views, the built-in check is done in the support_mode NONE
    -- section.
    if (view_type != 'ogg') THEN                           /* Built-in types */
      unsupp_adt := unsupp_adt || ' or ' || built_in_check(view_type, 'c2'); 
    END IF;

    unsupp_adt := unsupp_adt || '))))';

    if (alias is not null and alias != 'c') THEN
      unsupp_adt := replace(unsupp_adt, 'c.', alias || '.');
    end if;

    return unsupp_adt;
  END adt_check;

  /* Sharded Queue Table check:
   * Sharded Queue Tables (SQTs) should be INTERNAL for Rolling Upgrade, and
   * unsupported otherwise.  The feature is supported for Rolling Upgrade via
   * PL/SQL replication, and any activity on these tables should be skipped
   * as INTERNAL.  Outside of Rolling Upgrade, the feature is unsupported
   * for Logical Standby, and support_mode NONE for OGG.
   * RETURNS:
   *   A statement that evaluates to TRUE for a table that is an SQT
   *   A statement that evaluates to FALSE for a table that is not an SQT
   */
  FUNCTION sharded_queue_check(view_type VARCHAR2)
  RETURN VARCHAR2 IS
    sqt_stmt  VARCHAR2(1000);
  BEGIN

    IF (view_type = 'unsupported' or view_type = 'supported') THEN
      sqt_stmt :=
        ' (bitand(t.property, power(2,73)) != 0 and
           sys_context( ''userenv'', ''IS_DG_ROLLING_UPGRADE'' ) = ''TRUE'') ';
           
    ELSE
      sqt_stmt := 
        ' (bitand(t.property, power(2,73)) != 0) ';
    END IF;

    return sqt_stmt;
  END sharded_queue_check;

  /* UNSUPPORTED AQ QUEUE TABLE check:
   * AQ queue tables are supported during rolling upgrade, or by OGG with 
   * procedural supplemental logging.
   *
   * For the LSBY supported and unsupported views, we need to check whether 
   * we're in rolling upgrade before making the support decision.  
   * For the rolling upgrade view, we assume that we're in rolling upgrade, 
   * so AQ queue tables are supported.
   * For the OGG support_mode view, AQ queue tables are supported via 
   * procedural replication, so this routine returns TRUE, so they can be
   * properly identified as PLSQL support mode later in the view definition.
   */
  FUNCTION aq_queue_check(view_type VARCHAR2)
  RETURN VARCHAR2 IS
    aq_queue_stmt VARCHAR2(1000);
  BEGIN
    IF (view_type = 'unsupported' or view_type = 'supported') THEN
      aq_queue_stmt := 
        ' /* 0x00020000 table is used as an AQ queue table */
          or (bitand(t.property, 131072) != 0 and 
           sys_context( ''userenv'', ''IS_DG_ROLLING_UPGRADE'' ) = ''FALSE'') ';
    ELSE
      -- AQ Queue tables are always supported under Rolling upgrade
      aq_queue_stmt := '';
    END IF;

    return aq_queue_stmt;
  END aq_queue_check;

  /* UNSUPPORTED LONG IDENTIFIER check:
   * Long identifiers (identifiers with a byte-length of more than 30),
   * are supported by rolling upgrade, but not by Logical Standby.
   * We make an exception for system-generated long identifiers - in the
   * event that an internally generated column name exceeds 30 bytes, 
   * the table shouldn't be considered unsupported by Lsby.  Note that
   * this check isn't used for OGG, since long identifiers are always
   * fully supported there.
   *
   * RETURNS:
   *   TRUE for an unsupported column
   *   FALSE for a supported column
   */
  FUNCTION long_iden_check(view_type VARCHAR2, alias VARCHAR2)
  RETURN VARCHAR2 IS
    liden_stmt VARCHAR2(500);
  BEGIN
    IF (view_type = 'unsupported' or view_type = 'supported') THEN
      liden_stmt :=
        ' or ((lengthb(o.name) > 30 or lengthb(u.name) > 30 or
               (lengthb(c.name) > 30 and 
                bitand(c.property, 256 /* System-generated */) = 0)) and 
              sys_context( ''userenv'', ''IS_DG_ROLLING_UPGRADE'' ) = ''FALSE'') ';
    ELSE
      liden_stmt := '';
    END IF;

    if (alias is not null and alias != 'c') THEN
      liden_stmt := replace(liden_stmt, 'c.', alias || '.');
    end if;

    return liden_stmt;
  END long_iden_check;

  /* UNSUPPORTED 32k column
   *  - a long varchar (>4k) having a unique index or constraint defined on it
   *    is unsupported.  
   * 
   * RETURNS:
   *   TRUE for an unsupported column (support_mode NONE for OGG)
   *   FALSE for a supported column   (support_mode FULL for OGG)
   */
  FUNCTION vc32k_check(view_type VARCHAR2, alias VARCHAR2)
  RETURN VARCHAR2 IS
    unsupported_vc    varchar2(1000);
  BEGIN

    unsupported_vc := 
     '(bitand(c.property, 128) = 128                 /* column stored in LOB */
       and c.length between 4001 and 6398
       and (exists                                  /* Unique index on vc32k */
            (select null
             from ind$ i, icol$ ic
             where i.bo# = t.obj#
               and ic.obj# = i.obj#
               and c.intcol# = ic.intcol#
               and bitand(i.property, 1) = 1                       /* Unique */
            )
           or exists                  /* Primary or unique constraint on 32k */
            (select null
             from cdef$ cd, ccol$ ccol 
             where cd.obj# = t.obj#
               and cd.obj# = ccol.obj#
               and cd.con# = ccol.con#
               and cd.type# in (2,3)
               and ccol.intcol# = c.intcol#
            )))';

    if (alias is not null and alias != 'c') THEN
      unsupported_vc := replace(unsupported_vc, 'c.', alias || '.');
    end if;
    return unsupported_vc;
  END vc32k_check;

  FUNCTION view_gen_12_2(view_type VARCHAR2)
  RETURN VARCHAR2 IS
    view_stmt_12_2 VARCHAR2(32000);
  BEGIN

    ---------------------------------------------------------------------
    -- LOGSTDBY_UNSUPPORT_TAB_12_2 / LOGSTDBY_RU_UNSUPPORT_TAB_12_2
    --   Adds support for top-level varrays, HETs (rolling upgrade only)
    --   and REFs
    --
    -- This view encapsulates 12.2.0.0 compatibility support
    --   gensby:       1 supported, 
    --                 -1 internal so not supported   
    --                 0 user data not supported because of features     
    --   current_sby:  1 if lsby bit set in tab$ else 0
    --
    IF (view_type = 'unsupported' or view_type = 'ru_unsupported') THEN

      view_stmt_12_2 := 
  'as
  select u.name owner, o.name table_name, c.name column_name, 
         c.scale, c.precision#, c.charsetform, c.type#,
   (case when bitand(t.flags, 536870912) = 536870912
         then ''Mapping table for physical rowid of IOT''
         else null end) attributes,
    (case 
    /* The following are tables that are system maintained */
    when bitand(o.flags,
                2                                       /* temporary object */
              + 16                                      /* secondary object */
              + 32                                  /* in-memory temp table */
              + 128                           /* dropped table (RecycleBin) */
             ) != 0
    or bitand(t.flags,
                262144     /* 0x00040000        Summary Container Table, MV */ 
              + 134217728  /* 0x08000000          in-memory temporary table */
              + 536870912  /* 0x20000000  Mapping Tab for Phys rowid of IOT */
             ) != 0
    or bitand(t.property,
                512        /* 0x00000200               iot OVeRflow segment */
              + 8192       /* 0x00002000                       nested table */
              + 4194304    /* 0x00400000             global temporary table */
              + 8388608    /* 0x00800000   session-specific temporary table */
              + 33554432   /* 0x02000000        Read Only Materialized View */
              + 67108864   /* 0x04000000            Materialized View table */
              + 134217728  /* 0x08000000                    Is a Sub object */
              + 2147483648 /* 0x80000000                     eXternal TaBle */
              + 4294967296 /* 0x100000000                              Cube */
              + 8589934592 /* 0x200000000                      FBA Internal */
              + (2*4294967296*4294967296) /* PF3 0x00000002    XML TokenSet */
             ) != 0
    or bitand(t.trigflag,
                536870912  /* 0x20000000                  DDLs autofiltered */
               ) != 0
    or exists                                                /* MVLOG table */
       (select 1 
        from sys.mlog$ ml where ml.mowner = u.name and ml.log = o.name) 
    or exists (select 1 from sys.secobj$ so           /* ODCI storage table */
               where o.obj# = so.secobj#) 
    or exists (select 1 from sys.opqtype$ opq       /* XML OR storage table */
               where o.obj# = opq.obj# 
                 and bitand(opq.flags, 32) = 32) 
    or (bitand(t.property, 131072) != 0 and               /* AQ spill table */
        o.name like ''AQ$\_%\_P'' escape ''\'')
    or (bitand(t.property, 131072) != 0 and            /* AQ commit q table */
        o.name like ''AQ$\_%\_C'' escape ''\'')
    or ' || sharded_queue_check(view_type) || '      /* Sharded queue table */
  then -1
    /* The following tables are data tables in internal schemata *
     * that are not secondary objects                            */
  when (exists (select 1 from system.logstdby$skip_support s
                where s.name = u.name and action = 0))
  then -2
    /* The following tables are user visible tables that we choose to       *
     * skip because of some unsupported attribute of the table or column    */
  when (bitand(t.property, 1) = 1       /* 0x00000001            typed table */
    AND((bitand(t.property, 4096) = 4096) /* PK OID */
        OR exists                                
            (select 1
              from  sys.col$ c1
              where c1.obj# = t.obj# and
                    (' || opaque_check(view_type, 'c1') ||         /* Opaque */
                          long_iden_check(view_type, 'c1') || ' /* Long iden */
                     or (c1.type# = 114)                            /* BFILE */
                     /* Identify ADT typed tables containing unsupported:    */
                     /* Varray, REF, or nested table types.                  */
                     or ((exists
                          (select 1 from sys.col$ c2
                             where c2.obj# = t.obj# and
                                   c2.name = ''SYS_NC_ROWINFO$'' and
                                   c2.type# = 121)) and
                         (c1.type#=122 or ' ||    /* Nested Table */
                          varray_check(view_type, 'c1') || ' or ' ||
                          ref_check(view_type, 'c1') || ' or ' ||
                          built_in_check(view_type, 'c1') || ')))))) '
  || aq_queue_check(view_type) ||
' /* Table has a Temporal Validity column */
  or (bitand(t.property, 4611686018427387904) != 0) 
  or (bitand(t.property, 32) = 32) 
    and exists (select 1 from partobj$ po
                where po.obj#=o.obj#
                and  (po.parttype in (3,             /* System partitioned */
                                      5)))        /* Reference partitioned */
  or (c.type# not in ( 
                  2,                               /* NUMBER */
                  8,                                 /* LONG */
                  12,                                /* DATE */
                  24,                            /* LONG RAW */
                  96,                                /* CHAR */
                  100,                       /* BINARY FLOAT */
                  101,                      /* BINARY DOUBLE */
                  112,                     /* CLOB and NCLOB */
                  113,                               /* BLOB */
                  180,                     /* TIMESTAMP (..) */
                  181,       /* TIMESTAMP(..) WITH TIME ZONE */
                  182,         /* INTERVAL YEAR(..) TO MONTH */
                  183,     /* INTERVAL DAY(..) TO SECOND(..) */
                  231) /* TIMESTAMP(..) WITH LOCAL TIME ZONE */
  and (c.type# != 1
  or  (c.type# = 1 and ' || vc32k_check(view_type, 'c') || '))     /* 32k vc */
  and (c.type# != 23
  or  (c.type# = 23 and (bitand(c.property, 2) = 2 or '   /* RAW not RAW OID */
        || vc32k_check(view_type, 'c') || ')))                     /* 32k vc */
  and (c.type# != 58                                               /* Opaque */
  or  ' || opaque_check(view_type, 'c') || ')
  and (c.type# != 111                                        /* Internal REF */ 
  or  ' || ref_check(view_type, 'c') || ')
  and (c.type# != 121                                                 /* ADT */
  or  ( '|| adt_check(view_type, 'c') ||' or 
       (c.type#=121 and
       /* For non-typed tables, Primary keys on ADT attrs are disallowed.    */
       /* Primary keys should be supported on typed tables.                  */
       (bitand(t.property, 1) = 0
         and exists 
         (select 1 from 
           sys.ccol$ ccol, sys.col$ c2, sys.cdef$ cd
           where c.obj# = c2.obj#
             and c.obj# = cd.obj#
             and c.obj# = ccol.obj#
             and c.col# = c2.col#
             and ccol.con# = cd.con#
             and ccol.intcol# = c2.intcol#
             and bitand(c2.property, 32) = 32    /* Hidden */
             and cd.type# = 2)))))          /* Primary key */
  and (c.type# != 123                                              /* Varray */
  or '|| varray_check(view_type, 'c') || '))
  ----------------------------------------------------------
  /* table must have at least one scalar column to use as the id key */
  or ((c.type# in (8,24,58,112,113,121,123) or bitand(c.property, 128) = 128)
      and bitand(t.property, 1) = 0                  /* not a typed table or */
      and 0 = (select count(*) from sys.col$ c2
               where t.obj# = c2.obj#
               and bitand(c2.property, 32)  != 32              /* Not hidden */
	       and bitand(c2.property, 8)   != 8              /* Not virtual */
               and bitand(c2.property, 128) != 128      /* not stored in lob */
               and (c2.type# in ( 1,                             /* VARCHAR2 */
                                  2,                               /* NUMBER */
                                  12,                                /* DATE */
                                  23,                                 /* RAW */
                                  96,                                /* CHAR */
                                  100,                       /* BINARY FLOAT */
                                  101,                      /* BINARY DOUBLE */
                                  180,                     /* TIMESTAMP (..) */
                                  181,       /* TIMESTAMP(..) WITH TIME ZONE */
                                  182,         /* INTERVAL YEAR(..) TO MONTH */
                                  183,     /* INTERVAL DAY(..) TO SECOND(..) */
                                  231) /* TIMESTAMP(..) WITH LOCAL TIME ZONE */
      )))
  /* Identity column + RNW (Replace null with) column */
  or bitand(c.property, 137438953472 + 274877906944 + 1099511627776) != 0
   ' || long_iden_check(view_type, 'c') || ' 
  ----------------------------------------------------------
  then 0 else 1 end) gensby
  from sys.obj$ o, sys.user$ u, sys.tab$ t, sys.col$ c
  where o.owner# = u.user#
  and o.obj# = t.obj#
  and o.obj# = c.obj#
  and t.obj# = o.obj#
  and bitand(c.property, 32) != 32                         /* Not hidden */';

    ---------------------------------------------------------------------
    -- LOGSTDBY_SUPPORT_TAB_12_2
    --   Adds support for top-level varrays, HETs (rolling upgrade only)
    --   and REFs
    --
    -- This view encapsulates 12.2.0.0 compatibility support
    --   gensby:       1 supported, 
    --                 -1 internal so not supported   
    --                 0 user data not supported because of features     
    --   current_sby:  1 if lsby bit set in tab$ else 0
    --
    ELSIF  (view_type = 'supported') THEN
      view_stmt_12_2 :=
'as
  select u.name owner, o.name name, o.type#, o.obj#,
         decode(bitand(t.flags, 1073741824), 1073741824, 1, 0) current_sby,
 (case 
    /* The following are tables that are system maintained */
  when ( exists (select 1 from system.logstdby$skip_support s
                 where s.name = u.name and action = 0))
    or bitand(o.flags,
                2                                       /* temporary object */
              + 16                                      /* secondary object */
              + 32                                  /* in-memory temp table */
              + 128                           /* dropped table (RecycleBin) */
             ) != 0
    or bitand(t.flags,
                262144     /* 0x00040000        Summary Container Table, MV */ 
              + 134217728  /* 0x08000000          in-memory temporary table */
              + 536870912  /* 0x20000000  Mapping Tab for Phys rowid of IOT */
             ) != 0
    or bitand(t.property,
                512        /* 0x00000200               iot OVeRflow segment */
              + 8192       /* 0x00002000                       nested table */
              + 4194304    /* 0x00400000             global temporary table */
              + 8388608    /* 0x00800000   session-specific temporary table */
              + 33554432   /* 0x02000000        Read Only Materialized View */
              + 67108864   /* 0x04000000            Materialized View table */
              + 134217728  /* 0x08000000                    Is a Sub object */
              + 2147483648 /* 0x80000000                     eXternal TaBle */
              + 4294967296 /* 0x100000000                              Cube */
              + 8589934592 /* 0x200000000                      FBA Internal */
              + (2*4294967296*4294967296) /* PF3 0x00000002    XML TokenSet */
             ) != 0
    or bitand(t.trigflag,
                536870912  /* 0x20000000                  DDLs autofiltered */
               ) != 0
    or exists (select 1 from sys.mlog$ ml                    /* MVLOG table */
               where ml.mowner = u.name and ml.log = o.name) 
    or exists (select 1 from sys.secobj$ so           /* ODCI storage table */
               where o.obj# = so.secobj#) 
    or exists (select 1 from sys.opqtype$ opq       /* XML OR storage table */
               where o.obj# = opq.obj# 
                 and bitand(opq.flags, 32) = 32) 
    or (bitand(t.property, 131072) != 0 and               /* AQ spill table */
        o.name like ''AQ$\_%\_P'' escape ''\'')
    or (bitand(t.property, 131072) != 0 and            /* AQ commit q table */
        o.name like ''AQ$\_%\_C'' escape ''\'')
    or ' || sharded_queue_check(view_type) || '      /* Sharded queue table */
  then -1
    /* The following tables are user visible tables that we choose to 
     * skip because of some unsupported attribute of the table or column */
  when (bitand(t.property, 1 ) = 1    /* 0x00000001             typed table */
        AND ((bitand(t.property, 4096) = 4096)                     /* pk oid */
             OR exists                                
              (select 1
               from  sys.col$ c1
               where c1.obj# = t.obj# and
                     (' || opaque_check('supported', 'c1') ||      /* Opaque */ 
                          long_iden_check(view_type, 'c1') || ' /* Long iden */
                      or (c1.type# = 114)                           /* BFILE */
                     /* Identify ADT typed tables containing unsupported:    */
                     /* Varray, REF, or nested table types.                  */
                      or ((exists
                           (select 1 from sys.col$ c2
                             where c2.obj# = t.obj# and
                                   c2.name = ''SYS_NC_ROWINFO$'' and
                                   c2.type# = 121)) and
                          (c1.type#=122 or ' ||    /* Nested Table */
                           varray_check(view_type, 'c1') || ' or ' ||
                           ref_check(view_type, 'c1') || ' or ' ||
                           built_in_check(view_type, 'c1') || '))))))
    /* Table has a Temporal Validity column */
    or (bitand(t.property, 4611686018427387904) != 0) 
    or (bitand(t.property, 32) = 32)                         /* Partitioned */
      and exists (select 1 from partobj$ po
                  where po.obj#=o.obj#
                  and  (po.parttype in (3,             /* System partitioned */
                                        5)))        /* Reference partitioned */
    or bitand(t.property,
             /* This clause is only for performance; they could be
                excluded by the column datatype checks below. */
              32768        /* 0x00008000                   has FILE columns */
             ) != 0 ' || aq_queue_check('supported') || '
             -----------------------------------------
             /* unsupp view joins col$, here we subquery it */
    or exists (select 1 from sys.col$ c 
               where t.obj# = c.obj#
             -----------------------------------------
             /*  ignore any hidden columns in this subquery */
               and bitand(c.property, 32) != 32                /* Not hidden */
             -----------------------------------------
             /* table has an unsupported datatype */
               and ((c.type# not in ( 
                                  2,                               /* NUMBER */
                                  8,                                 /* LONG */
                                  12,                                /* DATE */
                                  24,                            /* LONG RAW */
                                  96,                                /* CHAR */
                                  100,                       /* BINARY FLOAT */
                                  101,                      /* BINARY DOUBLE */
                                  112,                     /* CLOB and NCLOB */
                                  113,                               /* BLOB */
                                  180,                     /* TIMESTAMP (..) */
                                  181,       /* TIMESTAMP(..) WITH TIME ZONE */
                                  182,         /* INTERVAL YEAR(..) TO MONTH */
                                  183,     /* INTERVAL DAY(..) TO SECOND(..) */
                                  231) /* TIMESTAMP(..) WITH LOCAL TIME ZONE */
                  and (c.type# != 1
                  or  (c.type# = 1 and ' 
                       || vc32k_check(view_type, 'c') || '))       /* 32k vc */
                  and (c.type# != 23                      /* RAW not RAW OID */
                  or (c.type# = 23 and (bitand(c.property, 2) = 2 or '
                      || vc32k_check(view_type, 'c') || ')))       /* 32k vc */
                  and (c.type# != 58                               /* OPAQUE */
                    or ' || opaque_check('supported', 'c') || ')
                  and (c.type# != 111                        /* Internal REF */
                    or  ' || ref_check('supported', 'c') || ')
                  and (c.type# != 121                                 /* ADT */
                    or ( '|| adt_check('supported', 'c') ||' or
                         (c.type#=121 and
                          /* For non-typed tables, Primary keys on ADT attrs */
                          /* are disallowed.  Pkeys should be supported on   */
                          /* typed tables.                                   */
                          (bitand(t.property, 1 ) = 0 and exists 
                            (select 1 from 
                              sys.ccol$ ccol, sys.col$ c2, sys.cdef$ cd
                              where c.obj# = c2.obj#
                                and c.obj# = cd.obj#
                                and c.obj# = ccol.obj#
                                and c.col# = c2.col#
                                and ccol.con# = cd.con#
                                and ccol.intcol# = c2.intcol#
                                and bitand(c2.property, 32) = 32   /* Hidden */
                                and cd.type# = 2)))))         /* Primary key */
                  and (c.type# != 123                              /* Varray */
                       or ' || varray_check('supported', 'c') || '))
             -----------------------------------------
             /* table doesnt have at least one scalar column */
             or ((c.type# in (8,24,58,112,113,121,123) 
                  or bitand(c.property, 128) = 128)
             and (bitand(t.property, 1) = 0          /* not a typed table or */
             and 0 = (select count(*) from sys.col$ c2
               where t.obj# = c2.obj#
               and bitand(c2.property, 32)  != 32              /* Not hidden */
               and bitand(c2.property, 8)   != 8              /* Not virtual */
               and bitand(c2.property, 128) != 128      /* not stored in lob */
               and (c2.type# in ( 1,                             /* VARCHAR2 */
                                  2,                               /* NUMBER */
                                  12,                                /* DATE */
                                  23,                                 /* RAW */
                                  96,                                /* CHAR */
                                  100,                       /* BINARY FLOAT */
                                  101,                      /* BINARY DOUBLE */
                                  180,                     /* TIMESTAMP (..) */
                                  181,       /* TIMESTAMP(..) WITH TIME ZONE */
                                  182,         /* INTERVAL YEAR(..) TO MONTH */
                                  183,     /* INTERVAL DAY(..) TO SECOND(..) */
                                  231) /* TIMESTAMP(..) WITH LOCAL TIME ZONE */
                ))))
            /* Identity column + RNW (Replace null with) column */
            or bitand(c.property, 137438953472 + 274877906944 
                                               + 1099511627776) != 0
             ' || long_iden_check(view_type, 'c') || ')
	) /* end col$ exists subquery */
----------------------------------------------
  then 0 else 1 end) gensby
  from sys.obj$ o, sys.user$ u, sys.tab$ t
  where o.owner# = u.user#
  and o.obj# = t.obj#
  and t.obj# = o.obj#';

  ---------------------------------------------------------------------
  -- OGG_SUPPORT_TAB_12_2
  -- This view encapsulates 12.2.0.0 compatibility support for OGG
  --   gensby:      -1 internal, so not supported
  --                   e.g. IOT overflow, nested table storage tab
  --                 1 SUPPORT_MODE=FULL supported
  --                   includes BFILE(non-ADT), REF/Sys partitioning
  --                 0 SUPPORT_MODE=ID KEY (Fetch)
  --                   e.g. nested table columns
  --                 2 SUPPORT_MODE=PLSQL plsql supp logging required
  --                   e.g. HETs, SDO_TOPO/RASTER, AQ queue tables
  --                 3 SUPPORT_MODE=NONE, table not supportable by OGG
  --                   e.g. tables with no usable key, ADT w/BFILE attr 
  --
  ELSE /* (view_type = 'OGG') */
        view_stmt_12_2 :=
'as
  select u.name owner, o.name name, o.type#, o.obj#,
 (case 
  /* INTERNAL - The following are tables that are system maintained.  
     These are internal, so no SUPPORT_MODE given */
  when ( exists (select 1 from system.logstdby$skip_support s
                 where s.name = u.name and action = 0))
    or bitand(o.flags,
                2                                       /* temporary object */
              + 16                                      /* secondary object */
              + 32                                  /* in-memory temp table */
              + 128                           /* dropped table (RecycleBin) */
             ) != 0
    or bitand(t.flags,
                134217728  /* 0x08000000          in-memory temporary table */
              + 536870912  /* 0x20000000  Mapping Tab for Phys rowid of IOT */
             ) != 0
    or bitand(t.property,
                512        /* 0x00000200               iot OVeRflow segment */
              + 8192       /* 0x00002000                       nested table */
              + 4194304    /* 0x00400000             global temporary table */
              + 8388608    /* 0x00800000   session-specific temporary table */
              + 134217728  /* 0x08000000                    Is a Sub object */
              + 2147483648 /* 0x80000000                     eXternal TaBle */
              + 4294967296 /* 0x100000000                              Cube */
              + 8589934592 /* 0x200000000                      FBA Internal */
              + (2*4294967296*4294967296) /* PF3 0x00000002    XML TokenSet */
             ) != 0
    or bitand(t.trigflag,
                536870912  /* 0x20000000                  DDLs autofiltered */
               ) != 0
    or exists (select 1 from sys.secobj$ so           /* ODCI storage table */
               where o.obj# = so.secobj#) 
    or exists (select 1 from sys.opqtype$ opq       /* XML OR storage table */
               where o.obj# = opq.obj# 
                 and bitand(opq.flags, 32) = 32) 
    or (bitand(t.property, 131072) != 0 and               /* AQ spill table */
        o.name like ''AQ$\_%\_P'' escape ''\'')
    or (bitand(t.property, 131072) != 0 and            /* AQ commit q table */
        o.name like ''AQ$\_%\_C'' escape ''\'')
  then -1
  ----------------------------------------- 
  /* SUPPORT_MODE "NONE" */
  when exists 
     (select 1 from sys.col$ c 
               where t.obj# = c.obj#
             /* Table has a 32k column with a unique idx/constraint on it */
        and ((c.type# in (1, 23) and ' || vc32k_check('ogg', 'c') || ')
             /* ADT typed table with BFILE attribute */
             or (bitand(t.property, 1) = 1 and 
                 c.type# = 114 /* BFILE */ and
                 exists(select 1 
                        from sys.col$ c1
                        where c1.obj#=t.obj# and
                              c1.name = ''SYS_NC_ROWINFO$'' and
                              c1.type# = 121))
             /* Relational table with ADT column having BFILE attribute */
             or (bitand(t.property, 1) = 0 and 
                 c.type# = 114 /* BFILE */ and
                 bitand(c.property, 32) = 32 /* hidden */ and
                 exists (select 1 
                         from sys.col$ c1 
                         where c1.obj#=t.obj# and
                               c1.col# = c.col# and
                               bitand(c1.property, 32) = 0 /* not hidden */ and
                               c1.type# = 121))
             /* Any table (relational or typed) that has an unsupported */
             /* built-in ADT */
             or ' || built_in_check(view_type, 'c') || '
             /* table doesnt have at least one scalar column */
             or ((c.type# in (8,24,58,112,113,114,115,121,123) 
                  or bitand(c.property, 128) = 128)
             and (bitand(t.property, 1) = 0          /* not a typed table or */
             and 0 = (select count(*) from sys.col$ c2
               where t.obj# = c2.obj#
               and bitand(c2.property, 32)  != 32              /* Not hidden */
               and bitand(c2.property, 8)   != 8              /* Not virtual */
               and bitand(c2.property, 128) != 128      /* not stored in lob */
               and (c2.type# in ( 1,                             /* VARCHAR2 */
                                  2,                               /* NUMBER */
                                  12,                                /* DATE */
                                  23,                                 /* RAW */
                                  96,                                /* CHAR */
                                  100,                       /* BINARY FLOAT */
                                  101,                      /* BINARY DOUBLE */
                                  180,                     /* TIMESTAMP (..) */
                                  181,       /* TIMESTAMP(..) WITH TIME ZONE */
                                  182,         /* INTERVAL YEAR(..) TO MONTH */
                                  183,     /* INTERVAL DAY(..) TO SECOND(..) */
                                  208,                             /* UROWID */
                                  231) /* TIMESTAMP(..) WITH LOCAL TIME ZONE */
     ))))))
     or ' || sharded_queue_check(view_type) || '      /* Sharded queue table */
  then 3
  ------------------------------------------
  /* SUPPORT_MODE "ID KEY" */
  when (bitand(t.property, 1 ) = 1     /* 0x00000001             typed table */
        AND ((bitand(t.property, 4096) = 4096)                     /* pk oid */
             OR exists                                
              (select 1
               from  sys.col$ c1
               where c1.obj# = t.obj# and
                     (' || opaque_check('ogg', 'c1') || '          /* Opaque */ 
                        /* Non-hidden varray or varray stored in table in an */
                        /* ADT typed table.                                  */
                     /* Identify ADT typed tables containing unsupported:    */
                     /* Varray, REF, or nested table types.                  */
                      or ((exists
                           (select 1 from sys.col$ c2
                             where c2.obj# = t.obj# and
                                   c2.name = ''SYS_NC_ROWINFO$'' and
                                   c2.type# = 121)) and
                          (c1.type#=122 or ' ||    /* Nested Table */
                           varray_check(view_type, 'c1') || ' or ' ||
                           ref_check(view_type, 'c1') || '))))))
    /* Table has a Temporal Validity column */
    or (bitand(t.property, 4611686018427387904) != 0) 
             -----------------------------------------
             /* unsupp view joins col$, here we subquery it */
    or exists (select 1 from sys.col$ c 
               where t.obj# = c.obj#
             -----------------------------------------
             /*  ignore any hidden columns in this subquery */
               and bitand(c.property, 32) != 32                /* Not hidden */
             -----------------------------------------
             /* table has an unsupported datatype */
               and ((c.type# not in ( 
                                  1,                             /* VARCHAR2 */
                                  2,                               /* NUMBER */
                                  8,                                 /* LONG */
                                  12,                                /* DATE */
                                  24,                            /* LONG RAW */
                                  96,                                /* CHAR */
                                  100,                       /* BINARY FLOAT */
                                  101,                      /* BINARY DOUBLE */
                                  112,                     /* CLOB and NCLOB */
                                  113,                               /* BLOB */
                                  114,                              /* BFILE */
                                  115,                              /* CFILE */
                                  180,                     /* TIMESTAMP (..) */
                                  181,       /* TIMESTAMP(..) WITH TIME ZONE */
                                  182,         /* INTERVAL YEAR(..) TO MONTH */
                                  183,     /* INTERVAL DAY(..) TO SECOND(..) */
                                  208,                             /* UROWID */
                                  231) /* TIMESTAMP(..) WITH LOCAL TIME ZONE */
                  and (c.type# != 23                      /* RAW not RAW OID */
                  or (c.type# = 23 and bitand(c.property, 2) = 2))
                  and (c.type# != 58                               /* OPAQUE */
                    or ' || opaque_check('ogg', 'c') || ')
                  and (c.type# != 111                        /* Internal REF */
                    or  ' || ref_check('ogg', 'c') || ')
                  and (c.type# != 121                                 /* ADT */
                    or ( '|| adt_check('ogg', 'c') ||' or
                         (c.type#=121 and
                          /* For non-typed tables, Primary keys on ADT attrs */
                          /* are disallowed.  Pkeys should be supported on   */
                          /* typed tables.                                   */
                          (bitand(t.property, 1 ) = 0 and exists 
                            (select 1 from 
                              sys.ccol$ ccol, sys.col$ c2, sys.cdef$ cd
                              where c.obj# = c2.obj#
                                and c.obj# = cd.obj#
                                and c.obj# = ccol.obj#
                                and c.col# = c2.col#
                                and ccol.con# = cd.con#
                                and ccol.intcol# = c2.intcol#
                                and bitand(c2.property, 32) = 32   /* Hidden */
                                and cd.type# = 2)))))         /* Primary key */
                  and (c.type# != 123                              /* Varray */
                       or ' || varray_check('ogg', 'c') || '))
            /* Identity column + RNW (Replace null with) column */
            or bitand(c.property, 137438953472 + 274877906944 
                                               + 1099511627776) != 0))
  then 0
  ---------------------------------------------
  /* SUPPORT_MODE "PLSQL" */
  when (bitand(t.property, 131072) != 0 or               /* AQ queue tables */
        (bitand(t.property, 1) = 1 and
         exists (select 1 from sys.opqtype$ opq        /* Hierarchy enabled */
                   where opq.obj# = t.obj# and
                         opq.type=1 and
                         bitand(opq.flags,512) = 512)) or
        (exists (select 1                            /* Topology/ Georaster */
                 from sys.obj$ o2, sys.coltype$ ct2, sys.user$ u2
                 where o.obj# = ct2.obj# and
                       u2.user# = o2.owner# and
                       ct2.toid = o2.oid$ and
                       u2.name=''MDSYS'' and
                       (o2.name = ''SDO_TOPO_GEOMETRY'' or 
                        o2.name = ''SDO_GEORASTER'')))
  ) then 2
  ----------------------------------------------
  /* SUPPORT_MODE "FULL" */
  else 1 end) gensby
  from sys.obj$ o, sys.user$ u, sys.tab$ t
  where o.owner# = u.user#
  and o.obj# = t.obj#';
  END IF;

  return view_stmt_12_2;
END view_gen_12_2;

BEGIN
  unsup_tab_12_2 := 
    'create or replace view logstdby_unsupport_tab_12_2 ' ||
    view_gen_12_2('unsupported');
  ru_unsup_tab_12_2 :=
    'create or replace view logstdby_ru_unsupport_tab_12_2 ' ||
    view_gen_12_2('ru_unsupported');
  support_tab_12_2 :=
    'create or replace view logstdby_support_tab_12_2 ' ||
    view_gen_12_2('supported');
  ogg_support_tab_12_2 :=
    'create or replace view ogg_support_tab_12_2 ' ||
    view_gen_12_2('ogg');

  execute immediate unsup_tab_12_2;
  execute immediate ru_unsup_tab_12_2;
  execute immediate support_tab_12_2;
  execute immediate ogg_support_tab_12_2;

end;
/

/* 12.2.0.2 SUPPORTED/UNSUPPORTED VIEW DEFINITIONS */
DECLARE
  ru_unsup_tab_12_2_0_2        varchar2(32000);
  ogg_support_tab_12_2_0_2     varchar2(32000);
  unsup_tab_12_2_0_2           varchar2(32000);
  support_tab_12_2_0_2         varchar2(32000);

  /* UNSUPPORTED VARRAY is a:
   *  - varray stored as table (= varray with Nested Table bit set) 
   *  - A non-hidden varray column (except during rolling upgrade)
   * 
   * CLAUSE EVALUATES TO:
   *   TRUE for an unsupported column (support_mode ID KEY for OGG)
   *   FALSE (or empty string) for a supported column 
   *                                  (support_mode FULL for OGG)
   */
  FUNCTION varray_check(view_type VARCHAR2, alias VARCHAR2)
  RETURN VARCHAR2 IS
    unsupported_varray    varchar2(1000);
  BEGIN

    if (view_type = 'unsupported' or view_type = 'supported') THEN
      unsupported_varray := 
      '(c.type# = 123 and 
        (bitand(c.property, 4) = 4 or 
          (bitand(c.property, 32)!=32 
           and sys_context( ''userenv'', ''IS_DG_ROLLING_UPGRADE'' ) 
               = ''FALSE'')))';
    else  /* view_type = 'ru_unsupported' or 'ogg'*/
      unsupported_varray :=  '(c.type# = 123 and bitand(c.property, 4) = 4)';
    end if;

    if (alias is not null and alias != 'c') THEN
      unsupported_varray := replace(unsupported_varray, 'c.', alias || '.');
    end if;
    return unsupported_varray;
  END varray_check;

  /* UNSUPPORTED REF 
   *   - refs are unsupported, unless this is rolling upgrade
   *     Only non-virtual REFs are supportable.
   *     Examples of virtual REF columns are PK-REFs and referential 
   *     integrity constraints.
   *
   * CLAUSE EVALUATES TO:
   *   TRUE for an unsupported column (support_mode ID KEY for OGG)
   *   FALSE (or empty string) for a supported column 
   *                                  (support_mode FULL for OGG)
   */
  FUNCTION ref_check(view_type VARCHAR2, alias VARCHAR2)
  RETURN VARCHAR2 IS
    unsupported_ref    varchar2(1000);
  BEGIN
    if (view_type = 'unsupported' or view_type = 'supported') THEN
      unsupported_ref := 
      '(c.type# = 111 and 
         (bitand(c.property, 8) = 8
          or sys_context( ''userenv'', ''IS_DG_ROLLING_UPGRADE'' )
             = ''FALSE''))';
    else  /* view_type = 'ru_unsupported' || 'ogg' */
      -- REFs are only supported in rolling upgrade when they are not virtual
      unsupported_ref :=  
       '(c.type# = 111 and bitand(c.property, 8) = 8)';
    end if;

    if (alias is not null and alias != 'c') THEN
      unsupported_ref := replace(unsupported_ref, 'c.', alias || '.');
    end if;
    return unsupported_ref;
  END ref_check;

  /* UNSUPPORTED OPAQUE types include:
   * - XMLType columns that are hierarchy enabled (except during rolling upgrd)
   * - Any opaque column which is not a SYS.XMLType or a SYS.ANYDATA type.
   *
   * CLAUSE EVALUATES TO:
   *   TRUE for an unsupported column (support_mode ID KEY for OGG)
   *   FALSE (or empty string) for a supported column 
   *                                  (support_mode FULL for OGG)
   */
  FUNCTION opaque_check(view_type VARCHAR2, alias VARCHAR2)
  RETURN VARCHAR2 IS
    unsupported_opaque varchar2(1000);
    opaque_preamble    varchar2(100);
    opaque_hierarchy   varchar2(1000);
    opaque_others      varchar2(1000);
  BEGIN 
    opaque_preamble :=
    '(c.type# = 58 and (';
    opaque_hierarchy := 
    ' (exists (select 1 from opqtype$ opq
                where opq.type=1 
                  and bitand(opq.flags,512) = 512      /* hierarchy enabled */
                  and opq.obj#=c.obj# 
                  and opq.intcol#=c.intcol#) 
      and sys_context( ''userenv'', ''IS_DG_ROLLING_UPGRADE'' ) = ''FALSE'') ';
    opaque_others := 
    ' exists (select 1 from coltype$ ct
                    where ct.obj#=c.obj#
                    and   ct.intcol# = c.intcol#
                    and /* SYS.XMLTYPE */ 
                    ct.toid != ''00000000000000000000000000020100''
                    and /* SYS.ANYDATA */
                    ct.toid != ''00000000000000000000000000020011''))) ';


    if (view_type = 'unsupported' or view_type = 'supported') THEN
      -- [UN]SUPPORTED views need to check if rolling upgrade is in progress
      unsupported_opaque := 
        opaque_preamble || opaque_hierarchy || ' or ' || opaque_others;

    else /* view_type = 'ru_unsupported' or 'ogg' */
      -- RU_UNSUPPORTED view reports as if rolling upgrade IS in progress
      unsupported_opaque := 
        opaque_preamble || opaque_others;
    end if;

    if (alias is not null and alias != 'c') THEN
      unsupported_opaque := replace(unsupported_opaque, 'c.', alias || '.');
    end if;

    return unsupported_opaque;
  end opaque_check;

 /* UNSUPPORTED BUILT-IN type:
  * Check list of unsupported datatypes maintained in
  * skip_support.  These could be built-in opaque, ADT or varray
  * types that are singled out as being unsupported.
  *
  * CLAUSE EVALUATES TO:
  *   TRUE for an unsupported column (support_mode ID KEY for OGG)
  *   FALSE (or empty string) for a supported column 
  *                                  (support_mode FULL for OGG)
  *
  * NOTE:  This check is currently not performed in 12.2 because
  *  there are no longer any unsupported built-in types.  If new ones
  *  are identified, this routine can be re-introduced to the views.
  *  See the 12.1 views and their use of the unsupp_built_in_type
  *  string for guidance on placement.
  */
  FUNCTION built_in_check(view_type VARCHAR2, alias VARCHAR2)
  RETURN VARCHAR2 IS
    unsupp_built_in_type VARCHAR2(4000);
  BEGIN
    unsupp_built_in_type :=
   '(c.type# in (58, 121, 123) and
     (exists 
      (select 1 from obj$ o3, coltype$ ct3, user$ u3
       where u3.user# = o3.owner#
         and c.obj# = ct3.obj#
         and c.intcol# = ct3.intcol#
         and ct3.toid = o3.oid$  
         and exists (select 1 from system.logstdby$skip_support sk
                      where sk.action=-11 
                        and sk.name = u3.name   /* type owner */
                        and sk.name2 = o3.name  /* type name  */))))';

    if (alias is not null and alias != 'c') THEN
      unsupp_built_in_type := replace(unsupp_built_in_type, 'c.', alias || '.');
    end if;

    return unsupp_built_in_type;
  END built_in_check;

  /* UNSUPPORTED ADT ATTRIBUTE check:
   * In a subquery, we check for any unsupported (Lsby/Rolling), or 
   * ID KEY (OGG) datatypes in the attributes of this ADT.  These are: 
   * Nested Tables, or any opaque, varray, or built-in datatypes failing 
   * the above checks.  For Lsby/Rolling, BFILE columns are unsupported.
   * For OGG, BFILE columns are supported FULL.
   * Note that the sys.col$ subquery is necessary so that we don't return any 
   * hidden columns from the unsupported query.  When an ADT attribute is
   * unsupported, the parent (non-hidden) ADT column should be identified as
   * the culprit.             
   *
   * CLAUSE EVALUATES TO:
   *   TRUE for an unsupported column (support_mode ID KEY for OGG)
   *   FALSE (or empty string) for a supported column 
   *                                  (support_mode FULL for OGG)
   */
  FUNCTION adt_check(view_type VARCHAR2, alias VARCHAR2)
  RETURN VARCHAR2 IS
    unsupp_adt VARCHAR2(4000);
    bfile_unsupport VARCHAR2(100);
  BEGIN

    IF (view_type = 'ogg') THEN
      bfile_unsupport := ' ';
    ELSE
      bfile_unsupport := ' c2.type# = 114  or ';
    END IF;

    unsupp_adt :=
      '(c.type#=121 and
       (exists
         (select 1 from sys.col$ c2  
           where t.obj# = c2.obj#
             and c.col# = c2.col#
             and (c2.type# = 122         or                  /* Nested Table */
                 ' || bfile_unsupport || '                          /* BFILE */
                 ' || varray_check(view_type, 'c2') || ' or        /* Varray */
                 ' || opaque_check(view_type, 'c2') || ' or        /* Opaque */
                 ' || ref_check(view_type, 'c2');                     /* REF */

    -- For the Lsby/RU views, we do the built-in type check here.
    -- For the OGG views, the built-in check is done in the support_mode NONE
    -- section.
    if (view_type != 'ogg') THEN                           /* Built-in types */
      unsupp_adt := unsupp_adt || ' or ' || built_in_check(view_type, 'c2'); 
    END IF;

    unsupp_adt := unsupp_adt || '))))';

    if (alias is not null and alias != 'c') THEN
      unsupp_adt := replace(unsupp_adt, 'c.', alias || '.');
    end if;

    return unsupp_adt;
  END adt_check;


  /* Sharded Queue Table check:
   * Sharded Queue Tables (SQTs) should be INTERNAL for Rolling Upgrade, and
   * unsupported otherwise.  The feature is supported for Rolling Upgrade via
   * PL/SQL replication, and any activity on these tables should be skipped
   * as INTERNAL.  Outside of Rolling Upgrade, the feature is unsupported
   * for Logical Standby, and support_mode NONE for OGG.
   * RETURNS:
   *   A statement that evaluates to TRUE for a table that is an SQT
   *   A statement that evaluates to FALSE for a table that is not an SQT
   */
  FUNCTION sharded_queue_check(view_type VARCHAR2)
  RETURN VARCHAR2 IS
    sqt_stmt  VARCHAR2(1000);
  BEGIN

    IF (view_type = 'unsupported' or view_type = 'supported') THEN
      sqt_stmt :=
        ' (bitand(t.property, power(2,73)) != 0 and
           sys_context( ''userenv'', ''IS_DG_ROLLING_UPGRADE'' ) = ''TRUE'') ';
           
    ELSE
      sqt_stmt := 
        ' (bitand(t.property, power(2,73)) != 0) ';
    END IF;

    return sqt_stmt;
  END sharded_queue_check;

  /* UNSUPPORTED AQ QUEUE TABLE check:
   * AQ queue tables are supported during rolling upgrade, or by OGG with 
   * procedural supplemental logging.
   *
   * For the LSBY supported and unsupported views, we need to check whether 
   * we're in rolling upgrade before making the support decision.  
   * For the rolling upgrade view, we assume that we're in rolling upgrade, 
   * so AQ queue tables are supported.
   * For the OGG support_mode view, AQ queue tables are supported via 
   * procedural replication, so this routine returns TRUE, so they can be
   * properly identified as PLSQL support mode later in the view definition.
   *
   * CLAUSE EVALUATES TO:
   *   TRUE for an unsupported column
   *   FALSE (or empty string) for a supported column 
   */
  FUNCTION aq_queue_check(view_type VARCHAR2)
  RETURN VARCHAR2 IS
    aq_queue_stmt VARCHAR2(1000);
  BEGIN
    IF (view_type = 'unsupported' or view_type = 'supported') THEN
      aq_queue_stmt := 
        ' /* 0x00020000 table is used as an AQ queue table */
          or (bitand(t.property, 131072) != 0 and 
           sys_context( ''userenv'', ''IS_DG_ROLLING_UPGRADE'' ) = ''FALSE'') ';
    ELSE
      -- AQ Queue tables are always supported under Rolling upgrade
      aq_queue_stmt := '';
    END IF;

    return aq_queue_stmt;
  END aq_queue_check;

  /* UNSUPPORTED LONG IDENTIFIER check:
   * Long identifiers (identifiers with a byte-length of more than 30),
   * are supported by rolling upgrade, but not by Logical Standby.
   * We make an exception for system-generated long identifiers - in the
   * event that an internally generated column name exceeds 30 bytes, 
   * the table shouldn't be considered unsupported by Lsby.  Note that
   * this check isn't used for OGG, since long identifiers are always
   * fully supported there.
   *
   * CLAUSE EVALUATES TO:
   *   TRUE for an unsupported column
   *   FALSE (or empty string) for a supported column 
   */
  FUNCTION long_iden_check(view_type VARCHAR2, alias VARCHAR2)
  RETURN VARCHAR2 IS
    liden_stmt VARCHAR2(500);
  BEGIN
    IF (view_type = 'unsupported' or view_type = 'supported') THEN
      liden_stmt :=
        ' or ((lengthb(o.name) > 30 or lengthb(u.name) > 30 or
               (lengthb(c.name) > 30 and 
                bitand(c.property, 256 /* System-generated */) = 0)) and 
              sys_context( ''userenv'', ''IS_DG_ROLLING_UPGRADE'' ) = ''FALSE'') ';
    ELSE
      liden_stmt := '';
    END IF;

    if (alias is not null and alias != 'c') THEN
      liden_stmt := replace(liden_stmt, 'c.', alias || '.');
    end if;

    return liden_stmt;
  END long_iden_check;

  /* UNSUPPORTED 32k column
   *  - a long varchar (>4k) having a unique index or constraint defined on it
   *    is unsupported.  
   * 
   * CLAUSE EVALUATES TO:
   *   TRUE for an unsupported column (support_mode NONE for OGG)
   *   FALSE (or empty string) for a supported column 
   *                                  (support_mode FULL for OGG)
   */
  FUNCTION vc32k_check(view_type VARCHAR2, alias VARCHAR2)
  RETURN VARCHAR2 IS
    unsupported_vc    varchar2(1000);
  BEGIN

    unsupported_vc := 
     '(bitand(c.property, 128) = 128                 /* column stored in LOB */
       and c.length between 4001 and 6398
       and (exists                                  /* Unique index on vc32k */
            (select null
             from ind$ i, icol$ ic
             where i.bo# = t.obj#
               and ic.obj# = i.obj#
               and c.intcol# = ic.intcol#
               and bitand(i.property, 1) = 1                       /* Unique */
            )
           or exists                  /* Primary or unique constraint on 32k */
            (select null
             from cdef$ cd, ccol$ ccol 
             where cd.obj# = t.obj#
               and cd.obj# = ccol.obj#
               and cd.con# = ccol.con#
               and cd.type# in (2,3)
               and ccol.intcol# = c.intcol#
            )))';

    if (alias is not null and alias != 'c') THEN
      unsupported_vc := replace(unsupported_vc, 'c.', alias || '.');
    end if;
    return unsupported_vc;
  END vc32k_check;
  
  /* UNSUPPORTED Identity column
   *  - Identity column is supported in 12.2.0.2, for rolling upgrade and
   *    OGG.
   *  - Identity column is not supported for Logical Standby.
   * 
   * CLAUSE EVALUATES TO:
   *   TRUE for an unsupported column (support_mode NONE for OGG)
   *   FALSE (or empty string) for a supported column 
   *                                  (support_mode FULL for OGG)
   */

  FUNCTION identity_check(view_type VARCHAR2, alias VARCHAR2)
  RETURN VARCHAR2 is
    iden_stmt VARCHAR2(500);
  BEGIN
    IF (view_type = 'unsupported' or view_type = 'supported') THEN
      iden_stmt :=
        ' or (bitand(c.property, 137438953472 + 274877906944) !=0 and 
              sys_context( ''userenv'', ''IS_DG_ROLLING_UPGRADE'' ) 
           = ''FALSE'') ';
    ELSE /* view_type = 'ru_unsupported' or 'ogg' */
      iden_stmt := '';
    END IF;

    if (alias is not null and alias != 'c') THEN
      iden_stmt := replace(iden_stmt, 'c.', alias || '.');
    end if;

    return iden_stmt;
  END identity_check;

  /* UNSUPPORTED column outside of rolling check
   *  - a BFILE/UROWID column is unsupported unless this is in logical rolloing
   * 
   * RETURNS:
   *   TRUE for an unsupported column 
   *   FALSE for a supported column  
   *
   * NOTE:
   *   This is used to check top level BFILE column.
   *   BFILE attribute is always unsupported, and checked in adt_check();
   */
  FUNCTION rolling_check(view_type VARCHAR2)
  RETURN VARCHAR2 IS
    rolling_stmt VARCHAR2(4000);
  BEGIN
    IF (view_type = 'unsupported' or view_type = 'supported') THEN
      rolling_stmt := 
        ' or sys_context( ''userenv'', ''IS_DG_ROLLING_UPGRADE'') = ''FALSE'' ';
    ELSE
      rolling_stmt := '';
    END IF;

    return rolling_stmt;
  END rolling_check;

  FUNCTION view_gen_12_2_0_2(view_type VARCHAR2)
  RETURN VARCHAR2 IS
    view_stmt_12_2_0_2 VARCHAR2(32000);
  BEGIN

    ---------------------------------------------------------------------
    --  LOGSTDBY_UNSUPPORT_TAB_12_2_0_2 / LOGSTDBY_RU_UNSUPPORT_TAB_12_2_0_2
    --   Adds support for Identity Columns, only in RU/OGG
    --
    -- This view encapsulates 12.2.0.2 compatibility support
    --   gensby:       1 supported, 
    --                 -1 internal so not supported   
    --                 0 user data not supported because of features     
    --   current_sby:  1 if lsby bit set in tab$ else 0
    --
    IF (view_type = 'unsupported' or view_type = 'ru_unsupported') THEN

      view_stmt_12_2_0_2 := 
  'as
  select u.name owner, o.name table_name, c.name column_name, 
         c.scale, c.precision#, c.charsetform, c.type#,
   (case when bitand(t.flags, 536870912) = 536870912
         then ''Mapping table for physical rowid of IOT''
         else null end) attributes,
    (case 
    /* The following are tables that are system maintained */
    when bitand(o.flags,
                2                                       /* temporary object */
              + 16                                      /* secondary object */
              + 32                                  /* in-memory temp table */
              + 128                           /* dropped table (RecycleBin) */
             ) != 0
    or bitand(t.flags,
                262144     /* 0x00040000        Summary Container Table, MV */ 
              + 134217728  /* 0x08000000          in-memory temporary table */
              + 536870912  /* 0x20000000  Mapping Tab for Phys rowid of IOT */
             ) != 0
    or bitand(t.property,
                512        /* 0x00000200               iot OVeRflow segment */
              + 8192       /* 0x00002000                       nested table */
              + 4194304    /* 0x00400000             global temporary table */
              + 8388608    /* 0x00800000   session-specific temporary table */
              + 33554432   /* 0x02000000        Read Only Materialized View */
              + 67108864   /* 0x04000000            Materialized View table */
              + 134217728  /* 0x08000000                    Is a Sub object */
              + 2147483648 /* 0x80000000                     eXternal TaBle */
              + 4294967296 /* 0x100000000                              Cube */
              + 8589934592 /* 0x200000000                      FBA Internal */
              + (2*4294967296*4294967296) /* PF3 0x00000002    XML TokenSet */
             ) != 0
    or bitand(t.trigflag,
                536870912  /* 0x20000000                  DDLs autofiltered */
               ) != 0
    or exists                                                /* MVLOG table */
       (select 1 
        from sys.mlog$ ml where ml.mowner = u.name and ml.log = o.name) 
    or exists (select 1 from sys.secobj$ so           /* ODCI storage table */
               where o.obj# = so.secobj#) 
    or exists (select 1 from sys.opqtype$ opq       /* XML OR storage table */
               where o.obj# = opq.obj# 
                 and bitand(opq.flags, 32) = 32) 
    or (bitand(t.property, 131072) != 0 and               /* AQ spill table */
        o.name like ''AQ$\_%\_P'' escape ''\'')
    or (bitand(t.property, 131072) != 0 and            /* AQ commit q table */
        o.name like ''AQ$\_%\_C'' escape ''\'')
    or ' || sharded_queue_check(view_type) || '      /* Sharded queue table */
  then -1
    /* The following tables are data tables in internal schemata *
     * that are not secondary objects                            */
  when (exists (select 1 from system.logstdby$skip_support s
                where s.name = u.name and action = 0))
  then -2
    /* The following tables are user visible tables that we choose to       *
     * skip because of some unsupported attribute of the table or column    */
  when (bitand(t.property, 1) = 1       /* 0x00000001            typed table */
    AND((bitand(t.property, 4096) = 4096) /* PK OID */
        OR exists                                
            (select 1
              from  sys.col$ c1
              where c1.obj# = t.obj# and
                    (' || opaque_check(view_type, 'c1') ||         /* Opaque */
                          long_iden_check(view_type, 'c1') || ' /* Long iden */
                     or (c1.type# = 114)                            /* BFILE */
                     /* Identify ADT typed tables containing unsupported:    */
                     /* Varray, REF, or nested table types.                  */
                     or ((exists
                          (select 1 from sys.col$ c2
                             where c2.obj# = t.obj# and
                                   c2.name = ''SYS_NC_ROWINFO$'' and
                                   c2.type# = 121)) and
                         (c1.type#=122 or ' ||    /* Nested Table */
                          varray_check(view_type, 'c1') || ' or ' ||
                          ref_check(view_type, 'c1') ||' or ' ||
                          built_in_check(view_type, 'c1') || ')))))) '
  || aq_queue_check(view_type) ||
' /* Table has a Temporal Validity column */
  or (bitand(t.property, 4611686018427387904) != 0) 
  /* OLAP AW$ table */
  or (bitand(t.property, power(2,69 /*PF3 */)) != 0)
  or (bitand(t.property, 32) = 32) 
    and exists (select 1 from partobj$ po
                where po.obj#=o.obj#
                and  (po.parttype in (3,             /* System partitioned */
                                      5)))        /* Reference partitioned */
  or (c.type# not in ( 
                  2,                               /* NUMBER */
                  8,                                 /* LONG */
                  12,                                /* DATE */
                  24,                            /* LONG RAW */
                  96,                                /* CHAR */
                  100,                       /* BINARY FLOAT */
                  101,                      /* BINARY DOUBLE */
                  112,                     /* CLOB and NCLOB */
                  113,                               /* BLOB */
                  180,                     /* TIMESTAMP (..) */
                  181,       /* TIMESTAMP(..) WITH TIME ZONE */
                  182,         /* INTERVAL YEAR(..) TO MONTH */
                  183,     /* INTERVAL DAY(..) TO SECOND(..) */
                  231) /* TIMESTAMP(..) WITH LOCAL TIME ZONE */
  and (c.type# != 1
  or  (c.type# = 1 and ' || vc32k_check(view_type, 'c') || '))     /* 32k vc */
  and (c.type# != 23
  or  (c.type# = 23 and (bitand(c.property, 2) = 2 or '   /* RAW not RAW OID */
        || vc32k_check(view_type, 'c') || ')))                     /* 32k vc */
  and (c.type# != 58                                               /* Opaque */
  or  ' || opaque_check(view_type, 'c') || ')
  and (c.type# != 111                                        /* Internal REF */ 
  or  ' || ref_check(view_type, 'c') || ')
  and (c.type# != 121                                                 /* ADT */
  or  ( '|| adt_check(view_type, 'c') ||' or 
       (c.type#=121 and
       /* For non-typed tables, Primary keys on ADT attrs are disallowed.    */
       /* Primary keys should be supported on typed tables.                  */
       (bitand(t.property, 1) = 0
         and exists 
         (select 1 from 
           sys.ccol$ ccol, sys.col$ c2, sys.cdef$ cd
           where c.obj# = c2.obj#
             and c.obj# = cd.obj#
             and c.obj# = ccol.obj#
             and c.col# = c2.col#
             and ccol.con# = cd.con#
             and ccol.intcol# = c2.intcol#
             and bitand(c2.property, 32) = 32    /* Hidden */
             and cd.type# = 2)))))          /* Primary key */
  and (c.type# != 123                                              /* Varray */
  or '|| varray_check(view_type, 'c') || ')
  and (c.type# != 208 '|| rolling_check(view_type) || ')           /* UROWID */
  and (c.type# != 114 '|| rolling_check(view_type) || '))           /* BFILE */
  ----------------------------------------------------------
  /* table must have at least one scalar column to use as the id key */
  or ((c.type# in (8,24,58,112,113,114,121,123)
       or bitand(c.property, 128) = 128)
      and bitand(t.property, 1) = 0                  /* not a typed table or */
      and 0 = (select count(*) from sys.col$ c2
               where t.obj# = c2.obj#
               and bitand(c2.property, 32)  != 32              /* Not hidden */
	       and bitand(c2.property, 8)   != 8              /* Not virtual */
               and bitand(c2.property, 128) != 128      /* not stored in lob */
               and (c2.type# in ( 1,                             /* VARCHAR2 */
                                  2,                               /* NUMBER */
                                  12,                                /* DATE */
                                  23,                                 /* RAW */
                                  96,                                /* CHAR */
                                  100,                       /* BINARY FLOAT */
                                  101,                      /* BINARY DOUBLE */
                                  180,                     /* TIMESTAMP (..) */
                                  181,       /* TIMESTAMP(..) WITH TIME ZONE */
                                  182,         /* INTERVAL YEAR(..) TO MONTH */
                                  183,     /* INTERVAL DAY(..) TO SECOND(..) */
                                  208,                             /* UROWID */
                                  231) /* TIMESTAMP(..) WITH LOCAL TIME ZONE */
      )))
  /* RNW (Replace null with) column */
  or bitand(c.property, 1099511627776) != 0
   ' || identity_check(view_type, 'c') || '
   ' || long_iden_check(view_type, 'c') || ' 
  ----------------------------------------------------------
  then 0 else 1 end) gensby
  from sys.obj$ o, sys.user$ u, sys.tab$ t, sys.col$ c
  where o.owner# = u.user#
  and o.obj# = t.obj#
  and o.obj# = c.obj#
  and t.obj# = o.obj#
  and bitand(c.property, 32) != 32                         /* Not hidden */';

    ---------------------------------------------------------------------
    -- LOGSTDBY_SUPPORT_TAB_12_2_0_2
    --   Adds support for Identity columns, only during Rolling Upgrade
    --
    -- This view encapsulates 12.2.0.2 compatibility support
    --   gensby:       1 supported, 
    --                 -1 internal so not supported   
    --                 0 user data not supported because of features     
    --   current_sby:  1 if lsby bit set in tab$ else 0
    --
    ELSIF  (view_type = 'supported') THEN
      view_stmt_12_2_0_2 :=
'as
  select u.name owner, o.name name, o.type#, o.obj#,
         decode(bitand(t.flags, 1073741824), 1073741824, 1, 0) current_sby,
 (case 
    /* The following are tables that are system maintained */
  when ( exists (select 1 from system.logstdby$skip_support s
                 where s.name = u.name and action = 0))
    or bitand(o.flags,
                2                                       /* temporary object */
              + 16                                      /* secondary object */
              + 32                                  /* in-memory temp table */
              + 128                           /* dropped table (RecycleBin) */
             ) != 0
    or bitand(t.flags,
                262144     /* 0x00040000        Summary Container Table, MV */ 
              + 134217728  /* 0x08000000          in-memory temporary table */
              + 536870912  /* 0x20000000  Mapping Tab for Phys rowid of IOT */
             ) != 0
    or bitand(t.property,
                512        /* 0x00000200               iot OVeRflow segment */
              + 8192       /* 0x00002000                       nested table */
              + 4194304    /* 0x00400000             global temporary table */
              + 8388608    /* 0x00800000   session-specific temporary table */
              + 33554432   /* 0x02000000        Read Only Materialized View */
              + 67108864   /* 0x04000000            Materialized View table */
              + 134217728  /* 0x08000000                    Is a Sub object */
              + 2147483648 /* 0x80000000                     eXternal TaBle */
              + 4294967296 /* 0x100000000                              Cube */
              + 8589934592 /* 0x200000000                      FBA Internal */
              + (2*4294967296*4294967296) /* PF3 0x00000002    XML TokenSet */
             ) != 0
    or bitand(t.trigflag,
                536870912  /* 0x20000000                  DDLs autofiltered */
               ) != 0
    or exists (select 1 from sys.mlog$ ml                    /* MVLOG table */
               where ml.mowner = u.name and ml.log = o.name) 
    or exists (select 1 from sys.secobj$ so           /* ODCI storage table */
               where o.obj# = so.secobj#) 
    or exists (select 1 from sys.opqtype$ opq       /* XML OR storage table */
               where o.obj# = opq.obj# 
                 and bitand(opq.flags, 32) = 32) 
    or (bitand(t.property, 131072) != 0 and               /* AQ spill table */
        o.name like ''AQ$\_%\_P'' escape ''\'')
    or (bitand(t.property, 131072) != 0 and            /* AQ commit q table */
        o.name like ''AQ$\_%\_C'' escape ''\'')
    or ' || sharded_queue_check(view_type) || '      /* Sharded queue table */
  then -1
    /* The following tables are user visible tables that we choose to 
     * skip because of some unsupported attribute of the table or column */
  when (bitand(t.property, 1 ) = 1    /* 0x00000001             typed table */
        AND ((bitand(t.property, 4096) = 4096)                     /* pk oid */
             OR exists                                
              (select 1
               from  sys.col$ c1
               where c1.obj# = t.obj# and
                     (' || opaque_check('supported', 'c1') ||      /* Opaque */ 
                          long_iden_check(view_type, 'c1') || ' /* Long iden */
                      or (c1.type# = 114 and     /* BFILE outside of rolling */
              sys_context( ''userenv'', ''IS_DG_ROLLING_UPGRADE'') = ''FALSE'')
                     /* Identify ADT typed tables containing unsupported:    */
                     /* Varray, REF, or nested table types.                  */
                      or ((exists
                           (select 1 from sys.col$ c2
                             where c2.obj# = t.obj# and
                                   c2.name = ''SYS_NC_ROWINFO$'' and
                                   c2.type# = 121)) and
                          (c1.type#=122 or ' ||    /* Nested Table */
                           varray_check(view_type, 'c1') || ' or ' ||
                           ref_check(view_type, 'c1') || ' or ' ||
                           built_in_check(view_type, 'c1') || '))))))
    /* Table has a Temporal Validity column */
    or (bitand(t.property, 4611686018427387904) != 0) 
    /* OLAP AW$ table */
    or (bitand(t.property, power(2,69 /*PF3 */)) != 0)
    or (bitand(t.property, 32) = 32)                         /* Partitioned */
      and exists (select 1 from partobj$ po
                  where po.obj#=o.obj#
                  and  (po.parttype in (3,             /* System partitioned */
                                        5)))        /* Reference partitioned */
    or (bitand(t.property,
             /* This clause is only for performance; they could be
                excluded by the column datatype checks below whe not in
                rolling mode. */
              32768        /* 0x00008000 has FILE columns outside of rolling */
             ) != 0 and
         sys_context( ''userenv'', ''IS_DG_ROLLING_UPGRADE'') = ''FALSE'') '
        || aq_queue_check('supported') || '
             -----------------------------------------
             /* unsupp view joins col$, here we subquery it */
    or exists (select 1 from sys.col$ c 
               where t.obj# = c.obj#
             -----------------------------------------
             /*  ignore any hidden columns in this subquery */
               and bitand(c.property, 32) != 32                /* Not hidden */
             -----------------------------------------
             /* table has an unsupported datatype */
               and ((c.type# not in ( 
                                  2,                               /* NUMBER */
                                  8,                                 /* LONG */
                                  12,                                /* DATE */
                                  24,                            /* LONG RAW */
                                  96,                                /* CHAR */
                                  100,                       /* BINARY FLOAT */
                                  101,                      /* BINARY DOUBLE */
                                  112,                     /* CLOB and NCLOB */
                                  113,                               /* BLOB */
                                  114,                              /* BFILE */
                                  180,                     /* TIMESTAMP (..) */
                                  181,       /* TIMESTAMP(..) WITH TIME ZONE */
                                  182,         /* INTERVAL YEAR(..) TO MONTH */
                                  183,     /* INTERVAL DAY(..) TO SECOND(..) */
                                  231) /* TIMESTAMP(..) WITH LOCAL TIME ZONE */
                  and (c.type# != 1
                  or  (c.type# = 1 and ' 
                       || vc32k_check(view_type, 'c') || '))       /* 32k vc */
                  and (c.type# != 23                      /* RAW not RAW OID */
                  or (c.type# = 23 and (bitand(c.property, 2) = 2 or '
                      || vc32k_check(view_type, 'c') || ')))       /* 32k vc */
                  and (c.type# != 58                               /* OPAQUE */
                    or ' || opaque_check('supported', 'c') || ')
                  and (c.type# != 111                        /* Internal REF */
                    or  ' || ref_check('supported', 'c') || ')
                  and (c.type# != 121                                 /* ADT */
                    or ( '|| adt_check('supported', 'c') ||' or
                         (c.type#=121 and
                          /* For non-typed tables, Primary keys on ADT attrs */
                          /* are disallowed.  Pkeys should be supported on   */
                          /* typed tables.                                   */
                          (bitand(t.property, 1 ) = 0 and exists 
                            (select 1 from 
                              sys.ccol$ ccol, sys.col$ c2, sys.cdef$ cd
                              where c.obj# = c2.obj#
                                and c.obj# = cd.obj#
                                and c.obj# = ccol.obj#
                                and c.col# = c2.col#
                                and ccol.con# = cd.con#
                                and ccol.intcol# = c2.intcol#
                                and bitand(c2.property, 32) = 32   /* Hidden */
                                and cd.type# = 2)))))         /* Primary key */
                  and (c.type# != 123                              /* Varray */
                       or ' || varray_check('supported', 'c') || ')
                  and (c.type# != 208 '|| rolling_check(view_type) || '))  /* UROWID */
             -----------------------------------------
             /* table doesnt have at least one scalar column */
             or ((c.type# in (8,24,58,112,113,114,121,123) 
                  or bitand(c.property, 128) = 128)
             and (bitand(t.property, 1) = 0          /* not a typed table or */
             and 0 = (select count(*) from sys.col$ c2
               where t.obj# = c2.obj#
               and bitand(c2.property, 32)  != 32              /* Not hidden */
               and bitand(c2.property, 8)   != 8              /* Not virtual */
               and bitand(c2.property, 128) != 128      /* not stored in lob */
               and (c2.type# in ( 1,                             /* VARCHAR2 */
                                  2,                               /* NUMBER */
                                  12,                                /* DATE */
                                  23,                                 /* RAW */
                                  96,                                /* CHAR */
                                  100,                       /* BINARY FLOAT */
                                  101,                      /* BINARY DOUBLE */
                                  180,                     /* TIMESTAMP (..) */
                                  181,       /* TIMESTAMP(..) WITH TIME ZONE */
                                  182,         /* INTERVAL YEAR(..) TO MONTH */
                                  183,     /* INTERVAL DAY(..) TO SECOND(..) */
                                  208,                             /* UROWID */
                                  231) /* TIMESTAMP(..) WITH LOCAL TIME ZONE */
                ))))
             /* RNW (Replace null with) column */
             or bitand(c.property, 1099511627776) != 0
             ' || identity_check(view_type, 'c') || '
             ' || long_iden_check(view_type, 'c') || ')
	) /* end col$ exists subquery */
----------------------------------------------
  then 0 else 1 end) gensby
  from sys.obj$ o, sys.user$ u, sys.tab$ t
  where o.owner# = u.user#
  and o.obj# = t.obj#
  and t.obj# = o.obj#';

  ---------------------------------------------------------------------
  -- OGG_SUPPORT_TAB_12_2_0_2
  --   Identity column support is introduced for OGG.
  -- 
  -- This view encapsulates 12.2.0.2 compatibility support for OGG
  --   gensby:      -1 internal, so not supported
  --                   e.g. IOT overflow, nested table storage tab
  --                 1 SUPPORT_MODE=FULL supported
  --                   includes BFILE(non-ADT), REF/Sys partitioning,
  --                   Identity columns (new)
  --                 0 SUPPORT_MODE=ID KEY (Fetch)
  --                   e.g. nested table columns
  --                 2 SUPPORT_MODE=PLSQL plsql supp logging required
  --                   e.g. HETs, SDO_TOPO/RASTER, AQ queue tables
  --                 3 SUPPORT_MODE=NONE, table not supportable by OGG
  --                   e.g. tables with no usable key, ADT w/BFILE attr
  --
  ELSE /* (view_type = 'OGG') */
        view_stmt_12_2_0_2 :=
'as
  select u.name owner, o.name name, o.type#, o.obj#,
 (case 
  /* INTERNAL - The following are tables that are system maintained.  
     These are internal, so no SUPPORT_MODE given */
  when ( exists (select 1 from system.logstdby$skip_support s
                 where s.name = u.name and action = 0))
    or bitand(o.flags,
                2                                       /* temporary object */
              + 16                                      /* secondary object */
              + 32                                  /* in-memory temp table */
              + 128                           /* dropped table (RecycleBin) */
             ) != 0
    or bitand(t.flags,
                134217728  /* 0x08000000          in-memory temporary table */
              + 536870912  /* 0x20000000  Mapping Tab for Phys rowid of IOT */
             ) != 0
    or bitand(t.property,
                512        /* 0x00000200               iot OVeRflow segment */
              + 8192       /* 0x00002000                       nested table */
              + 4194304    /* 0x00400000             global temporary table */
              + 8388608    /* 0x00800000   session-specific temporary table */
              + 134217728  /* 0x08000000                    Is a Sub object */
              + 2147483648 /* 0x80000000                     eXternal TaBle */
              + 4294967296 /* 0x100000000                              Cube */
              + 8589934592 /* 0x200000000                      FBA Internal */
              + (2*4294967296*4294967296) /* PF3 0x00000002    XML TokenSet */
             ) != 0
    or bitand(t.trigflag,
                536870912  /* 0x20000000                  DDLs autofiltered */
               ) != 0
    or exists (select 1 from sys.secobj$ so           /* ODCI storage table */
               where o.obj# = so.secobj#) 
    or exists (select 1 from sys.opqtype$ opq       /* XML OR storage table */
               where o.obj# = opq.obj# 
                 and bitand(opq.flags, 32) = 32) 
    or (bitand(t.property, 131072) != 0 and               /* AQ spill table */
        o.name like ''AQ$\_%\_P'' escape ''\'')
    or (bitand(t.property, 131072) != 0 and            /* AQ commit q table */
        o.name like ''AQ$\_%\_C'' escape ''\'')
  then -1
  ----------------------------------------- 
  /* SUPPORT_MODE "NONE" */
  when exists 
     (select 1 from sys.col$ c 
               where t.obj# = c.obj#
             /* Table has a 32k column with a unique idx/constraint on it */
        and ((c.type# in (1, 23) and ' || vc32k_check('ogg', 'c') || ')
             /* ADT typed table with BFILE attribute */
             or (bitand(t.property, 1) = 1 and 
                 c.type# = 114 /* BFILE */ and
                 exists(select 1 
                        from sys.col$ c1
                        where c1.obj#=t.obj# and
                              c1.name = ''SYS_NC_ROWINFO$'' and
                              c1.type# = 121))
             /* Relational table with ADT column having BFILE attribute */
             or (bitand(t.property, 1) = 0 and 
                 c.type# = 114 /* BFILE */ and
                 bitand(c.property, 32) = 32 /* hidden */ and
                 exists (select 1 
                         from sys.col$ c1 
                         where c1.obj#=t.obj# and
                               c1.col# = c.col# and
                               bitand(c1.property, 32) = 0 /* not hidden */ and
                               c1.type# = 121))
             /* Any table (relational or typed) that has an unsupported */
             /* built-in ADT */
             or ' || built_in_check(view_type, 'c') || '
             /* table doesnt have at least one scalar column */
             or ((c.type# in (8,24,58,112,113,114,115,121,123) 
                  or bitand(c.property, 128) = 128)
             and (bitand(t.property, 1) = 0          /* not a typed table or */
             and 0 = (select count(*) from sys.col$ c2
               where t.obj# = c2.obj#
               and bitand(c2.property, 32)  != 32              /* Not hidden */
               and bitand(c2.property, 8)   != 8              /* Not virtual */
               and bitand(c2.property, 128) != 128      /* not stored in lob */
               and (c2.type# in ( 1,                             /* VARCHAR2 */
                                  2,                               /* NUMBER */
                                  12,                                /* DATE */
                                  23,                                 /* RAW */
                                  96,                                /* CHAR */
                                  100,                       /* BINARY FLOAT */
                                  101,                      /* BINARY DOUBLE */
                                  180,                     /* TIMESTAMP (..) */
                                  181,       /* TIMESTAMP(..) WITH TIME ZONE */
                                  182,         /* INTERVAL YEAR(..) TO MONTH */
                                  183,     /* INTERVAL DAY(..) TO SECOND(..) */
                                  208,                             /* UROWID */
                                  231) /* TIMESTAMP(..) WITH LOCAL TIME ZONE */
     ))))))
    /* OLAP AW$ table */
    or (bitand(t.property, power(2,69 /*PF3 */)) != 0)
    or ' || sharded_queue_check(view_type) || '       /* Sharded queue table */
  then 3
  ------------------------------------------
  /* SUPPORT_MODE "ID KEY" */
  when (bitand(t.property, 1 ) = 1     /* 0x00000001             typed table */
        AND ((bitand(t.property, 4096) = 4096)                     /* pk oid */
             OR exists                                
              (select 1
               from  sys.col$ c1
               where c1.obj# = t.obj# and
                     (' || opaque_check('ogg', 'c1') || '          /* Opaque */ 
                        /* Non-hidden varray or varray stored in table in an */
                        /* ADT typed table.                                  */
                     /* Identify ADT typed tables containing unsupported:    */
                     /* Varray, REF, or nested table types.                  */
                      or ((exists
                           (select 1 from sys.col$ c2
                             where c2.obj# = t.obj# and
                                   c2.name = ''SYS_NC_ROWINFO$'' and
                                   c2.type# = 121)) and
                          (c1.type#=122 or ' ||    /* Nested Table */
                           varray_check(view_type, 'c1') || ' or ' ||
                           ref_check(view_type, 'c1') || '))))))
    /* Table has a Temporal Validity column */
    or (bitand(t.property, 4611686018427387904) != 0) 
             -----------------------------------------
             /* unsupp view joins col$, here we subquery it */
    or exists (select 1 from sys.col$ c 
               where t.obj# = c.obj#
             -----------------------------------------
             /*  ignore any hidden columns in this subquery */
               and bitand(c.property, 32) != 32                /* Not hidden */
             -----------------------------------------
             /* table has an unsupported datatype */
               and ((c.type# not in ( 
                                  1,                             /* VARCHAR2 */
                                  2,                               /* NUMBER */
                                  8,                                 /* LONG */
                                  12,                                /* DATE */
                                  24,                            /* LONG RAW */
                                  96,                                /* CHAR */
                                  100,                       /* BINARY FLOAT */
                                  101,                      /* BINARY DOUBLE */
                                  112,                     /* CLOB and NCLOB */
                                  113,                               /* BLOB */
                                  114,                              /* BFILE */
                                  115,                              /* CFILE */
                                  180,                     /* TIMESTAMP (..) */
                                  181,       /* TIMESTAMP(..) WITH TIME ZONE */
                                  182,         /* INTERVAL YEAR(..) TO MONTH */
                                  183,     /* INTERVAL DAY(..) TO SECOND(..) */
                                  208,                             /* UROWID */
                                  231) /* TIMESTAMP(..) WITH LOCAL TIME ZONE */
                  and (c.type# != 23                      /* RAW not RAW OID */
                  or (c.type# = 23 and bitand(c.property, 2) = 2))
                  and (c.type# != 58                               /* OPAQUE */
                    or ' || opaque_check('ogg', 'c') || ')
                  and (c.type# != 111                        /* Internal REF */
                    or  ' || ref_check('ogg', 'c') || ')
                  and (c.type# != 121                                 /* ADT */
                    or ( '|| adt_check('ogg', 'c') ||' or
                         (c.type#=121 and
                          /* For non-typed tables, Primary keys on ADT attrs */
                          /* are disallowed.  Pkeys should be supported on   */
                          /* typed tables.                                   */
                          (bitand(t.property, 1 ) = 0 and exists 
                            (select 1 from 
                              sys.ccol$ ccol, sys.col$ c2, sys.cdef$ cd
                              where c.obj# = c2.obj#
                                and c.obj# = cd.obj#
                                and c.obj# = ccol.obj#
                                and c.col# = c2.col#
                                and ccol.con# = cd.con#
                                and ccol.intcol# = c2.intcol#
                                and bitand(c2.property, 32) = 32   /* Hidden */
                                and cd.type# = 2)))))         /* Primary key */
                  and (c.type# != 123                              /* Varray */
                       or ' || varray_check('ogg', 'c') || '))
            /* RNW (Replace null with) column */
            or bitand(c.property, 1099511627776) != 0))
  then 0
  ---------------------------------------------
  /* SUPPORT_MODE "PLSQL" */
  when (bitand(t.property, 131072) != 0 or               /* AQ queue tables */
        (bitand(t.property, 1) = 1 and
         exists (select 1 from sys.opqtype$ opq        /* Hierarchy enabled */
                   where opq.obj# = t.obj# and
                         opq.type=1 and
                         bitand(opq.flags,512) = 512)) or
        (exists (select 1                            /* Topology/ Georaster */
                 from sys.obj$ o2, sys.coltype$ ct2, sys.user$ u2
                 where o.obj# = ct2.obj# and
                       u2.user# = o2.owner# and
                       ct2.toid = o2.oid$ and
                       u2.name=''MDSYS'' and
                       (o2.name = ''SDO_TOPO_GEOMETRY'' or 
                        o2.name = ''SDO_GEORASTER'')))
  ) then 2
  ----------------------------------------------
  /* SUPPORT_MODE "FULL" */
  else 1 end) gensby
  from sys.obj$ o, sys.user$ u, sys.tab$ t
  where o.owner# = u.user#
  and o.obj# = t.obj#';
  END IF;

  return view_stmt_12_2_0_2;
END view_gen_12_2_0_2;

BEGIN
  ru_unsup_tab_12_2_0_2 :=
    'create or replace view logstdby_ru_un_tab_12_2_0_2 ' ||
    view_gen_12_2_0_2('ru_unsupported');
  ogg_support_tab_12_2_0_2 :=
    'create or replace view ogg_support_tab_12_2_0_2 ' ||
    view_gen_12_2_0_2('ogg');
  unsup_tab_12_2_0_2 := 
    'create or replace view logstdby_unsupp_tab_12_2_0_2 ' ||
    view_gen_12_2_0_2('unsupported');
  support_tab_12_2_0_2 :=
    'create or replace view logstdby_support_tab_12_2_0_2 ' ||
    view_gen_12_2_0_2('supported');

  execute immediate ru_unsup_tab_12_2_0_2;
  execute immediate ogg_support_tab_12_2_0_2;
  execute immediate unsup_tab_12_2_0_2;
  execute immediate support_tab_12_2_0_2;
end;
/

---------------------------------------------------------------------
-- LOGSTDBY_SUPPORT_SEQ
-- set of sequences with indicator for lsby support            
--   full_sby:       not used for sequences use bogus constant
--   current_sby:    true if lsby bit set in seq$             
--   generated_sby:  2 for replicated but not guarded (special internal seq)
--                   1 for replicated and guarded
--                   0 for not replicated (internal schemas)
--                  -1 for not replicated (internally maintained sequences)
--                   (special case for internal sequences ie. action = -2)
--
-- 
create or replace view logstdby_support_seq 
as
  select u.name owner, o.name name, o.type#, o.obj#,
         decode(bitand(s.flags, 8), 8, 1, 0) current_sby,
         decode(bitand(s.flags, 1024), 1024, -1,
           nvl((select 2 from system.logstdby$skip_support s3
                where s3.name = u.name and s3.name2 = o.name
                  and s3.action = -2),
               nvl((select 0 from system.logstdby$skip_support s2
                    where s2.name = u.name and action = 0), 1))) gensby
  from obj$ o, user$ u, seq$ s
  where o.owner# = u.user# 
  and o.obj# = s.obj#
/

---------------------------------------------------------------------
-- LOGSTDBY_SUPPORT
-- filter tables with DML skip rules from logstdby_support_tab 
--   full_sby:       1 supported, -1 internal not supported   
--                   0 not supported because of features     
--   current_sby:    true if lsby bit set in tab$           
--   generated_sby:  true if supported and no DML skip rule
--                     sequence nextval is treated as DML for skip
--
create or replace view logstdby_support
as
  with redo_compat as
         (select nvl((select min(s.redo_compat)
                      from system.logstdby$parameters p,
                           system.logmnr_session$ s,
                           sys.v$database d
                      where p.name in ('LMNR_SID', 'FUTURE_SESSION') and
                            p.value = s.session# and
                            d.database_role = 'LOGICAL STANDBY'),
                     (select p.value
                      from sys.v$parameter p
                      where p.name = 'compatible')) compat
          from dual) 
  select owner, name, type#, obj#, gensby full_sby, current_sby,
   (case when decode(gensby, 1, 1, 0) = 1  
       and not exists  
      (select 1 from system.logstdby$skip s
       where statement_opt = 'DML' 
       and error is null 
       and 1 = case use_like
         when 0 then 
           case when l.owner = s.schema and l.name = s.name then
             1 else 0 
           end
         when 1 then 
           case when l.owner like s.schema and l.name like s.name then
             1 else 0
           end
         when 2 then
           case when l.owner like s.schema escape esc and 
                     l.name like s.name escape esc then
             1 else 0
           end
         else 0
       end)
    then 1 else 0 end) generated_sby
  from  
    (select owner, name, type#, obj#, current_sby, 
            case gensby when 2 then 1 else gensby end gensby
       from logstdby_support_seq
     union all 
    select * from (
    select u.owner, u.name, u.type#, u.obj#, u.current_sby, u.gensby 
    from logstdby_support_tab_10_1 u, redo_compat c
    where c.compat like '10.0%' or c.compat like '10.1%'
    UNION ALL
    select u.owner, u.name, u.type#, u.obj#, u.current_sby, u.gensby 
    from logstdby_support_tab_10_2 u, redo_compat c
    where c.compat like '10.2%'
    UNION ALL
    select u.owner, u.name, u.type#, u.obj#, u.current_sby, u.gensby 
    from logstdby_support_tab_11_1 u, redo_compat c
    where c.compat like '11.0%' or c.compat like '11.1%'
    UNION ALL
    select u.owner, u.name, u.type#, u.obj#, u.current_sby, u.gensby 
    from logstdby_support_tab_11_2 u, redo_compat c
    where c.compat like '11.2%' and c.compat not like '11.2.0.3%'
                                and c.compat not like '11.2.0.4%'
    UNION ALL
    select u.owner, u.name, u.type#, u.obj#, u.current_sby, u.gensby 
    from logstdby_support_tab_11_2b u, redo_compat c
    where c.compat like '11.2.0.3%' or c.compat like '11.2.0.4%'
    UNION ALL
    select u.owner, u.name, u.type#, u.obj#, u.current_sby, u.gensby 
    from logstdby_support_tab_12_1 u, redo_compat c
    where c.compat like '12.0%' or c.compat like '12.1%'
    UNION ALL
    select u.owner, u.name, u.type#, u.obj#, u.current_sby, u.gensby 
    from logstdby_support_tab_12_2 u, redo_compat c
    where c.compat like '12.2%' and c.compat not like '12.2.0.2%'
    UNION ALL
    select u.owner, u.name, u.type#, u.obj#, u.current_sby, u.gensby 
    from logstdby_support_tab_12_2_0_2 u, redo_compat c
    where c.compat like '12.2.0.2%' or c.compat like '18.0%' 
          or c.compat like '18.1%'
)
) l
/

---------------------------------------------------------------------
-- LOGSTDBY_UNSUPPORTED_TABLES
-- This undocumented view is created for the Data Guard GUI so that it
-- can get a list of tables that are not supported.  They could use
-- the dba_logstdby_unsupported view, but the query is expensive, mostly
-- because it's column based not table based.
--
create or replace view dba_logstdby_unsupported_table
as
  with redo_compat as
         (select nvl((select min(s.redo_compat)
                      from system.logstdby$parameters p,
                           system.logmnr_session$ s,
                           sys.v$database d
                      where p.name in ('LMNR_SID', 'FUTURE_SESSION') and
                            p.value = s.session# and
                            d.database_role = 'LOGICAL STANDBY'),
                     (select p.value
                      from sys.v$parameter p
                      where p.name = 'compatible')) compat
          from dual) 
  select owner, name table_name 
  from (
    select u.owner, u.name, u.gensby
    from logstdby_support_tab_10_1 u, redo_compat c
    where c.compat like '10.0%' or c.compat like '10.1%'
    UNION ALL
    select u.owner, u.name, u.gensby
    from logstdby_support_tab_10_2 u, redo_compat c
    where c.compat like '10.2%'
    UNION ALL
    select u.owner, u.name, u.gensby
    from logstdby_support_tab_11_1 u, redo_compat c
    where c.compat like '11.0%' or c.compat like '11.1%'
    UNION ALL
    select u.owner, u.name, u.gensby
    from logstdby_support_tab_11_2 u, redo_compat c
    where c.compat like '11.2%' and c.compat not like '11.2.0.3%'
                                and c.compat not like '11.2.0.4%'
    UNION ALL
    select u.owner, u.name, u.gensby
    from logstdby_support_tab_11_2b u, redo_compat c
    where c.compat like '11.2.0.3%' or c.compat like '11.2.0.4%'
    UNION ALL
    select u.owner, u.name, u.gensby
    from logstdby_support_tab_12_1 u, redo_compat c
    where c.compat like '12.0%' or c.compat like '12.1%'
    UNION ALL
    select u.owner, u.name, u.gensby
    from logstdby_support_tab_12_2 u, redo_compat c
    where c.compat like '12.2%' and c.compat not like '12.2.0.2%'
    UNION ALL
    select u.owner, u.name, u.gensby
    from logstdby_support_tab_12_2_0_2 u, redo_compat c
    where c.compat like '12.2.0.2%' or c.compat like '18.0%' 
          or c.compat like '18.1%'
  )
  where gensby = 0
/
grant select on dba_logstdby_unsupported_table to select_catalog_role
/
create or replace public synonym logstdby_unsupported_tables
   for sys.dba_logstdby_unsupported_table
/
create or replace public synonym dba_logstdby_unsupported_table
   for sys.dba_logstdby_unsupported_table
/
comment on table dba_logstdby_unsupported_table is 
'List of all the data tables that are not supported by Logical Standby'
/
comment on column dba_logstdby_unsupported_table.owner is 
'Schema name of unsupported table'
/
comment on column dba_logstdby_unsupported_table.table_name is 
'Table name of unsupported table'
/


execute CDBView.create_cdbview(false,'SYS','DBA_LOGSTDBY_UNSUPPORTED_TABLE','CDB_LOGSTDBY_UNSUPPORTED_TABLE');
grant select on SYS.CDB_logstdby_unsupported_table to select_catalog_role
/
create or replace public synonym CDB_logstdby_unsupported_table for SYS.CDB_logstdby_unsupported_table
/

---------------------------------------------------------------------
-- DBA_LOGSTDBY_UNSUPPORTED
-- This documented view displays all the unsupported columns.
-- The view is used by OEM if the users wishes to drill down on
-- the list of table returned by the faster logstdby_unsupported_tables.
-- This view is slower becuase of the join to col$ and filtering
-- by column rather than by table
--
-- The top level view simply queries the redo compatibility table 
-- function and decodes the datatype to text form (which is common
-- for all compatibilities)


---------------------------------------------------------------------
-- LOGSTDBY_UNSUPPORT_TAB_11_2b
-- This view encapsulates the rules for support of 11.2.0.3 redo
--    Support for XML OR is enabled (to the extent xml clob is enabled).
create or replace view logstdby_unsupport_tab_11_2b
as
  select u.name owner, o.name table_name, c.name column_name, 
         c.scale, c.precision#, c.charsetform, c.type#,
   (case when bitand(t.flags, 536870912) = 536870912
         then 'Mapping table for physical rowid of IOT'
         when bitand(t.property, 131072) = 131072
         then 'AQ queue table'
         when c.type# = 58
         then 'Unsupported XML'
         when bitand(t.property, 1 ) = 1     /* 0x00000001      typed table */
         then 'Object Table'
         when bitand(c.property, 65544) != 0
         then  'Unsupported Virtual Column'
         else null end) attributes,
    (case 
    /* The following are tables that are system maintained */
    when bitand(o.flags,
                2                                       /* temporary object */
              + 16                                      /* secondary object */
              + 32                                  /* in-memory temp table */
              + 128                           /* dropped table (RecycleBin) */
             ) != 0
    or bitand(t.flags,
                262144     /* 0x00040000        Summary Container Table, MV */ 
              + 134217728  /* 0x08000000          in-memory temporary table */
              + 536870912  /* 0x20000000  Mapping Tab for Phys rowid of IOT */
             ) != 0
    or bitand(t.property,
                512        /* 0x00000200               iot OVeRflow segment */
              + 8192       /* 0x00002000                       nested table */
              + 4194304    /* 0x00400000             global temporary table */
              + 8388608    /* 0x00800000   session-specific temporary table */
              + 33554432   /* 0x02000000        Read Only Materialized View */
              + 67108864   /* 0x04000000            Materialized View table */
              + 134217728  /* 0x08000000                    Is a Sub object */
              + 2147483648 /* 0x80000000                     eXternal TaBle */
              + 4294967296 /* 0x100000000                              Cube */
              + 8589934592 /* 0x200000000                      FBA Internal */
             ) != 0
    or bitand(t.trigflag,
                536870912  /* 0x20000000                  DDLs autofiltered */
               ) != 0
    or exists                                                /* MVLOG table */
       (select 1 
        from sys.mlog$ ml where ml.mowner = u.name and ml.log = o.name) 
    or exists (select 1 from sys.secobj$ so           /* ODCI storage table */
               where o.obj# = so.secobj#) 
    or exists (select 1 from sys.opqtype$ opq       /* XML OR storage table */
               where o.obj# = opq.obj# 
                 and bitand(opq.flags, 32) = 32) 
  then -1
    /* The following tables are data tables in internal schemata *
     * that are not secondary objects                            */
  when (exists (select 1 from system.logstdby$skip_support s
                where s.name = u.name and action = 0))
  then -2
    /* The following tables are user visible tables that we choose to       *
     * skip because of some unsupported attribute of the table or column    */
  when (bitand(t.property, 1) = 1       /* 0x00000001            typed table */
        AND((bitand(t.property, 4096) = 4096) /* PK OID */
            or not exists            /* Only XML Typed Tables Are Supported */
            (select 1
             from  sys.col$ cc, sys.opqtype$ opq
             where cc.name = 'SYS_NC_ROWINFO$' and cc.type# = 58 and
                   opq.obj# = cc.obj# and opq.intcol# = cc.intcol# and
                   opq.type = 1 and cc.obj# = t.obj# 
                   and (bitand(opq.flags,1) = 1 or      /* stored as object */
                        bitand(opq.flags,68) = 4 or     /* stored as lob */
                        bitand(opq.flags,68) = 68)      /* stored as binary */
                   and bitand(opq.flags,512) = 0 )))   /* not hierarch enab */
  or bitand(t.property,
                131072     /* 0x00020000 table is used as an AQ queue table */
             ) != 0
  or (bitand(t.property, 32) = 32) 
    and exists (select 1 from partobj$ po
                where po.obj#=o.obj#
                and  (po.parttype in (3,             /* System partitioned */
                                      5)))        /* Reference partitioned */
  or (c.type# not in ( 
                  1,                             /* VARCHAR2 */
                  2,                               /* NUMBER */
                  8,                                 /* LONG */
                  12,                                /* DATE */
                  24,                            /* LONG RAW */
                  96,                                /* CHAR */
                  100,                       /* BINARY FLOAT */
                  101,                      /* BINARY DOUBLE */
                  112,                     /* CLOB and NCLOB */
                  113,                               /* BLOB */
                  180,                     /* TIMESTAMP (..) */
                  181,       /* TIMESTAMP(..) WITH TIME ZONE */
                  182,         /* INTERVAL YEAR(..) TO MONTH */
                  183,     /* INTERVAL DAY(..) TO SECOND(..) */
                  231) /* TIMESTAMP(..) WITH LOCAL TIME ZONE */
  and (c.type# != 23                      /* RAW not RAW OID */
  or  (c.type# = 23 and bitand(c.property, 2) = 2))
  and (c.type# != 58                               /* OPAQUE */
  or  (c.type# = 58                       /* XMLTYPE as CLOB */
      and (not exists (select 1 from opqtype$ opq
                  where opq.type=1 
                  and (bitand(opq.flags,1) = 1 or      /* stored as object */
                       bitand(opq.flags,68) = 4 or     /* stored as lob */
                       bitand(opq.flags,68) = 68)      /* stored as binary */
                  and bitand(opq.flags,512) = 0        /* not hierarch enab */
                  and opq.obj#=c.obj# 
                  and opq.intcol#=c.intcol#)))))
  ----------------------------------------------------------
  /* longs must have a scalar column to use as the id key */
  or (c.type# in (8,24,58,112,113)
      and bitand(t.property, 1) = 0       /* not a typed table or */
      and 0 = (select count(*) from sys.col$ c2
               where t.obj# = c2.obj#
               and bitand(c2.property, 32) != 32               /* Not hidden */
               and bitand(c2.property, 8)  != 8               /* Not virtual */
               and (c2.type# in ( 1,                             /* VARCHAR2 */
                                  2,                               /* NUMBER */
                                  12,                                /* DATE */
                                  23,                                 /* RAW */
                                  96,                                /* CHAR */
                                  100,                       /* BINARY FLOAT */
                                  101,                      /* BINARY DOUBLE */
                                  180,                     /* TIMESTAMP (..) */
                                  181,       /* TIMESTAMP(..) WITH TIME ZONE */
                                  182,         /* INTERVAL YEAR(..) TO MONTH */
                                  183,     /* INTERVAL DAY(..) TO SECOND(..) */
                                  231) /* TIMESTAMP(..) WITH LOCAL TIME ZONE */
      )))
  ----------------------------------------------------------
  /* we don't support dedup securefile */
  or  (c.type# in (112, 113)
      and exists (select 1 from logstdby_support_11lob lb
                  where lb.obj# = o.obj#
                  and lb.col# = c.col#
                  and dedupsecurefile = 1))
  then 0 else 1 end) gensby
  from sys.obj$ o, sys.user$ u, sys.tab$ t, sys.seg$ s, sys.col$ c
  where o.owner# = u.user#
  and o.obj# = t.obj#
  and o.obj# = c.obj#
  and t.file# = s.file# (+)
  and t.ts# = s.ts# (+)
  and t.block# = s.block# (+)
  and t.obj# = o.obj#
  and bitand(c.property, 32) != 32                         /* Not hidden */
/

---------------------------------------------------------------------
-- LOGSTDBY_UNSUPPORT_TAB_11_2
-- This view encapsulates the rules for support of 11.2 redo
--
create or replace view logstdby_unsupport_tab_11_2
as
  select u.name owner, o.name table_name, c.name column_name, 
         c.scale, c.precision#, c.charsetform, c.type#,
   (case when bitand(t.flags, 536870912) = 536870912
         then 'Mapping table for physical rowid of IOT'
         when bitand(t.property, 131072) = 131072
         then 'AQ queue table'
         when c.type# = 58
         then 'Unsupported XML Storage'
         when bitand(t.property, 1 ) = 1     /* 0x00000001      typed table */
         then 'Object Table'
         when bitand(c.property, 65544) != 0
         then  'Unsupported Virtual Column'
         else null end) attributes,
    (case 
    /* The following are tables that are system maintained */
    when bitand(o.flags,
                2                                       /* temporary object */
              + 16                                      /* secondary object */
              + 32                                  /* in-memory temp table */
              + 128                           /* dropped table (RecycleBin) */
             ) != 0
    or bitand(t.flags,
                262144     /* 0x00040000        Summary Container Table, MV */ 
              + 134217728  /* 0x08000000          in-memory temporary table */
              + 536870912  /* 0x20000000  Mapping Tab for Phys rowid of IOT */
             ) != 0
    or bitand(t.property,
                512        /* 0x00000200               iot OVeRflow segment */
              + 8192       /* 0x00002000                       nested table */
              + 4194304    /* 0x00400000             global temporary table */
              + 8388608    /* 0x00800000   session-specific temporary table */
              + 33554432   /* 0x02000000        Read Only Materialized View */
              + 67108864   /* 0x04000000            Materialized View table */
              + 134217728  /* 0x08000000                    Is a Sub object */
              + 2147483648 /* 0x80000000                     eXternal TaBle */
              + 4294967296 /* 0x100000000                              Cube */
              + 8589934592 /* 0x200000000                      FBA Internal */
             ) != 0
    or bitand(t.trigflag,
                536870912  /* 0x20000000                  DDLs autofiltered */
               ) != 0
    or exists                                                /* MVLOG table */
       (select 1 
        from sys.mlog$ ml where ml.mowner = u.name and ml.log = o.name) 
    or exists (select 1 from sys.secobj$ so           /* ODCI storage table */
               where o.obj# = so.secobj#) 
  then -1
    /* The following tables are data tables in internal schemata *
     * that are not secondary objects                            */
  when (exists (select 1 from system.logstdby$skip_support s
                where s.name = u.name and action = 0))
  then -2
    /* The following tables are user visible tables that we choose to       *
     * skip because of some unsupported attribute of the table or column    */
  when (bitand(t.property, 1) = 1       /* 0x00000001            typed table */
           AND not exists             /* Only XML Typed Tables Are Supported */
            (select 1
             from  sys.col$ cc, sys.opqtype$ opq
             where cc.name = 'SYS_NC_ROWINFO$' and cc.type# = 58 and
                   opq.obj# = cc.obj# and opq.intcol# = cc.intcol# and
                   opq.type = 1 and cc.obj# = t.obj# 
                   and bitand(opq.flags,4) = 4             /* stored as lob */
                   and bitand(opq.flags,64) = 0     /* not stored as binary */
                   and bitand(opq.flags,512) = 0))     /* not hierarch enab */
  or bitand(t.property,
                131072     /* 0x00020000 table is used as an AQ queue table */
             ) != 0
  or (bitand(t.property, 32) = 32) 
    and exists (select 1 from partobj$ po
                where po.obj#=o.obj#
                and  (po.parttype in (3,             /* System partitioned */
                                      5)))        /* Reference partitioned */
  or (c.type# not in ( 
                  1,                             /* VARCHAR2 */
                  2,                               /* NUMBER */
                  8,                                 /* LONG */
                  12,                                /* DATE */
                  24,                            /* LONG RAW */
                  96,                                /* CHAR */
                  100,                       /* BINARY FLOAT */
                  101,                      /* BINARY DOUBLE */
                  112,                     /* CLOB and NCLOB */
                  113,                               /* BLOB */
                  180,                     /* TIMESTAMP (..) */
                  181,       /* TIMESTAMP(..) WITH TIME ZONE */
                  182,         /* INTERVAL YEAR(..) TO MONTH */
                  183,     /* INTERVAL DAY(..) TO SECOND(..) */
                  231) /* TIMESTAMP(..) WITH LOCAL TIME ZONE */
  and (c.type# != 23                      /* RAW not RAW OID */
  or  (c.type# = 23 and bitand(c.property, 2) = 2))
  and (c.type# != 58                               /* OPAQUE */
  or  (c.type# = 58                       /* XMLTYPE as CLOB */
      and not exists (select 1 from opqtype$ opq
                  where opq.type=1 
                  and bitand(opq.flags, 4) = 4             /* stored as lob */
                  and bitand(opq.flags,64) = 0      /* not stored as binary */
                  and bitand(opq.flags,512) = 0        /* not hierarch enab */
                  and opq.obj#=c.obj# 
                  and opq.intcol#=c.intcol#))))
  ----------------------------------------------------------
  /* longs must have a scalar column to use as the id key */
  or (c.type# in (8,24,58,112,113)
      and bitand(t.property, 1) = 0         /* typed table has an OID */
      and 0 = (select count(*) from sys.col$ c2
               where t.obj# = c2.obj#
               and bitand(c2.property, 32) != 32               /* Not hidden */
               and (c2.type# in ( 1,                             /* VARCHAR2 */
                                  2,                               /* NUMBER */
                                  12,                                /* DATE */
                                  23,                                 /* RAW */
                                  96,                                /* CHAR */
                                  100,                       /* BINARY FLOAT */
                                  101,                      /* BINARY DOUBLE */
                                  180,                     /* TIMESTAMP (..) */
                                  181,       /* TIMESTAMP(..) WITH TIME ZONE */
                                  182,         /* INTERVAL YEAR(..) TO MONTH */
                                  183,     /* INTERVAL DAY(..) TO SECOND(..) */
                                  231) /* TIMESTAMP(..) WITH LOCAL TIME ZONE */
      )))
  ----------------------------------------------------------
  /* we don't support dedup securefile */
  or  (c.type# in (112, 113)
     and exists (select 1 from logstdby_support_11lob lb
                   where lb.obj# = o.obj#
                     and lb.col# = c.col#
                     and lb.dedupsecurefile = 1)) 
  ----------------------------------------------------------
  /* we don't support virtual column candidate key */
  or (bitand(c.property, 65544) != 0                      /* Virtual Column */
     and bitand(c.property, 32) != 32                         /* Not hidden */
     and exists (select 1 from icol$ ic, ind$ i
                  where ic.bo# = t.obj# and ic.col# = c.col#
                    and i.bo# = t.obj# and i.obj# = ic.obj#
                    and bitand(i.property, 1) = 1))         /* Unique Index */
  ----------------------------------------------------------
  then 0 else 1 end) gensby
  from sys.obj$ o, sys.user$ u, sys.tab$ t, sys.seg$ s, sys.col$ c
  where o.owner# = u.user#
  and o.obj# = t.obj#
  and o.obj# = c.obj#
  and t.file# = s.file# (+)
  and t.ts# = s.ts# (+)
  and t.block# = s.block# (+)
  and t.obj# = o.obj#
  and bitand(c.property, 32) != 32                         /* Not hidden */
/

---------------------------------------------------------------------
-- LOGSTDBY_UNSUPPORT_TAB_11_1
-- This view encapsulates the rules for support of 11.1 redo
--
create or replace view logstdby_unsupport_tab_11_1
as
  select u.name owner, o.name table_name, c.name column_name, 
         c.scale, c.precision#, c.charsetform, c.type#,
   (case when bitand(t.flags, 536870912) = 536870912
         then 'Mapping table for physical rowid of IOT'
         when bitand(nvl(s.spare1, 0), 2048) = 2048 
         then 'Table Compression'
         when bitand(t.property, 131072) = 131072
         then 'AQ queue table'
         when c.type# = 58
         then 'Unsupported XML Storage'
         when bitand(t.property, 1 ) = 1     /* 0x00000001      typed table */
         then 'Object Table'
         when bitand(c.property, 65544) != 0
         then  'Unsupported Virtual Column'
         else null end) attributes,
    (case 
    /* The following are tables that are system maintained */
    when bitand(o.flags,
                2                                       /* temporary object */
              + 16                                      /* secondary object */
              + 32                                  /* in-memory temp table */
              + 128                           /* dropped table (RecycleBin) */
             ) != 0
    or bitand(t.flags,
                262144     /* 0x00040000        Summary Container Table, MV */ 
              + 134217728  /* 0x08000000          in-memory temporary table */
              + 536870912  /* 0x20000000  Mapping Tab for Phys rowid of IOT */
             ) != 0
    or bitand(t.property,
                512        /* 0x00000200               iot OVeRflow segment */
              + 8192       /* 0x00002000                       nested table */
              + 4194304    /* 0x00400000             global temporary table */
              + 8388608    /* 0x00800000   session-specific temporary table */
              + 33554432   /* 0x02000000        Read Only Materialized View */
              + 67108864   /* 0x04000000            Materialized View table */
              + 134217728  /* 0x08000000                    Is a Sub object */
              + 2147483648 /* 0x80000000                     eXternal TaBle */
              + 4294967296 /* 0x100000000                              Cube */
              + 8589934592 /* 0x200000000                      FBA Internal */
             ) != 0
    or bitand(t.trigflag,
                536870912  /* 0x20000000                  DDLs autofiltered */
               ) != 0
    or exists                                                /* MVLOG table */
       (select 1 
        from sys.mlog$ ml where ml.mowner = u.name and ml.log = o.name) 
    or exists (select 1 from sys.secobj$ so           /* ODCI storage table */
               where o.obj# = so.secobj#) 
  then -1
    /* The following tables are data tables in internal schemata *
     * that are not secondary objects                            */
  when (exists (select 1 from system.logstdby$skip_support s
                where s.name = u.name and action = 0))
  then -2
    /* The following tables are user visible tables that we choose to       *
     * skip because of some unsupported attribute of the table or column    */
  when (bitand(t.property, 1) = 1       /* 0x00000001            typed table */
           AND not exists             /* Only XML Typed Tables Are Supported */
            (select 1
             from  sys.col$ cc, sys.opqtype$ opq
             where cc.name = 'SYS_NC_ROWINFO$' and cc.type# = 58 and
                   opq.obj# = cc.obj# and opq.intcol# = cc.intcol# and
                   opq.type = 1 and cc.obj# = t.obj# 
                   and bitand(opq.flags,4) = 4             /* stored as lob */
                   and bitand(opq.flags,64) = 0     /* not stored as binary */
                   and bitand(opq.flags,512) = 0       /* not hierarch enab */
                   and not exists (select 1 from logstdby_support_11lob lb
                                    where lb.obj# = o.obj# 
                                      and lb.securefile = 1)))
  or bitand(t.property,
                131072     /* 0x00020000 table is used as an AQ queue table */
             ) != 0
  or (bitand(nvl(s.spare1,0), 2048) = 2048    /* Compression */
      and bitand(t.property, 32) != 32) 
  or (bitand(t.property, 32) = 32) 
    and exists (select 1 from partobj$ po
                where po.obj#=o.obj#
                and  (po.parttype in (3,             /* System partitioned */
                                      5)))        /* Reference partitioned */
  or (c.type# not in ( 
                  1,                             /* VARCHAR2 */
                  2,                               /* NUMBER */
                  8,                                 /* LONG */
                  12,                                /* DATE */
                  24,                            /* LONG RAW */
                  96,                                /* CHAR */
                  100,                       /* BINARY FLOAT */
                  101,                      /* BINARY DOUBLE */
                  112,                     /* CLOB and NCLOB */
                  113,                               /* BLOB */
                  180,                     /* TIMESTAMP (..) */
                  181,       /* TIMESTAMP(..) WITH TIME ZONE */
                  182,         /* INTERVAL YEAR(..) TO MONTH */
                  183,     /* INTERVAL DAY(..) TO SECOND(..) */
                  231) /* TIMESTAMP(..) WITH LOCAL TIME ZONE */
  and (c.type# != 23                      /* RAW not RAW OID */
  or  (c.type# = 23 and bitand(c.property, 2) = 2))
  and (c.type# != 58                               /* OPAQUE */
  or  (c.type# = 58                       /* XMLTYPE as CLOB */
      and not exists (select 1 from opqtype$ opq
                  where opq.type=1 
                  and bitand(opq.flags, 4) = 4             /* stored as lob */
                  and bitand(opq.flags,64) = 0      /* not stored as binary */
                  and bitand(opq.flags,512) = 0        /* not hierarch enab */
                  and opq.obj#=c.obj# 
                  and opq.intcol#=c.intcol#
                  and not exists ( select 1 from logstdby_support_11lob lb
                                    where lb.obj# = c.obj# 
                                      and lb.col# = c.col#
                                      and lb.securefile = 1)
))))
  ----------------------------------------------------------
  /* longs must have a scalar column to use as the id key */
  or (c.type# in (8,24,58,112,113)
      and bitand(t.property, 1) = 0                /* typed table has an OID */
      and 0 = (select count(*) from sys.col$ c2
               where t.obj# = c2.obj#
               and bitand(c2.property, 32) != 32               /* Not hidden */
               and (c2.type# in ( 1,                             /* VARCHAR2 */
                                  2,                               /* NUMBER */
                                  12,                                /* DATE */
                                  23,                                 /* RAW */
                                  96,                                /* CHAR */
                                  100,                       /* BINARY FLOAT */
                                  101,                      /* BINARY DOUBLE */
                                  180,                     /* TIMESTAMP (..) */
                                  181,       /* TIMESTAMP(..) WITH TIME ZONE */
                                  182,         /* INTERVAL YEAR(..) TO MONTH */
                                  183,     /* INTERVAL DAY(..) TO SECOND(..) */
                                  231) /* TIMESTAMP(..) WITH LOCAL TIME ZONE */
      )))
  ----------------------------------------------------------
  /* we don't support securefile */
  or  (c.type# in (112, 113)
      and exists (select 1 from logstdby_support_11lob lb
                   where lb.obj# = o.obj#
                     and lb.col# = c.col#
                     and lb.securefile = 1)) 
  ----------------------------------------------------------
  /* we don't support virtual column candidate key */
  or (bitand(c.property, 65544) != 0                      /* Virtual Column */
     and bitand(c.property, 32) != 32                         /* Not hidden */
     and exists (select 1 from icol$ ic, ind$ i
                  where ic.bo# = t.obj# and ic.col# = c.col#
                    and i.bo# = t.obj# and i.obj# = ic.obj#
                    and bitand(i.property, 1) = 1))         /* Unique Index */
  ----------------------------------------------------------
  then 0 else 1 end) gensby
  from sys.obj$ o, sys.user$ u, sys.tab$ t, sys.seg$ s, sys.col$ c
  where o.owner# = u.user#
  and o.obj# = t.obj#
  and o.obj# = c.obj#
  and t.file# = s.file# (+)
  and t.ts# = s.ts# (+)
  and t.block# = s.block# (+)
  and t.obj# = o.obj#
  and bitand(c.property, 32) != 32                         /* Not hidden */
/

-- LOGSTDBY_UNSUPPORT_TAB_10_2
-- This view encapsulates the rules for support of 10.2 redo
--
create or replace view logstdby_unsupport_tab_10_2
as
  select u.name owner, o.name table_name, c.name column_name, 
         c.scale, c.precision#, c.charsetform, c.type#,
   (case when bitand(t.flags, 536870912) = 536870912
         then 'Mapping table for physical rowid of IOT'
         when bitand(nvl(s.spare1, 0), 2048) = 2048 
         then 'Table Compression'
         when bitand(t.property, 1) = 1
         then 'Object Table'
         when bitand(c.property, 67108864) = 67108864  /* 0X4000000 */
         then 'Encrypted Column'
         when bitand(t.property, 131072) = 131072
         then 'AQ queue table'
         else null end) attributes,
    (case 
    /* The following are tables that are system maintained */
    when bitand(o.flags,
                2                                       /* temporary object */
              + 16                                      /* secondary object */
              + 32                                  /* in-memory temp table */
              + 128                           /* dropped table (RecycleBin) */
             ) != 0
    or bitand(t.flags,
                262144     /* 0x00040000        Summary Container Table, MV */ 
              + 134217728  /* 0x08000000          in-memory temporary table */
              + 536870912  /* 0x20000000  Mapping Tab for Phys rowid of IOT */
             ) != 0
    or bitand(t.property,
                512        /* 0x00000200               iot OVeRflow segment */
              + 8192       /* 0x00002000                       nested table */
              + 131072     /* 0x00020000 table is used as an AQ queue table */
              + 4194304    /* 0x00400000             global temporary table */
              + 8388608    /* 0x00800000   session-specific temporary table */
              + 33554432   /* 0x02000000        Read Only Materialized View */
              + 67108864   /* 0x04000000            Materialized View table */
              + 134217728  /* 0x08000000                    Is a Sub object */
              + 2147483648 /* 0x80000000                     eXternal TaBle */
             ) != 0
    or bitand(t.trigflag,
                536870912  /* 0x20000000                  DDLs autofiltered */
               ) != 0
    or exists                                                /* MVLOG table */
       (select 1 
        from sys.mlog$ ml where ml.mowner = u.name and ml.log = o.name) 
    or exists (select 1 from sys.secobj$ so           /* ODCI storage table */
               where o.obj# = so.secobj#) 
  then -1
    /* The following tables are data tables in internal schemata *
     * that are not secondary objects                            */
  when (exists (select 1 from system.logstdby$skip_support s
                where s.name = u.name and action = 0))
  then -2
    /* The following tables are user visible tables that we choose to 
     * skip because of some unsupported attribute of the table or column */
  when bitand(t.property, 
                  1        /* 0x00000001                        typed table */
                + 131072   /* 0x00020000 table is used as an AQ queue table */
             ) != 0
  or (bitand(t.property, 32) = 32) 
    and exists (select 1 from partobj$ po
                where po.obj#=o.obj#
                and  (po.parttype in (3,             /* System partitioned */
                                      5)))        /* Reference partitioned */
  or bitand(t.trigflag,
                65536      /* 0X10000           Table has encrypted columns */
             ) != 0
  or                                                       /* Compression */
       (bitand(nvl(s.spare1,0), 2048) = 2048 and bitand(t.property, 32) != 32) 
  or o.oid$ is not null
  or (c.type# not in ( 
                  1,                             /* VARCHAR2 */
                  2,                               /* NUMBER */
                  8,                                 /* LONG */
                  12,                                /* DATE */
                  24,                            /* LONG RAW */
                  96,                                /* CHAR */
                  100,                       /* BINARY FLOAT */
                  101,                      /* BINARY DOUBLE */
                  112,                     /* CLOB and NCLOB */
                  113,                               /* BLOB */
                  180,                     /* TIMESTAMP (..) */
                  181,       /* TIMESTAMP(..) WITH TIME ZONE */
                  182,         /* INTERVAL YEAR(..) TO MONTH */
                  183,     /* INTERVAL DAY(..) TO SECOND(..) */
                  231) /* TIMESTAMP(..) WITH LOCAL TIME ZONE */
  and (c.type# != 23                      /* RAW not RAW OID */
    or  (c.type# = 23 and bitand(c.property, 2) = 2)))
  ----------------------------------------------------------
  /* longs must have a scalar column to use as the id key */
  or (c.type# in (8,24,112,113)
      and 0 = (select count(*) from sys.col$ c2
               where t.obj# = c2.obj#
               and bitand(c2.property, 32) != 32               /* Not hidden */
               and (c2.type# in ( 1,                             /* VARCHAR2 */
                                  2,                               /* NUMBER */
                                  12,                                /* DATE */
                                  23,                                 /* RAW */
                                  96,                                /* CHAR */
                                  100,                       /* BINARY FLOAT */
                                  101,                      /* BINARY DOUBLE */
                                  180,                     /* TIMESTAMP (..) */
                                  181,       /* TIMESTAMP(..) WITH TIME ZONE */
                                  182,         /* INTERVAL YEAR(..) TO MONTH */
                                  183,     /* INTERVAL DAY(..) TO SECOND(..) */
                                  231) /* TIMESTAMP(..) WITH LOCAL TIME ZONE */
                                  )))
  ----------------------------------------------------------
  then 0 else 1 end) gensby
  from sys.obj$ o, sys.user$ u, sys.tab$ t, sys.seg$ s, sys.col$ c
  where o.owner# = u.user#
  and o.obj# = t.obj#
  and o.obj# = c.obj#
  and t.file# = s.file# (+)
  and t.ts# = s.ts# (+)
  and t.block# = s.block# (+)
  and t.obj# = o.obj#
  and bitand(c.property, 32) != 32                         /* Not hidden */
/

---------------------------------------------------------------------
-- LOGSTDBY_UNSUPPORT_TAB_10_1
-- This view encapsulates the rules for support of 10.1 redo
--
create or replace view logstdby_unsupport_tab_10_1
as
  select u.name owner, o.name table_name, c.name column_name, 
         c.scale, c.precision#, c.charsetform, c.type#,
    (case when bitand(t.property, 128) = 128 
          then 'IOT with Overflow'
          when bitand(t.property, 262208) = 262208
          then 'IOT with LOB' /* user lob */
          when bitand(t.flags, 536870912) = 536870912
          then 'Mapping table for physical rowid of IOT'
          when bitand(t.property, 2112) = 2112
          then 'IOT with LOB' /* internal lob */
          when (bitand(t.property, 64) = 64 
           and bitand(t.flags, 131072) = 131072)
          then 'IOT with row movement'
          when bitand(nvl(s.spare1,0), 2048) = 2048 
          then 'Table Compression'
          when bitand(t.property, 1) = 1
          then 'Object Table' /* typed table/object table */
          when bitand(t.property, 131072) = 131072
          then 'AQ queue table'
          else null end) attributes,
 (case 
    /* The following are tables that are system maintained */
  when bitand(o.flags,
                2                                       /* temporary object */
              + 16                                      /* secondary object */
              + 32                                  /* in-memory temp table */
              + 128                           /* dropped table (RecycleBin) */
             ) != 0
    or bitand(t.flags,
                262144     /* 0x00040000        Summary Container Table, MV */ 
              + 134217728  /* 0x08000000          in-memory temporary table */
              + 536870912  /* 0x20000000  Mapping Tab for Phys rowid of IOT */
             ) != 0
    or bitand(t.property,
                512        /* 0x00000200               iot OVeRflow segment */
              + 8192       /* 0x00002000                       nested table */
              + 4194304    /* 0x00400000             global temporary table */
              + 8388608    /* 0x00800000   session-specific temporary table */
              + 33554432   /* 0x02000000        Read Only Materialized View */
              + 67108864   /* 0x04000000            Materialized View table */
              + 134217728  /* 0x08000000                    Is a Sub object */
              + 2147483648 /* 0x80000000                     eXternal TaBle */
             ) != 0
    or bitand(t.trigflag,
                536870912  /* 0x20000000                  DDLs autofiltered */
               ) != 0
    or exists                                                /* MVLOG table */
       (select 1 
        from sys.mlog$ ml where ml.mowner = u.name and ml.log = o.name) 
    or exists (select 1 from sys.secobj$ so           /* ODCI storage table */
               where o.obj# = so.secobj#) 
  then -1
    /* The following tables are data tables in internal schemata *
     * that are not secondary objects                            */
  when (exists (select 1 from system.logstdby$skip_support s
                where s.name = u.name and action = 0))
  then -2
    /* The following tables are user visible tables that we choose to 
     * skip because of some unsupported attribute of the table or column */
  when bitand(t.property, 
                  1        /* 0x00000001                        typed table */
              + 128        /* 0x00000080              IOT2 with row overflow */
              + 256        /* 0x00000100            IOT with row clustering */
              + 131072     /* 0x00020000 table is used as an AQ queue table */
             ) != 0
    or bitand(t.property, 262208) = 262208   /* 0x40+0x40000 IOT + user LOB */
    or bitand(t.property, 2112) = 2112     /* 0x40+0x800 IOT + internal LOB */
    or                                           /* IOT with "Row Movement" */
       (bitand(t.property, 64) = 64 and bitand(t.flags, 131072) = 131072)
    or (bitand(t.property, 32) = 32) 
      and exists (select 1 from partobj$ po
                where po.obj#=o.obj#
                and  (po.parttype in (3,             /* System partitioned */
                                      5)))        /* Reference partitioned */
    or                                                       /* Compression */
       (bitand(nvl(s.spare1,0), 2048) = 2048 and bitand(t.property, 32) != 32) 
    or o.oid$ is not null
   or 
 (c.type# not in ( 
                  1,                             /* VARCHAR2 */
                  2,                               /* NUMBER */
                  8,                                 /* LONG */
                  12,                                /* DATE */
                  24,                            /* LONG RAW */
                  96,                                /* CHAR */
                  100,                       /* BINARY FLOAT */
                  101,                      /* BINARY DOUBLE */
                  112,                     /* CLOB and NCLOB */
                  113,                               /* BLOB */
                  180,                     /* TIMESTAMP (..) */
                  181,       /* TIMESTAMP(..) WITH TIME ZONE */
                  182,         /* INTERVAL YEAR(..) TO MONTH */
                  183,     /* INTERVAL DAY(..) TO SECOND(..) */
                  231) /* TIMESTAMP(..) WITH LOCAL TIME ZONE */
  and (c.type# != 23                      /* RAW not RAW OID */
       or (c.type# = 23 and bitand(c.property, 2) = 2)))
  ----------------------------------------------------------
  /* longs must have a scalar column to use as the id key */
  or (c.type# in (8,24,112,113)
      and 0 = (select count(*) from sys.col$ c2
               where t.obj# = c2.obj#
               and bitand(c2.property, 32) != 32               /* Not hidden */
               and (c2.type# in ( 1,                             /* VARCHAR2 */
                                  2,                               /* NUMBER */
                                  12,                                /* DATE */
                                  23,                                 /* RAW */
                                  96,                                /* CHAR */
                                  100,                       /* BINARY FLOAT */
                                  101,                      /* BINARY DOUBLE */
                                  180,                     /* TIMESTAMP (..) */
                                  181,       /* TIMESTAMP(..) WITH TIME ZONE */
                                  182,         /* INTERVAL YEAR(..) TO MONTH */
                                  183,     /* INTERVAL DAY(..) TO SECOND(..) */
                                  231) /* TIMESTAMP(..) WITH LOCAL TIME ZONE */
                                  )))
  ----------------------------------------------------------
   then 0 else 1 end) gensby
 from sys.obj$ o, sys.user$ u, sys.tab$ t, sys.seg$ s, sys.col$ c
where o.owner# = u.user#
  and o.obj# = t.obj#
  and o.obj# = c.obj#
  and t.file# = s.file# (+)
  and t.ts# = s.ts# (+)
  and t.block# = s.block# (+)
  and t.obj# = o.obj#
  and bitand(c.property, 32) != 32                         /* Not hidden */
/

create or replace view dba_logstdby_unsupported
as
  with redo_compat as
         (select nvl((select min(s.redo_compat)
                      from system.logstdby$parameters p,
                           system.logmnr_session$ s,
                           sys.v$database d
                      where p.name in ('LMNR_SID', 'FUTURE_SESSION') and
                            p.value = s.session# and
                            d.database_role = 'LOGICAL STANDBY'),
                     (select p.value
                      from sys.v$parameter p
                      where p.name = 'compatible')) compat
          from dual) 
  select owner, table_name, column_name, attributes,
  substrb(decode(type#, 1, decode(charsetform, 2, 'NVARCHAR2', 'VARCHAR2'),
                2, decode(scale, null, decode(precision#, null, 
                          'NUMBER', 'FLOAT'), 'NUMBER'),
                8, 'LONG',
                9, decode(charsetform, 2, 'NCHAR VARYING', 'VARCHAR'),
                12, 'DATE',
                23, 'RAW', 
                24, 'LONG RAW',
                58, 'OPAQUE',
                69, 'ROWID', 
                96, decode(charsetform, 2, 'NCHAR', 'CHAR'),
                100, 'BINARY_FLOAT',
                101, 'BINARY_DOUBLE',
                105, 'MLSLABEL',
                106, 'MLSLABEL',
                110, 'REF',
                111, 'REF',
                112, decode(charsetform, 2, 'NCLOB', 'CLOB'),
                113, 'BLOB', 
                114, 'BFILE', 
                115, 'CFILE',
                121, 'OBJECT',
                122, 'NESTED TABLE',
                123, 'VARRAY',
                178, 'TIME(' ||scale|| ')',
                179, 'TIME(' ||scale|| ')' || ' WITH TIME ZONE',
                180, 'TIMESTAMP(' ||scale|| ')',
                181, 'TIMESTAMP(' ||scale|| ')' || ' WITH TIME ZONE',
                231, 'TIMESTAMP(' ||scale|| ')' || ' WITH LOCAL TIME ZONE',
                182, 'INTERVAL YEAR(' ||precision#||') TO MONTH',
                183, 'INTERVAL DAY(' ||precision#||') TO SECOND(' 
                                     || scale || ')',
                208, 'UROWID',
                'UNDEFINED'),1,106) data_type
  from ( 
    select u.owner, u.table_name, u.column_name, u.scale, u.precision#, 
           u.charsetform, u.type#, u.attributes, u.gensby 
    from logstdby_unsupport_tab_10_1 u, redo_compat c
    where c.compat like '10.0%' or c.compat like '10.1%'
    UNION ALL
    select u.owner, u.table_name, u.column_name, u.scale, u.precision#, 
           u.charsetform, u.type#, u.attributes, u.gensby 
    from logstdby_unsupport_tab_10_2 u, redo_compat c
    where c.compat like '10.2%'
    UNION ALL
    select u.owner, u.table_name, u.column_name, u.scale, u.precision#, 
           u.charsetform, u.type#, u.attributes, u.gensby 
    from logstdby_unsupport_tab_11_1 u, redo_compat c
    where c.compat like '11.0%' or c.compat like '11.1%'
    UNION ALL
    select u.owner, u.table_name, u.column_name, u.scale, u.precision#, 
           u.charsetform, u.type#, u.attributes, u.gensby 
    from logstdby_unsupport_tab_11_2 u, redo_compat c
    where c.compat like '11.2%' and c.compat not like '11.2.0.3%'
                                and c.compat not like '11.2.0.4%'
    UNION ALL
    select u.owner, u.table_name, u.column_name, u.scale, u.precision#, 
           u.charsetform, u.type#, u.attributes, u.gensby 
    from logstdby_unsupport_tab_11_2b u, redo_compat c
    where c.compat like '11.2.0.3%' or c.compat like '11.2.0.4%'
    UNION ALL
    select u.owner, u.table_name, u.column_name, u.scale, u.precision#, 
           u.charsetform, u.type#, u.attributes, u.gensby 
    from logstdby_unsupport_tab_12_1 u, redo_compat c
    where c.compat like '12.0%' or c.compat like '12.1%'
    UNION ALL
    select u.owner, u.table_name, u.column_name, u.scale, u.precision#, 
           u.charsetform, u.type#, u.attributes, u.gensby 
    from logstdby_unsupport_tab_12_2 u, redo_compat c
    where c.compat like '12.2%' and c.compat not like '12.2.0.2%'
    UNION ALL
    select u.owner, u.table_name, u.column_name, u.scale, u.precision#, 
           u.charsetform, u.type#, u.attributes, u.gensby 
    from logstdby_unsupp_tab_12_2_0_2 u, redo_compat c
    where c.compat like '12.2.0.2%' or c.compat like '18.0%' 
          or c.compat like '18.1%'
)
  where gensby = 0
/

create or replace public synonym dba_logstdby_unsupported
   for dba_logstdby_unsupported
/
grant select on dba_logstdby_unsupported to select_catalog_role
/
comment on table dba_logstdby_unsupported is 
'List of all the columns that are not supported by Logical Standby'
/
comment on column dba_logstdby_unsupported.owner is 
'Schema name of unsupported column'
/
comment on column dba_logstdby_unsupported.table_name is 
'Table name of unsupported column'
/
comment on column dba_logstdby_unsupported.column_name is 
'Column name of unsupported column'
/
comment on column dba_logstdby_unsupported.data_type is
'Datatype of unsupported column'
/
comment on column dba_logstdby_unsupported.attributes is
'If not a data type issue, gives the reason why the table is unsupported'
/


execute CDBView.create_cdbview(false,'SYS','DBA_LOGSTDBY_UNSUPPORTED','CDB_LOGSTDBY_UNSUPPORTED');
grant select on SYS.CDB_logstdby_unsupported to select_catalog_role
/
create or replace public synonym CDB_logstdby_unsupported for SYS.CDB_logstdby_unsupported
/

create or replace view dba_rolling_unsupported
as
  with redo_compat as
         (select nvl((select min(s.redo_compat)
                      from system.logstdby$parameters p,
                           system.logmnr_session$ s,
                           sys.v$database d
                      where p.name in ('LMNR_SID', 'FUTURE_SESSION') and
                            p.value = s.session# and
                            d.database_role = 'LOGICAL STANDBY'),
                     (select p.value
                      from sys.v$parameter p
                      where p.name = 'compatible')) compat
          from dual) 
  select owner, table_name, column_name, attributes,
  substrb(decode(type#, 1, decode(charsetform, 2, 'NVARCHAR2', 'VARCHAR2'),
                2, decode(scale, null, decode(precision#, null, 
                          'NUMBER', 'FLOAT'), 'NUMBER'),
                8, 'LONG',
                9, decode(charsetform, 2, 'NCHAR VARYING', 'VARCHAR'),
                12, 'DATE',
                23, 'RAW', 
                24, 'LONG RAW',
                58, 'OPAQUE',
                69, 'ROWID', 
                96, decode(charsetform, 2, 'NCHAR', 'CHAR'),
                100, 'BINARY_FLOAT',
                101, 'BINARY_DOUBLE',
                105, 'MLSLABEL',
                106, 'MLSLABEL',
                110, 'REF',
                111, 'REF',
                112, decode(charsetform, 2, 'NCLOB', 'CLOB'),
                113, 'BLOB', 
                114, 'BFILE', 
                115, 'CFILE',
                121, 'OBJECT',
                122, 'NESTED TABLE',
                123, 'VARRAY',
                178, 'TIME(' ||scale|| ')',
                179, 'TIME(' ||scale|| ')' || ' WITH TIME ZONE',
                180, 'TIMESTAMP(' ||scale|| ')',
                181, 'TIMESTAMP(' ||scale|| ')' || ' WITH TIME ZONE',
                231, 'TIMESTAMP(' ||scale|| ')' || ' WITH LOCAL TIME ZONE',
                182, 'INTERVAL YEAR(' ||precision#||') TO MONTH',
                183, 'INTERVAL DAY(' ||precision#||') TO SECOND(' 
                                     || scale || ')',
                208, 'UROWID',
                'UNDEFINED'),1,106) data_type
  from (
   select u.owner, u.table_name, u.column_name, u.scale, u.precision#, 
           u.charsetform, u.type#, u.attributes, u.gensby 
    from logstdby_unsupport_tab_10_1 u, redo_compat c
    where c.compat like '10.0%' or c.compat like '10.1%'
    UNION ALL
   select u.owner, u.table_name, u.column_name, u.scale, u.precision#, 
           u.charsetform, u.type#, u.attributes, u.gensby 
    from logstdby_unsupport_tab_10_2 u, redo_compat c
    where c.compat like '10.2%'
    UNION ALL
   select u.owner, u.table_name, u.column_name, u.scale, u.precision#, 
           u.charsetform, u.type#, u.attributes, u.gensby 
    from logstdby_unsupport_tab_11_1 u, redo_compat c
    where c.compat like '11.0%' or c.compat like '11.1%'
    UNION ALL
   select u.owner, u.table_name, u.column_name, u.scale, u.precision#, 
           u.charsetform, u.type#, u.attributes, u.gensby 
    from logstdby_unsupport_tab_11_2 u, redo_compat c
    where c.compat like '11.2%' and c.compat not like '11.2.0.3%'
                                and c.compat not like '11.2.0.4%'
    UNION ALL
    select u.owner, u.table_name, u.column_name, u.scale, u.precision#, 
           u.charsetform, u.type#, u.attributes, u.gensby 
    from logstdby_unsupport_tab_11_2b u, redo_compat c
    where c.compat like '11.2.0.3%' or c.compat like '11.2.0.4%'
    UNION ALL
    select u.owner, u.table_name, u.column_name, u.scale, u.precision#, 
           u.charsetform, u.type#, u.attributes, u.gensby 
    from logstdby_ru_unsupport_tab_12_1 u, redo_compat c
    where c.compat like '12.0%' or c.compat like '12.1%'
    UNION ALL
    select u.owner, u.table_name, u.column_name, u.scale, u.precision#, 
           u.charsetform, u.type#, u.attributes, u.gensby 
    from logstdby_ru_unsupport_tab_12_2 u, redo_compat c
    where c.compat like '12.2%' and c.compat not like '12.2.0.2%'
    UNION ALL
    select u.owner, u.table_name, u.column_name, u.scale, u.precision#, 
           u.charsetform, u.type#, u.attributes, u.gensby 
    from logstdby_ru_un_tab_12_2_0_2 u, redo_compat c
    where c.compat like '12.2.0.2%' or c.compat like '18.0%' 
          or c.compat like '18.1%'
)
  where gensby = 0
/

create or replace public synonym dba_rolling_unsupported
   for dba_rolling_unsupported
/
grant select on dba_rolling_unsupported to select_catalog_role
/
comment on table dba_rolling_unsupported is 
'List of all the columns that are not supported by DBMS_ROLLING upgrades'
/
comment on column dba_rolling_unsupported.owner is 
'Schema name of unsupported column'
/
comment on column dba_rolling_unsupported.table_name is 
'Table name of unsupported column'
/
comment on column dba_rolling_unsupported.column_name is 
'Column name of unsupported column'
/
comment on column dba_rolling_unsupported.data_type is
'Datatype of unsupported column'
/
comment on column dba_rolling_unsupported.attributes is
'If not a data type issue, gives the reason why the table is unsupported'
/


execute CDBView.create_cdbview(false,'SYS','DBA_ROLLING_UNSUPPORTED','CDB_ROLLING_UNSUPPORTED');
grant select on SYS.CDB_rolling_unsupported to select_catalog_role
/
create or replace public synonym CDB_rolling_unsupported for SYS.CDB_rolling_unsupported
/

---------------------------------------------------------------------
-- DBA_LOGSTDBY_NOT_UNIQUE 
-- We do not supplementally log longs and virtual columns.
-- This view identifies tables that have no usable candidate key
-- and which also have columns which are not supp logged.
-- There is a chance that we could update the wrong row on the standby
-- The bad_column attribute shows for each table:
--   'Y' - the table has a candidate key or it has no non-supplogged cols
--   'N' - one or more columns cannot be predicated from the redo data
--         and it has no candidate key; DBA should add rely constraint!
--  note #1: 
--        cdef$ defer bits:
--          0x1: deferrable => if this bit set, the PK does not count.
--          0x4: sys validated 
--          0x20: rely         
--          bitand(defer, 37) in (4, 32, 36) => 
--           (0x25 & defer) = (0x4 | 0x20| 0x24)
--        col$ property bits:
--          NOTE 32k type columns (varchar & raw) will show up as 
--          DTYCHR or DTYBIN with the column property bit of 128.
--          0x80 = 128 = stored in a lob
--          0x20 =  32 = hidden column 
--          0x8  =  08 = virtual column)
--          0x2  =  02 = OID column     
--
--  note #2: The two "not exists" clauses (conditions #1 and #2) are 
--  verifying that there is no replication friendly "logical identification" 
--  key for the table in question. In other words, the rows in the table
--  are deemed not unique by the replication framework (possibly, 
--  even in the presence of a well defined primary key or a unique index
--  with at least one not-nullable column). Note that XML typed tables
--  with non-virtual OID columns are deemed supportable as the OID 
--  column could be used as logical row identifier, regardless of the 
--  nature of other unique indexes or primary key, if any, on those 
--  tables. For non-typed tables, the following conditions apply.
-- 
--   condition #1: A unique index that meets any of the following conditions
--   cannot be used as an identification key for logical replication.
--      
--      1. It does not have a not-nullable column.
--      2. It is a not a btree index.
--      3. It has dependencies on either virtual column(s) or 
--         hidden columns or 32k columns
--        (this is verified in the second not-exists subquery block).
-- 
--   condition #2: A primary key that meets any of the following conditions
--   cannot be used as an identification key for logical replication.
--  
--      1. It is marked deferrable OR is not marked as rely or sys-validated.
--      2. It has dependencies on either virtual column(s) or 
--         hidden columns or 32k columns
--         (this is verified in the second not-exists subquery block).
--    
---------------------------------------------------------------------
create or replace view dba_logstdby_not_unique
as
  with redo_compat as
         (select nvl((select min(s.redo_compat)
                      from system.logstdby$parameters p,
                           system.logmnr_session$ s,
                           sys.v$database d
                      where p.name in ('LMNR_SID', 'FUTURE_SESSION') and
                            p.value = s.session# and
                            d.database_role = 'LOGICAL STANDBY'),
                     (select p.value
                      from sys.v$parameter p
                      where p.name = 'compatible')) compat
          from dual) 
  select owner, name table_name, 
         decode((select count(c.obj#)
                 from sys.col$ c
                 where c.obj# = l.obj#
                 and ((c.type# in (8,                             /* LONG */
                                   24,                        /* LONG RAW */
                                   58,                             /* XML */
                                   112,                           /* CLOB */
                                   113,                           /* BLOB */
                                   114))                         /* BFILE */
                 or (c.type# = 1 and bitand(c.property, 128) = 128))), 
                 /* 32k varchar */
                 0, 'N', 'Y') bad_column
  from (
    select u.owner, u.name, u.type#, u.obj#, u.current_sby, u.gensby 
    from logstdby_support_tab_10_1 u, redo_compat c
    where c.compat like '10.0%' or c.compat like '10.1%'
    UNION ALL
    select u.owner, u.name, u.type#, u.obj#, u.current_sby, u.gensby 
    from logstdby_support_tab_10_2 u, redo_compat c
    where c.compat like '10.2%'
    UNION ALL
    select u.owner, u.name, u.type#, u.obj#, u.current_sby, u.gensby 
    from logstdby_support_tab_11_1 u, redo_compat c
    where c.compat like '11.0%' or c.compat like '11.1%'
    UNION ALL
    select u.owner, u.name, u.type#, u.obj#, u.current_sby, u.gensby 
    from logstdby_support_tab_11_2 u, redo_compat c
    where c.compat like '11.2%' and c.compat not like '11.2.0.3%'
                                and c.compat not like '11.2.0.4%'
    UNION ALL
    select u.owner, u.name, u.type#, u.obj#, u.current_sby, u.gensby 
    from logstdby_support_tab_11_2b u, redo_compat c
    where c.compat like '11.2.0.3%' or c.compat like '11.2.0.4%'
    UNION ALL
    select u.owner, u.name, u.type#, u.obj#, u.current_sby, u.gensby 
    from logstdby_support_tab_12_1 u, redo_compat c
    where c.compat like '12.0%' or c.compat like '12.1%'
    UNION ALL
    select u.owner, u.name, u.type#, u.obj#, u.current_sby, u.gensby 
    from logstdby_support_tab_12_2 u, redo_compat c
    where c.compat like '12.2%' and c.compat not like '12.2.0.2%'
    UNION ALL
    select u.owner, u.name, u.type#, u.obj#, u.current_sby, u.gensby 
    from logstdby_support_tab_12_2_0_2 u, redo_compat c
    where c.compat like '12.2.0.2%' or c.compat like '18.0%' 
          or c.compat like '18.1%'
  ) l, tab$ t
  where gensby = 1
    and l.type# = 2
    and l.obj# = t.obj# and
        bitand(t.property, 1) = 0                    /* rule out typed table */
    and not exists                    /* not null unique key -- condition #1 */
       (select null -- (tagA)
        from ind$ i, icol$ ic, col$ c
        where i.bo# = l.obj#
          and ic.obj# = i.obj#
          and c.col# = ic.col#
          and c.obj# = i.bo#
          and c.null$ > 0                                       /* not null */
          and i.type# = 1                                          /* Btree */
          and bitand(i.property, 1) = 1                           /* Unique */
          and i.intcols = i.cols                      /* no virtual columns */
          and not exists (select null 
                          from icol$ icol2, col$ col2
                          where  icol2.obj# = i.obj# and 
                                 icol2.bo#  = i.bo#  and -- redundant
                                 icol2.bo#  = col2.obj# and
                                 icol2.intcol# = col2.intcol# and
                                 bitand(col2.property, 168) != 0)) -- (tagA)
    and not exists               /* primary key constraint --  condition #2 */
       (select null                         /* defer bit 0x1: deferrable    */
        from cdef$ cd                       /*       bit 0x4: sys validated */
        where cd.obj# = l.obj#              /*       bit 0x20: rely         */
          and cd.type# = 2 
          and bitand(cd.defer, 37) in (4, 32, 36) 
          and not exists (select null 
                          from ccol$ ccol3, col$ col3
                          where ccol3.con# = cd.con# and 
                                ccol3.obj# = cd.obj# and 
                                ccol3.obj# = col3.obj# and 
                                ccol3.intcol# = col3.intcol# and 
                                bitand(col3.property, 168) != 0)
        )
/
create or replace public synonym dba_logstdby_not_unique
   for dba_logstdby_not_unique
/
grant select on dba_logstdby_not_unique to select_catalog_role
/
comment on table dba_logstdby_not_unique is 
'List of all the tables with out primary or unique key not null constraints'
/
comment on column dba_logstdby_not_unique.owner is 
'Schema name of the non-unique table'
/
comment on column dba_logstdby_not_unique.table_name is 
'Table name of the non-unique table'
/
comment on column dba_logstdby_not_unique.bad_column is 
'Indicates that the table has a column not useful in the where clause'
/


execute CDBView.create_cdbview(false,'SYS','DBA_LOGSTDBY_NOT_UNIQUE','CDB_LOGSTDBY_NOT_UNIQUE');
grant select on SYS.CDB_logstdby_not_unique to select_catalog_role
/
create or replace public synonym CDB_logstdby_not_unique for SYS.CDB_logstdby_not_unique
/

create or replace view dba_logstdby_parameters
as
  select name, value, unit, setting, dynamic
  from x$dglparam where visible=1
/
create or replace public synonym dba_logstdby_parameters
   for dba_logstdby_parameters
/
grant select on dba_logstdby_parameters to select_catalog_role
/
comment on table dba_logstdby_parameters is 
'Miscellaneous options and settings for Logical Standby'
/
comment on column dba_logstdby_parameters.name is 
'Name of the parameter'
/
comment on column dba_logstdby_parameters.value is 
'Optional value of the parameter'
/
comment on column dba_logstdby_parameters.unit is 
'Unit of the value, if applicable'
/
comment on column dba_logstdby_parameters.setting is 
'Indicates if the parameter was set by the user or the system'
/
comment on column dba_logstdby_parameters.dynamic is 
'Indicates if the parameter can be set without having to stop SQL Apply'
/



execute CDBView.create_cdbview(false,'SYS','DBA_LOGSTDBY_PARAMETERS','CDB_LOGSTDBY_PARAMETERS');
grant select on SYS.CDB_logstdby_parameters to select_catalog_role
/
create or replace public synonym CDB_logstdby_parameters for SYS.CDB_logstdby_parameters
/

-- DBA_LOGSTDBY_PROGRESS view
-- Just break things down to understand them.
-- First, the logstdby_log view is just an aid so we can include v$standby_log
-- information in our views.  So it combines logs in logmnr_log$ with
-- v$standby_log logs.
-- Second, the dba_logstdby_progress view is just a collection of subqueries.
-- There are three important columns that are computed in the base in-line
-- view X.  These are APPLIED_SCN, READ_SCN (past tense), and NEWEST_SCN.
-- Once these are computed, they are used as the source to compute all the
-- other columns in the view.
create or replace view logstdby_log
as
  select first_change#, next_change#, sequence#, thread#, 
         first_time, next_time
  from system.logmnr_log$ where session# = 
     (select value from system.logstdby$parameters where name = 'LMNR_SID')
    /* comment */
 union
  select first_change#, (last_change# + 1) next_change#, sequence#, thread#,
         first_time, last_time next_time
  from v$standby_log where status = 'ACTIVE'
/

create or replace view dba_logstdby_progress
as
  select
    applied_scn,
    /* thread# derived from applied_scn */
    (select min(thread#) from logstdby_log 
     where sequence# = 
       (select max(sequence#) from logstdby_log l
        where applied_scn >= first_change# and applied_scn <= next_change#)
    and applied_scn >= first_change# 
    and applied_scn <= next_change#)
       applied_thread#,
    /* sequence# derived from applied_scn */
    (select max(sequence#) from logstdby_log l
     where applied_scn >= first_change# and applied_scn <= next_change#)
       applied_sequence#,
    /* estimated time derived from applied_scn */
    (select max(first_time +
        ((next_time - first_time) / (next_change# - first_change#) *
         (applied_scn - first_change#)))
     from logstdby_log l
     where applied_scn >= first_change# and applied_scn <= next_change#)
       applied_time,
    read_scn,
    /* thread# derived from read_scn */
    (select min(thread#) from logstdby_log 
     where sequence# = 
       (select max(sequence#) from logstdby_log l
        where read_scn >= first_change# and read_scn <= next_change#)
     and read_scn >= first_change#
     and read_scn <= next_change#)
       read_thread#,
    /* sequence# derived from read_scn */
    (select max(sequence#) from logstdby_log l
     where read_scn >= first_change# and read_scn <= next_change#)
       read_sequence#,
    /* estimated time derived from read_scn */
    (select min(first_time +
        ((next_time - first_time) / (next_change# - first_change#) *
         (read_scn - first_change#)))
     from logstdby_log l
     where read_scn >= first_change# and read_scn <= next_change#)
       read_time,
    newest_scn,
    /* thread# derived from newest_scn */
    (select min(thread#) from logstdby_log 
     where sequence# = 
       (select max(sequence#) from logstdby_log l
        where newest_scn >= first_change# and newest_scn <= next_change#)
     and newest_scn >= first_change#
     and newest_scn <= next_change#)
       newest_thread#,
    /* sequence# derived from newest_scn */
    (select max(sequence#) from logstdby_log l
     where newest_scn >= first_change# and newest_scn <= next_change#)
       newest_sequence#,
    /* estimated time derived from newest_scn */
    (select max(first_time +
        ((next_time - first_time) / (next_change# - first_change#) *
         (newest_scn - first_change#)))
     from logstdby_log l
     where newest_scn >= first_change# and newest_scn <= next_change#)
       newest_time
  from
    /* in-line view to calculate relavent scn values */
    (select /* APPLIED_SCN */
            greatest(nvl((select max(a.processed_scn) - 1
                          from system.logstdby$apply_milestone a),0),
                     nvl((select max(a.commit_scn)
                          from system.logstdby$apply_milestone a),0),
                     sx.start_scn) applied_scn,
            /* READ_SCN */
            greatest(nvl(sx.spill_scn,1), sx.start_scn) read_scn,
            /* NEWEST_SCN */
            nvl((select max(next_change#)-1 from logstdby_log),
                sx.start_scn) newest_scn
    from system.logmnr_session$ sx
    where sx.session# =
      (select value from system.logstdby$parameters where name = 'LMNR_SID')) x
/
grant select on dba_logstdby_progress to select_catalog_role
/
create or replace public synonym dba_logstdby_progress
   for dba_logstdby_progress
/
comment on table dba_logstdby_progress is 
'List the SCN values describing read and apply progress'
/
comment on column dba_logstdby_progress.applied_scn is 
'All transactions with a commit SCN <= this value have been applied'
/
comment on column dba_logstdby_progress.applied_thread# is 
'Thread number for a log containing the applied_scn'
/
comment on column dba_logstdby_progress.applied_sequence# is 
'Sequence number for a log containing the applied_scn'
/
comment on column dba_logstdby_progress.applied_time is 
'Estimate of the time the applied_scn was generated'
/
comment on column dba_logstdby_progress.read_scn is 
'All log data less than this SCN has been preserved in the database'
/
comment on column dba_logstdby_progress.read_thread# is 
'Thread number for a log containing the read_scn'
/
comment on column dba_logstdby_progress.read_sequence# is 
'Sequence number for a log containing the read_scn'
/
comment on column dba_logstdby_progress.read_time is 
'Estimate of the time the read_scn was generated'
/
comment on column dba_logstdby_progress.newest_scn is 
'The highest SCN that could be applied given the existing logs'
/
comment on column dba_logstdby_progress.newest_thread# is 
'Thread number for a log containing the newest_scn'
/
comment on column dba_logstdby_progress.newest_sequence# is 
'Sequence number for a log containing the newest_scn'
/
comment on column dba_logstdby_progress.newest_time is 
'Estimate of the time the newest_scn was generated'
/

execute CDBView.create_cdbview(false,'SYS','DBA_LOGSTDBY_PROGRESS','CDB_LOGSTDBY_PROGRESS');
grant select on sys.cdb_logstdby_progress to select_catalog_role
/
create or replace public synonym cdb_logstdby_progress for sys.cdb_logstdby_progress
/

-- Logmnr tables aren't created yet so FORCE was necessary --
-- (don't list dummy entries)
create or replace force view dba_logstdby_log
as
  select thread#, resetlogs_change#, reset_timestamp resetlogs_id, sequence#, 
         first_change#, next_change#, first_time, next_time, file_name,
          timestamp, dict_begin, dict_end,
    (case when l.next_change# <= p.read_scn then 'YES'
          when ((bitand(l.contents, 16) = 16) and
                (bitand(l.status, 4) = 0)) then 'FETCHING'
          when ((bitand(l.contents, 16) = 16) and
                (bitand(l.status, 4) = 4)) then 'CORRUPT'
          when l.first_change# < p.applied_scn then 'CURRENT'
          else 'NO' end) applied, blocks, block_size
  from system.logmnr_log$ l, dba_logstdby_progress p
  where session# =
    (select value from system.logstdby$parameters where name = 'LMNR_SID') and
    (flags is NULL or bitand(l.flags,16) = 0)
/
grant select on dba_logstdby_log to select_catalog_role
/
create or replace public synonym dba_logstdby_log for dba_logstdby_log
/

comment on table dba_logstdby_log is
'List the information about received logs from the primary'
/
comment on column dba_logstdby_log.thread# is 
'Redo thread number'
/
comment on column dba_logstdby_log.resetlogs_change# is 
'Start SCN of the branch'
/
comment on column dba_logstdby_log.resetlogs_id is 
'Resetlogs identifier, a numeric form of the timestamp of the branch'
/
comment on column dba_logstdby_log.sequence# is 
'Redo log sequence number'
/
comment on column dba_logstdby_log.first_change# is 
'First change# in the archived log'
/
comment on column dba_logstdby_log.next_change# is 
'First change in the next log'
/
comment on column dba_logstdby_log.first_time is 
'Timestamp of the first change'
/
comment on column dba_logstdby_log.next_time is 
'Timestamp of the next change'
/
comment on column dba_logstdby_log.file_name is 
'Archived log file name'
/
comment on column dba_logstdby_log.timestamp is 
'Time when the archiving completed'
/
comment on column dba_logstdby_log.dict_begin is 
'Contains beginning of Log Miner Dictionary'
/
comment on column dba_logstdby_log.dict_end is 
'Contains end of Log Miner Dictionary'
/
comment on column dba_logstdby_log.applied is 
'Indicates apply progress through log stream'
/
comment on column dba_logstdby_log.blocks is 
'Indicates the number of blocks in the log'
/
comment on column dba_logstdby_log.block_size is 
'Indicates the size of each block in the log'
/

execute CDBView.create_cdbview(false,'SYS','DBA_LOGSTDBY_LOG','CDB_LOGSTDBY_LOG');
grant select on sys.cdb_logstdby_log to select_catalog_role
/
create or replace public synonym CDB_logstdby_log for SYS.CDB_logstdby_log
/

create or replace view dba_logstdby_skip_transaction
as
  select xidusn, xidslt, xidsqn, con_name
  from system.logstdby$skip_transaction
/
create or replace public synonym dba_logstdby_skip_transaction 
   for dba_logstdby_skip_transaction
/
grant select on dba_logstdby_skip_transaction to select_catalog_role
/
comment on table dba_logstdby_skip_transaction is 
'List the transactions to be skipped'
/
comment on column dba_logstdby_skip_transaction.xidusn is 
'Transaction id, component 1 of 3'
/
comment on column dba_logstdby_skip_transaction.xidslt is 
'Transaction id, component 2 of 3'
/
comment on column dba_logstdby_skip_transaction.xidsqn is 
'Transaction id, component 3 of 3'
/
comment on column dba_logstdby_skip_transaction.con_name is 
'Container name'
/


execute CDBView.create_cdbview(false,'SYS','DBA_LOGSTDBY_SKIP_TRANSACTION','CDB_LOGSTDBY_SKIP_TRANSACTION');
grant select on SYS.CDB_logstdby_skip_transaction to select_catalog_role
/
create or replace public synonym CDB_logstdby_skip_transaction for SYS.CDB_logstdby_skip_transaction
/

create or replace view dba_logstdby_skip
as
  select decode(error, 1, 'Y', 'N') error,
         statement_opt, schema owner, name,
         decode(use_like, 0, 'N', 'Y') use_like, esc, proc
  from system.logstdby$skip
  union all
  select 'N' error,
         'INTERNAL SCHEMA' statement_opt, u.username owner, '%' name,
         'N' use_like, null esc, null proc
  from dba_users u, system.logstdby$skip_support s
  where u.username = s.name
  and   s.action = 0
/
create or replace public synonym dba_logstdby_skip for dba_logstdby_skip
/
grant select on dba_logstdby_skip to select_catalog_role
/
comment on table dba_logstdby_skip is 
'List the skip settings choosen'
/
comment on column dba_logstdby_skip.error is 
'Does this skip setting only apply to failed attempts'
/
comment on column dba_logstdby_skip.statement_opt is 
'The statement option choosen to skip'
/
comment on column dba_logstdby_skip.owner is 
'Schema name under which this skip option should be applied'
/
comment on column dba_logstdby_skip.name is 
'Object name under which this skip option should be applied'
/
comment on column dba_logstdby_skip.use_like is 
'Use SQL wildcard search when matching names'
/
comment on column dba_logstdby_skip.esc is 
'The escape character used when performing wildcard matches.'
/
comment on column dba_logstdby_skip.proc is 
'The stored procedure to call for this skip setting.  DDL only'
/



execute CDBView.create_cdbview(false,'SYS','DBA_LOGSTDBY_SKIP','CDB_LOGSTDBY_SKIP');
grant select on SYS.CDB_logstdby_skip to select_catalog_role
/
create or replace public synonym CDB_logstdby_skip for SYS.CDB_logstdby_skip
/

create or replace view dba_logstdby_events
as
  select cast(event_time as date) event_time, event_time event_timestamp, 
         spare1 as start_scn, current_scn, commit_scn, xidusn, xidslt, xidsqn,
         full_event event, errval status_code, error status, 
         con_name src_con_name, con_id src_con_id
  from system.logstdby$events
/
create or replace public synonym dba_logstdby_events for dba_logstdby_events
/
grant select on dba_logstdby_events to select_catalog_role
/
comment on table dba_logstdby_events is 
'Information on why logical standby events'
/
comment on column dba_logstdby_events.event_time is
'Time the event took place'
/
comment on column dba_logstdby_events.event_timestamp is
'Timestamp when the event took place'
/
comment on column dba_logstdby_events.start_scn is
'SCN at which the transaction started'
/
comment on column dba_logstdby_events.current_scn is
'Change vector SCN for the change'
/
comment on column dba_logstdby_events.commit_scn is
'SCN for the commit record of the transaction'
/
comment on column dba_logstdby_events.xidusn is
'Transaction id, part 1 of 3'
/
comment on column dba_logstdby_events.xidslt is
'Transaction id, part 2 of 3'
/
comment on column dba_logstdby_events.xidsqn is
'Transaction id, part 3 of 3'
/
comment on column dba_logstdby_events.event is
'A SQL statement or other text describing the event'
/
comment on column dba_logstdby_events.status is
'A text string describing the event'
/
comment on column dba_logstdby_events.status_code is
'A number describing the event'
/
comment on column dba_logstdby_events.src_con_name is
'Source container name'
/
comment on column dba_logstdby_events.src_con_id is
'Source container id'
/


execute CDBView.create_cdbview(false,'SYS','DBA_LOGSTDBY_EVENTS','CDB_LOGSTDBY_EVENTS');
grant select on SYS.CDB_logstdby_events to select_catalog_role
/
create or replace public synonym CDB_logstdby_events for SYS.CDB_logstdby_events
/

create or replace view dba_logstdby_history
as
  select stream_sequence#, decode(status, 1, 'Past', 2, 'Immediate Past', 3, 
         'Current', 4, 'Immediate Future', 5, 'Future', 6, 'Canceled', 7,
         'Invalid') status, decode(source, 1, 'Rfs', 2, 'User', 3, 'Synch', 4,
         'Redo') source, dbid, first_change#, last_change#, first_time, 
         last_time, dgname, spare1 merge_change#, spare2 processed_change# 
  from system.logstdby$history
/
create or replace public synonym dba_logstdby_history for dba_logstdby_history
/
grant select on dba_logstdby_history to select_catalog_role
/
comment on table dba_logstdby_history is 
'Information on processed, active, and pending log streams'
/
comment on column dba_logstdby_history.stream_sequence# is
'Log Stream Identifier'
/
comment on column dba_logstdby_history.status is
'The processing status of this log stream'
/
comment on column dba_logstdby_history.source is
'How the logstream was started'
/
comment on column dba_logstdby_history.dbid is
'The dbid of the logfile provider'
/
comment on column dba_logstdby_history.first_change# is
'The starting scn for this log stream'
/
comment on column dba_logstdby_history.last_change# is
'The scn of the last committed transaction'
/
comment on column dba_logstdby_history.first_time is
'The time associated with first_change#'
/
comment on column dba_logstdby_history.last_time is
'The time associated with last_change#'
/
comment on column dba_logstdby_history.dgname is
'The Dataguard name'
/
comment on column dba_logstdby_history.merge_change# is
'The scn up to and including which was consistent during terminal apply'
/
comment on column dba_logstdby_history.processed_change# is
'The scn up to which all transactions have been processed'
/


execute CDBView.create_cdbview(false,'SYS','DBA_LOGSTDBY_HISTORY','CDB_LOGSTDBY_HISTORY');
grant select on SYS.CDB_logstdby_history to select_catalog_role
/
create or replace public synonym CDB_logstdby_history for SYS.CDB_logstdby_history
/

create or replace view dba_logstdby_eds_tables as
  select owner, table_name, ctime from system.logstdby$eds_tables
/

grant select on dba_logstdby_eds_tables to select_catalog_role
/
create or replace public synonym dba_logstdby_eds_tables
   for sys.dba_logstdby_eds_tables
/
comment on table dba_logstdby_eds_tables is 
'List of all tables that have EDS-based replication for Logical Standby'
/
comment on column dba_logstdby_eds_tables.owner is 
'Schema name of supported table'
/
comment on column dba_logstdby_eds_tables.table_name is 
'Table name of supported table'
/
comment on column dba_logstdby_eds_tables.ctime is 
'Time that table had EDS added'
/


execute CDBView.create_cdbview(false,'SYS','DBA_LOGSTDBY_EDS_TABLES','CDB_LOGSTDBY_EDS_TABLES');
grant select on SYS.CDB_logstdby_eds_tables to select_catalog_role
/
create or replace public synonym CDB_logstdby_eds_tables for SYS.CDB_logstdby_eds_tables
/

Rem View showing all tables that could be supported by EDS interface
Rem
Rem For a table to be a candidate for EDS-based replication it must 
Rem meet 2 criteria:
Rem     1) Must be unsupported by native replication
Rem        (e.g. has SDO_GEOMETRY, XMLTYPE, VARRAY, user type)
Rem     2) contain only a restricted set of datatypes
Rem
create or replace view dba_logstdby_eds_supported as
  select distinct owner, table_name from 
        dba_logstdby_unsupported_table un,
        tab$ t,
        obj$ o,
        user$ u,
        cdef$ c
  where
        /* get a handle on tab$ row to eliminate uninteresting tables */
        o.name = un.table_name and
        o.type# = 2 and 
        u.user# = o.owner# and 
        un.owner = u.name and
        o.obj# = t.obj# and 
        (bitand(t.property, 7) = 2 or   /* not an object table but has an
                                         * object column and no nested-table
                                         * columns:
                                         * 1  -- typed table 
                                         * 2  -- has ADT columns
                                         * 4  -- has nested-table columns
                                         */
        bitand(t.property, 21) = 16)    /* has varray columns
                                         * 1  -- typed table 
                                         * 4  -- has nested-table columns
                                         * 16 -- has a varray column
                                         */
        and c.obj# = o.obj# and c.type# = 2     /* has a primary key */
        and 
        /* 
         * evaluate all columns, hidden or not, to determine whether any that
         * are not system generated, including object attributes, fall outside 
         * of the supported set
         */
        (un.owner, un.table_name) NOT IN
        (select distinct owner,table_name from dba_tab_cols d where
                d.owner=un.owner and d.table_name=un.table_name
                and 
                ((d.data_type_owner IS NULL or 
                 d.data_type_owner = 'SYS' or
                 d.data_type_owner = 'MDSYS')
                and d.qualified_col_name not like 'SYS_NC%'
                and d.qualified_col_name not like '"SYS_NC%'
                and d.data_type != 'NUMBER' 
                and d.data_type != 'VARCHAR2'
                and d.data_type != 'RAW' 
                and d.data_type != 'DATE' 
                and d.data_type != 'FLOAT' 
                and d.data_type != 'INTEGER'
                and d.data_type != 'CHAR' 
                and d.data_type != 'NCHAR'
                and d.data_type != 'NVARCHAR2'
                and d.data_type != 'BINARY_FLOAT'
                and d.data_type != 'BINARY_DOUBLE'
                and not d.data_type LIKE 'TIMESTAMP(%'
                and not d.data_type LIKE 'INTERVAL %'
                and d.data_type != 'SDO_GEOMETRY'
                and d.data_type != 'SDO_ELEM_INFO_ARRAY'
                and d.data_type != 'SDO_ORDINATE_ARRAY'
                and d.data_type != 'XMLTYPE'
                and d.data_type != 'CLOB' 
                and d.data_type != 'NCLOB' 
                and d.data_type != 'BLOB' 
                ) or
                (d.data_type = 'XMLTYPE'        -- disallow XMLTYPE attribute
                and (d.data_type_owner = 'PUBLIC' or d.data_type_owner = 'SYS')
                and d.qualified_col_name != d.column_name)
                )
/
grant select on dba_logstdby_eds_supported to select_catalog_role
/
create or replace public synonym dba_logstdby_eds_supported
   for sys.dba_logstdby_eds_supported
/
comment on table dba_logstdby_eds_supported is 
'List of all tables that could have EDS-based replication for Logical Standby'
/
comment on column dba_logstdby_eds_supported.owner is 
'Schema name of supportable table'
/
comment on column dba_logstdby_eds_supported.table_name is 
'Table name of supportable table'
/


execute CDBView.create_cdbview(false,'SYS','DBA_LOGSTDBY_EDS_SUPPORTED','CDB_LOGSTDBY_EDS_SUPPORTED');
grant select on SYS.CDB_logstdby_eds_supported to select_catalog_role
/
create or replace public synonym CDB_logstdby_eds_supported for SYS.CDB_logstdby_eds_supported
/

Rem View showing the mapping between supported user invokable (/external)
Rem PLSQL procedure to the corresponding pragma-ed internal PLSQL procedure.
Rem
create or replace view dba_logstdby_plsql_map as
  select name as owner, name2 as pkg_name, name3 as proc_name, 
         name4 as internal_pkg_name, name5 as internal_proc_name
  from system.logstdby$skip_support
  where action = -3
  order by owner, pkg_name, proc_name, internal_pkg_name, internal_proc_name
/

grant select on dba_logstdby_plsql_map to select_catalog_role
/
create or replace public synonym dba_logstdby_plsql_map
   for sys.dba_logstdby_plsql_map
/
comment on table dba_logstdby_plsql_map is
'PLSQL mapping from user invokable procedure to supp-log pragma-ed procedure'
/
comment on column dba_logstdby_plsql_map.owner is
'Owner name of the procedure'
/
comment on column dba_logstdby_plsql_map.pkg_name is
'Package name of the user invokable procedure'
/
comment on column dba_logstdby_plsql_map.proc_name is
'Procedure name of the user invokable procedure'
/
comment on column dba_logstdby_plsql_map.internal_pkg_name is
'Package name of the internal procedure'
/
comment on column dba_logstdby_plsql_map.internal_proc_name is
'Procedure name of the internal procedure'
/


execute CDBView.create_cdbview(false,'SYS','DBA_LOGSTDBY_PLSQL_MAP','CDB_LOGSTDBY_PLSQL_MAP');
grant select on SYS.CDB_logstdby_plsql_map to select_catalog_role
/
create or replace public synonym CDB_logstdby_plsql_map for SYS.CDB_logstdby_plsql_map
/

Rem View showing the PLSQL packages that are only supported during
Rem rolling upgrade.
Rem
create or replace view dba_logstdby_plsql_support as
  select name as owner, name2 as pkg_name,
         case when (action = -6) then 'DBMS_ROLLING'
                                 else 'ALWAYS'
              end as support_level
  from system.logstdby$skip_support
  where action = -6 or action = -8 or action = -10
  order by owner, pkg_name
/

grant select on dba_logstdby_plsql_support to select_catalog_role
/
create or replace public synonym dba_logstdby_plsql_support
   for sys.dba_logstdby_plsql_support
/
comment on table dba_logstdby_plsql_support is
'PLSQL packages registered with logical standby'
/
comment on column dba_logstdby_plsql_support.owner is
'Owner name of the package'
/
comment on column dba_logstdby_plsql_support.pkg_name is
'Package name of the user invokable procedure'
/
comment on column dba_logstdby_plsql_support.support_level is
'Logical standby PLSQL support level for the package'
/


execute CDBView.create_cdbview(false,'SYS','DBA_LOGSTDBY_PLSQL_SUPPORT','CDB_LOGSTDBY_PLSQL_SUPPORT');
grant select on SYS.CDB_logstdby_plsql_support to select_catalog_role
/
create or replace public synonym CDB_logstdby_plsql_support for SYS.CDB_logstdby_plsql_support
/

rem ############################################################################

Rem 
Rem Private view used to identify applied transactions.
Rem
create or replace view ptc_apply_progress as
  select xidusn, xidslt, xidsqn, commit_scn, commit_time,
         spare1, spare2, spare3
  from system.logstdby$apply_progress
/

execute CDBView.create_cdbview(false,'SYS','PTC_APPLY_PROGRESS','CDB_PTC_APPLY_PROGRESS');


rem ###################################################################################

Rem Fix (Virtual) Views

create or replace view v_$logstdby as
  select * from v$logstdby;
create or replace public synonym v$logstdby for v_$logstdby;
grant select on v_$logstdby to select_catalog_role;

create or replace view v_$logstdby_stats as
  select * from v$logstdby_stats;
create or replace public synonym v$logstdby_stats for v_$logstdby_stats;
grant select on v_$logstdby_stats to select_catalog_role;

create or replace view v_$logstdby_transaction as
  select * from v$logstdby_transaction;
create or replace public synonym v$logstdby_transaction for
  v_$logstdby_transaction;
grant select on v_$logstdby_transaction to select_catalog_role;

create or replace view v_$logstdby_progress as
  select * from v$logstdby_progress;
create or replace public synonym v$logstdby_progress for v_$logstdby_progress;
grant select on v_$logstdby_progress to select_catalog_role;

create or replace view v_$logstdby_process as
  select * from v$logstdby_process;
create or replace public synonym v$logstdby_process for v_$logstdby_process;
grant select on v_$logstdby_process to select_catalog_role;

create or replace view v_$logstdby_state as
  select * from v$logstdby_state;
create or replace public synonym v$logstdby_state for v_$logstdby_state;
grant select on v_$logstdby_state to select_catalog_role;

Rem Create synonyms for the global fixed views

create or replace view gv_$logstdby as
  select * from gv$logstdby;
create or replace public synonym gv$logstdby for gv_$logstdby;
grant select on gv_$logstdby to select_catalog_role;

create or replace view gv_$logstdby_stats as
  select * from gv$logstdby_stats;
create or replace public synonym gv$logstdby_stats for gv_$logstdby_stats;
grant select on gv_$logstdby_stats to select_catalog_role;

create or replace view gv_$logstdby_transaction as
  select * from gv$logstdby_transaction;
create or replace public synonym gv$logstdby_transaction for
  gv_$logstdby_transaction;
grant select on gv_$logstdby_transaction to select_catalog_role;

create or replace view gv_$logstdby_progress as
  select * from gv$logstdby_progress;
create or replace public synonym gv$logstdby_progress for
  gv_$logstdby_progress;
grant select on gv_$logstdby_progress to select_catalog_role;

create or replace view gv_$logstdby_process as
  select * from gv$logstdby_process;
create or replace public synonym gv$logstdby_process for gv_$logstdby_process;
grant select on gv_$logstdby_process to select_catalog_role;

create or replace view gv_$logstdby_state as
  select * from gv$logstdby_state;
create or replace public synonym gv$logstdby_state for gv_$logstdby_state;
grant select on gv_$logstdby_state to select_catalog_role;

Rem Populate NOEXP$ to ensure logical standby metadata is not exported
delete from sys.noexp$ where name like 'LOGSTDBY$%';
insert into sys.noexp$
  select u.name, o.name, o.type#
  from sys.obj$ o, sys.user$ u
  where o.type# = 2
  and o.owner# = u.user# 
  and u.name = 'SYSTEM' 
  and o.name like 'LOGSTDBY$%';
commit;

Rem EDS DDL sequence, limiting to 10 digits for job name length restrictions
CREATE SEQUENCE SYSLSBY_EDS_DDL_SEQ 
        INCREMENT BY 1 
        MINVALUE 0
        MAXVALUE 9999999999
        CYCLE;

Rem EDS DDL trigger
CREATE OR REPLACE TRIGGER SYSLSBY_EDS_DDL_TRIG
  AFTER CREATE OR ALTER ON DATABASE
  DISABLE
DECLARE
   DGL_STATUS_EDS_EVOLVING     EXCEPTION;
   PRAGMA               EXCEPTION_INIT(DGL_STATUS_EDS_EVOLVING, -16310);
   sql_text             ora_name_list_t;
   t_stmt               CLOB;
   stmt                 CLOB;
   n                    NUMBER;
   dummy                NUMBER;
   pos		        NUMBER;
   evolve               BOOLEAN := FALSE;
   table_owner          VARCHAR2(140);
   table_ownerQ         VARCHAR2(140);
   table_name           VARCHAR2(140);
   table_nameQ          VARCHAR2(140);
   dbrole               VARCHAR2(80);
   state                VARCHAR2(255);
   job_stmt             CLOB;
   l_xid_str            VARCHAR2(22);
BEGIN
   -- only applicable on primary
   SELECT database_role INTO dbrole FROM v$database;
   IF dbrole != 'PRIMARY' THEN
      RETURN;
   END IF;

   -- put SQL into single buffer
   dummy := ora_sql_txt(sql_text);
   t_stmt := NULL;
   FOR i IN 1..dummy LOOP
      t_stmt := t_stmt || sql_text(i);
   END LOOP;

   -- handle CREATE UNIQUE INDEX which requires digging out table and owner
   IF ora_sysevent = 'CREATE' THEN
      IF ora_dict_obj_type = 'INDEX' THEN
	 SELECT INSTR(UPPER(t_stmt), ' UNIQUE ') INTO pos FROM dual;
	 IF pos = 0 THEN
	    RETURN;
	 END IF;

         -- only interested in user cursors
         dbms_internal_logstdby.eds_user_cursor(evolve, 
                                                table_owner, 
                                                table_name);

      END IF;

   -- otherwise anything other than ALTER TABLE is uninteresting
   ELSE
      IF ora_sysevent != 'ALTER' OR ora_dict_obj_type != 'TABLE' THEN
         RETURN;
      END IF;

      -- look for RENAME token to eliminate DROP TABLE lacking a PURGE which
      -- comes in as an ALTER TABLE RENAME TO
      SELECT INSTR(UPPER(t_stmt), ' RENAME TO ') INTO pos FROM dual;
      IF pos != 0 THEN
         RETURN;
      END IF;

      evolve := TRUE;
      table_owner := ora_dict_obj_owner;
      table_name :=  ora_dict_obj_name;
   END IF;

   -- if its an EDS table and evolve not already started then start one
   IF evolve THEN
      stmt := 'select state from system.logstdby$eds_tables where owner=:1' || 
              ' and table_name=:2';
      BEGIN
	 EXECUTE IMMEDIATE stmt INTO state USING table_owner, table_name;
      EXCEPTION
         WHEN others THEN state := NULL;
      END;
      IF state IS NOT NULL THEN
	 IF state = 'EVOLVING' THEN
	    RAISE DGL_STATUS_EDS_EVOLVING;
	 END IF;
	 table_ownerQ := DBMS_ASSERT.ENQUOTE_NAME(table_owner,FALSE);
	 table_nameQ := DBMS_ASSERT.ENQUOTE_NAME(table_name,FALSE);

          -- start the evolve
	 DBMS_LOGSTDBY.EDS_EVOLVE_MANUAL(
                options => 'START',
 	        table_owner => table_ownerQ,
		table_name => table_nameQ
                );

         -- schedule the evolve finish
         SELECT syslsby_eds_ddl_seq.NEXTVAL INTO n FROM DUAL;
         l_xid_str := dbms_transaction.local_transaction_id();
         job_stmt := 'BEGIN DBMS_INTERNAL_LOGSTDBY.EDS_EVOLVE(' ||
                DBMS_ASSERT.ENQUOTE_LITERAL(replace(table_ownerQ,'''',''''''))
                 || ',' || 
                DBMS_ASSERT.ENQUOTE_LITERAL(replace(table_nameQ,'''',''''''))
                 || ',' || 
                DBMS_ASSERT.ENQUOTE_LITERAL(l_xid_str) ||
                '); END;';
         dbms_system.ksdwrt(dbms_system.alert_file,
                'LOGSTDBY: performing an EDS evolve in response to DDL');
         DBMS_SCHEDULER.CREATE_JOB(
              job_name => 'SYSLSBY_EDS_DDL_JOB_' || n,
              job_type => 'PLSQL_BLOCK',
              job_action => job_stmt,
              enabled => TRUE
              );
      END IF;
   END IF;
END;
/
show errors

@?/rdbms/admin/sqlsessend.sql
