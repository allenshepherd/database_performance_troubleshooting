Rem
Rem $Header: rdbms/admin/dbmsgwmut.sql /main/133 2017/10/09 09:33:42 lenovak Exp $
Rem
Rem dbmsgwmut.sql
Rem
Rem Copyright (c) 2011, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsgwmut.sql - Global Workload Management Utility
Rem
Rem    DESCRIPTION
Rem      Defines the dbms_gsm_utility package that is used for utility
Rem      definitions and procedures used for GSM database cloud management.
Rem
Rem    NOTES
Rem      This package is for definitions and functions shared by the 
Rem      dbms_gsm_pooladmin and dbms_gsm_cloudadmin packages on the GSM
Rem      cloud catalog database, and for utility routines used by GSMCTL
Rem      when administering the cloud.
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmsgwmut.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmsgwmut.sql
Rem SQL_PHASE: DBMSGWMUT
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/prvtgmut.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    lenovak     09/28/17 - Bug 26887766: compare shard versions
Rem    dmaniyan    09/13/17 - Bug 26805562 : Add error message 3797
Rem    dcolello    08/25/17 - add error 3796
Rem    beleung     08/19/17 - DB version 18.1.0 => 18.0.0
Rem    dcolello    08/04/17 - bug 26314677: add errors 3793 and 3794
Rem    saratho     07/26/17 - Bug 26400719: add error 3791-3792
Rem    itaranov    08/03/17 - 26161483: non-online tss error message
Rem    dmaniyan    07/12/17 - Bug 21254317: Add parent_schema to new_table
Rem    dcolello    07/10/17 - bug 26314708: add 3790 err_cdb_exists
Rem    dmaniyan    06/28/17 - Bug 25443435: Add error 3789 err_incon_st
Rem    arjusing    06/09/17 - Bug 22537284: add 3788 err_no_prim_shardgroup
Rem    dmaniyan    06/07/17 - Bug 25443435: Add a boolean column - consistent
Rem                           per table in the global_table
Rem    arjusing    05/12/17 - Bug 22494147: Add warning 3783 no_shd_to_deploy
Rem    nbenadja    05/05/17 - Bug# 22145819: Add ddl_intcode to ddl_requests.
Rem    sdball      05/05/17 - New parameter for prepareName
Rem    saratho     04/12/17 - Bug 25816781: adding errors for replace shard
Rem    dmaniyan    03/31/17 - Add childobj_id parameter to new_ts_set_table
Rem    itaranov    03/24/17 - Disclaimer for versions
Rem    sdball      03/24/17 - Changes for atomic move
Rem    zzeng       03/07/17 - Bug 25684412: add getGDSOnsConfig
Rem    itaranov    03/20/17 - User-public DDL sync procedure
Rem    itaranov    02/15/17 - 25510880,25510356: session key info fixes
Rem    saratho     02/07/17 - add error for number of shards
Rem    dcolello    11/19/16 - always set schema to gsmadmin_internal
Rem    anidash     11/03/16 - err for split chunk not supported on userdef
Rem                           sharding
Rem    dcolello    10/20/16 - bug 23152783: add error msgs for set DG property
Rem    mtiwary     09/27/16 - Bug 22697214: add public function isGSMUp
Rem    dcolello    09/16/16 - bug 24681708: add err_job_queue_proc
Rem    zzeng       09/09/16 - Note error number range reservation for C
Rem    sdball      08/15/16 - Add err_service_del
Rem    vidgovin    08/12/16 - XbranchMerge vidgovin_incrdep2 from
Rem                           st_rdbms_12.2.0.1.0
Rem    itaranov    08/05/16 - XbranchMerge itaranov_bug-24328811 from
Rem                           st_rdbms_12.2.0.1.0
Rem    sdball      07/22/16 - Bug 24324684: move variables inside package
Rem    sdball      07/19/16 - Add 12.2.0.2 to version list
Rem    itaranov    07/18/16 - bug 24291688: double-split of same chunk
Rem    vidgovin    08/08/16 - Bug 24428345 - Add update_ddl_duptbl,
Rem                           update_ddl_incdep
Rem    itaranov    07/18/16 - bug 24291688: double-split of same chunk
Rem    lenovak     07/08/16 - project 62462 Sharding for RAC affinity
Rem    dcolello    07/01/16 - bug 23589416: add 3755 for 'add shard'
Rem    dcolello    07/01/16 - bug 23711027: add 3754 for user-defined
Rem    sdball      06/22/16 - New functions getCatalogLockPrvt and
Rem                           releaseCatalogLockPrvt
Rem    sdball      06/22/16 - dbms_gsm_nopriv is now authid currnt_user
Rem    zzeng       06/20/16 - Bug 23170629: new password DDL updates
Rem    sdball      06/17/16 - Make generateChangeLogEntry accessible only
Rem                           internally
Rem    itaranov    06/17/16 - bug 23548757: whitelist error
Rem    dcolello    06/10/16 - bug 23557722: add 3752 for removeVNCR()
Rem    dcolello    06/09/16 - bug 23563822: add 3751 for no user-defined 
Rem    dcolello    05/26/16 - add msg_info for GDSCTL error reporting
Rem    dcolello    05/25/16 - add 3748 for broker configuration
Rem    zzeng       05/20/16 - Bug 22450181: add ddl_password type
Rem    sdball      05/18/16 - New operation type for DDL
Rem    nbenadja    05/12/16 - Fix bug#: 22938484
Rem    sdball      05/11/16 - new field in new_partition_set
Rem    ralekra     05/10/16 - add constant for move chunk ogg error
Rem    dcolello    05/05/16 - add 3746 for shard validation
Rem    dcolello    05/03/16 - add no_gsm_running message for deploy
Rem    dcolello    05/03/16 - bug 23194420: no new shardspace if root table
Rem    itaranov    04/29/16 - 3743 error
Rem    sdball      04/21/16 - Add err_shd_pref
Rem    nbenadja    04/18/16 - Fix bug# 22379290
Rem    dcolello    04/18/16 - bump max vncrs to 1000 from 300
Rem    sdball      04/21/16 - Add err_shd_pref
Rem    sdball      04/20/16 - new errors
Rem    sdball      04/15/16 - Add 12.2.0.1 to valid version list
Rem    dcolello    04/09/16 - add 3740 and 3741	
Rem    lenovak     04/05/16 - bugfix 23032790
Rem    zzeng       03/30/16 - new_ddl_request takes clob for ddl_text
Rem    dcolello    03/10/16 - bug 22494157: add 3739
Rem    sdball      03/17/16 - chunk move enhancements
Rem    ralekra     02/29/16 - rectify shardgroup/shardspace status definition
Rem    lenovak     02/22/16 - gdsctl output for catalog_requests
Rem    dcolello    02/12/16 - add msg_warning
Rem    lenovak     02/04/16 - add gdsctl messages
Rem    vidgovin    02/02/16 - Create database link for dup. tables
Rem    lenovak     01/26/16 - shard error messaages
Rem    dcolello    01/19/16 - add 3718 and 3719
Rem    vidgovin    12/07/15 - Bug 22204627
Rem    itaranov    12/03/15 - Chunk lookup plsql
Rem    ralekra     11/23/15 - add an error message for OGG 
Rem    dcolello    11/21/15 - final terminology name changes
Rem    sdball      11/19/15 - Add exec_stmt
Rem    dcolello    11/11/15 - add err_no_xdb, agent port warnings
Rem    lenovak     11/10/15 - chunk recovery error
Rem    sdball      10/30/15 - New db flag for failed move
Rem    sdball      09/30/15 - Bug 21186904: Add cleanupDDL
Rem    dcolello    09/09/15 - add 3713
Rem    dmaniyan    08/26/15 - Add drop_tables_in_tset()
Rem    dcolello    08/06/15 - sharding syntax changes
Rem    dcolello    07/07/15 - add error 2662
Rem    ralekra     06/25/15 - OGG online move chunk support
Rem    dcolello    06/25/15 - add adddb_params error
Rem    nbenadja    06/24/15 - Add new DDL operation type.
Rem    dcolello    06/20/15 - add errors 2651-2658
Rem    dcolello    06/19/15 - add remove database errors
Rem    dcolello    06/18/15 - add error 2650
Rem    nbenadja    06/17/15 - add crt_CShdblink and drp_CShdblink procedures.
Rem    sdball      06/08/15 - Support for long identifiers
Rem    sdball      06/04/15 - Various shard fixes
Rem    sdball      05/27/15 - Add sharding methods
Rem    dcolello    05/18/15 - more create database/deploy errors
Rem    sdball      05/15/15 - New errors for sharding
Rem    sdball      04/13/15 - new deploy errors
Rem    sdball      03/25/15 - Support for manual sharding
Rem    sdball      03/10/15 - New meaning for gsm_requests payload
Rem    sdball      03/04/15 - New definitions for 12.2 sharding
Rem    nbenadja    12/11/14 - Change shd prefix to gws.
Rem    nbenadja    09/12/14 - Add new_ts_set_table().
Rem    nbenadja    07/24/14 - Add new parameters to new_partition_set().
Rem    nbenadja    06/26/14 - Add key_level parameter to new_keycol.
Rem    cechen      03/31/14 - Wrapper fro PKI encryption C call
Rem    sdball      02/05/14 - Add 12.2.0.0 to release ID table
Rem    nbenadja    04/08/14 - Handle supershards high values;
Rem    surman      01/23/14 - 13922626: Update SQL metadata
Rem    nbenadja    01/09/14 - Add Pluggable database cannot be a GDS catalog.
Rem    sdball      01/06/14 - Updates for sharding
Rem    sdball      09/27/13 - Add err_no_region_name
Rem    sdball      09/25/13 - Add rb_drop_service
Rem    sdball      09/24/13 - add err_no_prefs
Rem    sdball      09/19/13 - Add err_no_gsm_vers
Rem    sdball      08/30/13 - Add several new errors to fix error bugs
Rem    sdball      08/15/13 - Add err_no_svc_inst amd err_no_svcs
Rem    sdball      08/14/13 - Add err_noexist_inst and err_no_del
Rem    sdball      06/24/13 - Add err_nonexist_svc
Rem    lenovak     07/29/13 - shard support
Rem    sdball      05/29/13 - add err_srvctl_parms and err_noproc
Rem    sdball      05/20/13 - Add new errors; new interface for getCatalogLock
Rem                           New mechanism for warning messages
Rem    sdball      05/06/13 - Add err_invalid_weight
Rem    nbenadja    04/01/13 - Add gsm_session type.
Rem    sdball      02/26/13 - New types, lookup tables, and functions for
Rem                           versioning
Rem    sdball      03/13/13 - Support for admin managed databases
Rem    sdball      02/07/13 - Add catalog rollback changeIDs and new messages
Rem    xinjing     02/25/13 - Add err_add_to_pool
Rem    sdball      01/14/13 - New constants for TRUE/FALSE integers
Rem    sdball      11/20/12 - Add err_local_exists and err_in_cloud
Rem    lenovak     11/07/12 - update_svc_state
Rem    cechen      09/25/12 - bug-14576320: add err_need_dbp_name 
Rem    sdball      10/10/12 - add err_db_spfile
Rem    sdball      10/04/12 - add err_bad_retention, err_bad_replay,
Rem                           err_db_incompat, err_svc_stopped
Rem    sdball      09/26/12 - Add err_service_stopped
Rem    sdball      09/21/12 - Add sync_database
Rem    sdball      08/16/12 - add err_svc_relocate
Rem    sdball      07/09/12 - add err_loc_failover
Rem    sdball      06/15/12 - Add err_empty_dbpool
Rem    nbenadja    06/06/12 - Add a new warning.
Rem    sdball      05/18/12 - Add cross check messages.
Rem    sdball      04/09/12 - Code hard limits
Rem    sdball      03/26/12 - Add error err_db_incloud, err_nopref_all
Rem    sdball      03/01/12 - Better privilege errors
Rem    sdball      02/15/12 - New error messages
Rem    sdball      01/10/12 - Add message 45500.
Rem    sdball      12/08/11 - verify input lengths.
Rem    sdball      12/02/11 - error message cleanup
Rem    sdball      11/28/11 - Fix error messages.
Rem    nbenadja    11/23/11 - Add a new error
Rem    sdball      11/03/11 - changes for syncBrokerConfig
Rem    sdball      11/01/11 - Expose reserveNextDBNum for direct call by GSM
Rem    sdball      10/27/11 - Add removebk and remove_bk_ph
Rem    sdball      10/24/11 - Changes for recovery of add service
Rem    lenovak     07/22/11 - vncr support
Rem    mjstewar    04/17/11 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

-- SET ECHO ON
-- SPOOL dbmsgwmut.log

ALTER SESSION SET CURRENT_SCHEMA=GSMADMIN_INTERNAL
/

--*****************************************************************************
-- Public Types Needed for Package
--*****************************************************************************

-- Needed so that "create or replace" will work below
BEGIN
EXECUTE IMMEDIATE 'DROP TYPE tvers_lookup_t';
EXCEPTION
WHEN others THEN
  IF sqlcode = -4043 THEN NULL;
       -- suppress error for non-existent type
  ELSE raise;
  END IF;

END;
/

BEGIN
EXECUTE IMMEDIATE 'DROP TYPE vers_lookup_t';
EXCEPTION
WHEN others THEN
  IF sqlcode = -4043 THEN NULL;
       -- suppress error for non-existent type
  ELSE raise;
  END IF;

END;
/

BEGIN
EXECUTE IMMEDIATE 'DROP TYPE vers_lookup_rec';
EXCEPTION
WHEN others THEN
  IF sqlcode = -4043 THEN NULL;
       -- suppress error for non-existent type
  ELSE raise;
  END IF;

