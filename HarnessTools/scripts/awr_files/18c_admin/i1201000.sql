Rem
Rem i1201000.sql
Rem
Rem Copyright (c) 2012, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      i1201000.sql - load 12.1.0.2 specific tables that are needed to
Rem                     process basic DDL statements
Rem
Rem    DESCRIPTION
Rem      This script MUST be one of the first things called from the 
Rem      top-level upgrade script.
Rem
Rem      Only put statements in here that must be run in order
Rem      to process basic SQL commands.  For example, in order to 
Rem      drop a package, the server code may depend on new tables.
Rem      Another example: in order to alter a table, the server code
Rem      needs to perform an update of the radm_mc$ dictionary table.
Rem      If these tables do not exist, a recursive SQL error will occur,
Rem      causing the command to be aborted.
Rem
Rem      The upgrade is performed in the following stages:
Rem        STAGE 1: upgrade from 12.1.0.1 to the current release
Rem        STAGE 2: invoke script for subsequent release
Rem
Rem    NOTES
Rem      * This script must be run using SQL*PLUS.
Rem      * You must be connected AS SYSDBA to run this script.
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/i1201000.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/i1201000.sql
Rem SQL_PHASE: UPGRADE
Rem SQL_STARTUP_MODE: UPGRADE
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catupstr.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns   03/09/17 - Bug 25616909: Use UPGRADE for SQL_PHASE
Rem    vgerard    11/04/16 - Bug 24841465 - move autocdr to i script
Rem    rdecker    07/12/16 - Bug 23725672: improve plscope tables/indexes
Rem    welin      06/02/16 - invoking subsequent release
Rem    thbaby     05/11/16 - Bug 23254735: add app related columns to PROFNAME$
Rem    frealvar   12/13/15 - Bug 21156050 added tablespace to create
Rem                          statements without explicit tablespace 
Rem    rdecker    12/01/15 - 22244617: add typ_name to index i_type6
Rem    sudurai    10/09/15 - Bug 21805805: Encrypt NUMBER data type in
Rem                          statistics tables
Rem    hgong      09/03/15 - remove MGD
Rem    yanxie     07/17/15 - add flag4 in snap$
Rem    ddas       06/17/15 - proj 47170: persistent IMC statistics
Rem    yehan      04/02/15 - bug 20495105: remove OWB and EQ from registry$
Rem                          to keep their objects from being marked as
Rem                          noneditionable
Rem    hlili      02/09/15 - add cols to partobj$ to allow interval 
Rem                          subpartitioning
Rem    rdecker    12/01/14 - PL/Scope for SQL dictionary tables
Rem    jorgrive   11/24/14 - Remove Advanced Replication fixed objects.
Rem    schakkap   07/15/14 - proj 46828: Add scan rate
Rem    sagrawal   04/15/14 - Polymorphic Table Functions
Rem    cdilling   10/16/12 - Created
Rem

Rem =========================================================================
Rem BEGIN STAGE 1: upgrade from 12.1.0.1 to the current release
Rem =========================================================================

Rem =========================
Rem  Begin Dictionary changes
Rem =========================

Rem =====================================================================
Rem Begin Bug 23254735 changes
Rem =====================================================================

Rem Adding support for Application related columns. These statements 
Rem need to run before the first CREATE USER statement in the script

ALTER TABLE sys.profname$ ADD CREAPPID   NUMBER;
ALTER TABLE sys.profname$ ADD CREVERID   NUMBER;
ALTER TABLE sys.profname$ ADD CREPATCHID NUMBER;
ALTER TABLE sys.profname$ ADD MODAPPID   NUMBER;
ALTER TABLE sys.profname$ ADD MODVERID   NUMBER;
ALTER TABLE sys.profname$ ADD MODPATCHID NUMBER;
ALTER TABLE sys.profname$ ADD SPARE1     NUMBER;
ALTER TABLE sys.profname$ ADD SPARE2     NUMBER;
ALTER TABLE sys.profname$ ADD SPARE3     VARCHAR2(1000);
ALTER TABLE sys.profname$ ADD SPARE4     VARCHAR2(1000);
ALTER TABLE sys.profname$ ADD SPARE5     DATE;

Rem =====================================================================
Rem End Bug 23254735 changes
Rem =====================================================================

Rem *************************************************************************
Rem Begin PL/Scope for SQL changes
Rem *************************************************************************

