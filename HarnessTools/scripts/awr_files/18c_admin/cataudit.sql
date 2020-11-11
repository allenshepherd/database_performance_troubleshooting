rem $Header: rdbms/admin/cataudit.sql /main/151 2017/06/15 22:21:08 rthatte Exp $ audit.sql 
rem 
Rem Copyright (c) 1990, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem NAME
Rem    cataudit.sql
Rem FUNCTION
Rem    Creates data dictionary views for auditing. 
Rem NOTES
Rem    Must be run while connected to SYS or INTERNAL.
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/cataudit.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/cataudit.sql
Rem SQL_PHASE: CATAUDIT
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: ORA-00955
Rem SQL_CALLING_FILE: rdbms/admin/cdsec.sql
Rem END SQL_FILE_METADATA
Rem
Rem MODIFIED
Rem     rthatte    06/12/17  - Bug 25749803: Do not list system actions which
Rem                            cannot be audited in 'auditable_system_actions'
Rem     gaurameh   05/12/17  - Bug 26050809: audit PURGE [DBA_]RECYCLEBIN action
Rem     amunnoli   04/11/17  - Bug 25871688: Replace substr by substrb
Rem     amunnoli   07/20/16  - Bug 23483500:display correct ENTITY_TYPE
Rem     amunnoli   06/02/16  - Bug 23515378: grant read on audit views
Rem     akruglik   01/29/16  - (22132084) handle Ext Data Link bit
Rem     akruglik   01/25/16  - (22132084): replace COMMON_DATA with
Rem                            SHARING=EXTENDED DATA
Rem     rpang      12/08/15  - Bug 22325328: audit debug object privilege
Rem     mstasiew   12/07/15  - Bug 22309211: olap updates objtyp 92->95
Rem     rpang      11/04/15  - Bug 22275536: Add debug connect action
Rem     smesropi   10/20/15  - Bug 21171628: Rename HCS tables
Rem     mstasiew   10/19/15  - Bug 21984764: hcs object rename
Rem     hmohanku   09/23/15  - bug 21787568: add directory actions to
Rem                            AUDIT_ACTIONS & UNIFIED_MISC_AUDITED_ACTIONS
Rem     amunnoli   09/03/15  - Bug 13716158:Add CURRENT_USER to dba_audit_trail
Rem     ssonawan   08/20/15  - Bug 21427375: allow PDBs to query common unified
Rem                            audit configuration
Rem     juilin     22/07/15  - Bug 21458522 rename syscontext IS_FEDERATION_ROOT
Rem     rpang      08/18/15  - Bug 17169333: add TRANSLATE SQL action
Rem     youyang    07/23/15  - bug21314254:add all Standard actions for DV 
Rem                            component in all_unified_audit_actions 
Rem                            mapping table
Rem     akruglik   06/30/15  - Proj 47234: Get rid of scope column
Rem     amunnoli   06/23/15  - Proj 46892:Move creation of Unified audit trail
Rem                            to catuat.sql
Rem     ghicks     06/19/15  - bugs 20481832, 20481863: HIER and HIER CUBE
Rem                            in audit_actions
Rem     sanbhara   06/05/15  - Bug 21173992 - adding DV cnofiguration audit
Rem                            action to ALL_AUDITED_SYSTEM_ACTIONS view.
Rem     bnnguyen   04/29/15  - bug 20134461: Change KSACL_VMID to
Rem                            KSACL_SOURCE_LOCATION 
Rem     ssonawan   02/05/15  - bug 20383779: Add BECOME USER in audit_actions
Rem                            and unified_misc_audited_actions
Rem     nkgopal    01/20/15  - Bug 20370996: Dropping AUDIT_ACTIONS invalidates
Rem                            other objects
Rem     nkgopal    01/19/15  - Proj 55106: Federation Support
Rem     beiyu      12/16/14  - Proj 47091: support auditing for new HCS objects
Rem     bnnguyen   12/09/14  - Bug 19697038: Add KSACL_* columns to  
Rem                            UNIFIED_AUDIT_TRAIL view.
Rem     nkgopal    12/04/14  - Bug 20088905: Add 58 to AUDIT_ACTIONS
Rem     skayoor    11/30/14  - Proj 58196: Change Select priv to Read Priv
Rem     nkgopal    10/13/14  - Bug 19352543: Remove unnecessary setting of
Rem                            _ORACLE_SCRIPT
Rem     prshanth   08/20/14  - Proj 47234: Lockdown profile - adding DDLs
Rem     ratakuma   08/14/14  - Bug 18790613: Few Audit Actions doesnot have
Rem                            corresponding AUDIT ACTION Names
Rem     nkgopal    06/24/14  - Proj 35931: Add RLS_INFO to UNIFIED_AUDIT_TRAIL
Rem     nkgopal    04/15/14  - Proj# 35931: Add rls_info to audit trail views
Rem     amunnoli   04/08/14  - Proj 46893: Add ENTITY_NAME, ENTITY_TYPE,
Rem                            ENABLED_OPTION columns
Rem                            to AUDIT_UNIFIED_ENABLED_POLICIES view 
Rem     amozes     02/26/14  - project 47098: Add OCTDMO, change AMO/CMO
Rem     risgupta   01/29/14  - Bug 18157726: Add all_unified_audit_actions table
Rem     surman     12/29/13  - 13922626: Update SQL metadata
Rem     ssonawan   12/23/13  - Bug 17985613: for DV audit options check
Rem                            aud_object_opt$.type in AUDIT_UNIFIED_POLICIES 
Rem     vpriyans   10/21/13  - Bug 16386814: Add MERGE action for FGA in
Rem                            ALL_AUDITED_SYSTEM_ACTIONS view
Rem     ssonawan   07/10/13  - Bug 16354284: add proxy logon as audited action
Rem     talliu     06/28/13  - Add CDB view for DBA view
Rem     yiru       06/26/13  - Proj 47393: Add DELEGATE OPTION
Rem     amunnoli   02/22/13  - Bug #16310544: Add CREATE/ALTER/DROP PLUGGABLE 
Rem                            DATABASE actions to audit_actions. Add column
Rem                            EXCLUDED_OBJECT, EXCLUDED_SCHEMA to 
Rem                            unified_audit_trail view
Rem     vpriyans   01/25/13  - Bug 15996683: created table
Rem                            UNIFIED_MISC_AUDITED_ACTIONS
Rem     vpriyans   11/19/12  - Bug 15884394 : updated AUDIT_UNIFIED_POLICIES
Rem                            definition to display DIRECT_LOAD actions
Rem     msakayed   10/11/12  - Bug #14760094: replace "ALL ACTIONS" with "ALL"
Rem     sanbhara   08/27/12  - Bug 14536759 - fixing AUDIT_UNIFIED_POLICIES
Rem                            view to disaply datapump audit policies and fix
Rem                            where clause for DV audit policies.
Rem     nkgopal    08/08/12  - Bug 14458443: Add authentication_type to
Rem                            UNIFIED_AUDIT_TRAIL
Rem     mziauddi   08/05/12  - proj 35612: add zonemap audit actions
Rem     nkgopal    07/31/12  - Bug 13328867: Add LOGOFF BY CLEANUP
Rem     sanbhara   07/06/12  - Bug 13785394 - update audit_unified_policies to
Rem                            include DV object names.
Rem     byu        05/18/12  - Bug-13242046: add audit actions for measure 
Rem                            folder and build process
Rem     vpriyans   05/29/12  - Bug 13768040: Created
Rem                            AUDIT_UNIFIED_POLICY_COMMENTS view
Rem     mziauddi   06/26/12  - change code-based audit action values from
Rem                            239-240 to 232-233
Rem     nkgopal    06/12/12  - Bug 14117493: Add ORADEBUG COMMAND to
Rem                            ALL_AUDITED_SYSTEM_ACTIONS
Rem     msakayed   06/12/12  - Bug #13572741: fix views for dpapi auditing
Rem     mstasiew   06/06/12  - Bug 13537982 - remove olap cube ddl sql
Rem                            but maintain/move audit codes
Rem     nkgopal    05/22/12  - Bug 14108323: DBLINK_NAME->DBLINK_INFO, add 
Rem                            FGA actions
Rem     sanbhara   05/10/12  - Bug 14060290 - adding DV component to
Rem                            auditable_system_actions view.
Rem     vpriyans   04/13/12  - Bug-13413683 Inlcude RMAN columns in
Rem                            unified_audit_trail view
Rem     surman     03/27/12  - 13615447: Add SQL patching tags
Rem     msakayed   03/15/12  - Bug #13770085: fix views for Datapump
Rem     risgupta   03/12/12  - Bug 13706982:Remove OLS actions from 
Rem                            AUDIT_ACTIONS table
Rem     ssonawan   01/13/13  - Bug 13582041: fix UNIFIED_AUDIT_TRAIL view
Rem                          - Bug 13028328: do not grant access no audit views
Rem                                          to select_catalog_role
Rem                          - Remove handler column from AUDIT_UNIFIED_POLI...
Rem     nkgopal    09/07/11  - Bug 12794116: Move creation of policies from
Rem                            cataudit.sql to c1102000.sql
Rem     yanlili    08/30/11  - Proj 23934: Remove Triton actions from 
Rem                            AUDIT_ACTIONS; change TRITON prefixed columns to
Rem                            XS prefixed columns
Rem     ssonawan   09/12/11  - bug 12844480:remove flags column from audit$
Rem     nkgopal    08/24/11  - Bug 12794380: Add UNIFIED_AUDIT_TRAIL view and
Rem                            AUDITOR to AUDIT_VIEWER
Rem     skayoor    08/22/11  - Bug 12846043: Audit for INHERIT PRIVILEGES.
Rem     risgupta   06/10/11  - Proj 5700: OLS auditing support
Rem     ssonawan   07/04/11  - proj 16531: add role auditng support
Rem     skayoor    06/27/11  - Project 32719 - Add INHERIT PRIVILEGES
Rem     weihwang   07/11/11  - Add CODE-BASED GRANT/REVOKE in audit_actions
Rem     amunnoli   06/18/11  - Proj 26873: Add DATABASE STARTUP and DATABASE
Rem                            SHUTDOWN in AUDIT_ACTIONS
Rem     nalamand   05/27/11  - Proj-32480: Add COMMON column to some audit 
Rem                            views. Also set _oracle_script to TRUE.
Rem     ssonawan   06/09/11  - Proj 16531: grant select on audit config views to
Rem                            audit_admin; fix AUDITABLE_SYSTEM_ACTIONS view 
Rem     nalamand   05/27/11  - Proj-32480: Add COMMON column to some audit 
Rem                            views. Also set _oracle_script to TRUE.
Rem     yanlili    05/13/11  - Proj 23934: Triton security support
Rem     ssonawan   04/06/11  - Proj 16531: add entries to audit_actions table
Rem     rpang      04/01/11  - Auditing support for SQL translation profiles
Rem     rsamuels   03/22/11  - CREATE/ALTER/DROP DDL for CUBE & CUBE DIMENSION
Rem     amunnoli   02/24/11  - Grant audit system,audit any to AUDIT_ADMIN,
Rem                            Grant select on dba_audit_trail to AUDITOR
Rem                            and AUDIT_ADMIN
Rem     rmir       02/16/11  - Proj 32008, add ADMINISTER KEY MANAGEMENT audit
Rem                            action
Rem     ssonawan   01/14/11  - proj 16531: add dictionary tables and views
Rem                            related to Audit policy framework
Rem     nkgopal    01/06/11  - Proj 31908: Add PASSWORD CHANGE in AUDIT_ACTIONS
Rem     mjgreave   10/18/10  - add audit_actions for ALTER VIEW. #10206268
Rem     akruglik   11/02/09  - 31113 (ALTER USER RENAME): get rid of 
Rem                            audit_actions rows for ALTER SCHEMA [SYNONYM]
Rem     msakayed   10/28/09  - Bug #5842629: audit_actions for direct path load
Rem     msakayed   10/22/09  - Bug 8862486: audit_actions for DIRECTORY EXECUTE
Rem     apsrivas   11/25/08  - Bug 6755639 : Add DBID to DBA_AUDIT_TRAIL and
Rem                            USER_AUDIT_TRAIL
Rem     nkgopal    05/08/08  - Bug 6830207: Add Action names for ALTER DATABASE
Rem                            LINK
Rem     msakayed   04/03/08  - fix directory privs for *_obj_audit_opts
Rem     akruglik   03/16/08  - 31113 (RENAME SCHEMA): add audit_actions rows 
Rem                            for ALTER SCHEMA RENAME, CREATE/ALTER/DROP 
Rem                            SCHEMA SYNONYM
Rem     mjgreave   11/14/07  - add audit_actions for ALTER SYNONYM. #5647235
Rem     sfeinste   04/09/07  - rename olap_build_processes$ to
Rem                            olap_cube_build_processes$
Rem     wechen     02/17/07  - rename olap_primary_dimensions$ and
Rem                            olap_interactions$ to olap_cube_dimensions$
Rem                            and olap_build_processes$
Rem     pstengar   12/01/06  - bug 5586631: add MINING MODEL entries to
Rem                                         AUDIT_ACTIONS
Rem     achoi      09/27/06  - bug5508217: Change name in *_AUDIT_TRAIL to
Rem                                        OBJ_EDITION_NAME
Rem     ciyer      08/04/06  - audit support for edition objects
Rem     wechen     07/04/06  - add OLAP API support
Rem     gviswana   07/09/06  - Edition name support 
Rem     ssonawan   06/21/06  - bug5346555: add AUDIT_ACTIONS 166
Rem                            ALTER INDEXTYPE
Rem     liaguo     06/26/06  - Project 17991 - flashback archive
Rem     pstengar   05/30/06  - audit mining model objects
Rem     ssonawan   06/01/06  - BUG 5138541: DBA_AUDIT_TRAIL(LOGOFF$TIME) in 
Rem                                         session timezone format 
Rem     achoi      05/09/06  - support application edition 
Rem     rdecker    03/27/06  - Add assembly support
Rem     vmarwah    06/23/05  - PURGE TABLESPACE typo fix 
Rem     mxiao      03/17/05  - audit rewrite equivalence, bug 4276578
Rem     dsirmuka   12/18/04  - bug 4055382. Comment change.
Rem     gmulagun   12/08/04  - bug 4054898 add REA for ALL_DEF_AUDIT_OPTS
Rem     gtarora    11/12/04  - bug 3984527 
Rem     gmulagun   08/30/04  - bug 3629208 set execution contextid 
Rem     jnarasin   07/30/04  - EUS Proxy auditing changes 
Rem     xuhuali    04/13/04  - audit java
Rem     nmanappa   06/24/04  - 3633725 - select only audit set objects in 
Rem                            dba_obj_audit_opts and user_obj_audit_opts
Rem     ahwang     05/08/04  - add create and drop restore point 
Rem     gmulagun   04/04/03  - bug 2822534: rename tran_id to xid
Rem     nireland   02/25/03  - Add Become User/Create Session. #2798933
Rem     gmulagun   03/12/03  - bug 2817508
Rem     mxiao      01/29/03  - change SNAPSHOT to MATERIALIZED VIEW
Rem     gmulagun   12/27/02  - Add dummy REF column
Rem     nmanappa   10/11/02  - Adding FLASHBACK to audit_actions, and reusing 
Rem                            REFerence pos for FBK to store flashback option
Rem     gmulagun   09/23/02  - correct extended_timestamp column
Rem     gmulagun   09/16/02  - enhance audit trail
Rem     mjstewar   09/12/02  - Flashback Database: Insert auditing information. 
Rem     vmarwah    05/24/02  - Undrop Tables: Insert auditing information.
Rem     desinha    04/29/02  - #2303866: change user => userenv('SCHEMAID')
Rem     gviswana   05/24/01  - CREATE OR REPLACE SYNONYM
Rem     htseng     04/12/01  - eliminate execute twice (remove ;).
Rem     rvissapr   08/30/00  - add client_id in audit views
Rem     dmwong     12/09/98  - add missing entries into audit_action           
Rem     sbodagal   12/23/98 -  Make entries in audit_actions to audit outlines
Rem     rguzman    09/25/98 -  Add dimensions to audit_actions
Rem     rwessman   07/01/98  - Corrected comments in audit trail views.
Rem     rwessman   06/29/98  - Fixed bug in dba_stmt_audit_opts view where prox
Rem     rwessman   04/08/98 -  Added support for N-tier auditing
Rem     cozbutun   01/12/98 -  remove object_label session_label from views
Rem     nlewis     03/10/97 -  #376745: remove duplicate DROP PROC entry (#58)
Rem     rshaikh    08/08/96 -  add directory to user_obj_audit_opts
Rem     tanguyen   07/02/96 -  change EXECUTE TYPE from 84 to 123
Rem     tanguyen   06/25/96 -  add EXECUTE TYPE to audit_actions table
Rem     jwijaya    06/17/96 -  check for EXECUTE ANY TYPE
Rem     skaluska   06/13/96 -  Add auditing on libraries
Rem     jwijaya    06/19/96 -  remove USAGE
Rem     mmonajje   05/20/96 -  Replace timestamp col name with timestamp#
Rem     asurpur    04/08/96 -  Dictionary Protection Implementation
Rem     rshaikh    04/01/96 -  add DIRECTORY to audit_actions
Rem     rshaikh    12/01/95 -  add object support to user_obj_audit_opts and au
Rem     jwijaya    11/07/95 -  type privilege fix
Rem     jwijaya    08/28/95 -  add ADTs/objects
Rem     wmaimone   05/26/94 -  #186155 add public synoyms for dba_
Rem     jbellemo   04/10/95 -  NETAUDIT: add NETWORK
Rem     jbellemo   12/17/93 -  merge changes from branch 1.5.710.1
Rem     jbellemo   11/09/93 -  #170173: change uid to userenv schemaid
Rem     wmaimone   11/23/92 -  wrap rawtolab around labels 
Rem     dleary     11/12/92 -  add OER(2024) not exists error 
Rem     tpystyne   11/07/92 -  use create or replace view 
Rem     vraghuna   10/28/92 -  bug 130560 - move map tables in sql.bsq 
Rem     glumpkin   10/14/92 -  renamed from audit.sql
Rem     rlim       09/25/92 -  #128468 - remove dba synonyms already
Rem                            defined in dba_syn.sql 
Rem     ajasuja    06/02/92 -  new auditing codes 
Rem     ajasuja    02/12/92 -  add ses$label, obj$label columns 
Rem     ajasuja    12/31/91 -  fix dba_audit_trail view 
Rem     ajasuja    12/30/91 -  audit EXISTS 
Rem     ajasuja    11/27/91 -  add system privilege auditing 
Rem     smcadams   10/19/91 -  tweak audit_action table 
Rem     rlim       07/30/91 -         moved dba synonyms to dba_synonyms.sql 
Rem     smcadams   06/09/91 -         sync with catalog.sql 
Rem     smcadams   05/07/91 -         re-sync audit action decoding table with 
Rem     jwijaya    04/12/91 -         remove LINKNAME IS NULL 
Rem     smcadams   04/08/91 -         remove 'ANY' from audit option descriptio
Rem     smcadams   04/02/91 -         add action to audit_actions 
Rem     smcadams   04/02/91 -         add a couple more stmt_audit_opts 
Rem     rkooi      04/01/91 -         add 'o.linkname IS NULL' clause 
Rem   Chaudhr    04/30/90 - Add procedure and trigger stuff
Rem                       - Rename the following objects:
Rem                       -  audit_option_map    -> stmt_audit_option_map
Rem                       -  dba_sys_audit_opts  -> dba_stmt_audit_opts
Rem                       -  dba_tab_audit_opts  -> dba_obj_audit_opts
Rem                       -  user_tab_audit_opts -> user_obj_audit_opts
Rem   Chaudhr    03/09/90 - Creation
Rem

@@?/rdbms/admin/sqlsessstart.sql

-- SHARING bits in OBJ$.FLAGS are:
-- - 65536  = MDL (Metadata Link)
-- - 131072 = DL (Data Link, formerly OBL)
-- - 4294967296 = EDL (Extended Data Link)
define mdl=65536
define dl=131072
define edl=4294967296
define sharing_bits=(&mdl+&dl+&edl)

remark
remark AUDITING VIEWS
remark
remark  The auditing views can be dropped by running catnoaud.sql, and 
remark  recreated by running cataudit.sql.
remark
remark  STMT_AUDIT_OPTION_MAP now in sql.bsq
remark
remark  AUDIT_ACTIONS maps an action number to the action name.
remark  The table is accessible to public.
remark

Rem Bug 20370996: Dropping and re-creating AUDIT_ACTIONS cause invalidations of
Rem other objects like DBA_COMMON_AUDIT_TRAIL, etc (see bug). So, DO NOT run
Rem DROP TABLE AUDIT_ACTIONS. Instead TRUNCATE TABLE AUDIT_ACTIONS and then
Rem run the INSERT statements.
create table AUDIT_ACTIONS sharing = object (
  action number not null, name varchar2(28) not null)