END;
/

BEGIN
EXECUTE IMMEDIATE 'DROP TYPE t_shdcol_tab';
EXCEPTION
WHEN others THEN
  IF sqlcode = -4043 THEN NULL;
       -- suppress error for non-existent type
  ELSE raise;
  END IF;

END;
/

BEGIN
EXECUTE IMMEDIATE 'DROP TYPE t_shdcol_row';
EXCEPTION
WHEN others THEN
  IF sqlcode = -4043 THEN NULL;
       -- suppress error for non-existent type
  ELSE raise;
  END IF;

END;
/


-- version lookup table to translate string version to numeric version
CREATE OR REPLACE TYPE tvers_rec IS OBJECT (
   vers_str       varchar(30), -- string version
   vers_num       number       -- numeric version
);
/
show errors

CREATE OR REPLACE TYPE tvers_lookup_t IS TABLE OF tvers_rec;
/
show errors

-- compatible version lookup
-- currently allows up to 5 compatible versions (should be plenty)
CREATE OR REPLACE TYPE vers_list IS VARRAY(5) OF NUMBER;
/

CREATE OR REPLACE TYPE vers_lookup_rec IS OBJECT (
   vers             number,    -- version to check
   comp_vers        vers_list  -- compatible versions
);
/
show errors

-- gsm session info
CREATE OR REPLACE TYPE gsm_session IS OBJECT (
   sessionid        NUMBER,    -- session id 
   gsmname          VARCHAR2(256)  -- gsm name 
);
/
show errors

CREATE OR REPLACE TYPE vers_lookup_t IS TABLE OF vers_lookup_rec;
/
show errors

CREATE OR REPLACE TYPE t_shdcol_row AS OBJECT (
  col_cnt               number,
  position              number,
  col_name              VARCHAR2(128)
)
/
show errors

CREATE OR REPLACE TYPE t_shdcol_tab IS TABLE OF t_shdcol_row
/
show errors


--*****************************************************************************
-- Database package for GSM utility functions and definitions.
--*****************************************************************************

CREATE OR REPLACE PACKAGE dbms_gsm_utility AS

--*****************************************************************************
-- Package Public Variables
--*****************************************************************************


--*****************************************************************************
-- Package Public Types
--*****************************************************************************


--*****************************************************************************
-- Package Public Constants
--*****************************************************************************

------------------------------------------------------------------------------
--
-- Note on new versioning as of May 2017
--
-- Going forward, the code only needs to consider major versions, as the new 
-- release model will no longer support patch versions. We are moving to 
-- annual major releases and cannot modify the version code for every 
-- RU(release updates) as they will be quarterly, i.e. 18.2, 18.3. 
--
-- 12.2.0.2 becomes 18.0.0 after this point.
--
------------------------------------------------------------------------------
-- Catalog version lookup. This table is used to translate database version
-- string into catalog version (a number). Each time a new database release is
-- supported, we need to add a new record to this lookup table. Several
-- database releases may resolve to the same catalog version if nothing
-- in the catalog interface changed between database releases (highly
-- unlikely, but possible). Changes in catalog interface will be:
--
--   - any changes to existing database objects or additions of new
--     database objects
--
--   - any changes to existing external PL/SQL procedure interfaces 
--     executed in the catalog, or additions of new external PL/SQL
--     procedures executed in the catalog. This includes
--     all external functions and procedures in DBMS_GSM_POOLADMIN
--     and DBMS_GSM_CLOUDADMIN, and some procedures in DBMS_GSM_UTILITY
--     and DBMS_GSM_COMMON. If you are unsure, bump the catalog version.
--
-- NOTE: Adding a new catalog version may require new entries in the version
--       compatibility tables below
--
--       Making changes in minor patches is not allowed because they will
--       not be installed correctly
------------------------------------------------------------------------------
catvers_lookup    constant   tvers_lookup_t := tvers_lookup_t(
--        Database Version       Catalog Version
--------------------------------------------------
tvers_rec('12.1.0.1',                 1),
tvers_rec('12.1.0.2',                 2),
tvers_rec('12.2.0.0',                 3),
tvers_rec('12.2.0.1',                 3),
tvers_rec('18.0.0.0',                 4)
);

------------------------------------------------------------------------------
-- GSM version lookup. This table is used to translate GSM version
-- string into GSM version (a number). Each time a new GSM release is
-- supported, we need to add a new record to this lookup table. Several
-- GSM releases may resolve to the same GSM version number if nothing
-- in the GSM interface changed between database releases (highly
-- unlikely, but possible).
--
-- NOTE: Adding a new GSM version may require new entries in the version
--       compatibility tables below
--
--       Making changes in minor patches will require addding another level
--       to the version string
------------------------------------------------------------------------------
gsmvers_lookup    constant   tvers_lookup_t := tvers_lookup_t(
--     GSM Version String      GSM Version number
--------------------------------------------------
tvers_rec('12.1.0.1',                 1),
tvers_rec('12.1.0.2',                 2),
tvers_rec('12.2.0.0',                 3),
tvers_rec('12.2.0.1',                 3),
tvers_rec('18.0.0.0',                 4)
);

------------------------------------------------------------------------------
-- cloud database version lookup. This table is used to translate DB version
-- string into database version (a number). Each time a new DB release is
-- supported, we need to add a new record to this lookup table. Several
-- DB releases may resolve to the same DB version number if nothing
-- in the Database interface changed between database releases (highly
-- unlikely, but possible); but be aware that this would preclude a reverse
-- lookup (which we already use in the code) since a single version number
-- would resolve to several version strings.
-- 
-- Changes to the database interface will be:
--
--   - any changes to existing external PL/SQL procedure interfaces 
--     executed in the cloud database, or additions of new external PL/SQL
--     procedures executed in the cloud database. This includes
--     all external functions and procedures in DBMS_GSM_DBADMIN
--     and some procedures in DBMS_GSM_UTILITY
--     and DBMS_GSM_COMMON. If you are unsure, bump the database version.
--
-- NOTE: Adding a new DB version may require new entries in the version
--       compatibility tables below
--
--       Making changes in minor patches is not allowed because they will
--       not be installed correctly
--
-- WARNING! Important: If you add a new version here,
-- please add it into a C code as well into gwm_get_db_version()
------------------------------------------------------------------------------
dbvers_lookup    constant   tvers_lookup_t := tvers_lookup_t(
--      DB Version String      DB Version number
--------------------------------------------------
tvers_rec('12.1.0.1',                 1),
tvers_rec('12.1.0.2',                 2),
tvers_rec('12.2.0.0',                 3),
tvers_rec('12.2.0.1',                 3),
tvers_rec('18.0.0.0',                 4)
);

------------------------------------------------------------------------------
-- GDSCTL version lookup. This table is used to translate GDSCTL version
-- string into GDSCTL version (a number). Each time a new GDSCTL release is
-- supported, we need to add a new record to this lookup table. Several
-- GDSCTL releases may resolve to the same GDSCTL version number if nothing
-- in the GDSCTL interface changed between database releases (highly
-- unlikely, but possible).
--
-- NOTE: Adding a new GDSCTL version may require new entries in the version
--       compatibility tables below
--
--       Making changes in minor patches will require addding another level
--       to the version string
------------------------------------------------------------------------------
gdsctlvers_lookup    constant   tvers_lookup_t := tvers_lookup_t(
--  GDSCTL Version String     GDSCTL Version number
--------------------------------------------------
tvers_rec('12.1.0.1',                 1),
tvers_rec('12.1.0.2',                 2),
tvers_rec('12.2.0.0',                 3),
tvers_rec('12.2.0.1',                 3),
tvers_rec('18.0.0.0',                 4)
);

-------------------------------------------------------------------------------
-- GDSCTL <=> catalog version compatibility lookup
-- Each known GDSCTL version will have a list of compatible catalog versions
-- Current versioning rule:
--     - catalog version should always be greater than or equal to
--       GDSCTL version
-------------------------------------------------------------------------------
gdsctl_catalog_lookup    constant   vers_lookup_t := vers_lookup_t(
--          GDSCTL VERSION       Compatible catalog versions
------------------------------------------------------------------------
vers_lookup_rec(   1,                  vers_list(1,2,3,4) ),
vers_lookup_rec(   2,                  vers_list(2,3,4) ),
vers_lookup_rec(   3,                  vers_list(3,4) ),
vers_lookup_rec(   4,                  vers_list(4) )
);

-------------------------------------------------------------------------------
-- GSM <=> catalog version compatibility lookup
-- Each known GSM version will have a list of compatible catalog versions
-- Current versioning rule:
--     - catalog version should always be greater than or equal to
--       GSM version
-------------------------------------------------------------------------------
gsm_catalog_lookup    constant   vers_lookup_t := vers_lookup_t(
--             GSM VERSION       Compatible catalog versions
------------------------------------------------------------------------
vers_lookup_rec(   1,                  vers_list(1,2,3,4) ),
vers_lookup_rec(   2,                  vers_list(2,3,4) ),
vers_lookup_rec(   3,                  vers_list(3,4) ),
vers_lookup_rec(   4,                  vers_list(4) )
);

-------------------------------------------------------------------------------
-- Default Names
-------------------------------------------------------------------------------
default_cloud_name      constant   varchar2(10) := 'oradbcloud';

-------------------------------------------------------------------------------
-- Values for table indicator fields
-------------------------------------------------------------------------------

-- DDL operation types (operation_type in ddl_requests)
sync_signal             constant    char := 'S';
ddl_create              constant    char := 'C';
ddl_alter               constant    char := 'A';
ddl_drop                constant    char := 'D';
ddl_grant               constant    char := 'G';
ddl_revoke              constant    char := 'R';
ddl_truncate            constant    char := 'T';
new_shardspace          constant    char := 'P';
ddl_split               constant    char := 'L';
user_sql                constant    char := 'U';
ddl_password            constant    char := 'W'; -- DDL contains password

-- Database deployment status (dlp_status in database)
not_deployed            constant    number := 0;
deploy_requested        constant    number := 1;
replication_configured  constant    number := 2; -- Dataguard
chunks_deployed         constant    number := 3;
ddl_deployed            constant    number := 4;
ogg_rep_configured      constant    number := 5;

-- runtime database status (flags field in database table)
-- this is a bitmap in GSM, each value should correspond to a single bit
-- Use the BITAND function to compare these flags in PL/SQL
db_down                 constant    number := to_number('00000000','xxxxxxxx');
db_up                   constant    number := to_number('00000001','xxxxxxxx');
is_primary              constant    number := to_number('00000002','xxxxxxxx');
failed_source           constant    number := to_number('00000004','xxxxxxxx');
                                           -- move failed on source db
failed_target           constant    number := to_number('00000008','xxxxxxxx');
                                           -- move failed on target db
green_field             constant    number := to_number('00000010','xxxxxxxx');
                                           -- deploy requested on green filed DB
waiting_for_sync        constant    number := to_number('00000020','xxxxxxxx');
                                           -- waiting for GSM to run sync
failed_ogg              constant    number := to_number('00000040','xxxxxxxx');
                                           -- move failed on OGG operation

-- rerefernce table flags (ref_table_flag in sharded_table)
is_ref_table             constant    char := 'D';
is_root_table            constant    char := 'R';

-- catalog_requests (request_type)
chunk_move              constant    number := 1;
chunk_copy              constant    number := 2;
chunk_drop              constant    number := 3;
chunk_move_atomic       constant    number := 4;
chunk_move_atm_int      constant    number := 5;

-- deploy_state (cloud)
no_deploy               constant    number := 0; -- no deploy running
in_deploy               constant    number := 1; -- deploy in progress
deploy_chunks           constant    number := 2; -- request chunk deployment

-- catalog_requests (status)
req_pending             constant    number := 0; -- waiting to start
in_gsm                  constant    number := 1; -- sent to GSM
chunk_on_target         constant    number := 3; -- GSM moved to target
target_done             constant    number := 4; -- target confirmed move
move_suspended          constant    number := 5;
--  states of catalog request for atomic move
move_st_init            constant    number := 10; -- initial state 
move_st_dcpy            constant    number := 11; -- data copied 
move_st_mfnt            constant    number := 12; -- move finished on target 
move_st_dcfl            constant    number := 13; -- data copy fail 
move_st_mvcn            constant    number := 14; -- cancelled move 
move_st_srrl            constant    number := 15; -- source roll-backed 
move_st_srfl            constant    number := 16; -- source error 
move_st_trfl            constant    number := 17; -- initial state 
move_st_term            constant    number := 18; -- success terminal  state 
move_st_ftrm            constant    number := 19; -- failure terminal  state
-- failure codes (down from 99)
chunk_move_failed       constant    number := 99; -- actual move failed
target_failed           constant    number := 98; -- chunk not live on target
source_failed           constant    number := 97; -- cannot cleanup source

-- shardgroup (status)
sg_undeployed           constant    number := 0;
sg_deployed             constant    number := 1;

-- shardspace (status)
ss_undeployed           constant    number := 0;
ss_chunks               constant    number := 1; -- request sent to deploy chunks
ss_deployed             constant    number := 2;

-- shard (status)
gws_undeployed          constant    number := 0;
gws_deployed            constant    number := 1;

-- operations for AQ92 (gen_multi_target)
exec_stmt               constant    number := 1; -- execute a statement

msg_message             constant    number := 0; -- message
msg_start               constant    number := 1; -- start
msg_end                 constant    number := 2; -- end
msg_warning             constant    number := 3; -- warning
msg_info                constant    number := 4; -- info about AQs

-- actions for updateMovechunk
restart_move            constant    number := 0;
suspend_move            constant    number := 1;
remove_chunks           constant    number := 2;

-------------------------------------------------------------------------------
-- Identifier lengths
-------------------------------------------------------------------------------