create table plscope_sql$ (
  sql_id       varchar2(13),
  sql_text     varchar2(4000),
  sql_fulltext clob,
  obj#         number)
  tablespace sysaux
/
create unique index i_plscope_obj_sql_id$ on plscope_sql$(obj#,sql_id)
tablespace sysaux
/

create table plscope_statement$ (
  signature  varchar2(32),                           /* identifier signature */
  obj#       number,
  type#      number,
  sql_id     varchar2(13),
  flags      number)
  tablespace sysaux
/
create unique index i_plscope_sig_statement$ on plscope_statement$(signature)
tablespace sysaux
/
create index i_plscope_statement$ on plscope_statement$(obj#,sql_id)
tablespace sysaux
/

drop index i_plscope_obj_identifier$;
create index i_plscope_identifier$ on plscope_identifier$(obj#,signature,type#)
tablespace sysaux
/

drop index i_plscope_sig_action$;
create index i_plscope_action$ on plscope_action$(obj#,signature,action)
tablespace sysaux
/

Rem *************************************************************************
Rem End PL/Scope for SQL changes
Rem *************************************************************************

Rem *************************************************************************
Rem : polymorphic TABLE Functions
Rem *************************************************************************
ALTER  TABLE  procedureinfo$   ADD
properties2   number default 0 not NULL;

Rem ********************************************************************
Rem End  polymorphic TABLE Functions
Rem ********************************************************************

Rem *************************************************************************
Rem : Begin Optimizer changes
Rem *************************************************************************

Rem The column order should be same in newly created db and upgraded db for
Rem cdb. Spare columns does not have any data. We don't store length field
Rem in disk blocks for trailing nulls. To take advantage of this optimization
Rem we add the new columns before the spare columns.


Rem Drop spare columns. Note that this may fail if these columns are 
Rem already dropped and this script is rerun. We can not catch it 
Rem using PLSQL block since it is in the early stages of upgrade.
Rem Basic standard package is invalid at this point.
ALTER TABLE tab_stats$
    DROP (spare1, spare2, spare3, spare4, spare5, spare6);

Rem Add the new columns. Note that this may fail if the new column already 
Rem exists. It is silently ignored during upgrade.
ALTER TABLE tab_stats$
  ADD (im_imcu_count NUMBER);
ALTER TABLE tab_stats$
  ADD (im_block_count NUMBER);
ALTER TABLE tab_stats$
  ADD (im_sys_incarnation NUMBER);
ALTER TABLE tab_stats$
  ADD (im_stat_update_time TIMESTAMP);
ALTER TABLE tab_stats$
  ADD (scanrate NUMBER);

Rem Add spare columns
ALTER TABLE tab_stats$
  ADD (spare1 NUMBER, spare2 NUMBER, spare3 NUMBER, spare4 VARCHAR2(1000), 
       spare5 VARCHAR2(1000), spare6 TIMESTAMP WITH TIME ZONE);

Rem ********************************************************************
Rem End  Optimizer changes
Rem ********************************************************************

Rem ********************************************************************
Rem BEGIN  Replication changes
Rem ********************************************************************

Rem Delete fixed objects.
Rem
Rem GV$REPLQUEUE  4294951719 
Rem V$REPLQUEUE   4294951720
Rem GV$REPLPROP   4294951722
Rem V$REPLPROP    4294951723
Rem 

delete from dependency$ where p_obj# in (4294951719,4294951720,4294951722,4294951723);
commit;

Rem ********************************************************************
Rem End  Replication changes
Rem ********************************************************************

Rem ********************************************************************
Rem Begin Add columns to partobj$ to allow interval subpartitioning
Rem ********************************************************************
Alter table partobj$ add (subptn_interval_str VARCHAR2(1000),
                          subptn_interval_bival raw(200));

Rem ********************************************************************
Rem End Add columns to partobj$ to allow interval subpartitioning
Rem ********************************************************************

Rem *************************************************************************
Rem Begin BUG 20495105: Remove OWB and EQ from registry$.
Rem
Rem Remove OWB (bug 13338356)and EQ (bug 14227409) from SERVER registry
Rem (Incorrectly included in registry$ in 11.2 as components in the SERVER
Rem namespace.)
Rem
Rem Removing them here will also prevent their objects from being mistakenly
Rem marked as noneditionable by the update operation (marked with
Rem "bug 12915774") that is executed afterwards in catupstr.sql.
Rem *************************************************************************

delete from registry$ where namespace='SERVER' and cid in ('OWB','EQ', 'MGD');
commit;

Rem *************************************************************************
Rem End BUG 20495105: Remove OWB and EQ from registry$.
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN Project 49581 - Statistics Encryption
Rem *************************************************************************

alter table hist_head$ add minimum_enc raw(1000);
alter table hist_head$ add maximum_enc raw(1000);
alter table histgrm$ add endpoint_enc raw(1000);

alter table wri$_optstat_histhead_history add minimum_enc raw(1000);
alter table wri$_optstat_histhead_history add maximum_enc raw(1000);
alter table wri$_optstat_histgrm_history add endpoint_enc raw(1000);

Rem *************************************************************************
Rem END Project 49581
Rem *************************************************************************

Rem *************************************************************************
Rem Begin Changes for bug 22244617: Create a new version of i_type6 that
Rem includes typ_name for package type performance improvements
Rem *************************************************************************

drop index i_type6;
create unique index i_type6 on type$(toid, version#, typ_name, package_obj#)
tablespace system
/

Rem *************************************************************************
Rem End Changes for bug 22244617
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN add flag4 into snap$
Rem *************************************************************************

alter table sys.snap$ add (flag4 number);

Rem *************************************************************************
Rem END
Rem *************************************************************************

Rem *************************************************************************
Rem Begin Changes for bug 24841465: create apply$_auto_cdr_column_groups 
Rem *************************************************************************

create table apply$_auto_cdr_column_groups
(
  obj#                  number not null,                   /* obj# for table */
  column_group_name     varchar2(128) not null,         /* column group name */
  column_group_id       number not null,                  /* column group id */
  flags                 number,                                     /* flags */
  spare1                number,
  spare2                number,
  spare3                number,
  spare4                timestamp,
  spare5                varchar2(4000),
  spare6                varchar2(4000),
  spare7                varchar2(4000),
  spare8                date
)
/
create unique index apply$_auto_cdr_cg_unq1
 on apply$_auto_cdr_column_groups(obj#, column_group_name)
/
create unique index apply$_auto_cdr_cg_unq2
 on apply$_auto_cdr_column_groups(obj#, column_group_id)
/ 


Rem *************************************************************************
Rem End Changes for bug 24841465
Rem *************************************************************************



Rem =========================
Rem  End Dictionary changes
Rem =========================

Rem =========================================================================
Rem BEGIN STAGE 2: invoke script for subsequent release
Rem =========================================================================

@@i1202000.sql

Rem =========================================================================
Rem END STAGE 2: invoke script for subsequent release
Rem =========================================================================

Rem *************************************************************************
Rem END i1201000.sql
Rem *************************************************************************