/
comment on table AUDIT_ACTIONS is
'Description table for audit trail action type codes.  Maps action type numbers to action type names'
/
comment on column AUDIT_ACTIONS.ACTION is
'Numeric audit trail action type code'
/
comment on column AUDIT_ACTIONS.NAME is
'Name of the type of audit trail action'
/
truncate table AUDIT_ACTIONS
/
insert into audit_actions values (0, 'UNKNOWN');
insert into audit_actions values (1, 'CREATE TABLE');
insert into audit_actions values (2, 'INSERT');
insert into audit_actions values (3, 'SELECT');
insert into audit_actions values (4, 'CREATE CLUSTER');
insert into audit_actions values (5, 'ALTER CLUSTER');
insert into audit_actions values (6, 'UPDATE');
insert into audit_actions values (7, 'DELETE');
insert into audit_actions values (8, 'DROP CLUSTER');
insert into audit_actions values (9, 'CREATE INDEX');
insert into audit_actions values (10, 'DROP INDEX');
insert into audit_actions values (11, 'ALTER INDEX');
insert into audit_actions values (12, 'DROP TABLE');
insert into audit_actions values (13, 'CREATE SEQUENCE');
insert into audit_actions values (14, 'ALTER SEQUENCE');
insert into audit_actions values (15, 'ALTER TABLE');
insert into audit_actions values (16, 'DROP SEQUENCE');
insert into audit_actions values (17, 'GRANT OBJECT');
insert into audit_actions values (18, 'REVOKE OBJECT');
insert into audit_actions values (19, 'CREATE SYNONYM');
insert into audit_actions values (20, 'DROP SYNONYM');
insert into audit_actions values (21, 'CREATE VIEW');
insert into audit_actions values (22, 'DROP VIEW');
insert into audit_actions values (23, 'VALIDATE INDEX');
insert into audit_actions values (24, 'CREATE PROCEDURE');
insert into audit_actions values (25, 'ALTER PROCEDURE');
insert into audit_actions values (26, 'LOCK');
insert into audit_actions values (27, 'NO-OP');
insert into audit_actions values (28, 'RENAME');
insert into audit_actions values (29, 'COMMENT');
insert into audit_actions values (30, 'AUDIT OBJECT');
insert into audit_actions values (31, 'NOAUDIT OBJECT');
insert into audit_actions values (32, 'CREATE DATABASE LINK');
insert into audit_actions values (33, 'DROP DATABASE LINK');
insert into audit_actions values (34, 'CREATE DATABASE');
insert into audit_actions values (35, 'ALTER DATABASE');
insert into audit_actions values (36, 'CREATE ROLLBACK SEG');
insert into audit_actions values (37, 'ALTER ROLLBACK SEG');
insert into audit_actions values (38, 'DROP ROLLBACK SEG');
insert into audit_actions values (39, 'CREATE TABLESPACE');
insert into audit_actions values (40, 'ALTER TABLESPACE');
insert into audit_actions values (41, 'DROP TABLESPACE');
insert into audit_actions values (42, 'ALTER SESSION');
insert into audit_actions values (43, 'ALTER USER');
insert into audit_actions values (44, 'COMMIT');
insert into audit_actions values (45, 'ROLLBACK');
insert into audit_actions values (46, 'SAVEPOINT');
insert into audit_actions values (47, 'PL/SQL EXECUTE');
insert into audit_actions values (48, 'SET TRANSACTION');
insert into audit_actions values (49, 'ALTER SYSTEM');
insert into audit_actions values (50, 'EXPLAIN');
insert into audit_actions values (51, 'CREATE USER');
insert into audit_actions values (52, 'CREATE ROLE');
insert into audit_actions values (53, 'DROP USER');
insert into audit_actions values (54, 'DROP ROLE');
insert into audit_actions values (55, 'SET ROLE');
insert into audit_actions values (56, 'CREATE SCHEMA');
insert into audit_actions values (57, 'CREATE CONTROL FILE');
insert into audit_actions values (58, 'ALTER TRACING');
insert into audit_actions values (59, 'CREATE TRIGGER');
insert into audit_actions values (60, 'ALTER TRIGGER');
insert into audit_actions values (61, 'DROP TRIGGER');
insert into audit_actions values (62, 'ANALYZE TABLE');
insert into audit_actions values (63, 'ANALYZE INDEX');
insert into audit_actions values (64, 'ANALYZE CLUSTER');
insert into audit_actions values (65, 'CREATE PROFILE');
insert into audit_actions values (66, 'DROP PROFILE');
insert into audit_actions values (67, 'ALTER PROFILE');
insert into audit_actions values (68, 'DROP PROCEDURE');
insert into audit_actions values (70, 'ALTER RESOURCE COST');
insert into audit_actions values (71, 'CREATE MATERIALIZED VIEW LOG');
insert into audit_actions values (72, 'ALTER MATERIALIZED VIEW LOG');
insert into audit_actions values (73, 'DROP MATERIALIZED VIEW LOG');
insert into audit_actions values (74, 'CREATE MATERIALIZED VIEW');
insert into audit_actions values (75, 'ALTER MATERIALIZED VIEW');
insert into audit_actions values (76, 'DROP MATERIALIZED VIEW');
insert into audit_actions values (77, 'CREATE TYPE');
insert into audit_actions values (78, 'DROP TYPE');
insert into audit_actions values (79, 'ALTER ROLE');
insert into audit_actions values (80, 'ALTER TYPE');
insert into audit_actions values (81, 'CREATE TYPE BODY');
insert into audit_actions values (82, 'ALTER TYPE BODY');
insert into audit_actions values (83, 'DROP TYPE BODY');
insert into audit_actions values (84, 'DROP LIBRARY');
insert into audit_actions values (85, 'TRUNCATE TABLE');
insert into audit_actions values (86, 'TRUNCATE CLUSTER');
insert into audit_actions values (88, 'ALTER VIEW');
insert into audit_actions values (90, 'SET CONSTRAINTS');
insert into audit_actions values (91, 'CREATE FUNCTION');
insert into audit_actions values (92, 'ALTER FUNCTION');
insert into audit_actions values (93, 'DROP FUNCTION');
insert into audit_actions values (94, 'CREATE PACKAGE');
insert into audit_actions values (95, 'ALTER PACKAGE');
insert into audit_actions values (96, 'DROP PACKAGE');
insert into audit_actions values (97, 'CREATE PACKAGE BODY');
insert into audit_actions values (98, 'ALTER PACKAGE BODY');
insert into audit_actions values (99, 'DROP PACKAGE BODY');
insert into audit_actions values (100, 'LOGON');
insert into audit_actions values (101, 'LOGOFF');
insert into audit_actions values (102, 'LOGOFF BY CLEANUP');
insert into audit_actions values (103, 'SESSION REC');
insert into audit_actions values (104, 'SYSTEM AUDIT');
insert into audit_actions values (105, 'SYSTEM NOAUDIT');
insert into audit_actions values (106, 'AUDIT DEFAULT');
insert into audit_actions values (107, 'NOAUDIT DEFAULT');
insert into audit_actions values (108, 'SYSTEM GRANT');
insert into audit_actions values (109, 'SYSTEM REVOKE');
insert into audit_actions values (110, 'CREATE PUBLIC SYNONYM');
insert into audit_actions values (111, 'DROP PUBLIC SYNONYM');
insert into audit_actions values (112, 'CREATE PUBLIC DATABASE LINK');
insert into audit_actions values (113, 'DROP PUBLIC DATABASE LINK');
insert into audit_actions values (114, 'GRANT ROLE');
insert into audit_actions values (115, 'REVOKE ROLE');
insert into audit_actions values (116, 'EXECUTE PROCEDURE');
insert into audit_actions values (117, 'USER COMMENT');
insert into audit_actions values (118, 'ENABLE TRIGGER');
insert into audit_actions values (119, 'DISABLE TRIGGER');
insert into audit_actions values (120, 'ENABLE ALL TRIGGERS');
insert into audit_actions values (121, 'DISABLE ALL TRIGGERS');
insert into audit_actions values (122, 'NETWORK ERROR');
insert into audit_actions values (123, 'EXECUTE TYPE');
insert into audit_actions values (125, 'READ DIRECTORY');
insert into audit_actions values (126, 'WRITE DIRECTORY');
insert into audit_actions values (128, 'FLASHBACK');
insert into audit_actions values (129, 'BECOME USER');
insert into audit_actions values (130, 'ALTER MINING MODEL');
insert into audit_actions values (131, 'SELECT MINING MODEL');
insert into audit_actions values (133, 'CREATE MINING MODEL');
insert into audit_actions values (134, 'ALTER PUBLIC SYNONYM');
insert into audit_actions values (135, 'EXECUTE DIRECTORY');
insert into audit_actions values (136, 'SQL*LOADER DIRECT PATH LOAD');
insert into audit_actions values (137, 'DATAPUMP DIRECT PATH UNLOAD');
insert into audit_actions values (138, 'DATABASE STARTUP');
insert into audit_actions values (139, 'DATABASE SHUTDOWN');
insert into audit_actions values (140, 'CREATE SQL TXLN PROFILE');
insert into audit_actions values (141, 'ALTER SQL TXLN PROFILE');
insert into audit_actions values (142, 'USE SQL TXLN PROFILE');
insert into audit_actions values (143, 'DROP SQL TXLN PROFILE');
insert into audit_actions values (144, 'CREATE MEASURE FOLDER');
insert into audit_actions values (145, 'ALTER MEASURE FOLDER');
insert into audit_actions values (146, 'DROP MEASURE FOLDER');
insert into audit_actions values (147, 'CREATE CUBE BUILD PROCESS');
insert into audit_actions values (148, 'ALTER CUBE BUILD PROCESS');
insert into audit_actions values (149, 'DROP CUBE BUILD PROCESS');

/* codes 150 -> 155 are for olap dml cube objects.  There are no */
/* corresponding sql commands or octdef codes */
insert into audit_actions values (150, 'CREATE CUBE');
insert into audit_actions values (151, 'ALTER CUBE');
insert into audit_actions values (152, 'DROP CUBE');
insert into audit_actions values (153, 'CREATE CUBE DIMENSION');
insert into audit_actions values (154, 'ALTER CUBE DIMENSION');
insert into audit_actions values (155, 'DROP CUBE DIMENSION');

insert into audit_actions values (157, 'CREATE DIRECTORY');
insert into audit_actions values (158, 'DROP DIRECTORY');
insert into audit_actions values (159, 'CREATE LIBRARY');
insert into audit_actions values (160, 'CREATE JAVA');
insert into audit_actions values (161, 'ALTER JAVA');
insert into audit_actions values (162, 'DROP JAVA');
insert into audit_actions values (163, 'CREATE OPERATOR');
insert into audit_actions values (164, 'CREATE INDEXTYPE');
insert into audit_actions values (165, 'DROP INDEXTYPE');
insert into audit_actions values (166, 'ALTER INDEXTYPE');
insert into audit_actions values (167, 'DROP OPERATOR');
insert into audit_actions values (168, 'ASSOCIATE STATISTICS');
insert into audit_actions values (169, 'DISASSOCIATE STATISTICS');

insert into audit_actions values (170, 'CALL METHOD');
insert into audit_actions values (171, 'CREATE SUMMARY');
insert into audit_actions values (172, 'ALTER SUMMARY');
insert into audit_actions values (173, 'DROP SUMMARY');
insert into audit_actions values (174, 'CREATE DIMENSION');
insert into audit_actions values (175, 'ALTER DIMENSION');
insert into audit_actions values (176, 'DROP DIMENSION');
insert into audit_actions values (177, 'CREATE CONTEXT');
insert into audit_actions values (178, 'DROP CONTEXT');
insert into audit_actions values (179, 'ALTER OUTLINE');

insert into audit_actions values (180, 'CREATE OUTLINE');
insert into audit_actions values (181, 'DROP OUTLINE');
insert into audit_actions values (182, 'UPDATE INDEXES');
insert into audit_actions values (183, 'ALTER OPERATOR');

insert into audit_actions values (187, 'CREATE SPFILE');
insert into audit_actions values (188, 'CREATE PFILE');
insert into audit_actions values (189, 'MERGE');

insert into audit_actions values (190, 'PASSWORD CHANGE');
insert into audit_actions values (192, 'ALTER SYNONYM');

insert into audit_actions values (193, 'ALTER DISKGROUP');
insert into audit_actions values (194, 'CREATE DISKGROUP');
insert into audit_actions values (195, 'DROP DISKGROUP');

-- Bug 26050809: audit PURGE [DBA_]RECYCLEBIN action
insert into audit_actions values (197, 'PURGE RECYCLEBIN');
insert into audit_actions values (198, 'PURGE DBA_RECYCLEBIN');
insert into audit_actions values (199, 'PURGE TABLESPACE');
insert into audit_actions values (200, 'PURGE TABLE');
insert into audit_actions values (201, 'PURGE INDEX');
insert into audit_actions values (202, 'UNDROP OBJECT');

insert into audit_actions values (203, 'DROP DATABASE');

insert into audit_actions values (204, 'FLASHBACK DATABASE');
insert into audit_actions values (205, 'FLASHBACK TABLE');
insert into audit_actions values (206, 'CREATE RESTORE POINT');
insert into audit_actions values (207, 'DROP RESTORE POINT');

insert into audit_actions values (208, 'PROXY AUTHENTICATION ONLY') ;
insert into audit_actions values (209, 'DECLARE REWRITE EQUIVALENCE') ;
insert into audit_actions values (210, 'ALTER REWRITE EQUIVALENCE') ;
insert into audit_actions values (211, 'DROP REWRITE EQUIVALENCE') ;

insert into audit_actions values (212, 'CREATE EDITION');
insert into audit_actions values (213, 'ALTER EDITION');
insert into audit_actions values (214, 'DROP EDITION');

insert into audit_actions values (215, 'DROP ASSEMBLY');
insert into audit_actions values (216, 'CREATE ASSEMBLY');
insert into audit_actions values (217, 'ALTER ASSEMBLY');

insert into audit_actions values (218, 'CREATE FLASHBACK ARCHIVE');
insert into audit_actions values (219, 'ALTER FLASHBACK ARCHIVE');
insert into audit_actions values (220, 'DROP FLASHBACK ARCHIVE');

insert into audit_actions values (221, 'DEBUG CONNECT');

/* SCHEMA SYNONYMS will be added in 12g */
-- insert into audit_actions values (222, 'CREATE SCHEMA SYNONYM');
-- insert into audit_actions values (224, 'DROP SCHEMA SYNONYM');

insert into audit_actions values (223, 'DEBUG PROCEDURE');

insert into audit_actions values (225, 'ALTER DATABASE LINK');
insert into audit_actions values (229, 'CREATE AUDIT POLICY');
insert into audit_actions values (230, 'ALTER AUDIT POLICY');
insert into audit_actions values (231, 'DROP AUDIT POLICY');
insert into audit_actions values (305, 'ALTER PUBLIC DATABASE LINK');

insert into audit_actions values (232, 'CODE-BASED GRANT');
insert into audit_actions values (233, 'CODE-BASED REVOKE');

insert into audit_actions values (237, 'TRANSLATE SQL');

insert into audit_actions values (238, 'ADMINISTER KEY MANAGEMENT');

insert into audit_actions values (239, 'CREATE MATERIALIZED ZONEMAP');
insert into audit_actions values (240, 'ALTER MATERIALIZED ZONEMAP');
insert into audit_actions values (241, 'DROP MATERIALIZED ZONEMAP');

insert into audit_actions values (242, 'DROP MINING MODEL');

insert into audit_actions values (243, 'CREATE ATTRIBUTE DIMENSION');
insert into audit_actions values (244, 'ALTER ATTRIBUTE DIMENSION');
insert into audit_actions values (245, 'DROP ATTRIBUTE DIMENSION');

insert into audit_actions values (246, 'CREATE HIERARCHY');
insert into audit_actions values (247, 'ALTER HIERARCHY');
insert into audit_actions values (248, 'DROP HIERARCHY');

insert into audit_actions values (249, 'CREATE ANALYTIC VIEW');
insert into audit_actions values (250, 'ALTER ANALYTIC VIEW');
insert into audit_actions values (251, 'DROP ANALYTIC VIEW');


/* Bug #16310544 */
insert into audit_actions values (226, 'CREATE PLUGGABLE DATABASE');
insert into audit_actions values (227, 'ALTER PLUGGABLE DATABASE');
insert into audit_actions values (228, 'DROP PLUGGABLE DATABASE');

insert into audit_actions values (234, 'CREATE LOCKDOWN PROFILE');
insert into audit_actions values (235, 'DROP LOCKDOWN PROFILE');
insert into audit_actions values (236, 'ALTER LOCKDOWN PROFILE');

commit;

create unique index I_AUDIT_ACTIONS on audit_actions(action,name) nocompress
/
create or replace public synonym AUDIT_ACTIONS for AUDIT_ACTIONS
/
grant read on AUDIT_ACTIONS to public
/

remark
remark  FAMILY "DEF_AUDIT_OPTS"
remark  Single row view indicating the default auditing options
remark  for newly created objects.
remark  This family has an ALL member only, since the default is
remark  system-wide and applies to all accessible objects.
remark
create or replace view ALL_DEF_AUDIT_OPTS
    (ALT,
     AUD,
     COM,
     DEL,
     GRA,
     IND,
     INS,
     LOC,
     REN,
     SEL,
     UPD,
     REF,
     EXE,
     FBK,
     REA)
as
select substr(t.audit$, 1, 1) || '/' || substr(t.audit$, 2, 1),
       substr(t.audit$, 3, 1) || '/' || substr(t.audit$, 4, 1),
       substr(t.audit$, 5, 1) || '/' || substr(t.audit$, 6, 1),
       substr(t.audit$, 7, 1) || '/' || substr(t.audit$, 8, 1),
       substr(t.audit$, 9, 1) || '/' || substr(t.audit$, 10, 1),
       substr(t.audit$, 11, 1) || '/' || substr(t.audit$, 12, 1),
       substr(t.audit$, 13, 1) || '/' || substr(t.audit$, 14, 1),
       substr(t.audit$, 15, 1) || '/' || substr(t.audit$, 16, 1),
       substr(t.audit$, 17, 1) || '/' || substr(t.audit$, 18, 1),
       substr(t.audit$, 19, 1) || '/' || substr(t.audit$, 20, 1),
       substr(t.audit$, 21, 1) || '/' || substr(t.audit$, 22, 1),
       '-/-',                                            /* dummy REF column */
       substr(t.audit$, 25, 1) || '/' || substr(t.audit$, 26, 1),
       substr(t.audit$, 23, 1) || '/' || substr(t.audit$, 24, 1),
       substr(t.audit$, 29, 1) || '/' || substr(t.audit$, 30, 1)
from sys.obj$ o, sys.tab$ t
where o.obj# = t.obj#
  and o.owner# = 0
  and o.name = '_default_auditing_options_'
/
comment on table ALL_DEF_AUDIT_OPTS is
'Auditing options for newly created objects'
/
comment on column ALL_DEF_AUDIT_OPTS.ALT is
'Auditing ALTER WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column ALL_DEF_AUDIT_OPTS.AUD is
'Auditing AUDIT WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column ALL_DEF_AUDIT_OPTS.COM is
'Auditing COMMENT WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column ALL_DEF_AUDIT_OPTS.DEL is
'Auditing DELETE WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column ALL_DEF_AUDIT_OPTS.GRA is
'Auditing GRANT WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column ALL_DEF_AUDIT_OPTS.IND is
'Auditing INDEX WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column ALL_DEF_AUDIT_OPTS.INS is
'Auditing INSERT WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column ALL_DEF_AUDIT_OPTS.LOC is
'Auditing LOCK WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column ALL_DEF_AUDIT_OPTS.REN is
'Auditing RENAME WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column ALL_DEF_AUDIT_OPTS.SEL is
'Auditing SELECT WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column ALL_DEF_AUDIT_OPTS.UPD is
'Auditing UPDATE WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column ALL_DEF_AUDIT_OPTS.REF is
'Dummy REF column. Maintained for backward compatibility of the view'
/
comment on column ALL_DEF_AUDIT_OPTS.EXE is
'Auditing EXECUTE WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column ALL_DEF_AUDIT_OPTS.FBK is
'Auditing FLASHBACK WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column ALL_DEF_AUDIT_OPTS.REA is
'Auditing READ WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
create or replace public synonym ALL_DEF_AUDIT_OPTS for ALL_DEF_AUDIT_OPTS
/
grant read on ALL_DEF_AUDIT_OPTS to PUBLIC
/


remark
remark  FAMILY "OBJ_AUDIT_OPTS"
remark  Auditing options on objects.  Only "user_" and "dba_" members.
remark  A user is not allowed to see audit options for other people's objects.
remark
remark  These views indicate what kind of audit trail entries (none,
remark  session-level, or access-level) are generated by the success or failure
remark  of each possible operation on a table or view (e.g., select, alter).
remark
remark  The values in the columns ALT through UPD are three character
remark  strings like 'A/S', 'A/-'.  The letters 'A', 'S', and '-' correspond to
remark  different levels of detail called Access, Session and None.  The
remark  character before the slash determines the auditing level if the action
remark  is successful.  The character after the slash determines auditing level
remark  if the operation fails for any reason.
remark
remark  This compressed three character format has been chosen to make all
remark  the information fit on a single line.  The column names are
remark  three chars long for the same reason.  The alternative is to use long
remark  column names to improve readability, but
remark  serious users can get further documentation using the describe
remark  column statement.  I do not expect novice users to be looking at audit
remark  information.  Another alternative is to have separate columns for the
remark  success and failure settings.  This would eliminate the need to
remark  use the substr function in views built on top of these views,
remark  but the advantage to users of making information fit on one line
remark  overrides the hassle to view-implementors of using the substr function.
remark
create or replace view USER_OBJ_AUDIT_OPTS 
        (OBJECT_NAME, 
         OBJECT_TYPE, 
         ALT,
         AUD,
         COM,
         DEL,
         GRA,
         IND,
         INS,
         LOC,
         REN,
         SEL,
         UPD,
         REF,
         EXE,
         CRE,
         REA,
         WRI,
         FBK)
as
select o.name, 'TABLE',
       substr(t.audit$, 1, 1) || '/' || substr(t.audit$, 2, 1),
       substr(t.audit$, 3, 1) || '/' || substr(t.audit$, 4, 1),
       substr(t.audit$, 5, 1) || '/' || substr(t.audit$, 6, 1),
       substr(t.audit$, 7, 1) || '/' || substr(t.audit$, 8, 1),
       substr(t.audit$, 9, 1) || '/' || substr(t.audit$, 10, 1),
       substr(t.audit$, 11, 1) || '/' || substr(t.audit$, 12, 1),
       substr(t.audit$, 13, 1) || '/' || substr(t.audit$, 14, 1),
       substr(t.audit$, 15, 1) || '/' || substr(t.audit$, 16, 1),
       substr(t.audit$, 17, 1) || '/' || substr(t.audit$, 18, 1),
       substr(t.audit$, 19, 1) || '/' || substr(t.audit$, 20, 1),
       substr(t.audit$, 21, 1) || '/' || substr(t.audit$, 22, 1),
       '-/-',                                            /* dummy REF column */
       substr(t.audit$, 25, 1) || '/' || substr(t.audit$, 26, 1),
       substr(t.audit$, 27, 1) || '/' || substr(t.audit$, 28, 1),
       substr(t.audit$, 29, 1) || '/' || substr(t.audit$, 30, 1),
       substr(t.audit$, 31, 1) || '/' || substr(t.audit$, 32, 1),
       substr(t.audit$, 23, 1) || '/' || substr(t.audit$, 24, 1)