-- Must honor max service name lengths defined by database
max_service_name_len     constant  number := 64;
max_net_service_name_len constant  number := 250;

-- max length of an instance name
max_inst_name_len        constant  number := 16;

-- max length of AQ parameters
-- (matches size of additional_params in
--  type gsm_change_message, see catgwm.sql)
max_param_len            constant  number := 4000;

-- Max number of VNCRs
max_vncr_number constant  number := 1000;

-- Max number of services
max_services    constant  number := 1000;

-- Maximum number of database pools
max_dbpools       constant  number := 200;

------------------------------------------------------------------------------
-- Other global values
------------------------------------------------------------------------------

-- database deployment states for DB parameter _gws_deployed
not_depl           constant  number := 0;
gds_setup          constant  number := 1; -- GSM installed DB will register
db_depl            constant  number := 2; -- database deployment complete

-- values for parameter _gws_sharding_method
not_sharded        constant  number := 0; 
sh_system          constant  number := 1; -- system-managed sharding
sh_userdef         constant  number := 2; -- user-defined sharding
sh_composite       constant  number := 3; -- composite sharding

-------------------------------------------------------------------------------
-- Change Log Queue and generateChangeLogEntry() definitions.
-- These constants are defined for use with generateChangeLogEntry().
-- They are also the values stored in a gsm_change_message.
--
-- NOTE: The values are used to identify AQ messages that are sent to the GSM.
--       This is the primary way in which the catalog communicates with the GSM
--       servers. We currently allow the GSM server to be at a lower level than
--       the catalog (but not vice-versa). Be *VERY* careful not to change
--       the format of any existing AQ message in such a way that a prior
--       version of the GSM will not understand it. If there is a requirement,
--       add a new AQ message type, and be aware that new AQ message types
--       that are not understood by old GSM servers will simply be ignored.
--       Use the "version" field in the "gsm" table to work out how to handle
--       different situations.
-------------------------------------------------------------------------------

-- "adminId" values for generateChangeLogEntry().
-- These constants define the package that generated the change entry.
-- Also stored in the the change log queue in gsm_change_message.admin_id.
-- NOTE: this is here for backward compatibility. new calls to 
-- generateChangeLogEntry should use values below. These values are translated
-- in the procedure.

cloud_admin            constant   number := 1;
pool_admin             constant   number := 2;
ddl_admin              constant   number := 3; -- generated by DDL in SQL

-- new values for what used to be admin_id, now used to determine
-- number of targets.
in_payload             constant   number := 1; -- usually single target
all_databases          constant   number := 0;
-- Otherwise, number of targets

-- special gsm_requests sequence ID for pending GDSCTL warnings
pendingWarning         constant   number := -1;

-- "changeId" values for generateChangeLogEntry() when adminId is cloud_admin.
-- "target" of command is always the object name (e.g. GSM name).
--  Also stored in the change log queue in gsm_change_message.change_id.

add_gsm                constant   number := 1;
modify_gsm             constant   number := 2;
drop_gsm               constant   number := 3;
start_gsm              constant   number := 4;
stop_gsm               constant   number := 5;

add_region             constant   number := 10;
modify_region          constant   number := 11;
drop_region            constant   number := 12;

add_database_pool      constant   number := 20;
modify_database_pool   constant   number := 21;
drop_database_pool     constant   number := 22;

replace_database       constant   number := 23; -- adminId is pool_admin

-- "changeId" values for generateChangeLogEntry() when adminId is pool_admin.
-- "target" of command is always the object name (e.g. database or service name)
-- Also stored in the change log queue in gsm_change_message.change_id.

add_database           constant   number := 30;
modify_database        constant   number := 31;
drop_database          constant   number := 32;
start_database         constant   number := 33;
stop_database          constant   number := 34;
drop_db_phys           constant   number := 35;
add_broker_config      constant   number := 36;
mod_db_status          constant   number := 37;
add_db_done            constant   number := 38;
sync_database          constant   number := 39;
mod_db_runtime         constant   number := 40;
modify_dg_db_property  constant   number := 41;
modify_dg_bk_property  constant   number := 42;
deploy_primary         constant   number := 43;
deploy_standby         constant   number := 44;
modify_broker_config   constant   number := 45;
add_broker             constant   number := 46;
remove_broker_config   constant   number := 47;
add_service            constant   number := 50;
modify_service         constant   number := 51;
drop_service           constant   number := 52;
relocate_service       constant   number := 53;
start_service          constant   number := 54;
stop_service           constant   number := 55;
enable_service         constant   number := 56;
disable_service        constant   number := 57;
add_service_to_dbs     constant   number := 58;
move_service_to_db     constant   number := 59;
make_dbs_preferred     constant   number := 60;
modify_service_config  constant   number := 61;
modify_service_on_db   constant   number := 62;
update_service_state   constant   number := 63;
add_vncr               constant   number := 70;
remove_vncr            constant   number := 71;
drop_service_ph        constant   number := 72;
drop_broker_config     constant   number := 73;
drop_bc_phys           constant   number := 74;
sync_broker_config     constant   number := 75;
mod_db_vers            constant   number := 76;
-- Special number for warning messages
plsql_warning          constant   number := 77;
-- DDL request
ddl_request            constant   number :=80;
ddl_ignore             constant   number :=81;
ddl_recover            constant   number :=82;
add_shardgroup         constant   number :=83;
remove_shardgroup      constant   number :=84;
finalize_deploy        constant   number :=85;
deploy_brokers         constant   number :=86;
move_chunk             constant   number :=87;
move_complete          constant   number :=88;
move_abort             constant   number :=89;
split_chunk            constant   number :=90;
-- OGG requests
ogg_rep_setup          constant   number :=91;
gen_multi_target       constant   number :=92;
ogg_multi_target       constant   number :=93;
-- start observer
start_observer         constant   number :=94;

-- DDL refetch due to user password change
ddl_refetch            constant   number :=95;

-- catalog rollback IDs. There should be a matching "do it" ID above
-- for simplicity, we are just adding 100 to the "do it" counterpart
rb_drop_service           constant  number := 152;
rb_modify_service_on_db   constant  number := 162;

--*****************************************************************************
-- Package Public Exceptions
--*****************************************************************************


--*****************************************************************************
-- Package Public Procedures
--*****************************************************************************
-------------------------------------------------------------------------------
--
-- PROCEDURE     getCatalogLock
--
-- Description:
--       Gets the catalog lock prior to making a change to the cloud catalog.      
--
-- Parameters:
--       currentChangeSeq -    The current value of cloud.change_seq#
--                             This is the sequence # of the last committed 
--                             change.
--    
------------------------------------------------------------------------------- 

PROCEDURE getCatalogLock( currentChangeSeq OUT number);

PROCEDURE getCatalogLockPrvt( currentChangeSeq OUT    number,
                          privs            IN     number,
                          gdsctl_version   IN     varchar2 default NULL,
                          gsm_version      IN     varchar2 default NULL,
                          gsm_name         IN     varchar2 default NULL,
                          catalog_vers     OUT    number,
                          update_mode      IN     number);

-------------------------------------------------------------------------------
--
-- PROCEDURE     releaseCatalogLock
--
-- Description:
--      Releases the catalog lock and commits or rolls back the changes
--      made under the lock.       
--
-- Parameters:
--      action:  "releaseLockCommit" -> release lock and commit all
--                             changes
--               "releaseLockRollback" -> release lock and rollback
--                             all changes
--      changeSeq: If "action" = "releaseLockCommit" this is the change
--                 sequence number of the the last change made under this lock.
--                 If "action" = "releaseLockRollback" then will be set to 0.
--            
--
-- Notes:
--    
------------------------------------------------------------------------------- 

releaseLockCommit           constant  number := 1;
releaseLockRollback         constant  number := 2;


PROCEDURE releaseCatalogLock( action    IN number default releaseLockCommit,
                              changeSeq OUT number );
PROCEDURE releaseCatalogLockPrvt( action    IN number default releaseLockCommit,
                              changeSeq OUT number );

-------------------------------------------------------------------------------
--
-- FUNCTION     regionExists
--
-- Description:
--    Checks if the specified region exists in the cloud catalog.
--
-- Parameters:
--    region_name:   The region to check.
--    region_num:    If the region exists, returns its number
--
-- Returns:
--    TRUE if the region is in the cloud catalog.
--
-- Notes:
--    
------------------------------------------------------------------------------- 
FUNCTION regionExists( region_name IN  varchar2,
                       region_num  OUT number )
  RETURN boolean;

FUNCTION shardspaceExists( shardspace_name IN  varchar2,
                           shardspace_id  OUT number )
  RETURN boolean;

-- SHARD_TODO: description
FUNCTION shardgroupExists( shardgroup_name IN varchar2 )
  RETURN boolean;

FUNCTION isShardedCatalog (stype OUT number)
  RETURN BOOLEAN;

FUNCTION isGSMUp
  RETURN BOOLEAN;
-------------------------------------------------------------------------------
--
-- FUNCTION     databasePoolExists
--
-- Description:
--   Checks if the specified database pool exists in the cloud catalog.
--
-- Parameters:
--   database_pool_name:  The pool to check.
--
-- Returns:
--   TRUE if the database pool is in the cloud catalog.
--
-- Notes:
--    
------------------------------------------------------------------------------- 
FUNCTION databasePoolExists( database_pool_name IN varchar2 )
  RETURN boolean;

-------------------------------------------------------------------------------
--
-- FUNCTION     prepareName
--
-- Description:
--       Verifies the length of a (service, GSM, etc) name and prepares 
--       it for use by the GSM package.
--
--       Trims off leading and trailing spaces and converts it to lower
--       case.        
--
-- Parameters:
--       in_name:     The name to check and and prepare for use.
--       out_name:    The prepared name.
--       max_length:  The maximum allowable length for out_name.
-- 
-- Returns:
--    TRUE if the name is the correct length.
--    FALSE otherwise (out_name will not be set).           
--
-- Notes:
--   Names of GSM objects (services, GSMs, regions, etc) are stored in the
--   catalog in lower case.
--    
-------------------------------------------------------------------------------
FUNCTION prepareName( in_name     IN  varchar2,
                      out_name    OUT varchar2,
                      max_length  IN  number,
                      allow_mcase IN  boolean DEFAULT FALSE)
  RETURN boolean;

-------------------------------------------------------------------------------
--
-- FUNCTION     prepareRegionName
--
-- Description:
--     Returns the region name to use on a dbms_gsm_* call when the region
--     name in the routine call can be NULL.
--
--     If the supplied name is NULL will determine if a default region name
--     can be used and returns it.  A default only exists if a single
--     region has been defined.  The default is that region.  If more than one
--     region has been defined, then a default cannot be picked and FALSE is
--     returned.
--
--     If the supplied name is not NULL, then verifies that it is the right
--     length and prepares it for use: trims off leading and trailing spaces
--     and converts to upper case.
--          
--
-- Parameters:
--       input_name  (INPUT)  - the supplied name (can be NULL)
--       region_name (OUTPUT) - the region name to use
--
-- Returns:
--       TRUE if a valid region name can be returned
--       FALSE if not
--
-- Notes:
--    
------------------------------------------------------------------------------- 
FUNCTION prepareRegionName( input_name IN varchar2,
                            region_name OUT varchar2 )
  RETURN boolean;

-------------------------------------------------------------------------------
--
-- FUNCTION     prepareDBPoolName
--
-- Description:
--     Returns the database pool name to use on a dbms_gsm_* call when the
--     database pool name in the routine call can be NULL.
--
--     If the supplied name is NULL will determine if a default database pool
--     name can be used and returns it.  A default only exists if a single
--     pool has been defined.  The default is that pool.  If more than one
--     pool has been defined, then a default cannot be picked and FALSE is
--     returned.
--
--     If the supplied name is not NULL, then verifies that it is the right
--     length and prepares it for use: trims off leading and trailing spaces
--     and converts to upper case.
--          
--
-- Parameters:
--       input_name         (INPUT)  - the supplied name (can be NULL)
--       database_pool_name (OUTPUT) - the database pool name to use
--
-- Returns:
--       TRUE if a valid database pool name can be returned
--       FALSE if not
--
-- Notes:
--    
------------------------------------------------------------------------------- 

FUNCTION prepareDBPoolName( input_name         IN  varchar2,
                            database_pool_name OUT varchar2,
                            shardgroup_name    IN  varchar2 DEFAULT NULL,
                            shardspace_name    IN  varchar2 DEFAULT NULL )
  RETURN boolean;
-------------------------------------------------------------------------------
--
-- PROCEDURE     generateChangeLogEntry
--
-- Description:
--       Generates a description of a change and puts it into the
--       change log queue.     
--
-- Parameters:
--       adminId:   package that is calling this routine
--                  "cloud_admin" - dbms_gsm_cloudadmin package
--                  "pool_admin"  - dbms_gsm_pooladmin package
--       changeId:  the change made (see constant definitions above)
--       target:    command target (e.g. gsm name for "add gsm")
--       poolName:  database pool (only if adminId = pool_admin)
--       params:    additional parameters for the change
--       updateRequestTable: whether or not to also put the change into
--                   gsm_requests table
--            
--
-- Notes:
--   See constant definitions above for "adminId" and "changeId" parameters.
--    
-------------------------------------------------------------------------------

updateFalse  constant  number := 0;
updateTrue   constant  number := 1;

PROCEDURE generateChangeLogEntry( adminId   IN number,
                                  changeId  IN number,
                                  target    IN varchar2,
                                  poolName  IN varchar2 default NULL,
                                  params    IN varchar2 default NULL,
                                  updateRequestTable  IN number
                                      default updateTrue,
                                  old_instances IN instance_list
                                      default NULL,
                                  ddl_num   IN number default NULL,
                                  databases IN number_list default NULL)
