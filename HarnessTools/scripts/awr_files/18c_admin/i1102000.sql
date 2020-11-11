Rem
Rem $Header: rdbms/admin/i1102000.sql /main/16 2017/03/20 12:21:12 raeburns Exp $
Rem
Rem i1102000.sql
Rem
Rem Copyright (c) 2011, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      i1102000.sql - load 12.1 specific tables that are needed to
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
Rem        STAGE 1: upgrade from 11.2 to the current release
Rem        STAGE 2: invoke script for subsequent release
Rem
Rem    NOTES
Rem      * This script must be run using SQL*PLUS.
Rem      * You must be connected AS SYSDBA to run this script.
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/i1102000.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/i1102000.sql
Rem SQL_PHASE: UPGRADE
Rem SQL_STARTUP_MODE: UPGRADE
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catupstr.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns   03/09/17 - Bug 25616909: Use UPGRADE for SQL_PHASE
Rem    frealvar   12/13/15 - Bug 21156050 moved code that adds flags column
Rem                          to profname$ from c1102000.sql
Rem    mziauddi   01/07/14 - #(18036580) move in the addition of sum$.zmapscale
Rem                          and sumdetail$.flags from c1102000.sql
Rem    cdilling   10/19/12 - invoke 12.1 patch upgrade script
Rem    traney     03/22/12 - bug 13715632: add agent to library$
Rem    jkundu     03/12/12 - bug 10297974: drop v$logmnr_region/callback
Rem    dgraj      10/16/11 - Project 32079: Add upgrade support for TSDP
Rem    cslink     11/22/11 - Remove masking parameter type from radm_mc$
Rem    pknaggs    10/03/11 - RADM: Add Regular Expression support to radm_mc$
Rem    brwolf     09/01/11 - 32733: finer-grained editioning
Rem    wesmith    06/07/11 - project 31843: identity columns
Rem    dahlim     06/27/11 - Change radm_mc$ for performance
Rem    rpang      04/01/11 - Auditing support for SQL translation profiles
Rem    rdecker    01/11/11 - Upgrade for package type TOID/TDO support
Rem    pknaggs    01/31/11 - Created
Rem

Rem =========================================================================
Rem BEGIN STAGE 1: upgrade from 11.2 to the current release
Rem =========================================================================

Rem =========================
Rem  Begin Dictionary changes
Rem =========================

Rem =====================================================================
Rem Begin Bug 21156050 changes
Rem =====================================================================

Rem adding support for Common profiles; this statement needs to run
Rem before the first CREATE USER statement in the script

ALTER TABLE sys.profname$ ADD flags NUMBER DEFAULT 0 NOT NULL;

Rem =====================================================================
Rem End Bug 21156050 changes
Rem =====================================================================

Rem Enhance dictionary tables for package type TOIDs and TDOs
Rem This must happen prior to doing DDL on packages or types

alter table OID$ add INDEX# number default 0 not null;