from sys.obj$ o, sys.tab$ t
where o.type# = 2
  and not (o.owner# = 0 and o.name = '_default_auditing_options_')
  and (instrb(t.audit$,'S') != 0  or instrb(t.audit$,'A') != 0)
  and o.owner# = userenv('SCHEMAID')
  and o.obj# = t.obj#
union all
select o.name, 'VIEW',
       substr(v.audit$, 1, 1) || '/' || substr(v.audit$, 2, 1),
       substr(v.audit$, 3, 1) || '/' || substr(v.audit$, 4, 1),
       substr(v.audit$, 5, 1) || '/' || substr(v.audit$, 6, 1),
       substr(v.audit$, 7, 1) || '/' || substr(v.audit$, 8, 1),
       substr(v.audit$, 9, 1) || '/' || substr(v.audit$, 10, 1),
       substr(v.audit$, 11, 1) || '/' || substr(v.audit$, 12, 1),
       substr(v.audit$, 13, 1) || '/' || substr(v.audit$, 14, 1),
       substr(v.audit$, 15, 1) || '/' || substr(v.audit$, 16, 1),
       substr(v.audit$, 17, 1) || '/' || substr(v.audit$, 18, 1),
       substr(v.audit$, 19, 1) || '/' || substr(v.audit$, 20, 1),
       substr(v.audit$, 21, 1) || '/' || substr(v.audit$, 22, 1),
       '-/-',                                            /* dummy REF column */
       substr(v.audit$, 25, 1) || '/' || substr(v.audit$, 26, 1),
       substr(v.audit$, 27, 1) || '/' || substr(v.audit$, 28, 1),
       substr(v.audit$, 29, 1) || '/' || substr(v.audit$, 30, 1),
       substr(v.audit$, 31, 1) || '/' || substr(v.audit$, 32, 1),
       substr(v.audit$, 23, 1) || '/' || substr(v.audit$, 24, 1)
from sys."_CURRENT_EDITION_OBJ" o, sys.view$ v
where o.type# = 4
  and (instrb(v.audit$,'S') != 0  or instrb(v.audit$,'A') != 0)
  and o.owner# = userenv('SCHEMAID')
  and o.obj# = v.obj#
union all
select o.name, 'SEQUENCE',
       substr(s.audit$, 1, 1) || '/' || substr(s.audit$, 2, 1),
       substr(s.audit$, 3, 1) || '/' || substr(s.audit$, 4, 1),
       substr(s.audit$, 5, 1) || '/' || substr(s.audit$, 6, 1),
       substr(s.audit$, 7, 1) || '/' || substr(s.audit$, 8, 1),
       substr(s.audit$, 9, 1) || '/' || substr(s.audit$, 10, 1),
       substr(s.audit$, 11, 1) || '/' || substr(s.audit$, 12, 1),
       substr(s.audit$, 13, 1) || '/' || substr(s.audit$, 14, 1),
       substr(s.audit$, 15, 1) || '/' || substr(s.audit$, 16, 1),
       substr(s.audit$, 17, 1) || '/' || substr(s.audit$, 18, 1),
       substr(s.audit$, 19, 1) || '/' || substr(s.audit$, 20, 1),
       substr(s.audit$, 21, 1) || '/' || substr(s.audit$, 22, 1),
       '-/-',                                            /* dummy REF column */
       substr(s.audit$, 25, 1) || '/' || substr(s.audit$, 26, 1),
       substr(s.audit$, 27, 1) || '/' || substr(s.audit$, 28, 1),
       substr(s.audit$, 29, 1) || '/' || substr(s.audit$, 30, 1),
       substr(s.audit$, 31, 1) || '/' || substr(s.audit$, 32, 1),
       substr(s.audit$, 23, 1) || '/' || substr(s.audit$, 24, 1)
from sys.obj$ o, sys.seq$ s
where o.type# = 6
  and (instrb(s.audit$,'S') != 0  or instrb(s.audit$,'A') != 0)
  and o.owner# = userenv('SCHEMAID')
  and o.obj# = s.obj#
union all
select o.name, 'PROCEDURE',
       substr(p.audit$, 1, 1) || '/' || substr(p.audit$, 2, 1),
       substr(p.audit$, 3, 1) || '/' || substr(p.audit$, 4, 1),
       substr(p.audit$, 5, 1) || '/' || substr(p.audit$, 6, 1),
       substr(p.audit$, 7, 1) || '/' || substr(p.audit$, 8, 1),
       substr(p.audit$, 9, 1) || '/' || substr(p.audit$, 10, 1),
       substr(p.audit$, 11, 1) || '/' || substr(p.audit$, 12, 1),
       substr(p.audit$, 13, 1) || '/' || substr(p.audit$, 14, 1),
       substr(p.audit$, 15, 1) || '/' || substr(p.audit$, 16, 1),
       substr(p.audit$, 17, 1) || '/' || substr(p.audit$, 18, 1),
       substr(p.audit$, 19, 1) || '/' || substr(p.audit$, 20, 1),
       substr(p.audit$, 21, 1) || '/' || substr(p.audit$, 22, 1),
       '-/-',                                            /* dummy REF column */
       substr(p.audit$, 25, 1) || '/' || substr(p.audit$, 26, 1),
       substr(p.audit$, 27, 1) || '/' || substr(p.audit$, 28, 1),
       substr(p.audit$, 29, 1) || '/' || substr(p.audit$, 30, 1),
       substr(p.audit$, 31, 1) || '/' || substr(p.audit$, 32, 1),
       substr(p.audit$, 23, 1) || '/' || substr(p.audit$, 24, 1)
from sys."_CURRENT_EDITION_OBJ" o, sys.library$ p
where o.type# = 22
  and (instrb(p.audit$,'S') != 0  or instrb(p.audit$,'A') != 0)
  and o.owner# = userenv('SCHEMAID')
  and o.obj# = p.obj#
union all
select o.name, 'PROCEDURE',
       substr(p.audit$, 1, 1) || '/' || substr(p.audit$, 2, 1),
       substr(p.audit$, 3, 1) || '/' || substr(p.audit$, 4, 1),
       substr(p.audit$, 5, 1) || '/' || substr(p.audit$, 6, 1),
       substr(p.audit$, 7, 1) || '/' || substr(p.audit$, 8, 1),
       substr(p.audit$, 9, 1) || '/' || substr(p.audit$, 10, 1),
       substr(p.audit$, 11, 1) || '/' || substr(p.audit$, 12, 1),
       substr(p.audit$, 13, 1) || '/' || substr(p.audit$, 14, 1),
       substr(p.audit$, 15, 1) || '/' || substr(p.audit$, 16, 1),
       substr(p.audit$, 17, 1) || '/' || substr(p.audit$, 18, 1),
       substr(p.audit$, 19, 1) || '/' || substr(p.audit$, 20, 1),
       substr(p.audit$, 21, 1) || '/' || substr(p.audit$, 22, 1),
       '-/-',                                            /* dummy REF column */
       substr(p.audit$, 25, 1) || '/' || substr(p.audit$, 26, 1),
       substr(p.audit$, 27, 1) || '/' || substr(p.audit$, 28, 1),
       substr(p.audit$, 29, 1) || '/' || substr(p.audit$, 30, 1),
       substr(p.audit$, 31, 1) || '/' || substr(p.audit$, 32, 1),
       substr(p.audit$, 23, 1) || '/' || substr(p.audit$, 24, 1)
from sys."_CURRENT_EDITION_OBJ" o, sys.procedure$ p
where o.type# >= 7 and o.type# <= 9
  and (instrb(p.audit$,'S') != 0  or instrb(p.audit$,'A') != 0)
  and o.owner# = userenv('SCHEMAID')
  and o.obj# = p.obj#
union all
select o.name, 'TYPE',
       substr(t.audit$, 1, 1) || '/' || substr(t.audit$, 2, 1),
       substr(t.audit$, 3, 1) || '/' || substr(t.audit$, 4, 1),
       substr(t.audit$, 5, 1) || '/' || substr(t.audit$, 6, 1),
       substr(t.audit$, 7, 1) || '/' || substr(t.audit$, 8, 1),
       substr(t.audit$, 9, 1) || '/' || substr(t.audit$, 10, 1),
       substr(t.audit$, 11, 1) || '/' || substr(t.audit$, 12, 1),
       substr(t.audit$, 13, 1) || '/' || substr(t.audit$, 14, 1),
       substr(t.audit$, 15, 1) || '/' || substr(t.audit$, 16, 1),
       substr(t.audit$, 17, 1) || '/' || substr(t.audit$, 18, 1),
       substr(t.audit$, 19, 1) || '/' || substr(t.audit$, 20, 1),
       substr(t.audit$, 21, 1) || '/' || substr(t.audit$, 22, 1),
       '-/-',                                            /* dummy REF column */
       substr(t.audit$, 25, 1) || '/' || substr(t.audit$, 26, 1),
       substr(t.audit$, 27, 1) || '/' || substr(t.audit$, 28, 1),
       substr(t.audit$, 29, 1) || '/' || substr(t.audit$, 30, 1),
       substr(t.audit$, 31, 1) || '/' || substr(t.audit$, 32, 1),
       substr(t.audit$, 23, 1) || '/' || substr(t.audit$, 24, 1)
from sys."_CURRENT_EDITION_OBJ" o, sys.type_misc$ t
where o.type# = 13
  and (instrb(t.audit$,'S') != 0  or instrb(t.audit$,'A') != 0)
  and o.owner# = userenv('SCHEMAID')
  and o.obj# = t.obj#
union all
select o.name, 'DIRECTORY',
       substr(t.audit$, 1, 1) || '/' || substr(t.audit$, 2, 1),
       substr(t.audit$, 3, 1) || '/' || substr(t.audit$, 4, 1),
       substr(t.audit$, 5, 1) || '/' || substr(t.audit$, 6, 1),
       substr(t.audit$, 7, 1) || '/' || substr(t.audit$, 8, 1),
       substr(t.audit$, 9, 1) || '/' || substr(t.audit$, 10, 1),
       substr(t.audit$, 11, 1) || '/' || substr(t.audit$, 12, 1),
       substr(t.audit$, 13, 1) || '/' || substr(t.audit$, 14, 1),
       substr(t.audit$, 15, 1) || '/' || substr(t.audit$, 16, 1),
       substr(t.audit$, 17, 1) || '/' || substr(t.audit$, 18, 1),
       substr(t.audit$, 19, 1) || '/' || substr(t.audit$, 20, 1),
       substr(t.audit$, 21, 1) || '/' || substr(t.audit$, 22, 1),
       '-/-',                                            /* dummy REF column */
       substr(t.audit$, 25, 1) || '/' || substr(t.audit$, 26, 1),
       substr(t.audit$, 27, 1) || '/' || substr(t.audit$, 28, 1),
       substr(t.audit$, 35, 1) || '/' || substr(t.audit$, 36, 1),
       substr(t.audit$, 37, 1) || '/' || substr(t.audit$, 38, 1),
       substr(t.audit$, 23, 1) || '/' || substr(t.audit$, 24, 1)
from sys.obj$ o, sys.dir$ t
where o.type# = 23
  and (instrb(t.audit$,'S') != 0  or instrb(t.audit$,'A') != 0)
  and o.owner# = userenv('SCHEMAID')
  and o.obj# = t.obj#
union all
select o.name, 
       decode(o.type#, 28, 'JAVA SOURCE',
                       29, 'JAVA CLASS',
                       30, 'JAVA RESOURCE',
                       'ILLEGAL JAVA TYPE'),
       substr(t.audit$, 1, 1) || '/' || substr(t.audit$, 2, 1),
       substr(t.audit$, 3, 1) || '/' || substr(t.audit$, 4, 1),
       substr(t.audit$, 5, 1) || '/' || substr(t.audit$, 6, 1),
       substr(t.audit$, 7, 1) || '/' || substr(t.audit$, 8, 1),
       substr(t.audit$, 9, 1) || '/' || substr(t.audit$, 10, 1),
       substr(t.audit$, 11, 1) || '/' || substr(t.audit$, 12, 1),
       substr(t.audit$, 13, 1) || '/' || substr(t.audit$, 14, 1),
       substr(t.audit$, 15, 1) || '/' || substr(t.audit$, 16, 1),
       substr(t.audit$, 17, 1) || '/' || substr(t.audit$, 18, 1),
       substr(t.audit$, 19, 1) || '/' || substr(t.audit$, 20, 1),
       substr(t.audit$, 21, 1) || '/' || substr(t.audit$, 22, 1),
       '-/-',                                            /* dummy REF column */
       substr(t.audit$, 25, 1) || '/' || substr(t.audit$, 26, 1),
       substr(t.audit$, 27, 1) || '/' || substr(t.audit$, 28, 1),
       substr(t.audit$, 29, 1) || '/' || substr(t.audit$, 30, 1),
       substr(t.audit$, 31, 1) || '/' || substr(t.audit$, 32, 1),
       substr(t.audit$, 23, 1) || '/' || substr(t.audit$, 24, 1)
from sys.obj$ o, sys.javaobj$ t
where (o.type# = 28 or o.type# = 29 or o.type# = 30)
  and (instrb(t.audit$,'S') != 0  or instrb(t.audit$,'A') != 0)
  and o.owner# = userenv('SCHEMAID')
  and o.obj# = t.obj#
union all
select o.name, 'MINING MODEL',
       substr(t.audit$, 1, 1) || '/' || substr(t.audit$, 2, 1),
       substr(t.audit$, 3, 1) || '/' || substr(t.audit$, 4, 1),
       substr(t.audit$, 5, 1) || '/' || substr(t.audit$, 6, 1),
       substr(t.audit$, 7, 1) || '/' || substr(t.audit$, 8, 1),
       substr(t.audit$, 9, 1) || '/' || substr(t.audit$, 10, 1),
       substr(t.audit$, 11, 1) || '/' || substr(t.audit$, 12, 1),
       substr(t.audit$, 13, 1) || '/' || substr(t.audit$, 14, 1),
       substr(t.audit$, 15, 1) || '/' || substr(t.audit$, 16, 1),
       substr(t.audit$, 17, 1) || '/' || substr(t.audit$, 18, 1),
       substr(t.audit$, 19, 1) || '/' || substr(t.audit$, 20, 1),
       substr(t.audit$, 21, 1) || '/' || substr(t.audit$, 22, 1),
       '-/-',                                            /* dummy REF column */
       substr(t.audit$, 25, 1) || '/' || substr(t.audit$, 26, 1),
       substr(t.audit$, 27, 1) || '/' || substr(t.audit$, 28, 1),
       substr(t.audit$, 29, 1) || '/' || substr(t.audit$, 30, 1),
       substr(t.audit$, 31, 1) || '/' || substr(t.audit$, 32, 1),
       substr(t.audit$, 23, 1) || '/' || substr(t.audit$, 24, 1)
from sys.obj$ o, sys.model$ t
where o.type# = 82
  and (instrb(t.audit$,'S') != 0  or instrb(t.audit$,'A') != 0)
  and o.owner# = userenv('SCHEMAID')
  and o.obj# = t.obj#
union all
select o.name, 'EDITION',
       substr(t.audit$, 1, 1) || '/' || substr(t.audit$, 2, 1),
       substr(t.audit$, 3, 1) || '/' || substr(t.audit$, 4, 1),
       substr(t.audit$, 5, 1) || '/' || substr(t.audit$, 6, 1),
       substr(t.audit$, 7, 1) || '/' || substr(t.audit$, 8, 1),
       substr(t.audit$, 9, 1) || '/' || substr(t.audit$, 10, 1),
       substr(t.audit$, 11, 1) || '/' || substr(t.audit$, 12, 1),
       substr(t.audit$, 13, 1) || '/' || substr(t.audit$, 14, 1),
       substr(t.audit$, 15, 1) || '/' || substr(t.audit$, 16, 1),
       substr(t.audit$, 17, 1) || '/' || substr(t.audit$, 18, 1),
       substr(t.audit$, 19, 1) || '/' || substr(t.audit$, 20, 1),
       substr(t.audit$, 21, 1) || '/' || substr(t.audit$, 22, 1),
       '-/-',                                            /* dummy REF column */
       substr(t.audit$, 25, 1) || '/' || substr(t.audit$, 26, 1),
       substr(t.audit$, 27, 1) || '/' || substr(t.audit$, 28, 1),
       substr(t.audit$, 29, 1) || '/' || substr(t.audit$, 30, 1),
       substr(t.audit$, 31, 1) || '/' || substr(t.audit$, 32, 1),
       substr(t.audit$, 23, 1) || '/' || substr(t.audit$, 24, 1)
from sys.obj$ o, sys.edition$ t
where o.type# = 57
  and (instrb(t.audit$,'S') != 0  or instrb(t.audit$,'A') != 0)
  and o.owner# = userenv('SCHEMAID')
  and o.obj# = t.obj#
union all
select o.name, 'CUBE DIMENSION',
       substr(t.audit$, 1, 1) || '/' || substr(t.audit$, 2, 1),
       substr(t.audit$, 3, 1) || '/' || substr(t.audit$, 4, 1),
       substr(t.audit$, 5, 1) || '/' || substr(t.audit$, 6, 1),
       substr(t.audit$, 7, 1) || '/' || substr(t.audit$, 8, 1),
       substr(t.audit$, 9, 1) || '/' || substr(t.audit$, 10, 1),
       substr(t.audit$, 11, 1) || '/' || substr(t.audit$, 12, 1),
       substr(t.audit$, 13, 1) || '/' || substr(t.audit$, 14, 1),
       substr(t.audit$, 15, 1) || '/' || substr(t.audit$, 16, 1),
       substr(t.audit$, 17, 1) || '/' || substr(t.audit$, 18, 1),
       substr(t.audit$, 19, 1) || '/' || substr(t.audit$, 20, 1),
       substr(t.audit$, 21, 1) || '/' || substr(t.audit$, 22, 1),
       '-/-',                                            /* dummy REF column */
       substr(t.audit$, 25, 1) || '/' || substr(t.audit$, 26, 1),
       substr(t.audit$, 27, 1) || '/' || substr(t.audit$, 28, 1),
       substr(t.audit$, 29, 1) || '/' || substr(t.audit$, 30, 1),
       substr(t.audit$, 31, 1) || '/' || substr(t.audit$, 32, 1),
       substr(t.audit$, 23, 1) || '/' || substr(t.audit$, 24, 1)
from sys.obj$ o, sys.olap_cube_dimensions$ t
where o.type# = 92
  and (instrb(t.audit$,'S') != 0  or instrb(t.audit$,'A') != 0)
  and o.owner# = userenv('SCHEMAID')
  and o.obj# = t.obj#
union all
select o.name, 'CUBE',
       substr(t.audit$, 1, 1) || '/' || substr(t.audit$, 2, 1),
       substr(t.audit$, 3, 1) || '/' || substr(t.audit$, 4, 1),
       substr(t.audit$, 5, 1) || '/' || substr(t.audit$, 6, 1),
       substr(t.audit$, 7, 1) || '/' || substr(t.audit$, 8, 1),
       substr(t.audit$, 9, 1) || '/' || substr(t.audit$, 10, 1),
       substr(t.audit$, 11, 1) || '/' || substr(t.audit$, 12, 1),
       substr(t.audit$, 13, 1) || '/' || substr(t.audit$, 14, 1),
       substr(t.audit$, 15, 1) || '/' || substr(t.audit$, 16, 1),
       substr(t.audit$, 17, 1) || '/' || substr(t.audit$, 18, 1),
       substr(t.audit$, 19, 1) || '/' || substr(t.audit$, 20, 1),
       substr(t.audit$, 21, 1) || '/' || substr(t.audit$, 22, 1),
       '-/-',                                            /* dummy REF column */
       substr(t.audit$, 25, 1) || '/' || substr(t.audit$, 26, 1),
       substr(t.audit$, 27, 1) || '/' || substr(t.audit$, 28, 1),
       substr(t.audit$, 29, 1) || '/' || substr(t.audit$, 30, 1),
       substr(t.audit$, 31, 1) || '/' || substr(t.audit$, 32, 1),
       substr(t.audit$, 23, 1) || '/' || substr(t.audit$, 24, 1)
from sys.obj$ o, sys.olap_cubes$ t
where o.type# = 93
  and (instrb(t.audit$,'S') != 0  or instrb(t.audit$,'A') != 0)
  and o.owner# = userenv('SCHEMAID')
  and o.obj# = t.obj#
union all
select o.name, 'MEASURE FOLDER',
       substr(t.audit$, 1, 1) || '/' || substr(t.audit$, 2, 1),
       substr(t.audit$, 3, 1) || '/' || substr(t.audit$, 4, 1),
       substr(t.audit$, 5, 1) || '/' || substr(t.audit$, 6, 1),
       substr(t.audit$, 7, 1) || '/' || substr(t.audit$, 8, 1),
       substr(t.audit$, 9, 1) || '/' || substr(t.audit$, 10, 1),
       substr(t.audit$, 11, 1) || '/' || substr(t.audit$, 12, 1),
       substr(t.audit$, 13, 1) || '/' || substr(t.audit$, 14, 1),
       substr(t.audit$, 15, 1) || '/' || substr(t.audit$, 16, 1),
       substr(t.audit$, 17, 1) || '/' || substr(t.audit$, 18, 1),
       substr(t.audit$, 19, 1) || '/' || substr(t.audit$, 20, 1),
       substr(t.audit$, 21, 1) || '/' || substr(t.audit$, 22, 1),
       '-/-',                                            /* dummy REF column */
       substr(t.audit$, 25, 1) || '/' || substr(t.audit$, 26, 1),
       substr(t.audit$, 27, 1) || '/' || substr(t.audit$, 28, 1),
       substr(t.audit$, 29, 1) || '/' || substr(t.audit$, 30, 1),
       substr(t.audit$, 31, 1) || '/' || substr(t.audit$, 32, 1),
       substr(t.audit$, 23, 1) || '/' || substr(t.audit$, 24, 1)
from sys.obj$ o, sys.olap_measure_folders$ t
where o.type# = 94
  and (instrb(t.audit$,'S') != 0  or instrb(t.audit$,'A') != 0)
  and o.owner# = userenv('SCHEMAID')
  and o.obj# = t.obj#
union all
select o.name, 'CUBE BUILD PROCESS',
       substr(t.audit$, 1, 1) || '/' || substr(t.audit$, 2, 1),
       substr(t.audit$, 3, 1) || '/' || substr(t.audit$, 4, 1),
       substr(t.audit$, 5, 1) || '/' || substr(t.audit$, 6, 1),
       substr(t.audit$, 7, 1) || '/' || substr(t.audit$, 8, 1),
       substr(t.audit$, 9, 1) || '/' || substr(t.audit$, 10, 1),
       substr(t.audit$, 11, 1) || '/' || substr(t.audit$, 12, 1),
       substr(t.audit$, 13, 1) || '/' || substr(t.audit$, 14, 1),
       substr(t.audit$, 15, 1) || '/' || substr(t.audit$, 16, 1),
       substr(t.audit$, 17, 1) || '/' || substr(t.audit$, 18, 1),
       substr(t.audit$, 19, 1) || '/' || substr(t.audit$, 20, 1),
       substr(t.audit$, 21, 1) || '/' || substr(t.audit$, 22, 1),
       '-/-',                                            /* dummy REF column */
       substr(t.audit$, 25, 1) || '/' || substr(t.audit$, 26, 1),
       substr(t.audit$, 27, 1) || '/' || substr(t.audit$, 28, 1),
       substr(t.audit$, 29, 1) || '/' || substr(t.audit$, 30, 1),
       substr(t.audit$, 31, 1) || '/' || substr(t.audit$, 32, 1),
       substr(t.audit$, 23, 1) || '/' || substr(t.audit$, 24, 1)
from sys.obj$ o, sys.olap_cube_build_processes$ t
where o.type# = 95
  and (instrb(t.audit$,'S') != 0  or instrb(t.audit$,'A') != 0)
  and o.owner# = userenv('SCHEMAID')
  and o.obj# = t.obj#
union all
select o.name, 'SQL TRANSLATION PROFILE',
       substr(t.audit$, 1, 1) || '/' || substr(t.audit$, 2, 1),
       substr(t.audit$, 3, 1) || '/' || substr(t.audit$, 4, 1),
       substr(t.audit$, 5, 1) || '/' || substr(t.audit$, 6, 1),
       substr(t.audit$, 7, 1) || '/' || substr(t.audit$, 8, 1),
       substr(t.audit$, 9, 1) || '/' || substr(t.audit$, 10, 1),
       substr(t.audit$, 11, 1) || '/' || substr(t.audit$, 12, 1),
       substr(t.audit$, 13, 1) || '/' || substr(t.audit$, 14, 1),
       substr(t.audit$, 15, 1) || '/' || substr(t.audit$, 16, 1),
       substr(t.audit$, 17, 1) || '/' || substr(t.audit$, 18, 1),
       substr(t.audit$, 19, 1) || '/' || substr(t.audit$, 20, 1),
       substr(t.audit$, 21, 1) || '/' || substr(t.audit$, 22, 1),
       '-/-',                                            /* dummy REF column */
       substr(t.audit$, 25, 1) || '/' || substr(t.audit$, 26, 1),
       substr(t.audit$, 27, 1) || '/' || substr(t.audit$, 28, 1),
       substr(t.audit$, 29, 1) || '/' || substr(t.audit$, 30, 1),
       substr(t.audit$, 31, 1) || '/' || substr(t.audit$, 32, 1),
       substr(t.audit$, 23, 1) || '/' || substr(t.audit$, 24, 1)
from sys."_CURRENT_EDITION_OBJ" o, sys.sqltxl$ t
where o.type# = 114
  and (instrb(t.audit$,'S') != 0  or instrb(t.audit$,'A') != 0)
  and o.owner# = userenv('SCHEMAID')
  and o.obj# = t.obj#
union all
select o.name, 'ATTRIBUTE DIMENSION',
       substr(t.audit$, 1, 1) || '/' || substr(t.audit$, 2, 1),
       substr(t.audit$, 3, 1) || '/' || substr(t.audit$, 4, 1),
       substr(t.audit$, 5, 1) || '/' || substr(t.audit$, 6, 1),
       substr(t.audit$, 7, 1) || '/' || substr(t.audit$, 8, 1),
       substr(t.audit$, 9, 1) || '/' || substr(t.audit$, 10, 1),
       substr(t.audit$, 11, 1) || '/' || substr(t.audit$, 12, 1),
       substr(t.audit$, 13, 1) || '/' || substr(t.audit$, 14, 1),
       substr(t.audit$, 15, 1) || '/' || substr(t.audit$, 16, 1),
       substr(t.audit$, 17, 1) || '/' || substr(t.audit$, 18, 1),
       substr(t.audit$, 19, 1) || '/' || substr(t.audit$, 20, 1),
       substr(t.audit$, 21, 1) || '/' || substr(t.audit$, 22, 1),
       '-/-',                                            /* dummy REF column */
       substr(t.audit$, 25, 1) || '/' || substr(t.audit$, 26, 1),
       substr(t.audit$, 27, 1) || '/' || substr(t.audit$, 28, 1),
       substr(t.audit$, 29, 1) || '/' || substr(t.audit$, 30, 1),
       substr(t.audit$, 31, 1) || '/' || substr(t.audit$, 32, 1),
       substr(t.audit$, 23, 1) || '/' || substr(t.audit$, 24, 1)
from sys.obj$ o, sys.hcs_dim$ t
where o.type# = 151
  and (instrb(t.audit$,'S') != 0  or instrb(t.audit$,'A') != 0)
  and o.owner# = userenv('SCHEMAID')
  and o.obj# = t.obj#
union all
select o.name, 'HIERARCHY',
       substr(t.audit$, 1, 1) || '/' || substr(t.audit$, 2, 1),
       substr(t.audit$, 3, 1) || '/' || substr(t.audit$, 4, 1),
       substr(t.audit$, 5, 1) || '/' || substr(t.audit$, 6, 1),
       substr(t.audit$, 7, 1) || '/' || substr(t.audit$, 8, 1),
       substr(t.audit$, 9, 1) || '/' || substr(t.audit$, 10, 1),
       substr(t.audit$, 11, 1) || '/' || substr(t.audit$, 12, 1),
       substr(t.audit$, 13, 1) || '/' || substr(t.audit$, 14, 1),
       substr(t.audit$, 15, 1) || '/' || substr(t.audit$, 16, 1),
       substr(t.audit$, 17, 1) || '/' || substr(t.audit$, 18, 1),
       substr(t.audit$, 19, 1) || '/' || substr(t.audit$, 20, 1),
       substr(t.audit$, 21, 1) || '/' || substr(t.audit$, 22, 1),
       '-/-',                                            /* dummy REF column */
       substr(t.audit$, 25, 1) || '/' || substr(t.audit$, 26, 1),
       substr(t.audit$, 27, 1) || '/' || substr(t.audit$, 28, 1),
       substr(t.audit$, 29, 1) || '/' || substr(t.audit$, 30, 1),
       substr(t.audit$, 31, 1) || '/' || substr(t.audit$, 32, 1),
       substr(t.audit$, 23, 1) || '/' || substr(t.audit$, 24, 1)
from sys.obj$ o, sys.hcs_hierarchy$ t
where o.type# = 150
  and (instrb(t.audit$,'S') != 0  or instrb(t.audit$,'A') != 0)
  and o.owner# = userenv('SCHEMAID')
  and o.obj# = t.obj#
union all
select o.name, 'ANALYTIC VIEW',
       substr(t.audit$, 1, 1) || '/' || substr(t.audit$, 2, 1),
       substr(t.audit$, 3, 1) || '/' || substr(t.audit$, 4, 1),
       substr(t.audit$, 5, 1) || '/' || substr(t.audit$, 6, 1),
       substr(t.audit$, 7, 1) || '/' || substr(t.audit$, 8, 1),
       substr(t.audit$, 9, 1) || '/' || substr(t.audit$, 10, 1),
       substr(t.audit$, 11, 1) || '/' || substr(t.audit$, 12, 1),
       substr(t.audit$, 13, 1) || '/' || substr(t.audit$, 14, 1),
       substr(t.audit$, 15, 1) || '/' || substr(t.audit$, 16, 1),
       substr(t.audit$, 17, 1) || '/' || substr(t.audit$, 18, 1),
       substr(t.audit$, 19, 1) || '/' || substr(t.audit$, 20, 1),
       substr(t.audit$, 21, 1) || '/' || substr(t.audit$, 22, 1),
       '-/-',                                            /* dummy REF column */
       substr(t.audit$, 25, 1) || '/' || substr(t.audit$, 26, 1),
       substr(t.audit$, 27, 1) || '/' || substr(t.audit$, 28, 1),
       substr(t.audit$, 29, 1) || '/' || substr(t.audit$, 30, 1),
       substr(t.audit$, 31, 1) || '/' || substr(t.audit$, 32, 1),
       substr(t.audit$, 23, 1) || '/' || substr(t.audit$, 24, 1)
from sys.obj$ o, sys.hcs_analytic_view$ t
where o.type# = 152
  and (instrb(t.audit$,'S') != 0  or instrb(t.audit$,'A') != 0)
  and o.owner# = userenv('SCHEMAID')
  and o.obj# = t.obj#
/
comment on table USER_OBJ_AUDIT_OPTS is
'Auditing options for user''s own tables and views with atleast one option set'
/
comment on column USER_OBJ_AUDIT_OPTS.OBJECT_NAME is
'Name of the object'
/
comment on column USER_OBJ_AUDIT_OPTS.OBJECT_TYPE is
'Type of the object:  "TABLE" or "VIEW"'
/
comment on column USER_OBJ_AUDIT_OPTS.ALT is
'Auditing ALTER WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column USER_OBJ_AUDIT_OPTS.AUD is
'Auditing AUDIT WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column USER_OBJ_AUDIT_OPTS.COM is
'Auditing COMMENT WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column USER_OBJ_AUDIT_OPTS.DEL is
'Auditing DELETE WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column USER_OBJ_AUDIT_OPTS.GRA is
'Auditing GRANT WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column USER_OBJ_AUDIT_OPTS.IND is
'Auditing INDEX WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column USER_OBJ_AUDIT_OPTS.INS is
'Auditing INSERT WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column USER_OBJ_AUDIT_OPTS.LOC is
'Auditing LOCK WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column USER_OBJ_AUDIT_OPTS.REN is
'Auditing RENAME WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column USER_OBJ_AUDIT_OPTS.SEL is
'Auditing SELECT WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column USER_OBJ_AUDIT_OPTS.UPD is
'Auditing UPDATE WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column USER_OBJ_AUDIT_OPTS.REF is
'Dummy REF column. Maintained for backward compatibility of the view'
/
comment on column USER_OBJ_AUDIT_OPTS.EXE is
'Auditing EXECUTE WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column USER_OBJ_AUDIT_OPTS.CRE is
'Auditing CREATE WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column USER_OBJ_AUDIT_OPTS.REA is
'Auditing READ WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column USER_OBJ_AUDIT_OPTS.WRI is
'Auditing WRITE WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column USER_OBJ_AUDIT_OPTS.EXE is
'Auditing EXECUTE WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column USER_OBJ_AUDIT_OPTS.FBK is
'Auditing FLASHBACK WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
create or replace public synonym USER_OBJ_AUDIT_OPTS for USER_OBJ_AUDIT_OPTS
/
grant read on USER_OBJ_AUDIT_OPTS to PUBLIC
/
create or replace view DBA_OBJ_AUDIT_OPTS 
        (OWNER,
         OBJECT_NAME, 
         OBJECT_TYPE, 
         ALT,
         AUD,
         COM,
         DEL,
         GRA,
         IND,
         INS,
         LOC,
         REN,
         SEL,
         UPD,
         REF,
         EXE,
         CRE,
         REA,
         WRI,
         FBK)
as
select u.name, o.name, 'TABLE',
       substr(t.audit$, 1, 1) || '/' || substr(t.audit$, 2, 1),
       substr(t.audit$, 3, 1) || '/' || substr(t.audit$, 4, 1),
       substr(t.audit$, 5, 1) || '/' || substr(t.audit$, 6, 1),
       substr(t.audit$, 7, 1) || '/' || substr(t.audit$, 8, 1),
       substr(t.audit$, 9, 1) || '/' || substr(t.audit$, 10, 1),
       substr(t.audit$, 11, 1) || '/' || substr(t.audit$, 12, 1),
       substr(t.audit$, 13, 1) || '/' || substr(t.audit$, 14, 1),
       substr(t.audit$, 15, 1) || '/' || substr(t.audit$, 16, 1),
       substr(t.audit$, 17, 1) || '/' || substr(t.audit$, 18, 1),
       substr(t.audit$, 19, 1) || '/' || substr(t.audit$, 20, 1),
       substr(t.audit$, 21, 1) || '/' || substr(t.audit$, 22, 1),
       '-/-',                                            /* dummy REF column */
       substr(t.audit$, 25, 1) || '/' || substr(t.audit$, 26, 1),
       substr(t.audit$, 27, 1) || '/' || substr(t.audit$, 28, 1),
       substr(t.audit$, 29, 1) || '/' || substr(t.audit$, 30, 1),
       substr(t.audit$, 31, 1) || '/' || substr(t.audit$, 32, 1),
       substr(t.audit$, 23, 1) || '/' || substr(t.audit$, 24, 1)
from sys.obj$ o, sys.user$ u, sys.tab$ t
where o.type# = 2
  and not (o.owner# = 0 and o.name = '_default_auditing_options_')
  and (instrb(t.audit$,'S') != 0  or instrb(t.audit$,'A') != 0)
  and o.owner# = u.user#
  and o.obj# = t.obj#
union all
select u.name, o.name, 'VIEW',
       substr(v.audit$, 1, 1) || '/' || substr(v.audit$, 2, 1),
       substr(v.audit$, 3, 1) || '/' || substr(v.audit$, 4, 1),
       substr(v.audit$, 5, 1) || '/' || substr(v.audit$, 6, 1),
       substr(v.audit$, 7, 1) || '/' || substr(v.audit$, 8, 1),
       substr(v.audit$, 9, 1) || '/' || substr(v.audit$, 10, 1),
       substr(v.audit$, 11, 1) || '/' || substr(v.audit$, 12, 1),
       substr(v.audit$, 13, 1) || '/' || substr(v.audit$, 14, 1),
       substr(v.audit$, 15, 1) || '/' || substr(v.audit$, 16, 1),
       substr(v.audit$, 17, 1) || '/' || substr(v.audit$, 18, 1),
       substr(v.audit$, 19, 1) || '/' || substr(v.audit$, 20, 1),
       substr(v.audit$, 21, 1) || '/' || substr(v.audit$, 22, 1),
       '-/-',                                            /* dummy REF column */
       substr(v.audit$, 25, 1) || '/' || substr(v.audit$, 26, 1),
       substr(v.audit$, 27, 1) || '/' || substr(v.audit$, 28, 1),
       substr(v.audit$, 29, 1) || '/' || substr(v.audit$, 30, 1),
       substr(v.audit$, 31, 1) || '/' || substr(v.audit$, 32, 1),
       substr(v.audit$, 23, 1) || '/' || substr(v.audit$, 24, 1)
from sys."_CURRENT_EDITION_OBJ" o, sys.user$ u, sys.view$ v
where o.type# = 4
  and o.owner# = u.user#
  and (instrb(v.audit$,'S') != 0  or instrb(v.audit$,'A') != 0)
  and o.obj# = v.obj#
union all
select u.name, o.name, 'SEQUENCE',
       substr(s.audit$, 1, 1) || '/' || substr(s.audit$, 2, 1),
       substr(s.audit$, 3, 1) || '/' || substr(s.audit$, 4, 1),
       substr(s.audit$, 5, 1) || '/' || substr(s.audit$, 6, 1),
       substr(s.audit$, 7, 1) || '/' || substr(s.audit$, 8, 1),
       substr(s.audit$, 9, 1) || '/' || substr(s.audit$, 10, 1),
       substr(s.audit$, 11, 1) || '/' || substr(s.audit$, 12, 1),
       substr(s.audit$, 13, 1) || '/' || substr(s.audit$, 14, 1),
       substr(s.audit$, 15, 1) || '/' || substr(s.audit$, 16, 1),
       substr(s.audit$, 17, 1) || '/' || substr(s.audit$, 18, 1),
       substr(s.audit$, 19, 1) || '/' || substr(s.audit$, 20, 1),
       substr(s.audit$, 21, 1) || '/' || substr(s.audit$, 22, 1),
       '-/-',                                            /* dummy REF column */
       substr(s.audit$, 25, 1) || '/' || substr(s.audit$, 26, 1),
       substr(s.audit$, 27, 1) || '/' || substr(s.audit$, 28, 1),
       substr(s.audit$, 29, 1) || '/' || substr(s.audit$, 30, 1),
       substr(s.audit$, 31, 1) || '/' || substr(s.audit$, 32, 1),
       substr(s.audit$, 23, 1) || '/' || substr(s.audit$, 24, 1)
from sys.obj$ o, sys.user$ u, sys.seq$ s
where o.type# = 6
  and o.owner# = u.user#
  and (instrb(s.audit$,'S') != 0  or instrb(s.audit$,'A') != 0)
  and o.obj# = s.obj#
union all
select u.name, o.name, 'PROCEDURE',
       substr(p.audit$, 1, 1) || '/' || substr(p.audit$, 2, 1),
       substr(p.audit$, 3, 1) || '/' || substr(p.audit$, 4, 1),
       substr(p.audit$, 5, 1) || '/' || substr(p.audit$, 6, 1),
       substr(p.audit$, 7, 1) || '/' || substr(p.audit$, 8, 1),
       substr(p.audit$, 9, 1) || '/' || substr(p.audit$, 10, 1),
       substr(p.audit$, 11, 1) || '/' || substr(p.audit$, 12, 1),
       substr(p.audit$, 13, 1) || '/' || substr(p.audit$, 14, 1),
       substr(p.audit$, 15, 1) || '/' || substr(p.audit$, 16, 1),
       substr(p.audit$, 17, 1) || '/' || substr(p.audit$, 18, 1),
       substr(p.audit$, 19, 1) || '/' || substr(p.audit$, 20, 1),
       substr(p.audit$, 21, 1) || '/' || substr(p.audit$, 22, 1),
       '-/-',                                            /* dummy REF column */
       substr(p.audit$, 25, 1) || '/' || substr(p.audit$, 26, 1),
       substr(p.audit$, 27, 1) || '/' || substr(p.audit$, 28, 1),
       substr(p.audit$, 29, 1) || '/' || substr(p.audit$, 30, 1),
       substr(p.audit$, 31, 1) || '/' || substr(p.audit$, 32, 1),
       substr(p.audit$, 23, 1) || '/' || substr(p.audit$, 24, 1)
from sys."_CURRENT_EDITION_OBJ" o, sys.user$ u, sys.library$ p
where o.type# = 22
  and o.owner# = u.user#
  and (instrb(p.audit$,'S') != 0  or instrb(p.audit$,'A') != 0)
  and o.obj# = p.obj#
union all
select u.name, o.name, 'PROCEDURE',
       substr(p.audit$, 1, 1) || '/' || substr(p.audit$, 2, 1),
       substr(p.audit$, 3, 1) || '/' || substr(p.audit$, 4, 1),
       substr(p.audit$, 5, 1) || '/' || substr(p.audit$, 6, 1),
       substr(p.audit$, 7, 1) || '/' || substr(p.audit$, 8, 1),
       substr(p.audit$, 9, 1) || '/' || substr(p.audit$, 10, 1),
       substr(p.audit$, 11, 1) || '/' || substr(p.audit$, 12, 1),
       substr(p.audit$, 13, 1) || '/' || substr(p.audit$, 14, 1),
       substr(p.audit$, 15, 1) || '/' || substr(p.audit$, 16, 1),
       substr(p.audit$, 17, 1) || '/' || substr(p.audit$, 18, 1),
       substr(p.audit$, 19, 1) || '/' || substr(p.audit$, 20, 1),
       substr(p.audit$, 21, 1) || '/' || substr(p.audit$, 22, 1),
       '-/-',                                            /* dummy REF column */
       substr(p.audit$, 25, 1) || '/' || substr(p.audit$, 26, 1),
       substr(p.audit$, 27, 1) || '/' || substr(p.audit$, 28, 1),
       substr(p.audit$, 29, 1) || '/' || substr(p.audit$, 30, 1),
       substr(p.audit$, 31, 1) || '/' || substr(p.audit$, 32, 1),
       substr(p.audit$, 23, 1) || '/' || substr(p.audit$, 24, 1)
from sys."_CURRENT_EDITION_OBJ" o, sys.user$ u, sys.procedure$ p
where o.type# >= 7 and o.type# <= 9
  and o.owner# = u.user#
  and (instrb(p.audit$,'S') != 0  or instrb(p.audit$,'A') != 0)
  and o.obj# = p.obj#
union all
select u.name, o.name, 'TYPE',
       substr(t.audit$, 1, 1) || '/' || substr(t.audit$, 2, 1),
       substr(t.audit$, 3, 1) || '/' || substr(t.audit$, 4, 1),
       substr(t.audit$, 5, 1) || '/' || substr(t.audit$, 6, 1),
       substr(t.audit$, 7, 1) || '/' || substr(t.audit$, 8, 1),
       substr(t.audit$, 9, 1) || '/' || substr(t.audit$, 10, 1),
       substr(t.audit$, 11, 1) || '/' || substr(t.audit$, 12, 1),
       substr(t.audit$, 13, 1) || '/' || substr(t.audit$, 14, 1),
       substr(t.audit$, 15, 1) || '/' || substr(t.audit$, 16, 1),
       substr(t.audit$, 17, 1) || '/' || substr(t.audit$, 18, 1),
       substr(t.audit$, 19, 1) || '/' || substr(t.audit$, 20, 1),
       substr(t.audit$, 21, 1) || '/' || substr(t.audit$, 22, 1),
       '-/-',                                            /* dummy REF column */
       substr(t.audit$, 25, 1) || '/' || substr(t.audit$, 26, 1),
       substr(t.audit$, 27, 1) || '/' || substr(t.audit$, 28, 1),
       substr(t.audit$, 29, 1) || '/' || substr(t.audit$, 30, 1),
       substr(t.audit$, 31, 1) || '/' || substr(t.audit$, 32, 1),
       substr(t.audit$, 23, 1) || '/' || substr(t.audit$, 24, 1)
from sys."_CURRENT_EDITION_OBJ" o, sys.user$ u, sys.type_misc$ t
where o.type# = 13
  and o.owner# = u.user#
  and (instrb(t.audit$,'S') != 0  or instrb(t.audit$,'A') != 0)
  and o.obj# = t.obj#
union all
select u.name, o.name, 'DIRECTORY',
       substr(t.audit$, 1, 1) || '/' || substr(t.audit$, 2, 1),
       substr(t.audit$, 3, 1) || '/' || substr(t.audit$, 4, 1),
       substr(t.audit$, 5, 1) || '/' || substr(t.audit$, 6, 1),
       substr(t.audit$, 7, 1) || '/' || substr(t.audit$, 8, 1),
       substr(t.audit$, 9, 1) || '/' || substr(t.audit$, 10, 1),
       substr(t.audit$, 11, 1) || '/' || substr(t.audit$, 12, 1),
       substr(t.audit$, 13, 1) || '/' || substr(t.audit$, 14, 1),
       substr(t.audit$, 15, 1) || '/' || substr(t.audit$, 16, 1),
       substr(t.audit$, 17, 1) || '/' || substr(t.audit$, 18, 1),
       substr(t.audit$, 19, 1) || '/' || substr(t.audit$, 20, 1),
       substr(t.audit$, 21, 1) || '/' || substr(t.audit$, 22, 1),
       '-/-',                                            /* dummy REF column */
       substr(t.audit$, 25, 1) || '/' || substr(t.audit$, 26, 1),
       substr(t.audit$, 27, 1) || '/' || substr(t.audit$, 28, 1),
       substr(t.audit$, 35, 1) || '/' || substr(t.audit$, 36, 1),
       substr(t.audit$, 37, 1) || '/' || substr(t.audit$, 38, 1),
       substr(t.audit$, 23, 1) || '/' || substr(t.audit$, 24, 1)
from sys.obj$ o, sys.user$ u, sys.dir$ t
where o.type# = 23
  and (instrb(t.audit$,'S') != 0  or instrb(t.audit$,'A') != 0)
  and o.owner# = u.user#
  and o.obj# = t.obj#
union all
select u.name, o.name, 
       decode(o.type#, 28, 'JAVA SOURCE',
                       29, 'JAVA CLASS',
                       30, 'JAVA RESOURCE',
                       'ILLEGAL JAVA TYPE'),
       substr(t.audit$, 1, 1) || '/' || substr(t.audit$, 2, 1),
       substr(t.audit$, 3, 1) || '/' || substr(t.audit$, 4, 1),
       substr(t.audit$, 5, 1) || '/' || substr(t.audit$, 6, 1),
       substr(t.audit$, 7, 1) || '/' || substr(t.audit$, 8, 1),
       substr(t.audit$, 9, 1) || '/' || substr(t.audit$, 10, 1),
       substr(t.audit$, 11, 1) || '/' || substr(t.audit$, 12, 1),
       substr(t.audit$, 13, 1) || '/' || substr(t.audit$, 14, 1),
       substr(t.audit$, 15, 1) || '/' || substr(t.audit$, 16, 1),
       substr(t.audit$, 17, 1) || '/' || substr(t.audit$, 18, 1),
       substr(t.audit$, 19, 1) || '/' || substr(t.audit$, 20, 1),
       substr(t.audit$, 21, 1) || '/' || substr(t.audit$, 22, 1),
       '-/-',                                            /* dummy REF column */
       substr(t.audit$, 25, 1) || '/' || substr(t.audit$, 26, 1),
       substr(t.audit$, 27, 1) || '/' || substr(t.audit$, 28, 1),
       substr(t.audit$, 29, 1) || '/' || substr(t.audit$, 30, 1),
       substr(t.audit$, 31, 1) || '/' || substr(t.audit$, 32, 1),
       substr(t.audit$, 23, 1) || '/' || substr(t.audit$, 24, 1)
from sys.obj$ o, sys.user$ u, sys.javaobj$ t
where (o.type# = 28 or o.type# = 29 or o.type# = 30)
  and o.owner# = u.user#
  and (instrb(t.audit$,'S') != 0  or instrb(t.audit$,'A') != 0)
  and o.obj# = t.obj#
union all
select u.name, o.name, 'MINING MODEL',
       substr(t.audit$, 1, 1) || '/' || substr(t.audit$, 2, 1),
       substr(t.audit$, 3, 1) || '/' || substr(t.audit$, 4, 1),
       substr(t.audit$, 5, 1) || '/' || substr(t.audit$, 6, 1),
       substr(t.audit$, 7, 1) || '/' || substr(t.audit$, 8, 1),
       substr(t.audit$, 9, 1) || '/' || substr(t.audit$, 10, 1),
       substr(t.audit$, 11, 1) || '/' || substr(t.audit$, 12, 1),
       substr(t.audit$, 13, 1) || '/' || substr(t.audit$, 14, 1),
       substr(t.audit$, 15, 1) || '/' || substr(t.audit$, 16, 1),
       substr(t.audit$, 17, 1) || '/' || substr(t.audit$, 18, 1),
       substr(t.audit$, 19, 1) || '/' || substr(t.audit$, 20, 1),
       substr(t.audit$, 21, 1) || '/' || substr(t.audit$, 22, 1),
       '-/-',                                            /* dummy REF column */
       substr(t.audit$, 25, 1) || '/' || substr(t.audit$, 26, 1),
       substr(t.audit$, 27, 1) || '/' || substr(t.audit$, 28, 1),
       substr(t.audit$, 29, 1) || '/' || substr(t.audit$, 30, 1),
       substr(t.audit$, 31, 1) || '/' || substr(t.audit$, 32, 1),
       substr(t.audit$, 23, 1) || '/' || substr(t.audit$, 24, 1)
from sys.obj$ o, sys.user$ u, sys.model$ t
where o.type# = 82
  and (instrb(t.audit$,'S') != 0  or instrb(t.audit$,'A') != 0)
  and o.owner# = u.user#
  and o.obj# = t.obj#
union all
select u.name, o.name, 'EDITION',
       substr(e.audit$, 1, 1) || '/' || substr(e.audit$, 2, 1),
       substr(e.audit$, 3, 1) || '/' || substr(e.audit$, 4, 1),
       substr(e.audit$, 5, 1) || '/' || substr(e.audit$, 6, 1),
       substr(e.audit$, 7, 1) || '/' || substr(e.audit$, 8, 1),
       substr(e.audit$, 9, 1) || '/' || substr(e.audit$, 10, 1),
       substr(e.audit$, 11, 1) || '/' || substr(e.audit$, 12, 1),
       substr(e.audit$, 13, 1) || '/' || substr(e.audit$, 14, 1),
       substr(e.audit$, 15, 1) || '/' || substr(e.audit$, 16, 1),
       substr(e.audit$, 17, 1) || '/' || substr(e.audit$, 18, 1),
       substr(e.audit$, 19, 1) || '/' || substr(e.audit$, 20, 1),
       substr(e.audit$, 21, 1) || '/' || substr(e.audit$, 22, 1),
       '-/-',                                            /* dummy REF column */
       substr(e.audit$, 25, 1) || '/' || substr(e.audit$, 26, 1),
       substr(e.audit$, 27, 1) || '/' || substr(e.audit$, 28, 1),
       substr(e.audit$, 29, 1) || '/' || substr(e.audit$, 30, 1),
       substr(e.audit$, 31, 1) || '/' || substr(e.audit$, 32, 1),
       substr(e.audit$, 23, 1) || '/' || substr(e.audit$, 24, 1)
from sys.obj$ o, sys.user$ u, sys.edition$ e
where o.type# = 57
  and o.owner# = u.user#
  and (instrb(e.audit$,'S') != 0  or instrb(e.audit$,'A') != 0)
  and o.obj# = e.obj#
union all
select u.name, o.name, 'CUBE DIMENSION',
       substr(t.audit$, 1, 1) || '/' || substr(t.audit$, 2, 1),
       substr(t.audit$, 3, 1) || '/' || substr(t.audit$, 4, 1),
       substr(t.audit$, 5, 1) || '/' || substr(t.audit$, 6, 1),
       substr(t.audit$, 7, 1) || '/' || substr(t.audit$, 8, 1),
       substr(t.audit$, 9, 1) || '/' || substr(t.audit$, 10, 1),
       substr(t.audit$, 11, 1) || '/' || substr(t.audit$, 12, 1),
       substr(t.audit$, 13, 1) || '/' || substr(t.audit$, 14, 1),
       substr(t.audit$, 15, 1) || '/' || substr(t.audit$, 16, 1),
       substr(t.audit$, 17, 1) || '/' || substr(t.audit$, 18, 1),
       substr(t.audit$, 19, 1) || '/' || substr(t.audit$, 20, 1),
       substr(t.audit$, 21, 1) || '/' || substr(t.audit$, 22, 1),
       '-/-',                                            /* dummy REF column */
       substr(t.audit$, 25, 1) || '/' || substr(t.audit$, 26, 1),
       substr(t.audit$, 27, 1) || '/' || substr(t.audit$, 28, 1),
       substr(t.audit$, 29, 1) || '/' || substr(t.audit$, 30, 1),
       substr(t.audit$, 31, 1) || '/' || substr(t.audit$, 32, 1),
       substr(t.audit$, 23, 1) || '/' || substr(t.audit$, 24, 1)
from sys.obj$ o, sys.user$ u, sys.olap_cube_dimensions$ t
where o.type# = 92
  and o.owner# = u.user#
  and (instrb(t.audit$,'S') != 0  or instrb(t.audit$,'A') != 0)
  and o.obj# = t.obj#
union all
select u.name, o.name, 'CUBE',
       substr(t.audit$, 1, 1) || '/' || substr(t.audit$, 2, 1),
       substr(t.audit$, 3, 1) || '/' || substr(t.audit$, 4, 1),
       substr(t.audit$, 5, 1) || '/' || substr(t.audit$, 6, 1),
       substr(t.audit$, 7, 1) || '/' || substr(t.audit$, 8, 1),
       substr(t.audit$, 9, 1) || '/' || substr(t.audit$, 10, 1),
       substr(t.audit$, 11, 1) || '/' || substr(t.audit$, 12, 1),
       substr(t.audit$, 13, 1) || '/' || substr(t.audit$, 14, 1),
       substr(t.audit$, 15, 1) || '/' || substr(t.audit$, 16, 1),
       substr(t.audit$, 17, 1) || '/' || substr(t.audit$, 18, 1),
       substr(t.audit$, 19, 1) || '/' || substr(t.audit$, 20, 1),
       substr(t.audit$, 21, 1) || '/' || substr(t.audit$, 22, 1),
       '-/-',                                            /* dummy REF column */
       substr(t.audit$, 25, 1) || '/' || substr(t.audit$, 26, 1),
       substr(t.audit$, 27, 1) || '/' || substr(t.audit$, 28, 1),
       substr(t.audit$, 29, 1) || '/' || substr(t.audit$, 30, 1),
       substr(t.audit$, 31, 1) || '/' || substr(t.audit$, 32, 1),
       substr(t.audit$, 23, 1) || '/' || substr(t.audit$, 24, 1)
from sys.obj$ o, sys.user$ u, sys.olap_cubes$ t
where o.type# = 93
  and o.owner# = u.user#
  and (instrb(t.audit$,'S') != 0  or instrb(t.audit$,'A') != 0)
  and o.obj# = t.obj#
union all
select u.name, o.name, 'MEASURE FOLDER',
       substr(t.audit$, 1, 1) || '/' || substr(t.audit$, 2, 1),
       substr(t.audit$, 3, 1) || '/' || substr(t.audit$, 4, 1),
       substr(t.audit$, 5, 1) || '/' || substr(t.audit$, 6, 1),
       substr(t.audit$, 7, 1) || '/' || substr(t.audit$, 8, 1),
       substr(t.audit$, 9, 1) || '/' || substr(t.audit$, 10, 1),
       substr(t.audit$, 11, 1) || '/' || substr(t.audit$, 12, 1),
       substr(t.audit$, 13, 1) || '/' || substr(t.audit$, 14, 1),
       substr(t.audit$, 15, 1) || '/' || substr(t.audit$, 16, 1),
       substr(t.audit$, 17, 1) || '/' || substr(t.audit$, 18, 1),
       substr(t.audit$, 19, 1) || '/' || substr(t.audit$, 20, 1),
       substr(t.audit$, 21, 1) || '/' || substr(t.audit$, 22, 1),
       '-/-',                                            /* dummy REF column */
       substr(t.audit$, 25, 1) || '/' || substr(t.audit$, 26, 1),
       substr(t.audit$, 27, 1) || '/' || substr(t.audit$, 28, 1),
       substr(t.audit$, 29, 1) || '/' || substr(t.audit$, 30, 1),
       substr(t.audit$, 31, 1) || '/' || substr(t.audit$, 32, 1),
       substr(t.audit$, 23, 1) || '/' || substr(t.audit$, 24, 1)
from sys.obj$ o, sys.user$ u, sys.olap_measure_folders$ t
where o.type# = 94
  and o.owner# = u.user#
  and (instrb(t.audit$,'S') != 0  or instrb(t.audit$,'A') != 0)
  and o.obj# = t.obj#
union all
select u.name, o.name, 'CUBE BUILD PROCESS',
       substr(t.audit$, 1, 1) || '/' || substr(t.audit$, 2, 1),
       substr(t.audit$, 3, 1) || '/' || substr(t.audit$, 4, 1),
       substr(t.audit$, 5, 1) || '/' || substr(t.audit$, 6, 1),
       substr(t.audit$, 7, 1) || '/' || substr(t.audit$, 8, 1),
       substr(t.audit$, 9, 1) || '/' || substr(t.audit$, 10, 1),
       substr(t.audit$, 11, 1) || '/' || substr(t.audit$, 12, 1),
       substr(t.audit$, 13, 1) || '/' || substr(t.audit$, 14, 1),
       substr(t.audit$, 15, 1) || '/' || substr(t.audit$, 16, 1),
       substr(t.audit$, 17, 1) || '/' || substr(t.audit$, 18, 1),
       substr(t.audit$, 19, 1) || '/' || substr(t.audit$, 20, 1),
       substr(t.audit$, 21, 1) || '/' || substr(t.audit$, 22, 1),
       '-/-',                                            /* dummy REF column */
       substr(t.audit$, 25, 1) || '/' || substr(t.audit$, 26, 1),
       substr(t.audit$, 27, 1) || '/' || substr(t.audit$, 28, 1),
       substr(t.audit$, 29, 1) || '/' || substr(t.audit$, 30, 1),
       substr(t.audit$, 31, 1) || '/' || substr(t.audit$, 32, 1),
       substr(t.audit$, 23, 1) || '/' || substr(t.audit$, 24, 1)
from sys.obj$ o, sys.user$ u, sys.olap_cube_build_processes$ t
where o.type# = 95
  and o.owner# = u.user#
  and (instrb(t.audit$,'S') != 0  or instrb(t.audit$,'A') != 0)
  and o.obj# = t.obj#
union all
select u.name, o.name, 'SQL TRANSLATION PROFILE',
       substr(t.audit$, 1, 1) || '/' || substr(t.audit$, 2, 1),
       substr(t.audit$, 3, 1) || '/' || substr(t.audit$, 4, 1),
       substr(t.audit$, 5, 1) || '/' || substr(t.audit$, 6, 1),
       substr(t.audit$, 7, 1) || '/' || substr(t.audit$, 8, 1),
       substr(t.audit$, 9, 1) || '/' || substr(t.audit$, 10, 1),
       substr(t.audit$, 11, 1) || '/' || substr(t.audit$, 12, 1),
       substr(t.audit$, 13, 1) || '/' || substr(t.audit$, 14, 1),
       substr(t.audit$, 15, 1) || '/' || substr(t.audit$, 16, 1),
       substr(t.audit$, 17, 1) || '/' || substr(t.audit$, 18, 1),
       substr(t.audit$, 19, 1) || '/' || substr(t.audit$, 20, 1),
       substr(t.audit$, 21, 1) || '/' || substr(t.audit$, 22, 1),
       '-/-',                                            /* dummy REF column */
       substr(t.audit$, 25, 1) || '/' || substr(t.audit$, 26, 1),
       substr(t.audit$, 27, 1) || '/' || substr(t.audit$, 28, 1),
       substr(t.audit$, 29, 1) || '/' || substr(t.audit$, 30, 1),
       substr(t.audit$, 31, 1) || '/' || substr(t.audit$, 32, 1),
       substr(t.audit$, 23, 1) || '/' || substr(t.audit$, 24, 1)
from sys."_CURRENT_EDITION_OBJ" o, sys.user$ u, sys.sqltxl$ t
where o.type# = 114
  and o.owner# = u.user#
  and (instrb(t.audit$,'S') != 0  or instrb(t.audit$,'A') != 0)
  and o.obj# = t.obj#
union all
select u.name, o.name, 'ATTRIBUTE DIMENSION',
       substr(t.audit$, 1, 1) || '/' || substr(t.audit$, 2, 1),
       substr(t.audit$, 3, 1) || '/' || substr(t.audit$, 4, 1),
       substr(t.audit$, 5, 1) || '/' || substr(t.audit$, 6, 1),
       substr(t.audit$, 7, 1) || '/' || substr(t.audit$, 8, 1),
       substr(t.audit$, 9, 1) || '/' || substr(t.audit$, 10, 1),
       substr(t.audit$, 11, 1) || '/' || substr(t.audit$, 12, 1),
       substr(t.audit$, 13, 1) || '/' || substr(t.audit$, 14, 1),
       substr(t.audit$, 15, 1) || '/' || substr(t.audit$, 16, 1),
       substr(t.audit$, 17, 1) || '/' || substr(t.audit$, 18, 1),
       substr(t.audit$, 19, 1) || '/' || substr(t.audit$, 20, 1),
       substr(t.audit$, 21, 1) || '/' || substr(t.audit$, 22, 1),
       '-/-',                                            /* dummy REF column */
       substr(t.audit$, 25, 1) || '/' || substr(t.audit$, 26, 1),
       substr(t.audit$, 27, 1) || '/' || substr(t.audit$, 28, 1),
       substr(t.audit$, 29, 1) || '/' || substr(t.audit$, 30, 1),
       substr(t.audit$, 31, 1) || '/' || substr(t.audit$, 32, 1),
       substr(t.audit$, 23, 1) || '/' || substr(t.audit$, 24, 1)
from sys.obj$ o, sys.user$ u, sys.hcs_dim$ t
where o.type# = 151
  and o.owner# = u.user#
  and (instrb(t.audit$,'S') != 0  or instrb(t.audit$,'A') != 0)
  and o.obj# = t.obj#
union all
select u.name, o.name, 'HIERARCHY',
       substr(t.audit$, 1, 1) || '/' || substr(t.audit$, 2, 1),
       substr(t.audit$, 3, 1) || '/' || substr(t.audit$, 4, 1),
       substr(t.audit$, 5, 1) || '/' || substr(t.audit$, 6, 1),
       substr(t.audit$, 7, 1) || '/' || substr(t.audit$, 8, 1),
       substr(t.audit$, 9, 1) || '/' || substr(t.audit$, 10, 1),
       substr(t.audit$, 11, 1) || '/' || substr(t.audit$, 12, 1),
       substr(t.audit$, 13, 1) || '/' || substr(t.audit$, 14, 1),
       substr(t.audit$, 15, 1) || '/' || substr(t.audit$, 16, 1),
       substr(t.audit$, 17, 1) || '/' || substr(t.audit$, 18, 1),
       substr(t.audit$, 19, 1) || '/' || substr(t.audit$, 20, 1),
       substr(t.audit$, 21, 1) || '/' || substr(t.audit$, 22, 1),
       '-/-',                                            /* dummy REF column */
       substr(t.audit$, 25, 1) || '/' || substr(t.audit$, 26, 1),
       substr(t.audit$, 27, 1) || '/' || substr(t.audit$, 28, 1),
       substr(t.audit$, 29, 1) || '/' || substr(t.audit$, 30, 1),
       substr(t.audit$, 31, 1) || '/' || substr(t.audit$, 32, 1),
       substr(t.audit$, 23, 1) || '/' || substr(t.audit$, 24, 1)
from sys.obj$ o, sys.user$ u, sys.hcs_hierarchy$ t
where o.type# = 150
  and o.owner# = u.user#
  and (instrb(t.audit$,'S') != 0  or instrb(t.audit$,'A') != 0)
  and o.obj# = t.obj#
union all
select u.name, o.name, 'ANALYTIC VIEW',
       substr(t.audit$, 1, 1) || '/' || substr(t.audit$, 2, 1),
       substr(t.audit$, 3, 1) || '/' || substr(t.audit$, 4, 1),
       substr(t.audit$, 5, 1) || '/' || substr(t.audit$, 6, 1),
       substr(t.audit$, 7, 1) || '/' || substr(t.audit$, 8, 1),
       substr(t.audit$, 9, 1) || '/' || substr(t.audit$, 10, 1),
       substr(t.audit$, 11, 1) || '/' || substr(t.audit$, 12, 1),
       substr(t.audit$, 13, 1) || '/' || substr(t.audit$, 14, 1),
       substr(t.audit$, 15, 1) || '/' || substr(t.audit$, 16, 1),
       substr(t.audit$, 17, 1) || '/' || substr(t.audit$, 18, 1),
       substr(t.audit$, 19, 1) || '/' || substr(t.audit$, 20, 1),
       substr(t.audit$, 21, 1) || '/' || substr(t.audit$, 22, 1),
       '-/-',                                            /* dummy REF column */
       substr(t.audit$, 25, 1) || '/' || substr(t.audit$, 26, 1),
       substr(t.audit$, 27, 1) || '/' || substr(t.audit$, 28, 1),
       substr(t.audit$, 29, 1) || '/' || substr(t.audit$, 30, 1),
       substr(t.audit$, 31, 1) || '/' || substr(t.audit$, 32, 1),
       substr(t.audit$, 23, 1) || '/' || substr(t.audit$, 24, 1)
from sys.obj$ o, sys.user$ u, sys.hcs_analytic_view$ t
where o.type# = 152
  and o.owner# = u.user#
  and (instrb(t.audit$,'S') != 0  or instrb(t.audit$,'A') != 0)
  and o.obj# = t.obj#
/
create or replace public synonym DBA_OBJ_AUDIT_OPTS for DBA_OBJ_AUDIT_OPTS
/
grant select on DBA_OBJ_AUDIT_OPTS to select_catalog_role
/
comment on table DBA_OBJ_AUDIT_OPTS is
'Auditing options for all tables and views with atleast one option set'
/
comment on column DBA_OBJ_AUDIT_OPTS.OWNER is
'Owner of the object'
/
comment on column DBA_OBJ_AUDIT_OPTS.OBJECT_NAME is
'Name of the object'
/
comment on column DBA_OBJ_AUDIT_OPTS.OBJECT_TYPE is
'Type of the object'
/
comment on column DBA_OBJ_AUDIT_OPTS.ALT is
'Auditing ALTER WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column DBA_OBJ_AUDIT_OPTS.AUD is
'Auditing AUDIT WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column DBA_OBJ_AUDIT_OPTS.COM is
'Auditing COMMENT WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column DBA_OBJ_AUDIT_OPTS.DEL is
'Auditing DELETE WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column DBA_OBJ_AUDIT_OPTS.GRA is
'Auditing GRANT WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column DBA_OBJ_AUDIT_OPTS.IND is
'Auditing INDEX WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column DBA_OBJ_AUDIT_OPTS.INS is
'Auditing INSERT WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column DBA_OBJ_AUDIT_OPTS.LOC is
'Auditing LOCK WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column DBA_OBJ_AUDIT_OPTS.REN is
'Auditing RENAME WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column DBA_OBJ_AUDIT_OPTS.SEL is
'Auditing SELECT WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column DBA_OBJ_AUDIT_OPTS.UPD is
'Auditing UPDATE WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column DBA_OBJ_AUDIT_OPTS.REF is
'Dummy REF column. Maintained for backward compatibility of the view'
/
comment on column DBA_OBJ_AUDIT_OPTS.EXE is
'Auditing EXECUTE WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column DBA_OBJ_AUDIT_OPTS.CRE is
'Auditing CREATE WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column DBA_OBJ_AUDIT_OPTS.REA is
'Auditing READ WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column DBA_OBJ_AUDIT_OPTS.WRI is
'Auditing WRITE WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column DBA_OBJ_AUDIT_OPTS.EXE is
'Auditing EXECUTE WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column DBA_OBJ_AUDIT_OPTS.FBK is
'Auditing FLASHBACK WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/

execute CDBView.create_cdbview(false,'SYS','DBA_OBJ_AUDIT_OPTS','CDB_OBJ_AUDIT_OPTS');
grant select on SYS.CDB_OBJ_AUDIT_OPTS to select_catalog_role
/
create or replace public synonym CDB_OBJ_AUDIT_OPTS for SYS.CDB_OBJ_AUDIT_OPTS
/

remark
remark  FAMILY "STMT_AUDIT_OPTS"
remark  This view is only accessible to DBAs.
remark  One row is kept for each system auditing option set system wide, or
remark  for a particular user.
create or replace view DBA_STMT_AUDIT_OPTS
        (USER_NAME, 
        PROXY_NAME,
        AUDIT_OPTION, 
        SUCCESS, 
        FAILURE)
as
select decode(aud.user#, 0 /* client operations through proxy */, 'ANY CLIENT',
                         1 /* System wide auditing*/, null,
                         client.name)
                        /* USER_NAME */,
       proxy.name       /* PROXY_NAME */,
       aom.name         /* AUDIT_OPTION */,
       decode(aud.success, 1, 'BY SESSION', 2, 'BY ACCESS', 'NOT SET')
                        /* SUCCESS */,
       decode(aud.failure, 1, 'BY SESSION', 2, 'BY ACCESS', 'NOT SET')
                        /* FAILURE */
from sys.user$ client, sys.user$ proxy, STMT_AUDIT_OPTION_MAP aom,
     sys.audit$ aud
where aud.option# = aom.option#
  and aud.user# = client.user#
  and aud.proxy# = proxy.user#(+)
/
create or replace public synonym DBA_STMT_AUDIT_OPTS for DBA_STMT_AUDIT_OPTS
/
grant select on DBA_STMT_AUDIT_OPTS to select_catalog_role
/
comment on table DBA_STMT_AUDIT_OPTS is
'Describes current system auditing options across the system and by user'
/
comment on column DBA_STMT_AUDIT_OPTS.USER_NAME is
'User name if by user auditing.
 "ANY CLIENT" if access by a proxy on behalf of any client is being audited.
 NULL system wide auditing is being done'
/
comment on column DBA_STMT_AUDIT_OPTS.PROXY_NAME is
'Name of the proxy user if auditing is being done for operations being done on
behalf of a client. Null if auditing is being done for operations done by the
client directly'
/
comment on column DBA_STMT_AUDIT_OPTS.AUDIT_OPTION is
'Name of the system auditing option'
/
comment on column DBA_STMT_AUDIT_OPTS.SUCCESS is
'Mode for WHENEVER SUCCESSFUL system auditing'
/
comment on column DBA_STMT_AUDIT_OPTS.FAILURE is
'Mode for WHENEVER NOT SUCCESSFUL system auditing'
/


execute CDBView.create_cdbview(false,'SYS','DBA_STMT_AUDIT_OPTS','CDB_STMT_AUDIT_OPTS');
grant select on SYS.CDB_STMT_AUDIT_OPTS to select_catalog_role
/
create or replace public synonym CDB_STMT_AUDIT_OPTS for SYS.CDB_STMT_AUDIT_OPTS
/

remark
remark  FAMILY "PRIV_AUDIT_OPTS"
remark  This view is only accessible to DBAs.
remark  One row is kept for each system privilegeauditing option set 
remark  system wide, or for a particular user.
create or replace view DBA_PRIV_AUDIT_OPTS
        (USER_NAME, 
        PROXY_NAME,
        PRIVILEGE, 
        SUCCESS, 
        FAILURE) 
as
select decode(aud.user#, 0 /* client operations through proxy */, 'ANY CLIENT',
                         1 /* System wide auditing*/, null,
                         client.name) /* USER_NAME */,
       proxy.name       /* PROXY_NAME */,
       prv.name         /* PRIVILEGE */,
       decode(aud.success, 1, 'BY SESSION', 2, 'BY ACCESS', 'NOT SET')
                        /* SUCCESS */,
       decode(aud.failure, 1, 'BY SESSION', 2, 'BY ACCESS', 'NOT SET')
                        /* FAILURE */
from sys.user$ client, sys.user$ proxy, system_privilege_map prv,
     sys.audit$ aud
where aud.option# = -prv.privilege
  and aud.user# = client.user#
  and aud.proxy# = proxy.user#(+)
/
create or replace public synonym DBA_PRIV_AUDIT_OPTS for DBA_PRIV_AUDIT_OPTS
/
grant select on DBA_PRIV_AUDIT_OPTS to select_catalog_role
/
comment on table DBA_PRIV_AUDIT_OPTS is
'Describes current system privileges being audited across the system and by user'
/
comment on column DBA_PRIV_AUDIT_OPTS.USER_NAME is
'User name if by user auditing.
 "ANY CLIENT" if access by a proxy on behalf of any client is being audited.
 NULL system wide auditing is being done'
/
comment on column DBA_PRIV_AUDIT_OPTS.PROXY_NAME is
'Name of the proxy user if auditing is being done for operations being done on
behalf of a client. Null if auditing is being done for operations done by the
client directly'
/
comment on column DBA_PRIV_AUDIT_OPTS.PRIVILEGE is
'Name of the system privilege being audited'
/
comment on column DBA_PRIV_AUDIT_OPTS.SUCCESS is
'Mode for WHENEVER SUCCESSFUL system auditing'
/
comment on column DBA_PRIV_AUDIT_OPTS.FAILURE is
'Mode for WHENEVER NOT SUCCESSFUL system auditing'
/


execute CDBView.create_cdbview(false,'SYS','DBA_PRIV_AUDIT_OPTS','CDB_PRIV_AUDIT_OPTS');
grant select on SYS.CDB_PRIV_AUDIT_OPTS to select_catalog_role
/
create or replace public synonym CDB_PRIV_AUDIT_OPTS for SYS.CDB_PRIV_AUDIT_OPTS
/

remark
remark  FAMILY "AUDIT_TRAIL"
remark  DBA_AUDIT_TRAIL 
remark  The raw audit trail of all audit trail records in the system. Some
remark  columns are only filled in by certain statements. This view isis 
remark  accessible only to dba's.
remark
remark  USER_AUDIT_TRAIL
remark  The raw audit trail of all information related to the user
remark  or the objects owned by the user.  Some columns are only filled
remark  in by certain statements. This view is created by selecting from
remark  the DBA_AUDIT_TRAIL view, and retricting the rows.
remark '
create or replace view DBA_AUDIT_TRAIL
        (
         OS_USERNAME, 
         USERNAME,
         USERHOST,
         TERMINAL,
         TIMESTAMP,
         OWNER,
         OBJ_NAME,
         ACTION,
         ACTION_NAME,
         NEW_OWNER,
         NEW_NAME,
         OBJ_PRIVILEGE,
         SYS_PRIVILEGE,
         ADMIN_OPTION,
         GRANTEE,
         AUDIT_OPTION,
         SES_ACTIONS,
         LOGOFF_TIME,
         LOGOFF_LREAD,
         LOGOFF_PREAD,
         LOGOFF_LWRITE,
         LOGOFF_DLOCK,
         COMMENT_TEXT,
         SESSIONID,
         ENTRYID,
         STATEMENTID,
         RETURNCODE,
         PRIV_USED,
         CLIENT_ID,
         ECONTEXT_ID,
         SESSION_CPU,
         EXTENDED_TIMESTAMP,
         PROXY_SESSIONID,
         GLOBAL_UID,
         INSTANCE_NUMBER,
         OS_PROCESS, 
         TRANSACTIONID,
         SCN,
         SQL_BIND,
         SQL_TEXT,
         OBJ_EDITION_NAME,
         DBID,
         RLS_INFO,
         CURRENT_USER
        )
as
select spare1           /* OS_USERNAME */,
       userid           /* USERNAME */,
       userhost         /* USERHOST */,
       terminal         /* TERMINAL */,
       cast (           /* TIMESTAMP */
           (from_tz(ntimestamp#,'00:00') at local) as date),
       obj$creator      /* OWNER */,
       obj$name         /* OBJECT_NAME */,
       aud.action#      /* ACTION */,
       act.name         /* ACTION_NAME */,
       new$owner        /* NEW_OWNER */,
       new$name         /* NEW_NAME */,
       decode(aud.action#, 
              108 /* grant  sys_priv */, null, 
              109 /* revoke sys_priv */, null, 
              114 /* grant  role */, null, 
              115 /* revoke role */, null,
              auth$privileges)  
                        /* OBJ_PRIVILEGE */,
       decode(aud.action#, 
              108 /* grant  sys_priv */, spm.name, 
              109 /* revoke sys_priv */, spm.name, 
              null)
                        /* SYS_PRIVILEGE */,
       decode(aud.action#, 
              108 /* grant  sys_priv */, substrb(auth$privileges,1,1), 
              109 /* revoke sys_priv */, substrb(auth$privileges,1,1), 
              114 /* grant  role */, substrb(auth$privileges,1,1),
              115 /* revoke role */, substrb(auth$privileges,1,1), 
              null)
                        /* ADMIN_OPTION */,
       auth$grantee     /* GRANTEE */,
       decode(aud.action#,
              104 /* audit   */, aom.name,
              105 /* noaudit */, aom.name,
              null)
                        /* AUDIT_OPTION  */,
       ses$actions      /* SES_ACTIONS   */,
       cast((from_tz(cast(logoff$time as timestamp),'00:00') at local) as date)
                        /* LOGOFF_TIME   */,
       logoff$lread     /* LOGOFF_LREAD  */,
       logoff$pread     /* LOGOFF_PREAD  */,
       logoff$lwrite    /* LOGOFF_LWRITE */,
       decode(aud.action#,
              104 /* audit   */, null,
              105 /* noaudit */, null,
              108 /* grant  sys_priv */, null, 
              109 /* revoke sys_priv */, null,
              114 /* grant  role */, null,
              115 /* revoke role */, null,
              aud.logoff$dead)
                         /* LOGOFF_DLOCK */,
       comment$text      /* COMMENT_TEXT */,
       sessionid         /* SESSIONID */,
       entryid           /* ENTRYID */,
       statement         /* STATEMENTID */,
       returncode        /* RETURNCODE */,
       spx.name          /* PRIVILEGE */,
       clientid          /* CLIENT_ID */,
       auditid           /* ECONTEXT_ID */,
       sessioncpu        /* SESSION_CPU */,
       from_tz(ntimestamp#,'00:00') at local,
                                   /* EXTENDED_TIMESTAMP */
       proxy$sid                      /* PROXY_SESSIONID */,
       user$guid                           /* GLOBAL_UID */,
       instance#                      /* INSTANCE_NUMBER */,
       process#                            /* OS_PROCESS */,
       xid                              /* TRANSACTIONID */,
       scn                                        /* SCN */,
       to_nchar(substr(sqlbind,1,2000))      /* SQL_BIND */,
       to_nchar(substr(sqltext,1,2000))      /* SQL_TEXT */,
       obj$edition                   /* OBJ_EDITION_NAME */,
       dbid                                      /* DBID */,
       rls$info                       /* RLS information */,
       current_user                      /* Current User */
from sys.aud$ aud, system_privilege_map spm, system_privilege_map spx,
     STMT_AUDIT_OPTION_MAP aom, audit_actions act
where   aud.action#     = act.action    (+)
  and - aud.logoff$dead = spm.privilege (+)
  and   aud.logoff$dead = aom.option#   (+)
  and - aud.priv$used   = spx.privilege (+)
/
create or replace public synonym DBA_AUDIT_TRAIL for DBA_AUDIT_TRAIL
/
grant select on DBA_AUDIT_TRAIL  to select_catalog_role
/
grant read on DBA_AUDIT_TRAIL to AUDIT_ADMIN
/
grant read on DBA_AUDIT_TRAIL to AUDIT_VIEWER
/
comment on table DBA_AUDIT_TRAIL is
'All audit trail entries'
/
comment on column DBA_AUDIT_TRAIL.OS_USERNAME is
'Operating System logon user name of the user whose actions were audited'
/
comment on column DBA_AUDIT_TRAIL.USERNAME is
'Name of the logged in user whose actions were audited'
/
comment on column DBA_AUDIT_TRAIL.USERHOST is
'Client host machine name'
/
comment on column DBA_AUDIT_TRAIL.TERMINAL is
'Identifier for the user''s terminal'
/
comment on column DBA_AUDIT_TRAIL.TIMESTAMP is
'Date/Time of the creation of the audit trail entry (Date/Time of the user''s logon for entries created by AUDIT SESSION) in session''s time zone'
/
comment on column DBA_AUDIT_TRAIL.OWNER is
'Creator of object affected by the action'
/
comment on column DBA_AUDIT_TRAIL.OBJ_NAME is
'Name of the object affected by the action'
/
comment on column DBA_AUDIT_TRAIL.ACTION is
'Numeric action type code.  The corresponding name of the action type (CREATE TABLE, INSERT, etc.) is in the column ACTION_NAME'
/
comment on column DBA_AUDIT_TRAIL.ACTION_NAME is
'Name of the action type corresponding to the numeric code in ACTION'
/
comment on column DBA_AUDIT_TRAIL.NEW_OWNER is
'The owner of the object named in the NEW_NAME column'
/
comment on column DBA_AUDIT_TRAIL.NEW_NAME is
'New name of object after RENAME, or name of underlying object (e.g. CREATE INDEX owner.obj_name ON new_owner.new_name)'
/
comment on column DBA_AUDIT_TRAIL.OBJ_PRIVILEGE is
'Object privileges granted/revoked by a GRANT/REVOKE statement'
/
comment on column DBA_AUDIT_TRAIL.RLS_INFO is
'RLS predicates along with the RLS policy names used for the object accessed'
/
comment on column DBA_AUDIT_TRAIL.CURRENT_USER is
'Effective user for the statement execution'
/

execute CDBView.create_cdbview(false,'SYS','DBA_AUDIT_TRAIL','CDB_AUDIT_TRAIL');
grant select on SYS.CDB_AUDIT_TRAIL to select_catalog_role
/
grant read on SYS.CDB_AUDIT_TRAIL to AUDIT_ADMIN 
/
grant read on SYS.CDB_AUDIT_TRAIL to AUDIT_VIEWER 
/
create or replace public synonym CDB_AUDIT_TRAIL for SYS.CDB_AUDIT_TRAIL
/

remark  There is one audit entry for each system privilege

comment on column DBA_AUDIT_TRAIL.SYS_PRIVILEGE is
'System privileges granted/revoked by a GRANT/REVOKE statement'
/
comment on column DBA_AUDIT_TRAIL.ADMIN_OPTION is
'If role/sys_priv was granted WITH ADMIN OPTON, A/- or WITH DELEGATE OPTION, D/-'
/
remark  There is one audit entry for each grantee.

comment on column DBA_AUDIT_TRAIL.GRANTEE is
'The name of the grantee specified in a GRANT/REVOKE statement'
/
remark  There is one audit entry for each system audit option

comment on column DBA_AUDIT_TRAIL.AUDIT_OPTION is
'Auditing option set with the audit statement'
/
comment on column DBA_AUDIT_TRAIL.SES_ACTIONS is
'Session summary.  A string of 12 characters, one for each action type, in thisorder: Alter, Audit, Comment, Delete, Grant, Index, Insert, Lock, Rename, Select, Update, Flashback.  Values:  "-" = None, "S" = Success, "F" = Failure, "B" = Both'
/
remark  A single audit entry describes both the logon and logoff.
remark  The logoff_* columns are null while a user is logged in.

comment on column DBA_AUDIT_TRAIL.LOGOFF_TIME is
'Timestamp for user logoff'
/
comment on column DBA_AUDIT_TRAIL.LOGOFF_LREAD is
'Logical reads for the session'
/
comment on column DBA_AUDIT_TRAIL.LOGOFF_PREAD is
'Physical reads for the session'
/
comment on column DBA_AUDIT_TRAIL.LOGOFF_LWRITE is
'Logical writes for the session'
/
comment on column DBA_AUDIT_TRAIL.LOGOFF_DLOCK is
'Deadlocks detected during the session'
/
comment on column DBA_AUDIT_TRAIL.COMMENT_TEXT is
'Text comment on the audit trail entry.
Also indicates how the user was authenticated. The method can be one of the
following:
1. "DATABASE" - authentication was done by password.
2. "NETWORK"  - authentication was done by Net8 or the Advanced Networking
   Option.
3. "PROXY"    - the client was authenticated by another user. The name of the
   proxy user follows the method type.'
/
comment on column DBA_AUDIT_TRAIL.SESSIONID is
'Numeric ID for each Oracle session'
/
comment on column DBA_AUDIT_TRAIL.ENTRYID is
'Numeric ID for each audit trail entry in the session'
/
comment on column DBA_AUDIT_TRAIL.STATEMENTID is
'Numeric ID for each statement run (a statement may cause many actions)'
/
comment on column DBA_AUDIT_TRAIL.RETURNCODE is
'Oracle error code generated by the action.  Zero if the action succeeded'
/
comment on column DBA_AUDIT_TRAIL.PRIV_USED is
'System privilege used to execute the action'
/
comment on column DBA_AUDIT_TRAIL.CLIENT_ID is
'Client identifier in each Oracle session'
/
comment on column DBA_AUDIT_TRAIL.ECONTEXT_ID is
'Execution Context Identifier for each action'
/
comment on column DBA_AUDIT_TRAIL.SESSION_CPU is
'Amount of cpu time used by each Oracle session'
/
comment on column DBA_AUDIT_TRAIL.EXTENDED_TIMESTAMP is
'Timestamp of the creation of audit trail entry (Timestamp of the user''s logon for entries created by AUDIT SESSION) in session''s time zone'
/
comment on column DBA_AUDIT_TRAIL.PROXY_SESSIONID is
'Proxy session serial number, if enterprise user has logged through proxy mechanism'
/
comment on column DBA_AUDIT_TRAIL.GLOBAL_UID is
'Global user identifier for the user, if the user had logged in as enterprise user'
/
comment on column DBA_AUDIT_TRAIL.INSTANCE_NUMBER is
'Instance number as specified in the initialization parameter file ''init.ora'''
/
comment on column DBA_AUDIT_TRAIL.OS_PROCESS is
'Operating System process identifier of the Oracle server process'
/
comment on column DBA_AUDIT_TRAIL.TRANSACTIONID is
'Transaction identifier of the transaction in which the object is accessed or modified'
/
comment on column DBA_AUDIT_TRAIL.SCN is
'SCN (System Change Number) of the query'
/
comment on column DBA_AUDIT_TRAIL.SQL_BIND is
'Bind variable data of the query'
/
comment on column DBA_AUDIT_TRAIL.SQL_TEXT is
'SQL text of the query'
/
comment on column DBA_AUDIT_TRAIL.OBJ_EDITION_NAME is
'Edition containing audited object'
/
comment on column DBA_AUDIT_TRAIL.DBID is
'Database Identifier of the audited database'
/
create or replace view USER_AUDIT_TRAIL 
        (
         OS_USERNAME, 
         USERNAME,
         USERHOST,
         TERMINAL,
         TIMESTAMP,
         OWNER,
         OBJ_NAME,
         ACTION,
         ACTION_NAME,
         NEW_OWNER,
         NEW_NAME,
         OBJ_PRIVILEGE,
         SYS_PRIVILEGE,
         ADMIN_OPTION,
         GRANTEE,
         AUDIT_OPTION,
         SES_ACTIONS,
         LOGOFF_TIME,
         LOGOFF_LREAD,
         LOGOFF_PREAD,
         LOGOFF_LWRITE,
         LOGOFF_DLOCK,
         COMMENT_TEXT,
         SESSIONID,
         ENTRYID,
         STATEMENTID,
         RETURNCODE,
         PRIV_USED,
         CLIENT_ID,
         ECONTEXT_ID,
         SESSION_CPU,
         EXTENDED_TIMESTAMP,
         PROXY_SESSIONID,
         GLOBAL_UID,
         INSTANCE_NUMBER,
         OS_PROCESS,
         TRANSACTIONID,
         SCN,
         SQL_BIND,
         SQL_TEXT,
         OBJ_EDITION_NAME,
         DBID,
         RLS_INFO,
         CURRENT_USER
        )
as
select d.* from dba_audit_trail d, sys.user$ u
where ((d.owner = u.name and u.user# = USERENV('SCHEMAID'))
or (d.owner is null and d.username = u.name and u.user# = USERENV('SCHEMAID'))) 
/
comment on table USER_AUDIT_TRAIL is
'Audit trail entries relevant to the user'
/
comment on column USER_AUDIT_TRAIL.OS_USERNAME is
'Operating System logon user name of the user whose actions were audited'
/
comment on column USER_AUDIT_TRAIL.USERNAME is
'Name of the logged in user whose actions were audited'
/
comment on column USER_AUDIT_TRAIL.USERHOST is
'Numeric instance ID for the Oracle instance from which the user is accessing the database.  Used only in environments with distributed file systems and shared database files (e.g., clustered Oracle on DEC VAX/VMS clusters)'
/
comment on column USER_AUDIT_TRAIL.TERMINAL is
'Identifier for the user''s terminal'
/
comment on column USER_AUDIT_TRAIL.TIMESTAMP is
'Date/Time of the creation of the audit trail entry (Date/Time of the user''s logon for entries created by AUDIT SESSION) in session''s time zone'
/
comment on column USER_AUDIT_TRAIL.OWNER is
'Creator of object affected by the action'
/
comment on column USER_AUDIT_TRAIL.OBJ_NAME is
'Name of the object affected by the action'
/
comment on column USER_AUDIT_TRAIL.ACTION is
'Numeric action type code.  The corresponding name of the action type (CREATE TABLE, INSERT, etc.) is in the column ACTION_NAME'
/
comment on column USER_AUDIT_TRAIL.ACTION_NAME is
'Name of the action type corresponding to the numeric code in ACTION'
/
comment on column USER_AUDIT_TRAIL.NEW_OWNER is
'The owner of the object named in the NEW_NAME column'
/
comment on column USER_AUDIT_TRAIL.NEW_NAME is
'New name of object after RENAME, or name of underlying object (e.g. CREATE INDEX owner.obj_name ON new_owner.new_name)'
/
comment on column USER_AUDIT_TRAIL.OBJ_PRIVILEGE is
'Object privileges granted/revoked by a GRANT/REVOKE statement'
/
remark  There is one audit entry for each system privilege

comment on column USER_AUDIT_TRAIL.SYS_PRIVILEGE is
'System privileges granted/revoked by a GRANT/REVOKE statement'
/
comment on column USER_AUDIT_TRAIL.ADMIN_OPTION is
'If role/sys_priv was granted WITH ADMIN OPTON, A/- or WITH DELEGATE OPTION, D/-'
/
remark  There is one audit entry for each grantee.

comment on column USER_AUDIT_TRAIL.GRANTEE is
'The name of the grantee specified in a GRANT/REVOKE statement'
/
remark  There is one audit entry for each system audit option

comment on column USER_AUDIT_TRAIL.AUDIT_OPTION is
'Auditing option set with the audit statement'
/
comment on column USER_AUDIT_TRAIL.SES_ACTIONS is
'Session summary.  A string of 12 characters, one for each action type, in thisorder: Alter, Audit, Comment, Delete, Grant, Index, Insert, Lock, Rename, Select, Update, Flashback.  Values:  "-" = None, "S" = Success, "F" = Failure, "B" = Both'
/
remark  A single audit entry describes both the logon and logoff.
remark  The logoff_* columns are null while a user is logged in.

comment on column USER_AUDIT_TRAIL.LOGOFF_TIME is
'Timestamp for user logoff'
/
comment on column USER_AUDIT_TRAIL.LOGOFF_LREAD is
'Logical reads for the session'
/
comment on column USER_AUDIT_TRAIL.LOGOFF_PREAD is
'Physical reads for the session'
/
comment on column USER_AUDIT_TRAIL.LOGOFF_LWRITE is
'Logical writes for the session'
/
comment on column USER_AUDIT_TRAIL.LOGOFF_DLOCK is
'Deadlocks detected during the session'
/
comment on column USER_AUDIT_TRAIL.COMMENT_TEXT is
'Text comment on the audit trail entry.
Also indicates how the user was authenticated. The method can be one of the
following:
1. "DATABASE" - authentication was done by password.
2. "NETWORK"  - authentication was done by Net8 or the Advanced Networking
   Option.
3. "PROXY"    - the client was authenticated by another user. The name of the
   proxy user follows the method type.'
/
comment on column USER_AUDIT_TRAIL.SESSIONID is
'Numeric ID for each Oracle session'
/
comment on column USER_AUDIT_TRAIL.ENTRYID is
'Numeric ID for each audit trail entry in the session'
/
comment on column USER_AUDIT_TRAIL.STATEMENTID is
'Numeric ID for each statement run (a statement may cause many actions)'
/
comment on column USER_AUDIT_TRAIL.RETURNCODE is
'Oracle error code generated by the action.  Zero if the action succeeded'
/
comment on column USER_AUDIT_TRAIL.PRIV_USED is
'System privilege used to execute the action'
/
comment on column USER_AUDIT_TRAIL.CLIENT_ID is
'Client identifier in each Oracle session'
/
comment on column USER_AUDIT_TRAIL.ECONTEXT_ID is
'Execution Context Identifier for each action'
/
comment on column USER_AUDIT_TRAIL.SESSION_CPU is
'Amount of cpu time used by each Oracle session'
/
comment on column USER_AUDIT_TRAIL.EXTENDED_TIMESTAMP is
'Timestamp of the creation of audit trail entry (Timestamp of the user''s logon for entries created by AUDIT SESSION) in session''s time zone'
/
comment on column USER_AUDIT_TRAIL.PROXY_SESSIONID is
'Proxy session serial number, if enterprise user has logged through proxy mechanism'
/
comment on column USER_AUDIT_TRAIL.GLOBAL_UID is
'Global user identifier for the user, if the user had logged in as enterprise user'
/
comment on column USER_AUDIT_TRAIL.INSTANCE_NUMBER is
'Instance number as specified in the initialization parameter file ''init.ora'''
/
comment on column USER_AUDIT_TRAIL.OS_PROCESS is
'Operating System process identifier of the Oracle server process'
/
comment on column USER_AUDIT_TRAIL.TRANSACTIONID is
'Transaction identifier of the transaction in which the object is accessed or modified'
/
comment on column USER_AUDIT_TRAIL.SCN is
'SCN (System Change Number) of the query'
/
comment on column USER_AUDIT_TRAIL.SQL_BIND is
'Bind variable data of the query'
/
comment on column USER_AUDIT_TRAIL.SQL_TEXT is
'SQL text of the query'
/
comment on column USER_AUDIT_TRAIL.OBJ_EDITION_NAME is
'Edition containing audited object'
/
comment on column USER_AUDIT_TRAIL.DBID is
'Database Identifier of the audited database'
/
comment on column USER_AUDIT_TRAIL.RLS_INFO is
'RLS predicates along with the RLS policy names used for the object accessed'
/
comment on column USER_AUDIT_TRAIL.CURRENT_USER is
'Effective user for the statement execution'
/
create or replace public synonym USER_AUDIT_TRAIL for USER_AUDIT_TRAIL
/
grant read on USER_AUDIT_TRAIL to public
/
remark 
remark  FAMILY "AUDIT_SESSION"
remark
remark  DBA_AUDIT_SESSION
remark  All audit trail records concerning connect and disconnect, based
remark  DBA_AUDIT_TRAIL.
remark
remark  USER_AUDIT_SESSION
remark  All audit trail records concerning connect and disconnect, based
remark  USER_AUDIT_TRAIL.
remark


create or replace view DBA_AUDIT_SESSION
as
select os_username,  username, userhost, terminal, timestamp, action_name, 
       logoff_time, logoff_lread, logoff_pread, logoff_lwrite, logoff_dlock, 
       sessionid, returncode, client_id, session_cpu, extended_timestamp,
       proxy_sessionid, global_uid, instance_number, os_process
from dba_audit_trail
where action between 100 and 102
/
create or replace public synonym DBA_AUDIT_SESSION for DBA_AUDIT_SESSION
/
grant select on DBA_AUDIT_SESSION to select_catalog_role
/
comment on table DBA_AUDIT_SESSION is
'All audit trail records concerning CONNECT and DISCONNECT'
/


execute CDBView.create_cdbview(false,'SYS','DBA_AUDIT_SESSION','CDB_AUDIT_SESSION');
grant select on SYS.CDB_AUDIT_SESSION to select_catalog_role
/
create or replace public synonym CDB_AUDIT_SESSION for SYS.CDB_AUDIT_SESSION
/

create or replace view USER_AUDIT_SESSION
as
select os_username,  username, userhost, terminal, timestamp, action_name, 
       logoff_time, logoff_lread, logoff_pread, logoff_lwrite, logoff_dlock, 
       sessionid, returncode, client_id, session_cpu, extended_timestamp,
       proxy_sessionid, global_uid, instance_number, os_process
from user_audit_trail 
where action between 100 and 102
/
create or replace public synonym USER_AUDIT_SESSION for USER_AUDIT_SESSION
/
grant read on USER_AUDIT_SESSION to public
/
comment on table USER_AUDIT_SESSION is
'All audit trail records concerning CONNECT and DISCONNECT'
/

remark
remark  FAMILY "AUDIT_STATEMENT"
remark
remark  DBA_AUDIT_STATEMENT
remark  All audit trail records concerning the following statements:
remark  grant, revoke, audit, noaudit and alter system.
remark  Based on DBA_AUDIT_TRAIL.
remark  
remark  USER_AUDIT_STATEMENT
remark  Same as the DBA version, except it is based on USER_AUDIT_TRAIL.
remark

create or replace view DBA_AUDIT_STATEMENT
as
select OS_USERNAME, USERNAME, USERHOST, TERMINAL, TIMESTAMP, 
       OWNER, OBJ_NAME, ACTION_NAME, NEW_NAME, 
       OBJ_PRIVILEGE, SYS_PRIVILEGE, ADMIN_OPTION, GRANTEE, AUDIT_OPTION,
       SES_ACTIONS, COMMENT_TEXT,  SESSIONID, ENTRYID, STATEMENTID, 
       RETURNCODE, PRIV_USED, CLIENT_ID, ECONTEXT_ID, SESSION_CPU, 
       EXTENDED_TIMESTAMP, PROXY_SESSIONID, GLOBAL_UID, INSTANCE_NUMBER, 
       OS_PROCESS, TRANSACTIONID, SCN, SQL_BIND, SQL_TEXT, OBJ_EDITION_NAME
from dba_audit_trail
where action in (        17 /* GRANT OBJECT  */, 
                         18 /* REVOKE OBJECT */, 
                         30 /* AUDIT OBJECT */,
                         31 /* NOAUDIT OBJECT */,
                         49 /* ALTER SYSTEM */,
                        104 /* SYSTEM AUDIT */,
                        105 /* SYSTEM NOAUDIT */,
                        106 /* AUDIT DEFAULT */,
                        107 /* NOAUDIT DEFAULT */,
                        108 /* SYSTEM GRANT */,
                        109 /* SYSTEM REVOKE */,
                        114 /* GRANT ROLE */,
                        115 /* REVOKE ROLE */ ) 
/
create or replace public synonym DBA_AUDIT_STATEMENT for DBA_AUDIT_STATEMENT
/
grant select on DBA_AUDIT_STATEMENT  to select_catalog_role
/
comment on table DBA_AUDIT_STATEMENT is
'Audit trail records concerning  grant, revoke, audit, noaudit and alter system'
/


execute CDBView.create_cdbview(false,'SYS','DBA_AUDIT_STATEMENT','CDB_AUDIT_STATEMENT');
grant select on SYS.CDB_AUDIT_STATEMENT to select_catalog_role
/
create or replace public synonym CDB_AUDIT_STATEMENT for SYS.CDB_AUDIT_STATEMENT
/

create or replace view USER_AUDIT_STATEMENT
as
select OS_USERNAME, USERNAME, USERHOST, TERMINAL, TIMESTAMP, 
       OWNER, OBJ_NAME, ACTION_NAME, NEW_NAME, 
       OBJ_PRIVILEGE, SYS_PRIVILEGE, ADMIN_OPTION, GRANTEE, AUDIT_OPTION,
       SES_ACTIONS, COMMENT_TEXT,  SESSIONID, ENTRYID, STATEMENTID, 
       RETURNCODE, PRIV_USED, CLIENT_ID, ECONTEXT_ID, SESSION_CPU, 
       EXTENDED_TIMESTAMP, PROXY_SESSIONID, GLOBAL_UID, INSTANCE_NUMBER, 
       OS_PROCESS, TRANSACTIONID, SCN, SQL_BIND, SQL_TEXT, OBJ_EDITION_NAME
from user_audit_trail
where action in (        17 /* GRANT OBJECT  */, 
                         18 /* REVOKE OBJECT */, 
                         30 /* AUDIT OBJECT */,
                         31 /* NOAUDIT OBJECT */,
                         49 /* ALTER SYSTEM */,
                        104 /* SYSTEM AUDIT */,
                        105 /* SYSTEM NOAUDIT */,
                        106 /* AUDIT DEFAULT */,
                        107 /* NOAUDIT DEFAULT */,
                        108 /* SYSTEM GRANT*/,
                        109 /* SYSTEM REVOKE */,
                        114 /* GRANT ROLE */,
                        115 /* REVOKE ROLE */ ) 
/
comment on table USER_AUDIT_STATEMENT is
'Audit trail records concerning  grant, revoke, audit, noaudit and alter system'
/
create or replace public synonym USER_AUDIT_STATEMENT for USER_AUDIT_STATEMENT
/
grant read on USER_AUDIT_STATEMENT to public
/

remark
remark  FAMILY "AUDIT_OBJECT"
remark
remark  DBA_AUDIT_OBJECT
remark  Audit trail records for statements concerning objects, 
remark  specifically: table, cluster, view, index, sequence, 
remark  [public] database link, [public] synonym, procedure, trigger,
remark  rollback segment, tablespace, role, user. The audit trail 
remark  records for audit/noaudit and grant/revoke operations on these 
remark  objects can be seen through the dba_audit_statement view.
remark
remark  USER_AUDIT_OBJECT
remark  Same as DBA_AUDIT_OBJECT, except this is based on 
remark  DBA_AUDIT_TRAIL.
remark

create or replace view DBA_AUDIT_OBJECT
as
select OS_USERNAME, USERNAME, USERHOST, TERMINAL, TIMESTAMP, 
       OWNER, OBJ_NAME, ACTION_NAME, NEW_OWNER, NEW_NAME, 
       SES_ACTIONS, COMMENT_TEXT, SESSIONID, ENTRYID, STATEMENTID, 
       RETURNCODE, PRIV_USED, CLIENT_ID, ECONTEXT_ID, SESSION_CPU,
       EXTENDED_TIMESTAMP, PROXY_SESSIONID, GLOBAL_UID, INSTANCE_NUMBER, 
       OS_PROCESS, TRANSACTIONID, SCN, SQL_BIND, SQL_TEXT, OBJ_EDITION_NAME
from dba_audit_trail
where (action between 1 and 16)
   or (action between 19 and 29)
   or (action between 32 and 41)
   or (action = 43)
   or (action between 51 and 99)
   or (action = 103)
   or (action between 110 and 113)
   or (action between 116 and 121)
   or (action between 123 and 128)
   or (action between 160 and 162)
/
create or replace public synonym DBA_AUDIT_OBJECT for DBA_AUDIT_OBJECT
/
grant select on DBA_AUDIT_OBJECT to select_catalog_role
/
comment on table DBA_AUDIT_OBJECT is 
'Audit trail records for statements concerning objects, specifically: table, cluster, view, index, sequence,  [public] database link, [public] synonym, procedure, trigger, rollback segment, tablespace, role, user'
/


execute CDBView.create_cdbview(false,'SYS','DBA_AUDIT_OBJECT','CDB_AUDIT_OBJECT');
grant select on SYS.CDB_AUDIT_OBJECT to select_catalog_role
/
create or replace public synonym CDB_AUDIT_OBJECT for SYS.CDB_AUDIT_OBJECT
/

create or replace view USER_AUDIT_OBJECT
as
select OS_USERNAME, USERNAME, USERHOST, TERMINAL, TIMESTAMP, 
       OWNER, OBJ_NAME, ACTION_NAME, NEW_OWNER, NEW_NAME, 
       SES_ACTIONS, COMMENT_TEXT, SESSIONID, ENTRYID, STATEMENTID, 
       RETURNCODE, PRIV_USED, CLIENT_ID, ECONTEXT_ID, SESSION_CPU,
       EXTENDED_TIMESTAMP, PROXY_SESSIONID, GLOBAL_UID, INSTANCE_NUMBER, 
       OS_PROCESS, TRANSACTIONID, SCN, SQL_BIND, SQL_TEXT, OBJ_EDITION_NAME
from user_audit_trail
where (action between 1 and 16)
   or (action between 19 and 29)
   or (action between 32 and 41)
   or (action = 43)
   or (action between 51 and 99)
   or (action = 103)
   or (action between 110 and 113)
   or (action between 116 and 121)
   or (action between 123 and 128)
   or (action between 160 and 162)
/
comment on table USER_AUDIT_OBJECT is 
'Audit trail records for statements concerning objects, specifically: table, cluster, view, index, sequence,  [public] database link, [public] synonym, procedure, trigger, rollback segment, tablespace, role, user'
/
create or replace public synonym USER_AUDIT_OBJECT for USER_AUDIT_OBJECT
/
grant read on USER_AUDIT_OBJECT to public
/

remark
remark  DBA_AUDIT_EXISTS
remark  Only dba's can see audit info about objects that do not exist.
remark
remark  Lists audit trail entries produced by AUDIT EXISTS/NOT EXISTS.
remark  This is all audit trail entries with return codes of
remark  942, 943, 959, 1418, 1432, 1434, 1435, 1534, 1917, 1918, 1919,
remark  2019, 2024 and 2289 and for Trusted ORACLE 1, 951, 955, 957, 1430,
remark  1433, 1452, 1471, 1535, 1543, 1758, 1920, 1921, 1922, 2239, 2264,
remark  2266, 2273, 2292, 2297, 2378, 2379, 2382, 4081, 12006, 12325.
remark  This view is accessible to DBAs only.
remark
create or replace view DBA_AUDIT_EXISTS
as
  select os_username, username, userhost, terminal, timestamp, 
         owner, obj_name, 
         action_name, 
         new_owner, 
         new_name,
         obj_privilege, sys_privilege, grantee, 
         sessionid, entryid, statementid, returncode, client_id, 
         econtext_id, session_cpu, 
         extended_timestamp, proxy_sessionid, global_uid, instance_number, 
         os_process, transactionid, scn, sql_bind, sql_text, obj_edition_name
  from dba_audit_trail
  where returncode in
  (942, 943, 959, 1418, 1432, 1434, 1435, 1534, 1917, 1918, 1919, 2019, 
   2024, 2289,
   4042, 4043, 4080, 1, 951, 955, 957, 1430, 1433, 1452, 1471, 1535, 1543,
   1758, 1920, 1921, 1922, 2239, 2264, 2266, 2273, 2292, 2297, 2378, 2379,
   2382, 4081, 12006, 12325)
/
create or replace public synonym DBA_AUDIT_EXISTS for DBA_AUDIT_EXISTS
/
grant select on DBA_AUDIT_EXISTS to select_catalog_role
/
comment on table DBA_AUDIT_EXISTS is
'Lists audit trail entries produced by AUDIT NOT EXISTS and AUDIT EXISTS'
/
grant AUDIT SYSTEM to AUDIT_ADMIN
/
grant AUDIT ANY to AUDIT_ADMIN
/


execute CDBView.create_cdbview(false,'SYS','DBA_AUDIT_EXISTS','CDB_AUDIT_EXISTS');
grant select on SYS.CDB_AUDIT_EXISTS to select_catalog_role
/
create or replace public synonym CDB_AUDIT_EXISTS for SYS.CDB_AUDIT_EXISTS
/

remark
remark  AUDITABLE_SYSTEM_ACTIONS
remark    This view maps the auditable system action numbers to action name.
remark    Note that these actions are configurable for audit using new
remark       Audit policy framework.
remark    
remark    It includes - 
remark       1. All standard RDBMS actions except followings 
remark            - No operation (OCTNOP), Create Database (OCTCBD),
remark              Create control file (OCTCCF), Create bitmapfile (OCTCBM),
remark              Drop bitmapfile (OCTDBM), Drop Database (OCTDDB),
remark              Flashback database (OCTFBD), Declare Rewrite Equivalence
remark              (OCTCRE), Alter Rewrite Equivalence (OCTARE),
remark              Drop Rewrite Equivalence (OCTDRE), Alter Edition (OCTAAE)
remark       2. Other actions 
remark            - LOGON, LOGOFF, ALL
remark                  
remark    This view is accessible to public.
remark
create or replace view AUDITABLE_SYSTEM_ACTIONS
  (type, component, action, name)
as
/* 1. Add Standard audit actions */
select audit_type, component, command_type, command_name from
  (select distinct audit_type, component from v$unified_audit_record_format
                                         where component = 'Standard'),
  v$sqlcommand
  where command_type NOT IN (0,
                             17,  /* GRANT OBJECT */
                             18,  /* REVOKE OBJECT */
                             23,  /* VALIDATE INDEX */
                             27,  /* NO-OP */
                             30,  /* AUDIT OBJECT */
                             31,  /* NOAUDIT OBJECT */
                             34,  /* CREATE DATABASE */
                             46,  /* SAVEPOINT */
                             47,  /* PL/SQL EXECUTE */
                             50,  /* EXPLAIN */
                             57,  /* CREATE CONTROL FILE */
                             58,  /* ALTER TRACING */
                             87,  /* CREATE BITMAPFILE */
                             89,  /* DROP BITMAPFILE */
                             90,  /* SET CONSTRAINTS */
                             170, /* CALL METHOD */
                             171, /* CREATE SUMMARY */
                             172, /* ALTER SUMMARY */
                             173, /* DROP SUMMARY */
                             182, /* UPDATE INDEXES */
                             184, /* Do not use 184 */
                             185, /* Do not use 185 */
                             186, /* Do not use 186 */
                             189, /* UPSERT */
                             191, /* UPDATE JOIN INDEX */
                             198, /* PURGE DBA RECYCLEBIN */
                             202, /* UNDROP OBJECT */ 
                             203, /* DROP DATABASE */
                             204, /* FLASHBACK DATABASE */
                             209, /* DECLARE REWRITE EQUIVALENCE */
                             210, /* ALTER REWRITE EQUIVALENCE */
                             211, /* DROP REWRITE EQUIVALENCE */
                             213  /* ALTER EDITION */ )
UNION ALL
select audit_type, component, action, name from 
  (select distinct audit_type, component from v$unified_audit_record_format
                                         where component = 'Standard'),
  (select  17 action, 'GRANT'                name from dual UNION ALL
   select  18 action, 'REVOKE'               name from dual UNION ALL
   select  30 action, 'AUDIT'                name from dual UNION ALL
   select  31 action, 'NOAUDIT'              name from dual UNION ALL
   select 100 action, 'LOGON'                name from dual UNION ALL
   select 101 action, 'LOGOFF'               name from dual UNION ALL
   select  47 action, 'EXECUTE'              name from dual UNION ALL
   select  50 action, 'EXPLAIN PLAN'         name from dual UNION ALL
   select 170 action, 'CALL'                 name from dual UNION ALL
   select 198 action, 'PURGE DBA_RECYCLEBIN' name from dual UNION ALL 
   select (select max(command_type) from v$sqlcommand)+1 action, 
           'ALL' name from dual)
/* 2. Add OLS audit actions */
UNION ALL
select audit_type, component, indx, action_name from
  (select distinct audit_type, component from v$unified_audit_record_format
                                         where component = 'Label Security'),
  (select indx, action_name from x$aud_ols_actions where indx <> 0)
/* 3. Add Triton audit actions */
UNION ALL
select audit_type, component, indx, action_name from
  (select distinct audit_type, component from v$unified_audit_record_format
                                         where component = 'XS'),
  (select indx, action_name from x$aud_xs_actions where indx <> 0)
/* 5. Add Data Pump audit actions */
UNION ALL
select audit_type, component, indx, action_name from
  (select distinct audit_type, component from v$unified_audit_record_format
                                         where component = 'Datapump'),
  (select indx, action_name from x$aud_dp_actions where indx <> 0)
/* 6. Add Database Vault audit actions */
UNION ALL
select audit_type, component, indx, action_name from
  (select distinct audit_type, component from v$unified_audit_record_format
                                         where component = 'Database Vault'),
  (select indx, action_name from x$aud_dv_obj_events where indx <> 0)
/* 7. Add Direct path API audit actions */
UNION ALL
select audit_type, component, indx, action_name from
  (select distinct audit_type, component from v$unified_audit_record_format
                                         where component = 'Direct path API'),
  (select indx, action_name from x$aud_dpapi_actions where indx <> 0)
/
create or replace public synonym AUDITABLE_SYSTEM_ACTIONS for 
                  AUDITABLE_SYSTEM_ACTIONS
/
grant read on AUDITABLE_SYSTEM_ACTIONS to public
/
comment on table AUDITABLE_SYSTEM_ACTIONS is
'Mapping table to map the Audit policy''s auditable system action number 
 to action name'
/
comment on column AUDITABLE_SYSTEM_ACTIONS.TYPE is
'Numeric component type for system wide actions'
/
comment on column AUDITABLE_SYSTEM_ACTIONS.COMPONENT is
'Name of component for system wide actions'
/
comment on column AUDITABLE_SYSTEM_ACTIONS.ACTION is
'Numeric auditable action code for system wide actions'
/
comment on column AUDITABLE_SYSTEM_ACTIONS.NAME is
'Name of auditable action'
/
remark
remark  AUDITABLE_OBJECT_ACTIONS
remark    This  view maps the auditable object action numbers to action name.
remark    Note that these actions are configurable for audit using new
remark       Audit policy framework.
remark    
remark    This view is accessible to public.
remark
create or replace view AUDITABLE_OBJECT_ACTIONS
  (action,
   name)
as
  select INDX, ACTION_NAME from x$aud_obj_actions
/
comment on table AUDITABLE_OBJECT_ACTIONS is
'Mapping table to map the Audit policy''s auditable object action number 
 to action name'
/
comment on column AUDITABLE_OBJECT_ACTIONS.ACTION is
'Numeric auditable action code for object specific actions'
/
comment on column AUDITABLE_OBJECT_ACTIONS.NAME is
'Name of auditable action'
/
create or replace public synonym AUDITABLE_OBJECT_ACTIONS for 
                  AUDITABLE_OBJECT_ACTIONS
/
grant read on AUDITABLE_OBJECT_ACTIONS to public
/
remark
remark  AUDIT_UNIFIED_POLICIES
remark    This view shows the definition of all the Audit policys created in
remark      the database.
remark
remark  Bug 21427375: The Common audit configuration (i.e. policy definition
remark  and policy's enablement) resided only in ROOT's dictionary, but it is
remark  enforced to all containers (ROOT and PDBs). We are using COMMON_DATA
remark  infrastructure provided by CDB for making Common unified audit
remark  configuration queriable from PDBs as well.
remark  Note that 'obj$.flags' column value is compared with number 
remark  &sharing_bits to check if object is common object. For more details, 
remark  refer to 'kqdob' structure flag KQDOBF_COMMON_OBJECT.
remark
create or replace view INT$AUDIT_UNIFIED_POLICIES SHARING=EXTENDED DATA
   (POLICY_NAME,
    AUDIT_CONDITION,
    CONDITION_EVAL_OPT,
    AUDIT_OPTION,
    AUDIT_OPTION_TYPE,
    OBJECT_SCHEMA,
    OBJECT_NAME,
    OBJECT_TYPE,
    COMMON,
    INHERITED,
    SHARING,
    ORIGIN_CON_ID)
as
select obj.name,
       NVL(pol.condition, 'NONE'),
       decode(pol.condition_eval, 1, 'STATEMENT',
                                  2, 'SESSION',
                                  3, 'INSTANCE', 'NONE'),
       spm.name,
       'SYSTEM PRIVILEGE',
       'NONE',
       'NONE',
       'NONE',
       decode(bitand(pol.type, 152), 8, 'NO', 16, 'YES', 128, 'YES', NULL),
       decode(bitand(pol.type, 152), 
              8, 'NO',
              16, decode(SYS_CONTEXT('USERENV', 'CON_ID'), 1, 'NO', 'YES'),
              128, decode(SYS_CONTEXT('USERENV', 'IS_APPLICATION_PDB'), 
                          'YES', 'YES', 'NO')),
       case when bitand(obj.flags, &sharing_bits)>0 then 1 else 0 end,
       to_number(sys_context('USERENV', 'CON_ID'))
from sys.obj$ obj, sys.aud_policy$ pol, sys.system_privilege_map spm
where obj.obj# = pol.policy# and 
      bitand(pol.type, 1) = 1 and
      substr(pol.syspriv, -spm.privilege+1, 1) = 'S'
UNION all
select obj.name,
       NVL(pol.condition, 'NONE'),
       decode(pol.condition_eval, 1, 'STATEMENT',
                                  2, 'SESSION',
                                  3, 'INSTANCE', 'NONE'),
       asa.name,
       decode(asa.type, 4,  'STANDARD ACTION',
                        6,  'XS ACTION',
                        8,  'OLS ACTION', 
                        10, 'DATAPUMP ACTION',
                        11, 'DIRECT_LOAD ACTION', 'NONE'),
       'NONE',
       'NONE',
       'NONE',
       decode(bitand(pol.type, 152), 8, 'NO', 16, 'YES', 128, 'YES', NULL),
       decode(bitand(pol.type, 152), 
              8, 'NO',
              16, decode(SYS_CONTEXT('USERENV', 'CON_ID'), 1, 'NO', 'YES'),
              128, decode(SYS_CONTEXT('USERENV', 'IS_APPLICATION_PDB'), 
                          'YES', 'YES', 'NO')),
       case when bitand(obj.flags, &sharing_bits)>0 then 1 else 0 end,
       to_number(sys_context('USERENV', 'CON_ID'))
from sys.obj$ obj, sys.aud_policy$ pol, sys.auditable_system_actions asa
where obj.obj# = pol.policy# and 
      bitand(pol.type, 2) = 2 and
      ((asa.type = 4 and              /* selecting STANDARD ACTION options */
        substr(pol.sysactn, asa.action+1, 1) = 'S') or
       (asa.type = 6 and                    /* selecting XS ACTION options */
        substr(pol.sysactn,
               ((select max(action)+1 from sys.auditable_system_actions
                               where type = 4) + asa.action + 1), 1) = 'S') or
       (asa.type = 8 and                   /* selecting OLS ACTION options */
        substr(pol.sysactn,
               (((select max(action)+1 from sys.auditable_system_actions
                               where type = 4) +
                 (select count(*)+1 from sys.auditable_system_actions
                               where type = 6)) + asa.action + 1), 1) = 'S') or
       (asa.type = 10 and             /* selecting DATAPUMP ACTION options */
        substr(pol.sysactn,    
               (((select max(action)+1 from sys.auditable_system_actions
                               where type = 4) +
                 (select count(*)+1 from sys.auditable_system_actions
                               where type = 6) +
                 (select count(*)+1 from sys.auditable_system_actions
                               where type = 8)) + asa.action + 1), 1) = 'S') or 
       (asa.type = 11 and          /* selecting DIRECT_LOAD ACTION options */
       substr(pol.sysactn,
               (((select max(action)+1 from sys.auditable_system_actions
                               where type = 4) +
                 (select count(*)+1 from sys.auditable_system_actions
                               where type = 6) +
                 (select count(*)+1 from sys.auditable_system_actions
                               where type = 8) +
                 (select count(*)+1 from sys.auditable_system_actions
                               where type = 7) +
                 (select count(*)+1 from sys.auditable_system_actions
                               where type = 10)) + asa.action + 1), 1) = 'S'))
UNION all
select obj.name,
       NVL(pol.condition, 'NONE'),
       decode(pol.condition_eval, 1, 'STATEMENT',
                                  2, 'SESSION',
                                  3, 'INSTANCE', 'NONE'),
       aoa.name,
       'OBJECT ACTION',
       obj2.owner,
       obj2.object_name,
       obj2.object_type,
       decode(bitand(pol.type, 152), 8, 'NO', 16, 'YES', 128, 'YES', NULL),
       decode(bitand(pol.type, 152), 
              8, 'NO',
              16, decode(SYS_CONTEXT('USERENV', 'CON_ID'), 1, 'NO', 'YES'),
              128, decode(SYS_CONTEXT('USERENV', 'IS_APPLICATION_PDB'), 
                          'YES', 'YES', 'NO')),
       case when bitand(obj.flags, &sharing_bits)>0 then 1 else 0 end,
       to_number(sys_context('USERENV', 'CON_ID'))
from sys.obj$ obj, sys.aud_policy$ pol, sys.auditable_object_actions aoa,
     sys.aud_object_opt$ opt, sys.dba_objects obj2
where obj.obj# = pol.policy# and 
      opt.policy# = pol.policy# and
      opt.object# = obj2.object_id and
      bitand(pol.type, 4) = 4 and          /* Audit policy has Object option */
      opt.type = 2 and                         /* Schema Object audit option */
      substr(opt.action#, aoa.action+1, 1) = 'S'
UNION all
select obj.name,
       NVL(pol.condition, 'NONE'),
       decode(pol.condition_eval, 1, 'STATEMENT',
                                  2, 'SESSION',
                                  3, 'INSTANCE', 'NONE'),
       u.name,
       'ROLE PRIVILEGE',
       'NONE',
       'NONE',
       'NONE',
       decode(bitand(pol.type, 152), 8, 'NO', 16, 'YES', 128, 'YES', NULL),
       decode(bitand(pol.type, 152), 
              8, 'NO',
              16, decode(SYS_CONTEXT('USERENV', 'CON_ID'), 1, 'NO', 'YES'),
              128, decode(SYS_CONTEXT('USERENV', 'IS_APPLICATION_PDB'), 
                          'YES', 'YES', 'NO')),
       case when bitand(obj.flags, &sharing_bits)>0 then 1 else 0 end,
       to_number(sys_context('USERENV', 'CON_ID'))
from sys.obj$ obj, sys.aud_policy$ pol, sys.user$ u, sys.aud_object_opt$ opt
where obj.obj# = pol.policy# and 
      opt.policy# = pol.policy# and
      opt.object# = u.user# and
      bitand(pol.type, 32) = 32 and          /* Audit policy has Role option */
      opt.type = 1                                      /* Role audit option */
UNION all
select obj.name,
       NVL(pol.condition, 'NONE'),
       decode(pol.condition_eval, 1, 'STATEMENT',
                                  2, 'SESSION',
                                  3, 'INSTANCE', 'NONE'),
       'NONE',
       'NONE',
       'NONE',
       'NONE',
       'NONE',
       decode(bitand(pol.type, 152), 8, 'NO', 16, 'YES', 128, 'YES', NULL),
       decode(bitand(pol.type, 152), 
              8, 'NO',
              16, decode(SYS_CONTEXT('USERENV', 'CON_ID'), 1, 'NO', 'YES'),
              128, decode(SYS_CONTEXT('USERENV', 'IS_APPLICATION_PDB'), 
                          'YES', 'YES', 'NO')),
       case when bitand(obj.flags, &sharing_bits)>0 then 1 else 0 end,
       to_number(sys_context('USERENV', 'CON_ID'))
from sys.obj$ obj, sys.aud_policy$ pol
where obj.obj# = pol.policy# and pol.type = 0
UNION all
select obj.name,
       NVL(pol.condition, 'NONE'),
       decode(pol.condition_eval, 1, 'STATEMENT',
                                  2, 'SESSION',
                                  3, 'INSTANCE', 'NONE'),
       asa.name,
       decode(asa.type, 7, 'DV ACTION', 'NONE'),
       'NONE',
       opt.comp_info,
       decode(opt.type, 3, 'REALM',
                        4, 'RULE_SET',
                        5, 'FACTOR', 'NONE'),
       decode(bitand(pol.type, 152), 8, 'NO', 16, 'YES', 128, 'YES', NULL),
       decode(bitand(pol.type, 152), 
              8, 'NO',
              16, decode(SYS_CONTEXT('USERENV', 'CON_ID'), 1, 'NO', 'YES'),
              128, decode(SYS_CONTEXT('USERENV', 'IS_APPLICATION_PDB'), 
                          'YES', 'YES', 'NO')),
       case when bitand(obj.flags, &sharing_bits)>0 then 1 else 0 end,
       to_number(sys_context('USERENV', 'CON_ID'))
from sys.obj$ obj, sys.aud_policy$ pol, sys.aud_object_opt$ opt, 
     sys.auditable_system_actions asa
where obj.obj# = pol.policy# and 
      bitand(pol.type, 64) = 64 and /* Audit Policy has DV object policies */ 
      opt.policy# = pol.policy# and
      (asa.type = 7 and                       /* asa.type = 7 is DV action */
       opt.type in (3, 4, 5) and  /* object type must be DV : bug 17985613 */
       substr(opt.action#, asa.action+1, 1) = 'S')
/

create or replace view AUDIT_UNIFIED_POLICIES 
   (POLICY_NAME,
    AUDIT_CONDITION,
    CONDITION_EVAL_OPT,
    AUDIT_OPTION,
    AUDIT_OPTION_TYPE,
    OBJECT_SCHEMA,
    OBJECT_NAME,
    OBJECT_TYPE,
    COMMON,
    INHERITED)
as
select POLICY_NAME, AUDIT_CONDITION, CONDITION_EVAL_OPT, AUDIT_OPTION,
       AUDIT_OPTION_TYPE, OBJECT_SCHEMA, OBJECT_NAME, OBJECT_TYPE, COMMON,
       decode(COMMON,
              'YES', (decode(ORIGIN_CON_ID,
                             SYS_CONTEXT('USERENV', 'CON_ID'), 'NO', 'YES')),
              'NO', 'NO', NULL)
from INT$AUDIT_UNIFIED_POLICIES
/
create or replace public synonym AUDIT_UNIFIED_POLICIES
                 for AUDIT_UNIFIED_POLICIES
/
grant read on AUDIT_UNIFIED_POLICIES to audit_admin
/
grant read on AUDIT_UNIFIED_POLICIES to audit_viewer
/
comment on table AUDIT_UNIFIED_POLICIES is
'Describes the Audit policy''s definition of all policies created in database'
/
comment on column AUDIT_UNIFIED_POLICIES.POLICY_NAME is
'Name of the Audit policy'
/
comment on column AUDIT_UNIFIED_POLICIES.AUDIT_CONDITION is
'Condition associated with the Audit policy'
/
comment on column AUDIT_UNIFIED_POLICIES.CONDITION_EVAL_OPT is
'Evaluation option associated with the Audit policy''s Condition.
 The possible values are STATEMENT, SESSION, INSTANCE, NONE.'
/
comment on column AUDIT_UNIFIED_POLICIES.AUDIT_OPTION is
'Auditing option defined in the Audit policy'
/
comment on column AUDIT_UNIFIED_POLICIES.AUDIT_OPTION_TYPE is
'Type of the Auditing option. The possible values are SYSTEM PRIVILEGE,
 SYSTEM ACTION, OBJECT ACTION, INVALID'
/
comment on column AUDIT_UNIFIED_POLICIES.OBJECT_SCHEMA is
'Owner of the object, in case of Object-specific auditing option'
/
comment on column AUDIT_UNIFIED_POLICIES.OBJECT_NAME is
'Name of the object, in case of Object-specific auditing option'
/
comment on column AUDIT_UNIFIED_POLICIES.OBJECT_TYPE is
'Type of the object, in case of Object-specific auditing option'
/
comment on column AUDIT_UNIFIED_POLICIES.COMMON is
'Whether the audit policy is a Common Audit Policy or Local. It is NULL 
in case of non-CDBs'
/
comment on column AUDIT_UNIFIED_POLICIES.INHERITED is
'Was audit policy inherited from another container. It is NULL in case of non-CDBs'
/

/* Bug 23483500: Make sure we display the value of ENTITY_TYPE column
   based on how the policy is enabled. */
remark 
remark  AUDIT_UNIFIED_ENABLED_POLICIES
remark    This view shows the Audit policy''s enablement to users.
remark
create or replace view INT$AUDIT_UNIFIED_ENABLED_POL SHARING=EXTENDED DATA
   (USER_NAME,
    POLICY_NAME,
    ENABLED_OPT,
    ENABLED_OPTION,
    ENTITY_NAME,
    ENTITY_TYPE,
    SUCCESS,
    FAILURE,
    SHARING,
    ORIGIN_CON_ID)
as
select decode(a.how, 3, NULL, u.name),
       o.name,
       decode(a.how,  1, 'BY',  2, 'EXCEPT', 'INVALID'),
       decode(a.how,  1, 'BY USER',  2, 'EXCEPT USER',
              3, 'BY GRANTED ROLE', 'INVALID'),
       u.name,
       decode(a.how, 1, 'USER', 2, 'USER', 3, 'ROLE', 'INVALID'),
       decode(bitand(a.when, 1), 1, 'YES', 'NO'),
       decode(bitand(a.when, 2), 2, 'YES', 'NO'),
       case when bitand(o.flags, &sharing_bits)>0 then 1 else 0 end,
       to_number(sys_context('USERENV', 'CON_ID'))
from sys.obj$ o, sys.audit_ng$ a, sys.user$ u
where a.user#   = u.user# and
      a.policy# = o.obj#
UNION all 
select 'ALL USERS',
       o.name,
       decode(a.how,  1, 'BY',  2, 'EXCEPT', 'INVALID'),
       decode(a.how,  1, 'BY USER',  2, 'EXCEPT USER', 
              3, 'BY GRANTED ROLE', 'INVALID'),
       'ALL USERS', 
       'USER',
       decode(bitand(a.when, 1), 1, 'YES', 'NO'),
       decode(bitand(a.when, 2), 2, 'YES', 'NO'),    
       case when bitand(o.flags, &sharing_bits)>0 then 1 else 0 end,
       to_number(sys_context('USERENV', 'CON_ID'))
from sys.audit_ng$ a, sys.obj$ o
where a.user#   = -1 and 
      a.policy# = o.obj# 
/
create or replace view AUDIT_UNIFIED_ENABLED_POLICIES
   (USER_NAME,
    POLICY_NAME,
    ENABLED_OPT,
    ENABLED_OPTION,
    ENTITY_NAME,
    ENTITY_TYPE,
    SUCCESS,
    FAILURE)
as
select USER_NAME, POLICY_NAME, ENABLED_OPT, ENABLED_OPTION, ENTITY_NAME,
       ENTITY_TYPE, SUCCESS, FAILURE
from INT$AUDIT_UNIFIED_ENABLED_POL
/
create or replace public synonym AUDIT_UNIFIED_ENABLED_POLICIES
                 for AUDIT_UNIFIED_ENABLED_POLICIES
/
grant read on AUDIT_UNIFIED_ENABLED_POLICIES to audit_admin
/
grant read on AUDIT_UNIFIED_ENABLED_POLICIES to audit_viewer
/
comment on table AUDIT_UNIFIED_ENABLED_POLICIES is
'Describes the Audit policy''s enablement to users'
/
comment on column AUDIT_UNIFIED_ENABLED_POLICIES.USER_NAME is
'Deprecated - Use ENTITY_NAME column instead'
/
comment on column AUDIT_UNIFIED_ENABLED_POLICIES.POLICY_NAME is
'Name of the Audit policy'
/
comment on column AUDIT_UNIFIED_ENABLED_POLICIES.ENABLED_OPT is
'Deprecated - Use ENABLED_OPTION column instead'
/
comment on column AUDIT_UNIFIED_ENABLED_POLICIES.ENABLED_OPTION is
'Enabled option of the Audit policy. The possible values are BY USER, 
 EXCEPT USER, BY GRANTED ROLE, INVALID.'
/
comment on column AUDIT_UNIFIED_ENABLED_POLICIES.ENTITY_NAME is
'Database entity on which the Audit policy is enabled'
/
comment on column AUDIT_UNIFIED_ENABLED_POLICIES.ENTITY_TYPE is
'Database entity type - User or Role'
/
comment on column AUDIT_UNIFIED_ENABLED_POLICIES.SUCCESS is
'Is the Audit policy enabled for auditing successful events'
/
comment on column AUDIT_UNIFIED_ENABLED_POLICIES.FAILURE is
'Is the Audit policy enabled for auditing unsuccessful events'
/
remark
remark  AUDIT_UNIFIED_CONTEXTS
remark    This view shows the application context''s attributes, which are
remark      configured to be captured in the audit trail.
remark
create or replace view AUDIT_UNIFIED_CONTEXTS
   (NAMESPACE,
    ATTRIBUTE,
    USER_NAME)
as
select a.namespace, 
       a.attribute,
       u.name
from sys.aud_context$ a, sys.user$ u
where a.user# = u.user#
UNION all
select a.namespace,
       a.attribute,
       'ALL USERS'
from sys.aud_context$ a
where a.user# = -1
/
create or replace public synonym AUDIT_UNIFIED_CONTEXTS for AUDIT_UNIFIED_CONTEXTS
/
grant read on AUDIT_UNIFIED_CONTEXTS to audit_admin
/
grant read on AUDIT_UNIFIED_CONTEXTS to audit_viewer
/
comment on table AUDIT_UNIFIED_CONTEXTS is
'Describes the application context''s attributes, which are configured to be
 captured in the audit trail'
/
comment on column AUDIT_UNIFIED_CONTEXTS.NAMESPACE is
'Name of Application context''s Namespace'
/
comment on column AUDIT_UNIFIED_CONTEXTS.ATTRIBUTE is
'Name of Application context''s Attribute'
/
comment on column AUDIT_UNIFIED_CONTEXTS.USER_NAME is
'Database username for whom the Application context''s attribute is congfigured
 to be captured in the audit trail'
/
remark Bug 15996683: There are many auditable actions which are currently not
remark there in auditable_system_actions view. To include all such actions,
remark a table UNIFIED_MISC_AUDITED_ACTIONS has been created which will 
remark be used while creating auditable_system_actions view.

drop table UNIFIED_MISC_AUDITED_ACTIONS
/
create table UNIFIED_MISC_AUDITED_ACTIONS sharing = object (
  action number not null, name varchar2(32) not null)
/
comment on table UNIFIED_MISC_AUDITED_ACTIONS is
'Miscellaneous Audited Actions'
/
comment on column UNIFIED_MISC_AUDITED_ACTIONS.action is
'Action Number'
/
comment on column UNIFIED_MISC_AUDITED_ACTIONS.name is 
'Action Name'
/
insert into UNIFIED_MISC_AUDITED_ACTIONS values(138, 'STARTUP');
insert into UNIFIED_MISC_AUDITED_ACTIONS values(139, 'SHUTDOWN');
insert into UNIFIED_MISC_AUDITED_ACTIONS values(116, 'PL/SQL EXECUTE');
insert into UNIFIED_MISC_AUDITED_ACTIONS values(156, 'ORADEBUG COMMAND');
insert into UNIFIED_MISC_AUDITED_ACTIONS values(102, 'LOGOFF BY CLEANUP');

insert into UNIFIED_MISC_AUDITED_ACTIONS values(129, 'BECOME USER');

insert into UNIFIED_MISC_AUDITED_ACTIONS values(131, 'SELECT MINING MODEL');

insert into UNIFIED_MISC_AUDITED_ACTIONS values(140,
                                             'CREATE SQL TRANSLATION PROFILE');
insert into UNIFIED_MISC_AUDITED_ACTIONS values(141,
                                              'ALTER SQL TRANSLATION PROFILE');
insert into UNIFIED_MISC_AUDITED_ACTIONS values(142,
                                                'USE SQL TRANSLATION PROFILE');
insert into UNIFIED_MISC_AUDITED_ACTIONS values(143,
                                               'DROP SQL TRANSLATION PROFILE');

insert into UNIFIED_MISC_AUDITED_ACTIONS values(144, 
                                                  'CREATE MEASURE FOLDER');
insert into UNIFIED_MISC_AUDITED_ACTIONS values(145, 'ALTER MEASURE FOLDER');
insert into UNIFIED_MISC_AUDITED_ACTIONS values(146, 'DROP MEASURE FOLDER');

insert into UNIFIED_MISC_AUDITED_ACTIONS values(147, 
                                                  'CREATE CUBE BUILD PROCESS');
insert into UNIFIED_MISC_AUDITED_ACTIONS values(148, 
                                                  'ALTER CUBE BUILD PROCESS');
insert into UNIFIED_MISC_AUDITED_ACTIONS values(149, 
                                                  'DROP CUBE BUILD PROCESS');

insert into UNIFIED_MISC_AUDITED_ACTIONS values(150, 'CREATE CUBE');
insert into UNIFIED_MISC_AUDITED_ACTIONS values(151, 'ALTER  CUBE');
insert into UNIFIED_MISC_AUDITED_ACTIONS values(152, 'DROP CUBE');

insert into UNIFIED_MISC_AUDITED_ACTIONS values(153, 
                                                  'CREATE CUBE DIMENSION');
insert into UNIFIED_MISC_AUDITED_ACTIONS values(154, 'ALTER CUBE DIMENSION');
insert into UNIFIED_MISC_AUDITED_ACTIONS values(155, 'DROP CUBE DIMENSION');

/* bug-16354284 */
insert into UNIFIED_MISC_AUDITED_ACTIONS values(208, 'PROXY AUTHENTICATION');

insert into UNIFIED_MISC_AUDITED_ACTIONS values(125, 'READ DIRECTORY');
insert into UNIFIED_MISC_AUDITED_ACTIONS values(126, 'WRITE DIRECTORY');
insert into UNIFIED_MISC_AUDITED_ACTIONS values(135, 'EXECUTE DIRECTORY');

insert into UNIFIED_MISC_AUDITED_ACTIONS values(221, 'DEBUG CONNECT');
insert into UNIFIED_MISC_AUDITED_ACTIONS values(223, 'DEBUG');

insert into UNIFIED_MISC_AUDITED_ACTIONS values(237, 'TRANSLATE SQL');

commit;

remark 
remark  ALL_AUDITED_SYSTEM_ACTIONS
remark    This view shows the action names that will be displayed in audit
remark    records, when UNIFIED_AUDIT_TRAIL view is queried. This view includes
remark    all actions from AUDITABLE_SYSTEM_ACTIONS. Additionally it also 
remark    includes actions that cannot be configured for audit and hence are 
remark    not available in AUDITABLE_SYSTEM_ACTIONS.
remark
create or replace view all_audited_system_actions
  (type, component, action, name)
as
/* 1. All the auditable actions */
select type, component, action, name from auditable_system_actions
                                     where component not like 'Database Vault'
/* 2. Some non configurable audited actions */
UNION ALL
select audit_type, component, action, name from
  (select distinct audit_type, component from v$unified_audit_record_format
                                         where component = 'Standard'),
  (select action, name from UNIFIED_MISC_AUDITED_ACTIONS)
/* 3. Non-configurable RMAN actions */
/* We select audit_type and component from v$unified_audit_record_format view
   and as we know all the RMAN's "action_name" are listed as "pl sql execute", 
   we are selecting action number as 47 and including it as RMAN ACTION. So 
   when we query unified_audit_trail, it would show RMAN ACTION as action_name
   instead of "pl sql execute". */
UNION ALL
select audit_type, component, action, name from
  (select distinct audit_type, component from v$unified_audit_record_format
                                         where component = 'RMAN_AUDIT'),
  (select 47 action, 'RMAN ACTION' name from dual)
/* 4. FGA audit actions */
UNION ALL
select audit_type, component, action, name from
  (select distinct audit_type, component from v$unified_audit_record_format
                                         where component = 'FineGrainedAudit'),
  (select  2 action, 'INSERT'  name from dual UNION ALL
   select  3 action, 'SELECT'  name from dual UNION ALL
   select  6 action, 'UPDATE'  name from dual UNION ALL
   select  7 action, 'DELETE'  name from dual UNION ALL
   select  189 action, 'MERGE' name from dual)
/* 5. KSACL audit action */
UNION ALL
select audit_type, component, action, name from
  (select distinct audit_type, component from v$unified_audit_record_format
                                         where component = 'KACL_AUDIT'),
  (select 1 action, 'VALIDATE' name from dual)
/* 6. Database Vault Configuration Audit Actions */
UNION ALL
select audit_type, component, action, name from
  (select distinct audit_type, component from v$unified_audit_record_format
                                         where component = 'Database Vault'),
  (select action, name from auditable_system_actions
                       where component ='Standard')
/

Rem
Rem Table to list All Unified Auditable Actions
Rem
create table all_unified_audit_actions sharing = object (
  type number, component varchar2(64),
  action number, name varchar2(64))
/

comment on table ALL_UNIFIED_AUDIT_ACTIONS is 
'List of all actions audited in Unified Audit Trail'
/
comment on column ALL_UNIFIED_AUDIT_ACTIONS.TYPE is
'Numeric component type for system wide actions'
/
comment on column ALL_UNIFIED_AUDIT_ACTIONS.COMPONENT is
'Name of component for system wide actions'
/
comment on column ALL_UNIFIED_AUDIT_ACTIONS.ACTION is
'Numeric auditable action code for system wide actions'
/
comment on column ALL_UNIFIED_AUDIT_ACTIONS.NAME is
'Name of auditable action'
/

Rem
Rem Truncate table for handling upgrade scenarios, when cataudit.sql
Rem is rerun to avoid duplicate rows.
Rem
truncate table all_unified_audit_actions
/

insert into all_unified_audit_actions (type, component, action, name)
select type, component, action, name from all_audited_system_actions
/
commit;

Rem
Rem Index on all_unified_audit_actions table
Rem
create unique index i_unified_audit_actions on 
all_unified_audit_actions(type, action)
/

Rem
Rem  View to display Comments on Audit Policies
Rem
create  or replace view AUDIT_UNIFIED_POLICY_COMMENTS (POLICY_NAME, COMMENTS)
as
( select o.name, c.comment$ from sys.com$ c, obj$ o
  where c.obj# = o.obj# and o.type#=115 )
/
create or replace public synonym AUDIT_UNIFIED_POLICY_COMMENTS for
                                     AUDIT_UNIFIED_POLICY_COMMENTS
/
comment on column AUDIT_UNIFIED_POLICY_COMMENTS.POLICY_NAME is 
'Unified Audit Policy Name'
/
comment on column AUDIT_UNIFIED_POLICY_COMMENTS.COMMENTS is
'Unified Audit Policy Description'
/
grant read on AUDIT_UNIFIED_POLICY_COMMENTS to audit_admin
/
grant read on AUDIT_UNIFIED_POLICY_COMMENTS to audit_viewer
/

@?/rdbms/admin/sqlsessend.sql