ACCESSIBLE BY (PACKAGE dbms_gsm_dbadmin, 
               PACKAGE dbms_gsm_pooladmin,
               PACKAGE dbms_gsm_common,
               PACKAGE dbms_gsm_cloudadmin,
               PACKAGE ggsys.ggsharding);
PROCEDURE generateChangeLogEntry( adminId   IN number,
                                  changeId  IN number,
                                  target    IN varchar2,
                                  poolName  IN varchar2 default NULL,
                                  params    IN varchar2 default NULL,
                                  updateRequestTable  IN number
                                      default updateTrue,
                                  old_instances IN instance_list
                                      default NULL,
                                  ddl_num   IN number default NULL,
                                  databases IN number_list default NULL,
                                  parent_id IN number default NULL,
                                  seq_id  OUT number)
ACCESSIBLE BY (PACKAGE dbms_gsm_dbadmin, 
               PACKAGE dbms_gsm_pooladmin,
               PACKAGE dbms_gsm_common,
               PACKAGE dbms_gsm_cloudadmin,
               PACKAGE ggsys.ggsharding);

-------------------------------------------------------------------------------
--
-- PROCEDURE     raise_gsm_warning
--
-- Description:
--       Causes a warning message to display on GDSCTL session. Can be used
--       during catalog processing only  
--
-- Parameters:
--       message_id: numeric value of warning message
--       parms       message parameters (if any)
--            
-- Notes:
--   causes a warning message to be sent to GDSCTL by adding a new record
--   to gsm_requests. Does not interrupt processing
--    
-------------------------------------------------------------------------------
PROCEDURE raise_gsm_warning (message_id     IN   number,
                             parms          IN   message_param_list
                                DEFAULT message_param_list());
                                
-------------------------------------------------------------------------------
--
-- PROCEDURE     send_gdsctl_msg
--
-- Description:
--       Causes a  message to display on GDSCTL session.
--
-- Parameters:
--       message_type  - start, default,end
--       message       - diagnostic message
--       gdsctl_sid    - gdsctl sid
--            
-- Notes:
--   causes a warning message to be sent to GDSCTL by adding a new record
--   to gdsctl_messages.
--    
-------------------------------------------------------------------------------
PROCEDURE send_gdsctl_msg (
                           message          IN   VARCHAR2,
                           gdsctl_sid   IN NUMBER,
                           message_type     IN   number default msg_message);                                

-------------------------------------------------------------------------------
--
-- PROCEDURE     removeStaleRequests
--
-- Description:
--       Removes stale entries from gsm_requests
--
-- Parameters:
--       age:    IN    Requests older than this are removed
--
--
-- Notes:
------------------------------------------------------------------------------- 
PROCEDURE removeStaleRequests; --(age IN INTERVAL DAY TO SECOND 
--                                          default '10 minutes');

------------------------------------------------------------------------------
--
-- PROCEDURE isLockedByMaster
--
-- Description:
--      Determines if master locak is already taken
--
-- Parameters:
--      None
--
-- Returns:
--      0 - Master lock is not taken
--      1 - Master Lock is taken
--
------------------------------------------------------------------------------
FUNCTION isLockedByMaster
  RETURN integer;

------------------------------------------------------------------------------
--
-- PROCEDURE RSAEncoder
--
-- Description:
--      Encrypt input string to byte array using PKCS
--
-- Parameters:
--      input:      IN    String to be encrypted
--      keybyte:    IN    PKI public key bytes 
--      output:     OUT   Encrypted bytes
--
--
------------------------------------------------------------------------------

PROCEDURE RSAEncoder( input      IN    varchar2,
                      keybyte    IN    RAW,
                      output     OUT   RAW);

-------------------------------------------------------------------------------
--
-- FUNCTION     maxDBInstances
--
-- Description:
--       Queries the database parameter setting for the maximum number of
--       instances to reserve for a cloud database.
--
-- Parameters:
--       None
--
-- Returns:
--       The maximum.
--
-- Notes:
--    
-------------------------------------------------------------------------------
FUNCTION maxDBInstances
  RETURN number;


-------------------------------------------------------------------------------
--
-- FUNCTION     getChunkId
--
-- Description:
--       Return chunk id for the shard keys provided if the chunk exists
--       at the current shard. This function does not need supersharding 
--       key in case of the composite sharding.
--
--       Undefined behaviour on the catalog database.
--
-- Parameters:
--       Sharding key column values (in case of composite sharding, only 
--       sharding part is accepted, i.e. no supershard key).
--
-- Returns:
--       The Chunk Id, or 0 if chunk not found on the current shard.
--
-- Note:
--       If parameter types mismatch no error is thrown, NULL is returned.
--       Column values must have exactly the same type as defined for 
--       sharded table. Otherwise, NULL is returned.
--
-------------------------------------------------------------------------------

FUNCTION getChunkId(keys ...) RETURN number;


-------------------------------------------------------------------------------
--
-- FUNCTION     getChunkUniqueId
--
-- Description:
--       Return chunk unique id (not chunk id) for the supershard and shard 
--       keys provided if the chunk exists.
--
--       Works on the catalog database.
--
-- Parameters:
--       Supershard and shard key column values.
--
-- Returns:
--       The Chunk Unique Id, or NULL if chunk not found on the current shard.
--
-- Note:
--       If parameter types mismatch no error is thrown, NULL is returned.
--       Column values must have exactly the same type as defined for 
--       sharded table. Otherwise, NULL is returned.
--
-------------------------------------------------------------------------------

FUNCTION getChunkUniqueId(keys ...) RETURN number;


-------------------------------------------------------------------------------
--
-- FUNCTION     getShardspaceIdByText
--
-- Description:
--       Return shardspace id for the supershard key provided
--          if the shardspace exists.
--
--       Works on the catalog database.
--
-- Parameters:
--       super_sharding key in connect_data representation
--       if b64flag is set to 1, base64 representation should be used
--
-- Returns:
--       The Shardspace Id, or NULL if the shardspace not found.
--
-- Note:
--       If parameter types mismatch no error is thrown, NULL is returned.
--       Column values must have exactly the same type as defined for
--       sharded table. Otherwise, NULL is returned.
--
-------------------------------------------------------------------------------

FUNCTION getShardspaceIdByText(
    supersharding_key varchar2,
    b64flag           number default 0)
  RETURN number;

-------------------------------------------------------------------------------
--
-- FUNCTION     getChunkUniqueIdByText
--
-- Description:
--       Return chunk unique id (not chunk number) for the given shardspace
--       with keys provided if the chunk exists.
--
--       Works on the catalog database.
--
-- Parameters:
--       shardspace_id and sharding key in connect_data representation
--       if b64flag is set to 1, base64 representation should be used
--
-- Returns:
--       The Chunk Unique Id, or NULL if chunk not found.
--
-- Note:
--       If parameter types mismatch no error is thrown, NULL is returned.
--       Column values must have exactly the same type as defined for
--       sharded table. Otherwise, NULL is returned.
--
-------------------------------------------------------------------------------

FUNCTION getChunkUniqueIdByText(
    sharding_key  varchar2,
    shardspace_id number default null,
    b64flag       number default 0)
  RETURN number;


------------------------------------------------------------------------------
--
-- FUNCTION     getSessionKeyText
--
-- Description:
--      Return a human readible representation (not reversible) of the current
--      session key
--
-- Parameters:
--      klevel 0 for sharding, 1 for supersharding key
--
------------------------------------------------------------------------------

FUNCTION getSessionKeyText(klevel in number default 0) RETURN varchar2;


------------------------------------------------------------------------------
--
-- FUNCTION     getSessionKeyRaw
--
-- Description:
--      Return a binary (KDK) representation of the current session key.
--
-- Parameters:
--      colidx column number (in case of hash, 0 is for hash value)
--      klevel 0 for sharding, 1 for supersharding key
--
------------------------------------------------------------------------------

FUNCTION getSessionKeyRaw(colidx in number, klevel in number default 0) 
  RETURN raw;

------------------------------------------------------------------------------
--
-- FUNCTION     setSessionKey
--
-- Description:
--      Set the current session key as text value, columns separated by comma.
--      Base64 TEXT escaping for each column value is supported, ^ as the first
--      character, e.g. : 1,abc,3 can be represented as ^MQ==,^YWJj,^Mw==
--
-- NOTE: for non-composite sharding supersharding_k must be '' (empty string)
-- NOTE: NULL for sharding_k resets the key, make session sharding-detached.
--
------------------------------------------------------------------------------

PROCEDURE setSessionKey(sharding_k in varchar2, supersharding_k in varchar2);

------------------------------------------------------------------------------
--
-- PROCEDURE reserveInstNums
--
-- Description:
--    Reserve reserve_count database numbers from cloud
--
-- Notes:
--   Only useful for PL/SQL calls, current value should be known already
--   otherwise this function has no good use.
--
------------------------------------------------------------------------------
PROCEDURE reserveInstNums( reserve_count IN number );

------------------------------------------------------------------------------
--
-- FUNCTION reserveNextDBNum
--
-- Description:
--   Reserves the next available DB number for use.
--
-- Returns:
--   The next available number
--
-- Notes:
--   This function updates the cloud table, but does not commit. The caller
--   is expected to commit (if the number is used), or rollback (if the 
--   number can be re-used). An update lock on the cloud table will be held
--   until the caller either commits or rolls back.
--
------------------------------------------------------------------------------
FUNCTION reserveNextDBNum( reserve_count   IN number default NULL)
  RETURN number;

------------------------------------------------------------------------------
--
-- FUNCTION getFieldSize
--
-- Description:
--   gets the size of a database field
--
-- Returns:
--   size
--
-- Notes:
--   Used internally by PL/SQL to verify the size of input strings
--
------------------------------------------------------------------------------
FUNCTION getFieldSize( tab_name   IN varchar2,
                       col_name   IN varchar2)
  RETURN number;

------------------------------------------------------------------------------
--
-- FUNCTION getCatalogVersion
--
-- Description:
--   returns the version of this catalog
--
-- Returns:
--   catalog version (number)
--
-- Notes:
--    Catalog version is calculated from RDBMS version using a lookup table 
--    (see description at the top of this file)
--
------------------------------------------------------------------------------
FUNCTION getCatalogVersion
  RETURN number;

------------------------------------------------------------------------------
--
-- FUNCTION getDBVersion
--
-- Description:
--   returns the version of this cloud database
--
-- Returns:
--   cloud database version (number)
--
-- Notes:
--    Database version is calculated from RDBMS version using a lookup table 
--    (see description at the top of this file)
--
------------------------------------------------------------------------------
FUNCTION getDBVersion
  RETURN number;

------------------------------------------------------------------------------
--
-- FUNCTION DBVersRevLookup
--
-- Description:
--   returns the database version string given version number (reverse lookup)
--
-- Parameters:
--      dbvers - Database version number to look up
--
-- Returns:
--   cloud database version string
--
-- Notes:
--    Database version string is calculated from input using a lookup table 
--    (see description at the top of this file)
--
------------------------------------------------------------------------------
FUNCTION DBVersRevLookup (dbvers    IN    number)
   RETURN varchar2;

------------------------------------------------------------------------------
--
-- FUNCTION GSMVersLookup
--
-- Description:
--   returns the numeric version of the GSM given version string
--
-- Parameters:
--      gsm_vers - GSM version to lookup
--
-- Returns:
--   GSM version (number)
--
-- Notes:
--    GSM version is calculated from version string using a lookup table 
--    (see description at the top of this file)
--
------------------------------------------------------------------------------
FUNCTION GSMVersLookup (gsm_vers    IN    varchar2)
   RETURN number;

------------------------------------------------------------------------------
--
-- FUNCTION GDSCTLVersLookup
--
-- Description:
--   returns the numeric version of GDSCTL given version string
--
-- Parameters:
--      gdsctl_vers - GDSCTL version to lookup
--
-- Returns:
--   GDSCTL version (number)
--
-- Notes:
--    GDSCTL version is calculated from version string using a lookup table 
--    (see description at the top of this file)
--
------------------------------------------------------------------------------
FUNCTION GDSCTLVersLookup (gdsctl_vers    IN    varchar2)
   RETURN number;

------------------------------------------------------------------------------
--
-- FUNCTION compatibleVersion
--
-- Description:
--   determines if provided versions are compatible with each other
--
-- Returns:
--   TRUE/FALSE - are versions compatible
--
-- Notes:
--   Compatible versions are determined from a lookup table (see description
--   at the top of this file)
--
------------------------------------------------------------------------------
FUNCTION compatibleVersion (gdsctl_version    number default NULL,
                            catalog_version   number default NULL,
                            gsm_version       number default NULL,
                            db_version        number default NULL)
  RETURN boolean;

PROCEDURE new_family (family_name         IN  varchar2, 
                      partition_set_type  IN  number,
                      shard_type          IN  number);

PROCEDURE new_keycol (family_name    IN   varchar2,
                      column_name    IN   varchar2,
                      klevel         IN   number);

PROCEDURE new_table ( table_name            IN   varchar2,
                      schema_name           IN   varchar2,
                      table_id              IN   number,
                      parent_name           IN   varchar2 DEFAULT NULL,
                      ref_table_flag        IN   char DEFAULT NULL,
                      num_chunks            IN   number DEFAULT NULL,
                      is_consistent         IN   number DEFAULT 1,
                      parent_schema         IN   varchar2 DEFAULT NULL);


PROCEDURE new_shard_tablespace (tablespace_name     IN   varchar2,
                                chunk_number        IN   number,
                                shardspace_name     IN   varchar2 DEFAULT NULL);