alter table type$ add (typ_name varchar2(30));
alter table type$ add (package_obj# number);
create unique index i_type6 on type$(toid, version#, package_obj#) tablespace system;

alter table collection$ add (coll_name varchar2(30));
alter table collection$ add (package_obj# number);
create unique index i_collection1 on collection$(toid,version#,package_obj#) tablespace system;

Rem
Rem need explicit delete for 11.2 fixed objects not in 12.1
Rem
Rem  v_$logmnr_callback 4294951636
Rem gv_$logmnr_callback 4294951635
Rem  v_$logmnr_region   4294951633
Rem gv_$logmnr_region   4294951632
Rem

delete from dependency$ where p_obj# in (4294951632, 4294951633, 4294951635, 4294951636);
commit;

Rem =========================
Rem  End Dictionary changes
Rem =========================

Rem ======================================
Rem Begin RADM changes.
Rem ======================================

Rem *************************************************************************
Rem RADM (Real-time Application-controlled Data Masking): create
Rem the column-level RADM policy information dictionary table.
Rem The creation of the radm_mc$ must take place here, ahead of any use
Rem of any "alter table" DDL SQL command, because the intcol# column of
Rem the radm_mc$ table is now registered in the atbDT[] array, such that
Rem when the alter table driver runs, it automatically updates the intcol# 
Rem value in the radm_mc$ table. For this to work, the radm_mc$ table
Rem must of course exist, otherwise a recursive SQL error would occur
Rem during the attempted (recursive) update of the radm_mc$ table.
Rem *************************************************************************
Rem
create table radm_mc$                      /* RADM policies - Masked Columns */
(
  obj#                   NUMBER NOT NULL,             /* table object number */
  intcol#                NUMBER NOT NULL,                   /* column number */
  mfunc                  NUMBER NOT NULL,           /* RADM Masking Function */
  mparams                VARCHAR2(1000),          /* RADM Masking Parameters */
  regexp_pattern         VARCHAR2(512),        /* Regular Expression pattern */
  regexp_replace_string  VARCHAR2(4000),               /* Replacement string */
  regexp_position        NUMBER,                 /* Position to begin search */
  regexp_occurrence      NUMBER,    /* Replace specified or every occurrence */
  regexp_match_parameter VARCHAR2(10),          /* Control matching behavior */
  mp_iformat_start_byte  INTEGER,         /* starting byte # of INPUT FORMAT */
  mp_iformat_end_byte    INTEGER,           /* ending byte # of INPUT FORMAT */
  mp_oformat_start_byte  INTEGER,        /* starting byte # of OUTPUT FORMAT */
  mp_oformat_end_byte    INTEGER,          /* ending byte # of OUTPUT FORMAT */
  mp_maskchar_start_byte INTEGER,            /* starting byte # of MASK CHAR */
  mp_maskchar_end_byte   INTEGER,              /* ending byte # of MASK CHAR */
  mp_maskfrom            INTEGER,         /* MASK FROM, converted to integer */
  mp_maskto              INTEGER,           /* MASK TO, converted to integer */
  mp_datmask_Mo          INTEGER,                     /* date mask for Month */
  mp_datmask_D           INTEGER,                       /* date mask for Day */
  mp_datmask_Y           INTEGER,                      /* date mask for Year */
  mp_datmask_H           INTEGER,                      /* date mask for Hour */
  mp_datmask_Mi          INTEGER,                    /* date mask for Minute */
  mp_datmask_S           INTEGER                     /* date mask for Second */
) tablespace system
/
create index i_radm_mc1 on radm_mc$(obj#) tablespace system
/
create index i_radm_mc2 on radm_mc$(obj#, intcol#) tablespace system
/

Rem ====================================
Rem End RADM changes.
Rem ====================================

Rem ======================================
Rem Begin identity column changes.
Rem ======================================
create table idnseq$     /* stores table identity column to sequence mapping */
( obj#         number not null,                       /* table object number */
  intcol#      number not null,                    /* identity column number */
  seqobj#      number not null,                    /* sequence object number */
  startwith    number not null ) tablespace system /* sequence starting value */
/
create unique index i_idnseq1 on idnseq$(obj#, intcol#) tablespace system
/

Rem ======================================
Rem End identity column changes.
Rem ======================================

Rem ======================================
Rem  Begin SQL translation profile changes
Rem ======================================

Rem
Rem SQL translation profile
Rem

create table sqltxl$
(
  obj#      number not null,    /* object number of SQL translation profile  */
  txlrowner varchar2(128),      /* translator package owner name             */
  txlrname  varchar2(128),      /* translator package name                   */
  flags     number not null,    /* flags                                     */
                                /* 0x01 = automatic translation registration */
                                /* 0x02 = custom translation miss alert      */
                                /* 0x04 = tracing                            */
  audit$    varchar2(38) not null /* auditing options                        */
) tablespace system
/
create unique index i_sqltxl$_1 on sqltxl$(obj#) tablespace system
/

Rem
Rem SQL translations
Rem

create table sqltxl_sql$
(
  obj#    number not null,      /* object number of SQL translation profile  */
  sqltext clob not null,        /* original sql text                         */
  txltext clob,                 /* translated sql text                       */
  sqlid   varchar2(13) not null,/* sql id                                    */
  sqlhash number not null,      /* sql hash value                            */
  flags   number not null       /* flags                                     */
                                /* 0x01 = enabled                            */
) tablespace system
/
create index i_sqltxl_sql$_1 on sqltxl_sql$(obj#, sqlhash) tablespace system
/

Rem
Rem Error translations
Rem

create table sqltxl_err$
(
  obj#        number not null,  /* object number of SQL translation profile  */
  errcode#    number not null,  /* original error code                       */
  txlcode#    number,           /* translated error code                     */
  txlsqlstate varchar2(5),      /* translated sqlstate                       */
  flags       number not null   /* flags                                     */
                                /* 0x01 = enabled                            */
) tablespace system
/
create unique index i_sqltxl_err$_1 on sqltxl_err$(obj#, errcode#) tablespace system
/

Rem ====================================
Rem  End SQL translation profile changes
Rem ====================================

Rem =========================================
Rem  Begin Edition-based redefinition changes
Rem =========================================

create global temporary table editioning_types$ (type# number not null)
on commit delete rows
/
create table user_editioning$
(
  user# number not null,
  type# number not null
) tablespace system
/
create index i_user_editioning on user_editioning$(user#) tablespace system
/

insert into editioning_types$(type#) values (4);
insert into editioning_types$(type#) values (5);
insert into editioning_types$(type#) values (7);
insert into editioning_types$(type#) values (8);
insert into editioning_types$(type#) values (9);
insert into editioning_types$(type#) values (10);
insert into editioning_types$(type#) values (11);
insert into editioning_types$(type#) values (12);
insert into editioning_types$(type#) values (13);
insert into editioning_types$(type#) values (14);
insert into editioning_types$(type#) values (22);
insert into editioning_types$(type#) values (87);

insert into user_editioning$(user#, type#)
select u.user#, et.type#
from user$ u, editioning_types$ et
where bitand(u.spare1, 16) = 16;

commit;

Rem =========================================
Rem  End Edition-based redefinition changes
Rem =========================================

Rem =========================================
Rem  Start TSDP changes
Rem =========================================

Rem *************************************************************************
Rem TSDP (Transparent Sensitive Data Protection): create
Rem the sensitive data information dictionary table. The creation of the 
Rem tsdp_sensitive_data$ must take place here, ahead of 
Rem of any "alter table" DDL SQL command, because the intcol# column of
Rem the tsdp_sensitive_data$ table is registered in the atbDT[] array, so that
Rem when the alter table driver runs, it automatically updates the intcol#
Rem value in the tsdp_sensitive_data$ table. For this to work, table
Rem tsdp_sensitive_data$ must exist,otherwise a recursive SQL error would occur
Rem during the attempted (recursive) update of the tsdp_sensitive_data$ table.
Rem *************************************************************************
Rem

create table tsdp_sensitive_data$ (
  sensitive#                    number not null,
  obj#                          number not null,
  col_argument#                 number not null,
  procedure#                    number,
  sensitive_type                varchar2(128),
  user_comment                  varchar2(128),
  source#                       number,
  ts                            timestamp with time zone,
  property                      number,
  constraint tsdp_sensitive_data$pk primary key (sensitive#),
  constraint tsdp_sensitive_data$uk unique (obj#,col_argument#,procedure#)
) tablespace system
/

Rem =========================================
Rem  End TSDP changes
Rem =========================================

Rem =========================================================================
Rem Begin library$ changes
Rem =========================================================================

alter table library$ add (agent varchar2(128))
/
alter table library$ add (leaf_filename varchar2(2000))
/

Rem =========================================================================
Rem End library$ changes
Rem =========================================================================

Rem =========================================================================
Rem Begin Bug 18036580 changes
Rem Move in the addition of sum$.zmapscale, sumdetail$.flags from c1102000.sql
Rem Upgrade for Zonemaps
Rem =========================================================================

alter table sys.sum$ add (zmapscale number default 0)
/
alter table sumdetail$ add (flags number default 0)
/

Rem =========================================================================
Rem End Bug 18036580 changes
Rem =========================================================================

Rem =========================================================================
Rem BEGIN STAGE 2: invoke script for subsequent release
Rem =========================================================================

@@i1201000.sql

Rem =========================================================================
Rem END STAGE 2: invoke script for subsequent release
Rem =========================================================================

Rem *************************************************************************
Rem END i1102000.sql
Rem *************************************************************************