PROCEDURE new_tablespace_set (set_name        IN    varchar2,
                              shardspace_id   IN    number,
                              partition_set   IN    varchar2 DEFAULT NULL);

PROCEDURE new_ts_set_table (ts_set_name        IN    varchar2,
                            table_id           IN    number,
                            parent_name        IN    varchar2,
                            usage_flag         IN    char,
                            childobj_id        IN    number DEFAULT NULL);
 
PROCEDURE new_partition_set ( set_name              IN   varchar2,
                              tsset_name            IN   varchar2,
                              family_name           IN   varchar2,
                              high_value_len        IN   number,
                              high_value            IN   long,
                              bin_high_value        IN   BLOB,
                              low_value_len         IN   number,
                              low_value             IN   long,
                              bin_low_value         IN   BLOB,
                              psorder               IN   number default NULL);

PROCEDURE new_ddl_request (ddl_text         IN   clob,
                           orig_ddl_text    IN   clob,
                           schema_name      IN   varchar2 DEFAULT NULL,
                           object_name      IN   varchar2 DEFAULT NULL,
                           operation_type   IN   varchar2,
                           pwd_count        IN   number,
                           ddl_intcode      IN   number,
                           ddl_num          OUT  number);
                           
PROCEDURE new_ddl_request_pwd (e_pwd           IN   varchar2,
                              pwd_begin        IN   number,
                              ddl_num          IN   number,
                              user_name        IN   varchar2 DEFAULT NULL);  

PROCEDURE  update_ddl_duptbl(object_name           IN   varchar2,
                             schema_name        IN   varchar2);

PROCEDURE  update_ddl_incdep;

PROCEDURE cleanupDDL;

PROCEDURE drop_table (table_id       IN number); 

PROCEDURE drop_tables_in_tset(ts_name IN VARCHAR2,
                              user_id IN NUMBER,
                              ddl_enabled IN BOOLEAN,
                              prop_ddl IN BOOLEAN);
PROCEDURE drp_created_ts (name     IN   varchar2);

PROCEDURE crt_Cshdblink (user_name    IN   varchar2,
                        passwd        IN   varchar2,
                        conn_str      IN   varchar2,
                        isCat         IN   boolean);

PROCEDURE alt_Cshdblink (user_name    IN   varchar2,
                        passwd        IN   varchar2,
                        isCat         IN   boolean);

PROCEDURE drp_Cshdblink (user_name    IN   varchar2,
                        isCat         IN   boolean);

FUNCTION getRepType (dbname    IN   varchar2)
RETURN number;

PROCEDURE getCatInfo(html_port            OUT     number,
                     registration_pass    OUT     varchar2,
                     cat_host             OUT     varchar2);

FUNCTION getShardCol (object_id IN NUMBER)
  RETURN t_shdcol_tab;

------------------------------------------------------------------------------
--
-- FUNCTION getGDSOnsConfig
--
-- Description:
--   obtains the GDS ONS config string based on region.
--   This is used by the mid-tier routing Java library to get ONS subscription
--   information when connected to the catalog local service.
--
-- Returns:
--   The GDS ONS configuration string, or NULL. See Notes.
--
-- Notes:
--   If the input region_name is NULL, and there is only 1 region defined,
--   that region will be used to find the GDS ONS config. If there are more
--   than 1 regions, this function will return NULL.
--   If there is no region in the catalog matching the input region, NULL is
--   also returned.
--
------------------------------------------------------------------------------
FUNCTION getGDSOnsConfig (region_name IN VARCHAR2 default NULL)
  RETURN VARCHAR2;



-------------------------------------------------------------------------------
-- PROCEDURE gsm_requests_update
--   Inform all the subscribers of an updated gsm_requests tables
-------------------------------------------------------------------------------
procedure gsm_requests_update;

-------------------------------------------------------------------------------
-- FUNCTION wait_for_ddl_noex
--   Wait for particular DDL statement to be applied on shards.
--
--
-- PARAMETERS
--   ddl_id    - for DDL to wait. If NULL picks up the latest
--               DDL from DDL_REQUESTS
--   p_timeout - approximate (!) amount of seconds to wait. Defaults to
--               3600 seconds (one hour). Usually the connection will be
--               broken well before that time.
--
-- RETURNS
--   * 0 when finished and DDL was executed succesefully or
--   * distinctive error codes for the cases when DDL
--     could not be executed everywhere, or timeout was reached.
-------------------------------------------------------------------------------

function wait_for_ddl_noex(
  in_ddl_id in number := null,
  p_timeout in number := 3600)
return number;

-------------------------------------------------------------------------------
-- PROCEDURE wait_for_ddl
--   Wait for particular DDL statement to be applied on shards.
--
-- See wait_for_ddl_noex function. The only difference is that the
--  procedure throws an exception on timeout or error
--
-------------------------------------------------------------------------------

procedure wait_for_ddl(
  in_ddl_id in number := null,
  p_timeout in number := 3600);

--*****************************************************************************
-- End of Package Public Procedures
--*****************************************************************************

  -------------------------
  --  ERRORS AND EXCEPTIONS
  --
  --  When adding errors remember to add a corresponding exception below.
err_generic_gsm      constant number := -44850;
err_bad_db_name      constant number := -44851;
err_region_max       constant number := -44852;
err_vncr_max         constant number := -44853;
err_exist_cld        constant number := -44854;
err_invalid_cld      constant number := -44855;
err_invalid_cldsvc   constant number := -44856;
err_nfound_cld       constant number := -44857;
err_remove_cld       constant number := -44858;
err_exist_GSM        constant number := -44859;
err_nfound_region    constant number := -44860;
err_remove_vncr      constant number := -44861;
err_buddy_region     constant number := -44862;
err_last_region      constant number := -44863;
err_remove_rgn_gsm   constant number := -44864;
err_remove_pool      constant number := -44865;
err_non_broker       constant number := -44866;
err_already_in_pool  constant number := -44867;
err_is_broker        constant number := -44868;
err_net_name         constant number := -44869;
err_svc_non_bc       constant number := -44870;
err_svc_non_pa       constant number := -44871;
err_db_same          constant number := -44872;
err_db_offer         constant number := -44873;
err_db_not_offer     constant number := -44874;
err_invalid_param    constant number := -44875;
err_svc_is_rng       constant number := -44876;
err_svc_is_dis       constant number := -44877;
err_svc_is_lag       constant number := -44878;
err_no_region        constant number := -44879;
err_no_cld           constant number := -44880;
err_nonempty_pool    constant number := -44881;
err_bad_dbp_name     constant number := -44882;
err_bad_region_name  constant number := -44883;
err_bad_svc_name     constant number := -44884;
err_bad_vncr_name    constant number := -44885;
err_bad_vncrgrp_name constant number := -44886;
err_bad_gsm_name     constant number := -44887;
err_bad_gsmu_name    constant number := -44888;
err_exist_region     constant number := -44889;
err_exist_dbpool     constant number := -44890;
err_nfound_gsm       constant number := -44891;
err_nfound_dbpool    constant number := -44892;
err_nfound_database  constant number := -44893;
err_nfound_service   constant number := -44894;
err_remove_rgn_db    constant number := -44895;
err_svc_in_pool      constant number := -44896;
err_svc_lag          constant number := -44897;
err_svc_failover     constant number := -44898;
err_exist_vncr       constant number := -44899;
err_string_size      constant number := -44900;
err_rem_db           constant number := -45500;
err_max_gsm          constant number := -45501;
err_no_priv          constant number := -45502;
err_db_incloud       constant number := -45503;
err_nopref_all       constant number := -45504;
err_max_service      constant number := -45505;
err_max_pools        constant number := -45506;
-- information messages for VerifyCatalog
err_no_buddy         constant number := -45507;
err_no_dbregion      constant number := -45508;
err_bad_dbstatus     constant number := -45509;
err_gsm_request      constant number := -45510;
err_no_preferred     constant number := -45511;
err_no_lcl_pref      constant number := -45512;
err_no_service       constant number := -45513;
err_no_dbreg         constant number := -45514;
err_no_gsm_reg       constant number := -45515;
err_pool_db          constant number := -45516;
err_pool_svc         constant number := -45517;
-- end information messages for VerifyCatalog
err_lag_lgsdby       constant number := -45518;
err_empty_dbpool     constant number := -45519;
err_loc_failover     constant number := -45520;
err_role_failover    constant number := -45521;
err_svc_relocate     constant number := -45522;
err_service_stopped  constant number := -45523;
err_need_dbp_name    constant number := -45524;
err_bad_retention    constant number := -45525;
err_bad_replay       constant number := -45526;
err_db_incompat      constant number := -45527;
err_svc_stopped      constant number := -45528;
err_db_spfile        constant number := -45529;
err_local_exists     constant number := -45530;
err_in_cloud         constant number := -45531;
err_is_cat           constant number := -45532;
err_service_change   constant number := -45533;
err_gsm_running      constant number := -45534;
err_unknown_catvers  constant number := -45535;
err_bad_gdscl_vers   constant number := -45536;
err_bad_gsmvers      constant number := -45537;
err_bad_dbvers       constant number := -45538;
err_add_to_pool      constant number := -45539;
err_srvctl_failed    constant number := -45540;
err_invalid_admin    constant number := -45541;
err_invalid_norac    constant number := -45542;
err_invalid_policy   constant number := -45543;
err_invalid_weight   constant number := -45544;
err_no_inst          constant number := -45545;
err_noproc           constant number := -45546;
err_srvctl_parms     constant number := -45547;
err_downg_db         constant number := -45548; -- Warning
err_no_curgsm        constant number := -45549;
err_nonexist_svc     constant number := -45550;
err_noexist_inst     constant number := -45551; -- Warning
err_no_del           constant number := -45552;
err_no_svc_inst      constant number := -45553;
err_no_svcs          constant number := -45554;
err_npa_db           constant number := -45555;
err_bad_disable      constant number := -45556;
err_empty_pool       constant number := -45557;
err_no_pools         constant number := -45558;
err_no_gsm_vers      constant number := -45559;
err_no_prefs         constant number := -45560;
err_no_region_name   constant number := -45561;
err_pdb_catalog      constant number := -45562;
err_pdb_pooldb       constant number := -45563;
err_shroot_svc       constant number := -45564;
err_sharded_pool     constant number := -45565;
err_is_not_shroot    constant number := -45566;
err_is_not_shard     constant number := -45567;
err_catlink          constant number := -45568;
err_cont_sleep       constant number := -45569;
err_not_empty        constant number := -45570;
err_conv_failed      constant number := -45572;
err_bad_dbrole       constant number := -45573;
err_bad_omode        constant number := -45574;
err_deploy_term      constant number := -45575;
err_no_sched         constant number := -45576;
err_no_dbid          constant number := -45577;
err_no_cred          constant number := -45578;
err_stby_conv        constant number := -45579;
err_param_value      constant number := -45580;
err_mix_pools        constant number := -45581;
err_chk_nonlocal     constant number := -45582;
err_no_sobj          constant number := -45584;
err_remove_rgn_sg    constant number := -45596;
err_dpumpimp_err     constant number := -45597;
err_bad_state        constant number := -45598;
err_inv_dbid         constant number := -45599;
err_chunk_down       constant number := -2519;
err_dataobj_limit    constant number := -2520;

-- start of createDatabase-related messages
err_bad_cred_name    constant number := -2600;
err_dup_cred_name    constant number := -2601;
err_cred_no_exist    constant number := -2602;
err_bad_file_name    constant number := -2603;
err_dup_file_name    constant number := -2604;
err_file_no_exist    constant number := -2605;
err_bad_dest_name    constant number := -2606;
err_no_dest_name     constant number := -2607;
err_dest_no_exist    constant number := -2608;
err_no_agent         constant number := -2609;
err_job_failed       constant number := -2610;
err_bad_dbg_name     constant number := -2611;
err_dbg_no_exist     constant number := -2612;
err_bad_shd_name     constant number := -2613;
err_shd_no_exist     constant number := -2614;
err_no_dbg_or_shd    constant number := -2615;
err_both_dbg_and_shd    constant number := -2616;
err_no_cred_or_uname    constant number := -2617;
err_both_cred_and_uname constant number := -2618;
err_both_file_and_cont  constant number := -2619;
err_domain_too_long     constant number := -2620;
err_file_in_use      constant number := -2621;
err_open_mode        constant number  := -2622;
err_config_create    constant number := -2623;
err_config_enable    constant number := -2624;
err_db_add           constant number := -2625;
err_db_enable        constant number := -2626;
err_nfound_shardgroup  constant number := -2627;
err_bad_ddgroup_name  constant number := -2628;
err_mod_dbgroup      constant number := -2629;
err_mod_prim         constant number := -2630;
err_bad_sg_name      constant number := -2631;
err_mod_dpl_ss       constant number := -2632;
err_bad_sh_name      constant number := -2633;
err_no_xdb           constant number := -2634;
err_bad_chunks       constant number := -2635;
err_inshard          constant number := -2636;
err_dif_dbg          constant number := -2637;
err_undep_dbg        constant number := -2638;
err_st_same          constant number := -2639;
err_has_prim         constant number := -2640;
err_db_not_dep       constant number := -2641;
err_no_brokers       constant number := -2642;
err_enable_fsfo      constant number := -2643;
err_invalid_rack     constant number := -2644;
err_prim_shard       constant number := -2645;
err_stby_gg          constant number := -2646;
err_bad_rack_name    constant number := -2647;
err_no_sys_pwd       constant number := -2648;
err_region_change    constant number := -2649;
err_agent_error      constant number := -2650;
err_pool_not_sharded constant number := -2651;
err_max_shd_pools    constant number := -2652;
err_dbg_exists       constant number := -2653;
err_no_shd_sg_in_pool constant number := -2654;
err_not_shd_cat      constant number := -2655;  
err_shd_exists       constant number := -2656;
err_too_few_chunks   constant number := -2657;
err_sg_exists        constant number := -2658;
err_rem_db_chunks    constant number := -2659;
err_removing_db      constant number := -2660;
err_adddb_params     constant number := -2661;
err_inv_chunknum     constant number := -2662;
err_agent_port       constant number := -2663;
err_port_used        constant number := -2664;
err_not_shspace      constant number := -2665;
err_not_tsset        constant number := -2666;
err_not_tfam         constant number := -2667;
err_obs_ns           constant number := -2668;


err_toomany_ss       constant number := -3700;
err_invalid_combo    constant number := -3701;
err_reserved_word    constant number := -3702;
err_no_shd_pool      constant number := -3703;
err_toomany_shd_pool constant number := -3704;
err_need_sg_name     constant number := -3705;
err_need_ss_name     constant number := -3706;
err_no_envvar        constant number := -3707;
err_shard_no_exist   constant number := -3708;
err_param_too_long   constant number := -3709;
err_dir_no_exist     constant number := -3710;
err_drset_diff_sg    constant number := -3711;
err_drset_same_sg    constant number := -3712;
err_removing_chunks  constant number := -3713;
err_rcv_chunks       constant number := -3714;
err_inv_user         constant number := -3715;
err_stmt_toolong     constant number := -3716;
err_no_shard         constant number := -3717;
err_no_prim          constant number := -3718;
err_cs_mismatch      constant number := -3719;
err_ncs_mismatch     constant number := -3720;
msg_move_cmd         constant number :=  3721;
msg_move_sch         constant number :=  3731;
msg_move_fsrc        constant number :=  3732;
msg_move_fl          constant number :=  3733;
msg_move_ftrg        constant number :=  3734;
msg_move_dbnr        constant number :=  3735;
err_no_db            constant number := -3736;
err_chunk_susp       constant number := -3737;
err_chunk_del        constant number := -3738;
err_not_catalog      constant number := -3739;
err_dep_exception    constant number := -3740;
err_no_template      constant number := -3741;
err_move_chck        constant number := -3742;
err_shd_pref         constant number := -3743;
err_ddl_state        constant number := -3744;
err_no_gsm_running   constant number := -3745;
err_gsmuser_priv     constant number := -3746;
err_root_table_exist constant number := -3747;
err_ein_deploy       constant number := -3748;
err_move_chnk        constant number := -3749;
err_no_flashback     constant number := -3750;
err_no_userdef       constant number := -3751;
err_vncr_in_use      constant number := -3752;
err_refuse_exec      constant number := -3753;
err_user_no_sg       constant number := -3754;
err_wrong_role       constant number := -3755;
err_split_pending    constant number := -3756;
err_system_ddl       constant number := -3757;
err_split_move_conflict constant number := -3758;
err_no_param         constant number := -3759; -- raised from gwm.c
err_rac_aff_tabnotf  constant number := -3761;
err_rac_aff_tabns    constant number := -3762;
err_rac_aff_tabfam   constant number := -3763;
err_rac_aff_tabex    constant number := -3764;
err_service_del      constant number := -3765;
err_service_deleted  constant number := -3766;
err_db_not_deployed  constant number := -3767;
err_db_is_up         constant number := -3768;
err_job_queue_proc   constant number := -3769;
err_wrong_shd        constant number := -3770;
err_bad_dg_param     constant number := -3771;
err_set_dg_prop      constant number := -3772;
err_split_userdef    constant number := -3773;
err_replace_db_ogg   constant number := -3774;
err_dbid_mismatch    constant number := -3775;
err_num_shards_exceed constant number := -3776;
err_move_in_prog     constant number := -3777;
err_exist_move       constant number := -3778;
err_bc_update        constant number := -3779;
err_stop_obs         constant number := -3780;
err_ddl_error        constant number := -3781;
err_ddl_wait_timeout constant number := -3782;
err_no_shd_to_deploy constant number := -3783;  -- Warning
err_disable_fsfo     constant number := -3784;
err_db_nopen         constant number := -3785;
err_repl_prim        constant number := -3786;
err_remove_db_bc     constant number := -3787;
err_no_prim_shardgroup constant number := -3788;
err_incon_st         constant number := -3789;
err_cdb_exists       constant number := -3790;
err_addpdb_no_cdb    constant number := -3791;
err_multiple_pdbs    constant number := -3792;
err_bad_cdb_name     constant number := -3793;
err_cdb_no_exist     constant number := -3794;
err_tss_not_online   constant number := -3795;
err_shd_meta         constant number := -3796;
err_uds_invdbver     constant number := -3797;
err_mv_dbver         constant number := -3798;
-------------------- Sub-Range 3800-3849 reserved for C sharding code

-------------------- Sub-Range 3900-3949 reserved for C sharding code

-------------------- Sub-Range 3950-3999 reserved for OGG/DB sharding
err_ogg_error        constant number := -3950;


generic_gsm       EXCEPTION;
PRAGMA EXCEPTION_INIT(generic_gsm,      -44850); 
bad_db_name      EXCEPTION;
PRAGMA EXCEPTION_INIT(bad_db_name,      -44851);
region_max        EXCEPTION;
PRAGMA EXCEPTION_INIT(region_max,       -44852);
vncr_max          EXCEPTION;
PRAGMA EXCEPTION_INIT(vncr_max,         -44853);
exist_cld         EXCEPTION;
PRAGMA EXCEPTION_INIT(exist_cld,        -44854);
invalid_cld       EXCEPTION;
PRAGMA EXCEPTION_INIT(invalid_cld,      -44855);
invalid_cldsvc    EXCEPTION;
PRAGMA EXCEPTION_INIT(invalid_cldsvc,   -44856);
nfound_cld        EXCEPTION;
PRAGMA EXCEPTION_INIT(nfound_cld,       -44857);
remove_cld        EXCEPTION;
PRAGMA EXCEPTION_INIT(remove_cld,       -44858);
exist_GSM      EXCEPTION;
PRAGMA EXCEPTION_INIT(exist_GSM   ,     -44859);
nfound_region     EXCEPTION;
PRAGMA EXCEPTION_INIT(nfound_region,    -44860);
exremove_vncr     EXCEPTION;
PRAGMA EXCEPTION_INIT(exremove_vncr,    -44861);
buddy_region      EXCEPTION;
PRAGMA EXCEPTION_INIT(buddy_region,     -44862);
last_region       EXCEPTION;
PRAGMA EXCEPTION_INIT(last_region,      -44863);
remove_rgn_gsm        EXCEPTION;
PRAGMA EXCEPTION_INIT(remove_rgn_gsm,   -44864);
remove_pool  EXCEPTION;
PRAGMA EXCEPTION_INIT(remove_pool,      -44865);
non_broker        EXCEPTION;
PRAGMA EXCEPTION_INIT(non_broker,       -44866);
already_in_pool   EXCEPTION;
PRAGMA EXCEPTION_INIT(already_in_pool,  -44867);
is_broker         EXCEPTION;
PRAGMA EXCEPTION_INIT(is_broker,        -44868);
net_name          EXCEPTION;
PRAGMA EXCEPTION_INIT(net_name,         -44869);
svc_non_bc        EXCEPTION;
PRAGMA EXCEPTION_INIT(svc_non_bc,       -44870);
svc_non_pa        EXCEPTION;
PRAGMA EXCEPTION_INIT(svc_non_pa,       -44871);
db_same           EXCEPTION;
PRAGMA EXCEPTION_INIT(db_same,          -44872);
db_offer          EXCEPTION;
PRAGMA EXCEPTION_INIT(db_offer,         -44873);
db_not_offer      EXCEPTION;
PRAGMA EXCEPTION_INIT(db_not_offer,     -44874);
invalid_param     EXCEPTION;
PRAGMA EXCEPTION_INIT(invalid_param,    -44875);
svc_is_rng        EXCEPTION;
PRAGMA EXCEPTION_INIT(svc_is_rng,       -44876);
svc_is_dis        EXCEPTION;
PRAGMA EXCEPTION_INIT(svc_is_dis,       -44877);
svc_is_lag        EXCEPTION;
PRAGMA EXCEPTION_INIT(svc_is_lag,       -44878);
no_region         EXCEPTION;
PRAGMA EXCEPTION_INIT(no_region,        -44879);
no_cld         EXCEPTION;
PRAGMA EXCEPTION_INIT(no_cld   ,        -44880);
nonempty_pool         EXCEPTION;
PRAGMA EXCEPTION_INIT(nonempty_pool ,   -44881);
bad_dbp_name         EXCEPTION;
PRAGMA EXCEPTION_INIT(bad_dbp_name  ,   -44882);
bad_region_name         EXCEPTION;
PRAGMA EXCEPTION_INIT(bad_region_name , -44883);
bad_svc_name         EXCEPTION;
PRAGMA EXCEPTION_INIT(bad_svc_name  ,   -44884);
bad_vncr_name         EXCEPTION;
PRAGMA EXCEPTION_INIT(bad_vncr_name  ,  -44885);
bad_vncrgrp_name         EXCEPTION;
PRAGMA EXCEPTION_INIT(bad_vncrgrp_name, -44886);
bad_gsm_name         EXCEPTION;
PRAGMA EXCEPTION_INIT(bad_gsm_name  ,   -44887);
bad_gsmu_name         EXCEPTION;
PRAGMA EXCEPTION_INIT(bad_gsmu_name  ,  -44888);
exist_region         EXCEPTION;
PRAGMA EXCEPTION_INIT(exist_region   ,  -44889);
exist_dbpool         EXCEPTION;
PRAGMA EXCEPTION_INIT(exist_dbpool   ,  -44890);
nfound_gsm         EXCEPTION;
PRAGMA EXCEPTION_INIT(nfound_gsm     ,  -44891);
nfound_dbpool         EXCEPTION;
PRAGMA EXCEPTION_INIT(nfound_dbpool  ,  -44892);
nfound_database         EXCEPTION;
PRAGMA EXCEPTION_INIT(nfound_database,  -44893);
nfound_service        EXCEPTION;
PRAGMA EXCEPTION_INIT(nfound_service ,  -44894);
remove_rgn_db            EXCEPTION;
PRAGMA EXCEPTION_INIT(remove_rgn_db ,   -44895);
svc_in_pool            EXCEPTION;
PRAGMA EXCEPTION_INIT(svc_in_pool   ,   -44896);
svc_lag            EXCEPTION;
PRAGMA EXCEPTION_INIT(svc_lag       ,   -44897);
svc_failover            EXCEPTION;
PRAGMA EXCEPTION_INIT(svc_failover  ,   -44898);
exist_vncr            EXCEPTION;
PRAGMA EXCEPTION_INIT(exist_vncr    ,   -44899);
string_size            EXCEPTION;
PRAGMA EXCEPTION_INIT(string_size    ,  -44900);
rem_db            EXCEPTION;
PRAGMA EXCEPTION_INIT(rem_db    ,       -45500);
max_gsm            EXCEPTION;
PRAGMA EXCEPTION_INIT(max_gsm    ,      -45501);
no_priv            EXCEPTION;
PRAGMA EXCEPTION_INIT(no_priv    ,      -45502);
db_incloud            EXCEPTION;
PRAGMA EXCEPTION_INIT(db_incloud    ,   -45503);
nopref_all            EXCEPTION;
PRAGMA EXCEPTION_INIT(nopref_all    ,   -45504);
max_service            EXCEPTION;
PRAGMA EXCEPTION_INIT(max_service    ,  -45505);
max_pools          EXCEPTION;
PRAGMA EXCEPTION_INIT(max_pools    ,  -45506);
empty_dbpool          EXCEPTION;
PRAGMA EXCEPTION_INIT(empty_dbpool    ,  -45519);
loc_failover          EXCEPTION;
PRAGMA EXCEPTION_INIT(loc_failover    ,  -45520);
role_failover          EXCEPTION;
PRAGMA EXCEPTION_INIT(role_failover    ,  -45521);
svc_relocate          EXCEPTION;
PRAGMA EXCEPTION_INIT(svc_relocate    ,  -45522);
svc_stopped          EXCEPTION;
PRAGMA EXCEPTION_INIT(svc_stopped    ,  -45523);
need_dbp_name         EXCEPTION;
PRAGMA EXCEPTION_INIT(need_dbp_name   ,  -45524);
bad_retention          EXCEPTION;
PRAGMA EXCEPTION_INIT(bad_retention    ,  -45525);
bad_replay        EXCEPTION;
PRAGMA EXCEPTION_INIT(bad_replay    ,  -45526);
db_incompat        EXCEPTION;
PRAGMA EXCEPTION_INIT(db_incompat    ,  -45527);
svc_stopped        EXCEPTION;
PRAGMA EXCEPTION_INIT(svc_stopped    ,  -45528);
db_spfile        EXCEPTION;
PRAGMA EXCEPTION_INIT(db_spfile    ,  -45529);
local_exists        EXCEPTION;
PRAGMA EXCEPTION_INIT(local_exists    ,  -45530);
in_cloud        EXCEPTION;
PRAGMA EXCEPTION_INIT(in_cloud    ,  -45531);
is_cat        EXCEPTION;
PRAGMA EXCEPTION_INIT(is_cat    ,  -45532);
service_change        EXCEPTION;
PRAGMA EXCEPTION_INIT(service_change ,  -45533);
gsm_running        EXCEPTION;
PRAGMA EXCEPTION_INIT(gsm_running ,  -45534);
unknown_catvers        EXCEPTION;
PRAGMA EXCEPTION_INIT(unknown_catvers ,  -45535);
bad_gdsctl_vers        EXCEPTION;
PRAGMA EXCEPTION_INIT(bad_gdsctl_vers ,  -45536);
bad_gsmvers        EXCEPTION;
PRAGMA EXCEPTION_INIT(bad_gsmvers ,  -45537);
bad_dbvers        EXCEPTION;
PRAGMA EXCEPTION_INIT(bad_dbvers ,  -45538);
add_to_pool       EXCEPTION; 
PRAGMA EXCEPTION_INIT(add_to_pool,       -45539);
srvctl_failed       EXCEPTION; 
PRAGMA EXCEPTION_INIT(srvctl_failed,       -45540);
invalid_admin       EXCEPTION; 
PRAGMA EXCEPTION_INIT(invalid_admin,       -45541);
invalid_norac       EXCEPTION; 
PRAGMA EXCEPTION_INIT(invalid_norac,       -45542);
invalid_policy      EXCEPTION; 
PRAGMA EXCEPTION_INIT(invalid_policy,       -45543);
invalid_weight      EXCEPTION; 
PRAGMA EXCEPTION_INIT(invalid_weight,       -45544);
no_inst      EXCEPTION; 
PRAGMA EXCEPTION_INIT(no_inst,       -45545);
noproc      EXCEPTION; 
PRAGMA EXCEPTION_INIT(noproc,       -45546);
srvctl_parms      EXCEPTION; 
PRAGMA EXCEPTION_INIT(srvctl_parms,       -45547);
downg_db      EXCEPTION; 
PRAGMA EXCEPTION_INIT(downg_db,       -45548);
no_curgsm      EXCEPTION; 
PRAGMA EXCEPTION_INIT(no_curgsm,       -45549);
nonexist_svc      EXCEPTION; 
PRAGMA EXCEPTION_INIT(nonexist_svc,       -45550);
noexist_inst      EXCEPTION; 
PRAGMA EXCEPTION_INIT(noexist_inst,       -45551);
no_del      EXCEPTION; 
PRAGMA EXCEPTION_INIT(no_del,       -45552);
no_svc_inst      EXCEPTION; 
PRAGMA EXCEPTION_INIT(no_svc_inst,       -45553);
no_svcs     EXCEPTION; 
PRAGMA EXCEPTION_INIT(no_svcs,       -45554);
npa_db      EXCEPTION; 
PRAGMA EXCEPTION_INIT(npa_db,       -45555);
bad_disable      EXCEPTION; 
PRAGMA EXCEPTION_INIT(bad_disable,       -45556);
empty_pool      EXCEPTION; 
PRAGMA EXCEPTION_INIT(empty_pool,       -45557);
no_pools      EXCEPTION; 
PRAGMA EXCEPTION_INIT(no_pools,       -45558);
no_gsm_vers      EXCEPTION; 
PRAGMA EXCEPTION_INIT(no_gsm_vers,       -45559);
no_prefs      EXCEPTION; 
PRAGMA EXCEPTION_INIT(no_prefs,       -45560);
no_region_name      EXCEPTION; 
PRAGMA EXCEPTION_INIT(no_region_name,       -45561);
pdb_catalog        EXCEPTION; 
PRAGMA EXCEPTION_INIT(pdb_catalog,       -45562);
pdb_pooldb        EXCEPTION; 
PRAGMA EXCEPTION_INIT(pdb_pooldb,       -45563);
shroot_svc      EXCEPTION; 
PRAGMA EXCEPTION_INIT(shroot_svc ,       -45564);
sharded_pool      EXCEPTION; 
PRAGMA EXCEPTION_INIT(sharded_pool ,       -45565);
is_not_shroot      EXCEPTION; 
PRAGMA EXCEPTION_INIT(is_not_shroot ,       -45566);
is_not_shard      EXCEPTION; 
PRAGMA EXCEPTION_INIT(is_not_shard ,       -45567);
catlink     EXCEPTION; 
PRAGMA EXCEPTION_INIT(catlink ,       -45568);
cont_sleep            EXCEPTION;
PRAGMA EXCEPTION_INIT(cont_sleep    ,      -45569);
not_empty            EXCEPTION;
PRAGMA EXCEPTION_INIT(not_empty    ,      -45570);
conv_failed            EXCEPTION;
PRAGMA EXCEPTION_INIT(conv_failed    ,      -45572);
bad_dbrole            EXCEPTION;
PRAGMA EXCEPTION_INIT(bad_dbrole    ,      -45573);
bad_omode            EXCEPTION;
PRAGMA EXCEPTION_INIT(bad_omode    ,      -45574);
deploy_term            EXCEPTION;
PRAGMA EXCEPTION_INIT(deploy_term    ,      -45575);
no_sched            EXCEPTION;
PRAGMA EXCEPTION_INIT(no_sched    ,      -45576);
no_dbid              EXCEPTION;
PRAGMA EXCEPTION_INIT(no_dbid    ,      -45577);
no_cred            EXCEPTION;
PRAGMA EXCEPTION_INIT(no_cred    ,      -45578);
param_value           EXCEPTION;
PRAGMA EXCEPTION_INIT(param_value    , -45580);
mix_pools            EXCEPTION;
PRAGMA EXCEPTION_INIT(mix_pools    , -45581);
chk_nonlocal            EXCEPTION;
PRAGMA EXCEPTION_INIT(chk_nonlocal    , -45582);
no_sobj            EXCEPTION;
PRAGMA EXCEPTION_INIT(no_sobj    ,      -45584);
remove_rgn_sg            EXCEPTION;
PRAGMA EXCEPTION_INIT(remove_rgn_sg    ,      -45596);
dpumpimp_err            EXCEPTION;
PRAGMA EXCEPTION_INIT(dpumpimp_err    ,      -45597);
bad_state            EXCEPTION;
PRAGMA EXCEPTION_INIT(bad_state    ,      -45598);
inv_dbid            EXCEPTION;
PRAGMA EXCEPTION_INIT(inv_dbid    ,      -45599);
chunk_down            EXCEPTION;
PRAGMA EXCEPTION_INIT(chunk_down ,      -2519);
dataobj_limit            EXCEPTION;
PRAGMA EXCEPTION_INIT(dataobj_limit ,      -2520);
bad_cred_name       EXCEPTION;
PRAGMA EXCEPTION_INIT(bad_cred_name, -2600);
dup_cred_name       EXCEPTION;
PRAGMA EXCEPTION_INIT(dup_cred_name, -2601);
cred_no_exist        EXCEPTION;
PRAGMA EXCEPTION_INIT(cred_no_exist, -2602);
bad_file_name        EXCEPTION;
PRAGMA EXCEPTION_INIT(bad_file_name, -2603);
dup_file_name        EXCEPTION;
PRAGMA EXCEPTION_INIT(dup_file_name, -2604);
file_no_exist       EXCEPTION;
PRAGMA EXCEPTION_INIT(file_no_exist, -2605);
bad_dest_name       EXCEPTION;
PRAGMA EXCEPTION_INIT(bad_dest_name, -2606);
no_dest_name        EXCEPTION;
PRAGMA EXCEPTION_INIT(no_dest_name, -2607);
dest_no_exist       EXCEPTION;
PRAGMA EXCEPTION_INIT(dest_no_exist, -2608);
no_agent            EXCEPTION;
PRAGMA EXCEPTION_INIT(no_agent, -2609);
job_failed          EXCEPTION;
PRAGMA EXCEPTION_INIT(job_failed, -2610);
bad_dbg_name        EXCEPTION;
PRAGMA EXCEPTION_INIT(bad_dbg_name, -2611);
dbg_no_exist       EXCEPTION;
PRAGMA EXCEPTION_INIT(dbg_no_exist, -2612);
bad_shd_name        EXCEPTION;
PRAGMA EXCEPTION_INIT(bad_shd_name, -2613);
shd_no_exist        EXCEPTION;
PRAGMA EXCEPTION_INIT(shd_no_exist, -2614);
no_dbg_or_shd       EXCEPTION;
PRAGMA EXCEPTION_INIT(no_dbg_or_shd, -2615);
both_dbg_and_shd       EXCEPTION;
PRAGMA EXCEPTION_INIT(both_dbg_and_shd, -2616);
no_cred_or_uname    EXCEPTION;
PRAGMA EXCEPTION_INIT(no_cred_or_uname, -2617);
both_cred_and_uname      EXCEPTION;
PRAGMA EXCEPTION_INIT(both_cred_and_uname, -2618);
both_file_and_cont     EXCEPTION;
PRAGMA EXCEPTION_INIT(both_file_and_cont, -2619);
domain_too_long     EXCEPTION;
PRAGMA EXCEPTION_INIT(domain_too_long, -2620);
file_in_use       EXCEPTION;
PRAGMA EXCEPTION_INIT(file_in_use, -2621);
open_mode       EXCEPTION;
PRAGMA EXCEPTION_INIT(open_mode, -2622);
config_create       EXCEPTION;
PRAGMA EXCEPTION_INIT(config_create, -2623);
config_enable       EXCEPTION;
PRAGMA EXCEPTION_INIT(config_enable, -2624);
db_add       EXCEPTION;
PRAGMA EXCEPTION_INIT(db_add, -2625);
db_enable       EXCEPTION;
PRAGMA EXCEPTION_INIT(db_enable, -2626);
nfound_shardgroup       EXCEPTION;
PRAGMA EXCEPTION_INIT(nfound_shardgroup, -2627);
bad_dbgroup_name       EXCEPTION;
PRAGMA EXCEPTION_INIT(bad_dbgroup_name, -2628);
mod_dbgroup       EXCEPTION;
PRAGMA EXCEPTION_INIT(mod_dbgroup, -2629);
mod_prim       EXCEPTION;
PRAGMA EXCEPTION_INIT(mod_prim, -2630);
bad_sg_name       EXCEPTION;
PRAGMA EXCEPTION_INIT(bad_sg_name, -2631);
mod_dpl_ss       EXCEPTION;
PRAGMA EXCEPTION_INIT(mod_dpl_ss, -2632);
bad_sh_name       EXCEPTION;
PRAGMA EXCEPTION_INIT(bad_sh_name, -2633);
no_xdb       EXCEPTION;
PRAGMA EXCEPTION_INIT(no_xdb, -2634);
bad_chunks       EXCEPTION;
PRAGMA EXCEPTION_INIT(bad_chunks, -2635);
inshard       EXCEPTION;
PRAGMA EXCEPTION_INIT(inshard, -2636);
dif_dbg       EXCEPTION;
PRAGMA EXCEPTION_INIT(dif_dbg, -2637);
undep_dbg       EXCEPTION;
PRAGMA EXCEPTION_INIT(undep_dbg, -2638);
st_same       EXCEPTION;
PRAGMA EXCEPTION_INIT(st_same, -2639);
has_prim       EXCEPTION;
PRAGMA EXCEPTION_INIT(has_prim, -2640);
db_not_dep       EXCEPTION;
PRAGMA EXCEPTION_INIT(db_not_dep, -2641);
no_brokers       EXCEPTION;
PRAGMA EXCEPTION_INIT(no_brokers, -2642);
enable_fsfo       EXCEPTION;
PRAGMA EXCEPTION_INIT(enable_fsfo, -2643);
invalid_rack       EXCEPTION;
PRAGMA EXCEPTION_INIT(invalid_rack, -2644);
primary_shard       EXCEPTION;
PRAGMA EXCEPTION_INIT(primary_shard, -2645);
standby_gg      EXCEPTION;
PRAGMA EXCEPTION_INIT(standby_gg, -2646);
bad_rack_name      EXCEPTION;
PRAGMA EXCEPTION_INIT(bad_rack_name, -2647);
no_sys_pwd     EXCEPTION;
PRAGMA EXCEPTION_INIT(no_sys_pwd, -2648);
region_change     EXCEPTION;
PRAGMA EXCEPTION_INIT(region_change, -2649);
agent_error     EXCEPTION;
PRAGMA EXCEPTION_INIT(agent_error, -2650);
pool_not_sharded     EXCEPTION;
PRAGMA EXCEPTION_INIT(pool_not_sharded, -2651);
max_shd_pools     EXCEPTION;
PRAGMA EXCEPTION_INIT(max_shd_pools, -2652);
dbg_exists     EXCEPTION;
PRAGMA EXCEPTION_INIT(dbg_exists, -2653);
no_shd_sg_in_pool    EXCEPTION;
PRAGMA EXCEPTION_INIT(no_shd_sg_in_pool, -2654);
not_shd_cat    EXCEPTION;
PRAGMA EXCEPTION_INIT(not_shd_cat, -2655);
shd_exists    EXCEPTION;
PRAGMA EXCEPTION_INIT(shd_exists, -2656);
too_few_chunks   EXCEPTION;
PRAGMA EXCEPTION_INIT(too_few_chunks, -2657);
sg_exists     EXCEPTION;
PRAGMA EXCEPTION_INIT(sg_exists, -2658);
rem_db_chunks     EXCEPTION;
PRAGMA EXCEPTION_INIT(rem_db_chunks, -2659);
removing_db    EXCEPTION;
PRAGMA EXCEPTION_INIT(removing_db, -2660);
adddb_params    EXCEPTION;
PRAGMA EXCEPTION_INIT(adddb_params, -2661);
inv_chunknum    EXCEPTION;
PRAGMA EXCEPTION_INIT(inv_chunknum, -2662);
agent_port   EXCEPTION;
PRAGMA EXCEPTION_INIT(agent_port, -2663);
port_used   EXCEPTION;
PRAGMA EXCEPTION_INIT(port_used, -2664);
not_shspace  EXCEPTION;
PRAGMA EXCEPTION_INIT(not_shspace, -2665);
not_tsset       EXCEPTION;
PRAGMA EXCEPTION_INIT(not_tsset, -2666);
not_tfam        EXCEPTION;
PRAGMA EXCEPTION_INIT(not_tfam, -2667);
obs_ns        EXCEPTION;
PRAGMA EXCEPTION_INIT(obs_ns, -2668);

toomany_ss   EXCEPTION;
PRAGMA EXCEPTION_INIT(toomany_ss, -3700);
invalid_combo   EXCEPTION;
PRAGMA EXCEPTION_INIT(invalid_combo, -3701);
reserved_word   EXCEPTION;
PRAGMA EXCEPTION_INIT(reserved_word, -3702);
no_shd_pool    EXCEPTION;
PRAGMA EXCEPTION_INIT(no_shd_pool, -3703);
toomany_shd_pool    EXCEPTION;
PRAGMA EXCEPTION_INIT(toomany_shd_pool, -3704);
need_sg_name  EXCEPTION;
PRAGMA EXCEPTION_INIT(need_sg_name, -3705);
need_ss_name   EXCEPTION;
PRAGMA EXCEPTION_INIT(need_ss_name, -3706);
no_envvar   EXCEPTION;
PRAGMA EXCEPTION_INIT(no_envvar, -3707);
shard_no_exist   EXCEPTION;
PRAGMA EXCEPTION_INIT(shard_no_exist, -3708);
param_too_long   EXCEPTION;
PRAGMA EXCEPTION_INIT(param_too_long, -3709);
dir_no_exist   EXCEPTION;
PRAGMA EXCEPTION_INIT(dir_no_exist, -3710);
drset_diff_sg  EXCEPTION;
PRAGMA EXCEPTION_INIT(drset_diff_sg, -3711);
drset_same_sg  EXCEPTION;
PRAGMA EXCEPTION_INIT(drset_same_sg, -3712);
removing_chunks  EXCEPTION;
PRAGMA EXCEPTION_INIT(removing_chunks, -3713);
rcv_chunks  EXCEPTION;
PRAGMA EXCEPTION_INIT(rcv_chunks, -3714);
inv_user  EXCEPTION;
PRAGMA EXCEPTION_INIT(inv_user, -3715);
stmt_toolong  EXCEPTION;
PRAGMA EXCEPTION_INIT(stmt_toolong, -3716);
no_shard  EXCEPTION;
PRAGMA EXCEPTION_INIT(no_shard, -3717);
no_prim  EXCEPTION;
PRAGMA EXCEPTION_INIT(no_prim, -3718);
cs_mismatch EXCEPTION;
PRAGMA EXCEPTION_INIT(cs_mismatch, -3719);
ncs_mismatch  EXCEPTION;
PRAGMA EXCEPTION_INIT(ncs_mismatch, -3720);

no_db  EXCEPTION;
PRAGMA EXCEPTION_INIT(no_db, -3736);
chunk_susp  EXCEPTION;
PRAGMA EXCEPTION_INIT(chunk_susp, -3737);
chunk_del  EXCEPTION;
PRAGMA EXCEPTION_INIT(chunk_del, -3738);
not_catalog  EXCEPTION;
PRAGMA EXCEPTION_INIT(not_catalog, -3739);
dep_exception  EXCEPTION;
PRAGMA EXCEPTION_INIT(dep_exception, -3740);
no_template  EXCEPTION;
PRAGMA EXCEPTION_INIT(no_template, -3741);
move_chck  EXCEPTION;
PRAGMA EXCEPTION_INIT(move_chck, -3742);
shd_pref  EXCEPTION;
PRAGMA EXCEPTION_INIT(shd_pref, -3743);
e_ddl_state EXCEPTION;
PRAGMA EXCEPTION_INIT(e_ddl_state, -3744);
no_gsm_running  EXCEPTION;
PRAGMA EXCEPTION_INIT(no_gsm_running, -3745);
gsmuser_priv  EXCEPTION;
PRAGMA EXCEPTION_INIT(gsmuser_priv, -3746);
root_table_exist  EXCEPTION;
PRAGMA EXCEPTION_INIT(root_table_exist, -3747);
ein_deploy  EXCEPTION;
PRAGMA EXCEPTION_INIT(ein_deploy, -3748);
move_chnk EXCEPTION;
PRAGMA EXCEPTION_INIT(move_chnk, -3749);
no_flashback  EXCEPTION;
PRAGMA EXCEPTION_INIT(no_flashback, -3750);
no_userdef  EXCEPTION;
PRAGMA EXCEPTION_INIT(no_userdef, -3751);
vncr_in_use  EXCEPTION;
PRAGMA EXCEPTION_INIT(vncr_in_use, -3752);
refuse_exec  EXCEPTION;
PRAGMA EXCEPTION_INIT(refuse_exec, -3753);
user_no_sg  EXCEPTION;
PRAGMA EXCEPTION_INIT(user_no_sg, -3754);
wrong_role EXCEPTION;
PRAGMA EXCEPTION_INIT(wrong_role, -3755);
split_pending  EXCEPTION;
PRAGMA EXCEPTION_INIT(split_pending, -3756);
system_ddl EXCEPTION;
PRAGMA EXCEPTION_INIT(system_ddl, -3757);
split_move_conflict EXCEPTION;
PRAGMA EXCEPTION_INIT(split_move_conflict, -3758);
no_param EXCEPTION;
PRAGMA EXCEPTION_INIT(no_param, -3759);
rac_aff_tabnotf      EXCEPTION;
PRAGMA EXCEPTION_INIT(rac_aff_tabnotf, -3761);
rac_aff_tabns      EXCEPTION;
PRAGMA EXCEPTION_INIT(rac_aff_tabns, -3762);
rac_aff_tabfam      EXCEPTION;
PRAGMA EXCEPTION_INIT(rac_aff_tabfam, -3763);
rac_aff_tabex       EXCEPTION;
PRAGMA EXCEPTION_INIT(rac_aff_tabex, -3764);
service_del EXCEPTION;
PRAGMA EXCEPTION_INIT(service_del, -3765);
service_deleted EXCEPTION;
PRAGMA EXCEPTION_INIT(service_deleted, -3766);
db_not_deployed EXCEPTION;
PRAGMA EXCEPTION_INIT(db_not_deployed, -3767);
db_is_up EXCEPTION;
PRAGMA EXCEPTION_INIT(db_is_up, -3768);
job_queue_proc EXCEPTION;
PRAGMA EXCEPTION_INIT(job_queue_proc, -3769);
wrong_shd EXCEPTION;
PRAGMA EXCEPTION_INIT(wrong_shd, -3770);
bad_dg_param EXCEPTION;
PRAGMA EXCEPTION_INIT(bad_dg_param, -3771);
set_dg_prop EXCEPTION;
PRAGMA EXCEPTION_INIT(set_dg_prop, -3772);
split_userdef_error  EXCEPTION;
PRAGMA EXCEPTION_INIT(split_userdef_error, -3773);
replace_db_ogg EXCEPTION;
PRAGMA EXCEPTION_INIT(replace_db_ogg, -3774);
dbid_mismatch EXCEPTION;
PRAGMA EXCEPTION_INIT(dbid_mismatch, -3775);
num_shards_exceed EXCEPTION;
PRAGMA EXCEPTION_INIT(num_shards_exceed, -3776);
move_in_prog EXCEPTION;
PRAGMA EXCEPTION_INIT(move_in_prog, -3777);
exist_move EXCEPTION;
PRAGMA EXCEPTION_INIT(exist_move, -3778);
bc_update EXCEPTION;
PRAGMA EXCEPTION_INIT(bc_update, -3779);
stop_obs EXCEPTION;
PRAGMA EXCEPTION_INIT(stop_obs, -3780);
ddl_wait_error EXCEPTION;
PRAGMA EXCEPTION_INIT(ddl_wait_error, -3781);
ddl_wait_timeout EXCEPTION;
PRAGMA EXCEPTION_INIT(ddl_wait_timeout, -3782);
no_shd_to_deploy EXCEPTION;
PRAGMA EXCEPTION_INIT(no_shd_to_deploy, -3783);
disable_fsfo EXCEPTION;
PRAGMA EXCEPTION_INIT(disable_fsfo, -3784);
db_nopen EXCEPTION;
PRAGMA EXCEPTION_INIT(db_nopen, -3785);
repl_prim EXCEPTION;
PRAGMA EXCEPTION_INIT(repl_prim, -3786);
remove_db_bc EXCEPTION;
PRAGMA EXCEPTION_INIT(remove_db_bc, -3787);
no_prim_shardgroup EXCEPTION;
PRAGMA EXCEPTION_INIT(no_prim_shardgroup, -3788);
incon_st     EXCEPTION;
PRAGMA EXCEPTION_INIT(incon_st, -3789);
cdb_exists     EXCEPTION;
PRAGMA EXCEPTION_INIT(cdb_exists, -3790);
addpdb_no_cdb EXCEPTION;
PRAGMA EXCEPTION_INIT(addpdb_no_cdb, -3791);
multiple_pdbs EXCEPTION;
PRAGMA EXCEPTION_INIT(multiple_pdbs, -3792);
bad_cdb_name EXCEPTION;
PRAGMA EXCEPTION_INIT(bad_cdb_name, -3793);
cdb_no_exist EXCEPTION;
PRAGMA EXCEPTION_INIT(cdb_no_exist, -3794);
tss_not_online EXCEPTION;
PRAGMA EXCEPTION_INIT(tss_not_online, -3795);
shd_meta EXCEPTION;
PRAGMA EXCEPTION_INIT(shd_meta, -3796);
uds_invdbver EXCEPTION;
PRAGMA EXCEPTION_INIT(uds_invdbver, -3797);
mv_dbver EXCEPTION;
PRAGMA EXCEPTION_INIT(mv_dbver, -3798);

ogg_error  EXCEPTION;
PRAGMA EXCEPTION_INIT(ogg_error, -3950);

END dbms_gsm_utility;

/

show errors

--*****************************************************************************
-- Database package for functions that can be executed without GSM privileges
--*****************************************************************************

CREATE OR REPLACE PACKAGE dbms_gsm_nopriv 
AUTHID CURRENT_USER AS

--*****************************************************************************
-- NOTE: This package is executeable by public. We *MUST* ensure that the
-- calling user has the correct catalog privileges at the start of every 
-- procedure before executing any other code with the package.
--*****************************************************************************


--*****************************************************************************
-- Package Public Types
--*****************************************************************************

-- Update modes for catalog lock
noUpdate constant  number := 0;  -- catalog is not updated
updNoGSM constant  number := 1;  -- catalog Update does not require running GSM
updGSM   constant  number := 2;  -- catalog update requires running GSM

--*****************************************************************************
-- Package Public Constants
--*****************************************************************************

--*****************************************************************************
-- Package Public Exceptions
--*****************************************************************************


--*****************************************************************************
-- Package Public Procedures
--*****************************************************************************
-------------------------------------------------------------------------------
--
-- PROCEDURE     getCatalogLock
--
-- Description:
--       Gets the catalog lock prior to making a change to the cloud catalog.      
--
-- Parameters:
--       currentChangeSeq -    The current value of cloud.change_seq#
--                             This is the sequence # of the last committed 
--                             change.
--       privs                 Privilege required for this lock operation
--       gdsctl_version        Version of gdsctl (GDSCTL interface only)
--       gsm_version           Version of GSM (GSM interface only)
--       gsm_name              Name of GSM (GSM interface only)
--       catalog_version       Version of the catalog
--
-- Notes:
--       WARNING: This function is executabble by "public" and runs with
--       gsmadmin_internal privileges. It *MUST* check that the real calling
--       session user has the privilege to peform catalog operations first
--       (before anything else is done). The "privs" and "pool_name"
--       parameters provide the require privileges for the current "lock"
--       operation. The sequence of events is that the user "locks" the catalog,
--       performs the desired operation, and then unlocks the catalog
--    
------------------------------------------------------------------------------- 

GSMAdmin                    constant    number := 1;
GSMPoolAdmin                constant    number := 2;

-- overloaded old version for backwards compatibility
PROCEDURE getCatalogLock( currentChangeSeq OUT number,
                          privs IN number default GSMAdmin);
-- version called by GDSCTL
PROCEDURE getCatalogLock( currentChangeSeq OUT    number,
                          privs            IN     number default GSMAdmin,
                          gdsctl_version   IN     varchar2 default NULL,
                          catalog_version  OUT    number,
                          update_mode      IN     number
                               default updNoGSM);
-- version called by GSM servers
PROCEDURE getCatalogLock( currentChangeSeq OUT    number,
                          privs            IN     number default GSMAdmin,
                          gsm_version      IN     varchar2 default NULL,
                          gsm_name         IN     varchar2 default NULL,
                          catalog_version  OUT    number,
                          update_mode      IN     number
                               default noUpdate);

-------------------------------------------------------------------------------
--
-- PROCEDURE     releaseCatalogLock
--
-- Description:
--      Releases the catalog lock and commits or rolls back the changes
--      made under the lock.       
--
-- Parameters:
--      action:  "releaseLockCommit" -> release lock and commit all
--                             changes
--               "releaseLockRollback" -> release lock and rollback
--                             all changes
--      changeSeq: If "action" = "releaseLockCommit" this is the change
--                 sequence number of the the last change made under this lock.
--                 If "action" = "releaseLockRollback" then will be set to 0.
--            
--
-- Notes:
--    
------------------------------------------------------------------------------- 

releaseLockCommit           constant  number := 1;
releaseLockRollback         constant  number := 2;


PROCEDURE releaseCatalogLock( action    IN number default releaseLockCommit,
                              changeSeq OUT number );


END dbms_gsm_nopriv;

/

show errors

ALTER SESSION SET CURRENT_SCHEMA=SYS
/

@?/rdbms/admin/sqlsessend.sql
