Rem
Rem $Header: rdbms/admin/catdpb.sql /main/94 2017/09/20 08:37:49 sdavidso Exp $
Rem
Rem catdpb.sql
Rem
Rem Copyright (c) 2004, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catdpb.sql - Data Pump and Metadata API script for building
Rem                   miscellaneous components
Rem
Rem    DESCRIPTION
Rem      This script is invoked from catptabs.sql.  During upgrade, all
Rem      scripts invoked by catptabs.sql are run in parallel. catptab
Rem      also executes catnodpobs.sql.  Therefore, the two scripts must 
Rem      not have any ordering dependencies.  Note, operations may be moved 
Rem      to catbph.sql which is run by itself from catproc.sql before
Rem      catptabs.sql.
Rem
Rem    NOTES
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catdpb.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catdpb.sql
Rem SQL_PHASE: CATDPB
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catptabs.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    sdavidso    08/29/17 - datapummp - shard domain index name mapping
Rem    bwright     08/14/17 - Bug 26638628 Move as much from catdph to catdpb
Rem                           to maximize upgrade parallelism
Rem    bwright     08/14/17 - RTI 20496727: catdpb, catnodpobs run concurrently
Rem                           during upgrade, so cannot have any overlaps
Rem    pjulsaks    06/26/17 - Bug 25688154: Uppercase input to create_cdbview
Rem    bwright     09/21/16 - Bug 24704817: Cleanup output from running dpload
Rem    jstraub     04/06/16 - Exclude APEX schemas
Rem    sdball      03/22/16 - add profile gsm_prof
Rem    smavris     03/17/16 - Change ORDSYS import callout from ORDSYS to SYS
Rem    dgagne      12/10/15 - grant analyze any to exp_full_database
Rem    msakayed    05/08/15 - Bug #20823349: access driver feature tracking
Rem    msakayed    04/22/15 - remove DATAPUMP_DIR_OBJS
Rem    bnnguyen    04/11/15 - bug 20860190: Rename 'EXADIRECT' to 'DBSFWUSER'
Rem    jorgrive    03/25/15 - add GGSYS to ku_noexp_ab 
Rem    dgagne      03/15/15 - add alter any tablepace to import_full_database
Rem    msakayed    03/06/15 - Lrg #15305720: fix DATAPUMP_DIR_OBJS
Rem    msakayed    02/19/15 - Bug #20354576: use ORA_CHECK_SYS_PRIVILEGE
Rem    bnnguyen    01/27/15 - bug 19697038: exclude schema EXADIRECT 
Rem    skayoor     11/30/14 - Proj 58196: Change Select priv to Read Priv
Rem    jlingow     09/18/14 - excluding remote_scheduler_agent schema from dp
Rem                           tests
Rem    thbaby      08/27/14 - Proj 47234: avoid export of db link to CDB$ROOT
Rem    spapadom    08/25/14 - Project 47321: Added SYS$UMF.
Rem    gclaborn    07/16/14 - lrg12632056: grant FLASHBACK ANY TABLE to
Rem                           EXP_FULL_DATABASE, not SELECT_CATALOG_ROLE
Rem    dkoppar     07/03/14 - #18909599- add OPATCH_TEMP_DIR
Rem    gclaborn    07/02/14 - 18844843: grant flashback on SYS views
Rem    sanbhara    04/23/14 - Project 46816 - adding support for SYSRAC.
Rem    jkati       04/20/14 - lrg-11783472 : Grant select on radm_fptm$ to
Rem                           imp_full_database role since sql92_security is
Rem                           TRUE by default
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    gclaborn    10/14/13 - Bug#17543726 : Add new profile ORA_STIG_PROFILE
Rem    gclaborn    08/08/13 - 16304706/17070445: Remove explicit roles from
Rem                           ku_noexp_tab. They are now excluded via
Rem                           Oracle-supplied and common bits in user$
Rem    rpang       06/28/13 - Add XS_ACL to ku_noexp_view
Rem    talliu      06/28/13 - Add CDB view for DBA view
Rem    sdavidso    01/02/13 - XbranchMerge sdavidso_lrg-8658292 from
Rem                           st_rdbms_12.1.0.1
Rem    sdavidso    12/28/12 - lrg8658292: alter table may get ORA-00054:
Rem                           resource busy
Rem    minx        10/22/12 - Rename xs_nsattr_admin to xs_namespace_admin
Rem    krajaman    10/01/12 - Use X$DIR
Rem    jkaloger    09/20/12 - Feature tracking for Data Pump full transportable
Rem    yanchuan    09/12/12 - Bug 14456083: add dv_datapump_network_link to
Rem                           exclusion list
Rem    sdavidso    08/24/12 - bug 12977174 - allow option tags for
Rem                           include/exclude
Rem    sdball      08/16/12 - Add new GDS role to exclusion list
Rem    mjungerm    08/08/12 - add DBHADOOP to ku_noexp_tab - lrg 7165007
Rem    cchiappa    07/17/12 - Add OLAP rules/users to ku_noexp_tab
Rem    sanbhara    07/06/12 - Lrg 7102632 - adding DV roles to ku_noexp_tab.
Rem    verangan    06/04/12 - Exclucde Oracle_OCM objects
Rem    sdipirro    06/01/12 - Cleanup import noise with stuff that belongs in
Rem                           noexp table
Rem    gclaborn    04/05/12 - Add SYSAUX tablespace to the no export list
Rem    gclaborn    04/02/12 - Add explicit ON_USER_GRANT exclusions
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    gclaborn    02/28/12 - Remove object type-specific rows from
Rem                           ku_noexp_tab - use existing SCHEMA rows
Rem    gclaborn    02/08/12 - Add no export rows for ON_USER_GRANTs
Rem    tbhukya     01/17/12 - Remove OPATCH_SCRIPT_DIR, OPATCH_LOG_DIR
Rem                           directory object from export
Rem    sdavidso    10/12/11 - remove XDB_REPOSITORY type export
Rem    nkgopal     08/21/11 - Bug 12794380: AUDITOR to AUDIT_VIEWER
Rem    dahlim      07/29/11 - lrg 5745794 grant privs on radm_fptm$ to impdp
Rem    sdavidso    06/30/11 - skip import of XDB types
Rem    dahlim      06/14/11 - 32006: RADM: EXEMPT REDACTION POLICY
Rem    smavris     03/30/11 - Register ORDIM for import callouts
Rem    traney      03/29/11 - 35209: long identifiers dictionary upgrade
Rem    jibyun      03/14/11 - Project 5687: Do not export SYSBACKUP, SYSDG, and
Rem                           SYSKM schemas
Rem    amunnoli    03/09/11 - Proj 26873:Add AUDSYS user,AUDIT_ADMIN,AUDITOR 
Rem                           roles to ku_noexp_tab
Rem    gclaborn    03/01/11 - Move user mapping view to catdpb.sql
Rem    smavris     02/22/11 - Remove ORDDATA from import/export
Rem    dgagne      02/22/11 - add grant on sys.impcalloutreg$
Rem    jkaloger    01/04/11 - PROJ:27450 - track comp/encr algorithms
Rem    mjungerm    11/19/10 - make OJVMSYS no export
Rem    sdipirro    04/20/10 - Fix datapump_jobs view queries to ignore dropped
Rem                           (but not purged) master tables
Rem    ebatbout    09/10/09 - bug 8523879: Add MGDSYS user to ku_noexp_tab
Rem    dvoss       03/19/09 - bug 8350972, logstdby_administrator, ku_noexp_tab
Rem    dgagne      02/02/09 - put ku_list_filter_temp back and create a version
Rem                           2 table
Rem    rlong       09/25/08 - 
Rem    dsemler     08/07/08 - 
Rem    dgagne      07/01/08 - add columns to ku$_list_filter_temp
Rem    dgagne      05/19/08 - add TSMSYS to the noexp table
Rem    pknaggs     05/12/08 - bug 6938028: Database Vault protected schema.
Rem    msakayed    04/17/08 - compression/encryption feature tracking for 11.2
Rem    dsemler     02/28/08 - Add APPQOSSYS user to noexp table
Rem    bmccarth    02/19/08 - add view for getting directory objects - legacy
Rem                           mode
Rem    sdipirro    04/18/07 - Support multiple queue tables
Rem    wfisher     05/18/07 - granting AUDIT ANY and CREATE PROFILE to
Rem                           IMP_FULL_DATABASE
Rem    htseng      05/03/07 - bug 5567364: DEFAULT profile
Rem    wfisher     02/02/07 - Adding ku$_list_filter_temp
Rem    dgagne      12/26/06 - add alter database to datapump_imp_full_database
Rem    dgagne      11/01/06 - add idr_dir to noexp
Rem    msakayed    10/09/06 - add sys.ku_utluse for feature tracking
Rem    mhho        09/08/06 - add XS$NULL to ku_noexp_tab
Rem    rburns      08/13/06 - add drop_queue
Rem    ataracha    07/13/06 - add user anonymous to ku_noexp_tab
Rem    dkapoor     06/19/06 - don't export ORACLE_OCM 
Rem    xbarr       06/06/06 - remove DMSYS entries  
Rem    dgagne      03/23/06 - add global temporary master tables
Rem    wfisher     09/01/05 - Lrg 1908671: Factoring for Standard Edition 
Rem    wfisher     08/18/05 - Adding new Data Pump roles 
Rem    lbarton     05/03/05 - Bug 4338735: don't export WMSYS 
Rem    emagrath    02/07/05 - Remove unused oper. from DATAPUMP_JOBS view 
Rem    lbarton     01/07/05 - Bug 4109444: exclude schemas 
Rem    dgagne      10/15/04 - dgagne_split_catdp
Rem    dgagne      10/04/04 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql
--
----------------------------------------------------------------
-- Procedure to create object (default is role).  
-- Ignore "already exist" errors
----------------------------------------------------------------
--
CREATE OR REPLACE PROCEDURE catdpb_create(
  sts    OUT VARCHAR2,
  objnam IN VARCHAR2, 
  objtyp IN VARCHAR2 DEFAULT 'role') 
IS
  stmt                    VARCHAR2(4000);
  lc_objtyp               VARCHAR2(100) := LOWER(objtyp);
BEGIN
  stmt := 'CREATE ' || lc_objtyp || ' ' || objnam;
  EXECUTE IMMEDIATE stmt;
  sts := INITCAP(lc_objtyp) || ' created.';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN (-01921) THEN  -- Name conflicts
      sts := INITCAP(lc_objtyp) || ' already created.';
    ELSE
      RAISE;
    END IF;
END;
/

--
----------------------------------------------------------------
-- Procedure to drop object (default is table).  
-- Ignore "does not exist" errors
----------------------------------------------------------------
--
CREATE OR REPLACE PROCEDURE catdpb_drop(
  sts    OUT VARCHAR2,
  objnam IN VARCHAR2, 
  objtyp IN VARCHAR2 DEFAULT 'table') 
IS
  stmt                    VARCHAR2(4000);
  lc_objtyp               VARCHAR2(100) := LOWER(objtyp);
BEGIN
  stmt := 'DROP ' || lc_objtyp || ' ' || objnam;
  IF (lc_objtyp = 'type') THEN
    stmt := stmt || ' FORCE';
  END IF;
  EXECUTE IMMEDIATE stmt;
  sts := INITCAP(lc_objtyp) || ' dropped.';
EXCEPTION
  WHEN OTHERS THEN
    -- Object exists errors
    IF SQLCODE IN (-00942, -01418, -01432, -04043) THEN 
      sts := INITCAP(lc_objtyp) || ' already dropped.';
    ELSE
      RAISE;
    END IF;
END;
/

--
-- Minimize output.  Note SET HEADING OFF and SET AUTOPRINT ON is use to
-- output the result of the drop procedure calls where we pass back the
-- result of the drop operation in the bind variable.  Oracle doc describes
-- this: "To automatically display bind variables referenced in a successful 
-- PL/SQL block or used in an EXECUTE command, use the AUTOPRINT clause of 
-- the SET command".  We use this esoteric method as the procedure cannot
-- use DBMS_OUTPUT to output this information as the DBMS_OUTPUT package is
-- not already loaded/valid by time our scripts are run.
--
SET HEADING OFF
SET AUTOPRINT ON
VARIABLE sts VARCHAR2(520)

--
-------------------------------------------------------------------------
-- Create Data Pump application roles and grant privileges to them
-------------------------------------------------------------------------
-- 
-- Note: Create these roles within a PL/SQL procedure to ignore
-- errors if they already exist.  We don't want to drop these
-- roles first, before creating them, because dropping the role
-- would remove it from untold users and we have not way of
-- recreating that.
--
SET FEEDBACK 0
exec catdpb_create(:sts, 'datapump_exp_full_database');
exec catdpb_create(:sts, 'datapump_imp_full_database');
SET FEEDBACK 1 

GRANT create session,
      create table,                        /* Needed for fgac test in dpx3f2 */
      exp_full_database         
TO datapump_exp_full_database;

--
-- Grant of exp_full_database is needed to make loopback network jobs
-- work right Since the application role makes it disappear otherwise.
--
GRANT alter database,
      alter profile,
      alter resource cost,
      alter user,
      audit any,
      audit system,
      create profile,
      create session,
      delete any table,
      execute any operator,
      exp_full_database,                                 /* old exp/imp role */
      grant any object privilege,
      grant any privilege,
      grant any role,
      imp_full_database,                                 /* old exp/imp role */
      select any table          
TO datapump_imp_full_database;

GRANT export full database,
      import full database,
      datapump_exp_full_database,
      datapump_imp_full_database
TO dba;
--
-- Note: DataPump roles are not documented so grant them to old exp/imp roles
-- 
GRANT analyze any,
      create session,
      create table,                        /* Needed for fgac test in dpx3f2 */
      exempt redaction policy,                                       /* RADM */
      flashback any table       
TO exp_full_database;

GRANT alter database,
      alter profile,
      alter resource cost,
      alter tablespace,
      alter user,
      audit any,
      audit system,
      create profile,
      create session,
      delete any table,
      execute any operator,
      grant any object privilege,
      grant any privilege,
      grant any role,
      select any table
TO imp_full_database; 
--
-- 12c project 32006 RADM
--
GRANT delete, 
      insert,
      select                          /* see LRG11783472, re: SQL92_SECURITY */
ON sys.radm_fptm$     
TO imp_full_database;
--
-- For transportable import
--
GRANT delete,
      insert,
      select,
      update 
ON sys.expimp_tts_ct$ 
TO imp_full_database;

--
-------------------------------------------------------------------------
-- Public Dynamic and Global Dynamic performance views
-------------------------------------------------------------------------
--
-- Views
--
CREATE OR REPLACE VIEW sys.v_$datapump_job
  AS SELECT * FROM     sys.v$datapump_job;

CREATE OR REPLACE VIEW sys.v_$datapump_session
  AS SELECT * FROM     sys.v$datapump_session;

CREATE OR REPLACE VIEW sys.gv_$datapump_job
  AS SELECT * FROM     sys.gv$datapump_job;

CREATE OR REPLACE VIEW sys.gv_$datapump_session
  AS SELECT * FROM     sys.gv$datapump_session;
--
-- Synonyms
--
CREATE OR REPLACE PUBLIC SYNONYM
                       v$datapump_job FOR
                       sys.v_$datapump_job;

CREATE OR REPLACE PUBLIC SYNONYM
                       v$datapump_session FOR 
                       sys.v_$datapump_session;

CREATE OR REPLACE PUBLIC SYNONYM 
                       gv$datapump_job FOR 
                       sys.gv_$datapump_job;

CREATE OR REPLACE PUBLIC SYNONYM
                       gv$datapump_session FOR 
                       sys.gv_$datapump_session;
--
-- Grants
--
GRANT select ON        sys.v_$datapump_job      TO select_catalog_role;
GRANT select ON        sys.v_$datapump_session  TO select_catalog_role;
GRANT select ON        sys.gv_$datapump_job     TO select_catalog_role;
GRANT select ON        sys.gv_$datapump_session TO select_catalog_role;

--
-------------------------------------------------------------------------
-- The DATAPUMP_JOBS views (DBA_, USER_ and CDB_, no ALL_ variety).
-------------------------------------------------------------------------
--
-- =======================
-- DBA_DATAPUMP_JOBS view
-- =======================
--
CREATE OR REPLACE VIEW SYS.dba_datapump_jobs (
                owner_name, job_name, operation, job_mode, state, degree,
                attached_sessions, datapump_sessions) AS
        SELECT  j.owner_name, j.job_name, j.operation, j.job_mode, j.state,
                j.workers,
                NVL((SELECT    COUNT(*)
                     FROM      SYS.GV$DATAPUMP_SESSION s
                     WHERE     j.job_id = s.job_id AND
                               s.type = 'DBMS_DATAPUMP'
                     GROUP BY  s.job_id), 0),
                NVL((SELECT    COUNT(*)
                     FROM      SYS.GV$DATAPUMP_SESSION s
                     WHERE     j.job_id = s.job_id
                     GROUP BY  s.job_id), 0)
        FROM    SYS.GV$DATAPUMP_JOB j
        WHERE   j.msg_ctrl_queue IS NOT NULL
      UNION ALL                               /* Not Running - Master Tables */
        SELECT u.name, o.name,
               SUBSTR (c.comment$, 24, 30), SUBSTR (c.comment$, 55, 30),
               'NOT RUNNING', 0, 0, 0
        FROM sys.obj$ o, sys.user$ u, sys.com$ c
        WHERE SUBSTR (c.comment$, 1, 22) = 'Data Pump Master Table' AND
              RTRIM (SUBSTR (c.comment$, 24, 30)) IN
                ('EXPORT','ESTIMATE','IMPORT','SQL_FILE','NETWORK') AND
              RTRIM (SUBSTR (c.comment$, 55, 30)) IN
                ('FULL','SCHEMA','TABLE','TABLESPACE','TRANSPORTABLE') AND
              o.obj# = c.obj# AND
              o.type# = 2 AND
              BITAND(o.flags, 128) <> 128 AND
              u.user# = o.owner# AND
              NOT EXISTS (SELECT 1
                          FROM   SYS.GV$DATAPUMP_JOB
                          WHERE  owner_name = u.name AND
                                 job_name = o.name)
/
COMMENT ON TABLE SYS.dba_datapump_jobs IS
'Datapump jobs'
/
COMMENT ON COLUMN SYS.dba_datapump_jobs.owner_name IS
'User that initiated the job'
/
COMMENT ON COLUMN SYS.dba_datapump_jobs.job_name IS
'Job name'
/
COMMENT ON COLUMN SYS.dba_datapump_jobs.operation IS
'Type of operation being performed'
/
COMMENT ON COLUMN SYS.dba_datapump_jobs.job_mode IS
'Mode of operation being performed'
/
COMMENT ON COLUMN SYS.dba_datapump_jobs.state IS
'Current job state'
/
COMMENT ON COLUMN SYS.dba_datapump_jobs.degree IS
'Number of worker proceses performing the operation'
/
COMMENT ON COLUMN SYS.dba_datapump_jobs.attached_sessions IS
'Number of sessions attached to the job'
/
COMMENT ON COLUMN SYS.dba_datapump_jobs.datapump_sessions IS
'Number of Datapump sessions participating in the job'
/
CREATE OR REPLACE PUBLIC SYNONYM      dba_datapump_jobs FOR 
                                  sys.dba_datapump_jobs
/
GRANT select 
ON sys.dba_datapump_jobs 
TO select_catalog_role
/
--
-- =======================
-- USER_DATAPUMP_JOBS view
-- =======================
--
CREATE OR REPLACE VIEW SYS.user_datapump_jobs (
                job_name, operation, job_mode, state, degree,
                attached_sessions, datapump_sessions) AS
        SELECT  j.job_name, j.operation, j.job_mode, j.state, j.workers,
                NVL((SELECT    COUNT(*)
                     FROM      SYS.GV$DATAPUMP_SESSION s
                     WHERE     j.job_id = s.job_id AND
                               s.type = 'DBMS_DATAPUMP'
                     GROUP BY  s.job_id), 0),
                NVL((SELECT    COUNT(*)
                     FROM      SYS.GV$DATAPUMP_SESSION s
                     WHERE     j.job_id = s.job_id
                     GROUP BY  s.job_id), 0)
        FROM    SYS.GV$DATAPUMP_JOB j
        WHERE   j.msg_ctrl_queue IS NOT NULL AND 
                j.owner_name = SYS_CONTEXT('USERENV', 'CURRENT_USER')
      UNION ALL                               /* Not Running - Master Tables */
        SELECT o.name,
               SUBSTR (c.comment$, 24, 30), SUBSTR (c.comment$, 55, 30),
               'NOT RUNNING', 0, 0, 0
        FROM sys.obj$ o, sys.user$ u, sys.com$ c
        WHERE SUBSTR (c.comment$, 1, 22) = 'Data Pump Master Table' AND
              RTRIM (SUBSTR (c.comment$, 24, 30)) IN
                ('EXPORT','IMPORT','SQL_FILE') AND
              RTRIM (SUBSTR (c.comment$, 55, 30)) IN
                ('FULL','SCHEMA','TABLE','TABLESPACE','TRANSPORTABLE') AND
              o.obj# = c.obj# AND
              o.type# = 2 AND
              BITAND(o.flags, 128) <> 128 AND
              u.user# = o.owner# AND
              u.name = SYS_CONTEXT('USERENV', 'CURRENT_USER') AND
              NOT EXISTS (SELECT 1
                          FROM   SYS.GV$DATAPUMP_JOB
                          WHERE  owner_name = u.name AND
                                 job_name = o.name)
/
COMMENT ON TABLE SYS.user_datapump_jobs IS
'Datapump jobs for current user'
/
COMMENT ON COLUMN SYS.user_datapump_jobs.job_name IS
'Job name'
/
COMMENT ON COLUMN SYS.user_datapump_jobs.operation IS
'Type of operation being performed'
/
COMMENT ON COLUMN SYS.user_datapump_jobs.job_mode IS
'Mode of operation being performed'
/
COMMENT ON COLUMN SYS.user_datapump_jobs.state IS
'Current job state'
/
COMMENT ON COLUMN SYS.user_datapump_jobs.degree IS
'Number of worker processes performing the operation'
/
COMMENT ON COLUMN SYS.user_datapump_jobs.attached_sessions IS
'Number of sessions attached to the job'
/
COMMENT ON COLUMN SYS.user_datapump_jobs.datapump_sessions IS
'Number of Datapump sessions participating in the job'
/
CREATE OR REPLACE PUBLIC SYNONYM     user_datapump_jobs FOR 
                                 sys.user_datapump_jobs
/
GRANT read
ON sys.user_datapump_jobs 
TO PUBLIC WITH GRANT OPTION
/
--
-- =======================
-- CDB_DATAPUMP_JOBS view
-- =======================
--
EXECUTE cdbview.create_cdbview(false,               -
                               'SYS',               -
                               'DBA_DATAPUMP_JOBS', -
                               'CDB_DATAPUMP_JOBS');
GRANT select 
ON sys.cdb_datapump_jobs 
TO select_catalog_role
/
CREATE OR REPLACE PUBLIC SYNONYM     cdb_datapump_jobs FOR
                                 sys.cdb_datapump_jobs
/

--
-------------------------------------------------------------------------
-- DATAPUMP_SESSIONS views (DBA_ and CDB_, no ALL_, no USER_ varieties)
-------------------------------------------------------------------------
--
-- ===========================
-- DBA_DATAPUMP_SESSIONS view
-- ===========================
--
CREATE OR REPLACE VIEW SYS.dba_datapump_sessions (
                owner_name, job_name, inst_id, saddr, session_type) AS
        SELECT  j.owner_name, j.job_name, s.inst_id, s.saddr, s.type
        FROM    SYS.GV$DATAPUMP_JOB j, SYS.GV$DATAPUMP_SESSION s
        WHERE   j.job_id = s.job_id
/
COMMENT ON TABLE SYS.dba_datapump_sessions IS
'Datapump sessions attached to a job'
/
COMMENT ON COLUMN SYS.dba_datapump_sessions.owner_name IS
'User that initiated the job'
/
COMMENT ON COLUMN SYS.dba_datapump_sessions.job_name IS
'Job name'
/
COMMENT ON COLUMN SYS.dba_datapump_sessions.inst_id IS
'Instance ID'
/
COMMENT ON COLUMN SYS.dba_datapump_sessions.saddr IS
'Address of session attached to job'
/
COMMENT ON COLUMN SYS.dba_datapump_sessions.session_type IS
'Datapump session type'
/
CREATE OR REPLACE PUBLIC SYNONYM     dba_datapump_sessions FOR
                                 SYS.dba_datapump_sessions
/
GRANT select 
ON SYS.dba_datapump_sessions 
TO select_catalog_role
/
--
-- ===========================
-- CDB_DATAPUMP_SESSIONS view
-- ===========================
--
EXECUTE CDBView.create_cdbview(false,                   -
                               'SYS',                   -
                               'DBA_DATAPUMP_SESSIONS', -
                               'CDB_DATAPUMP_SESSIONS');

GRANT select 
ON sys.cdb_datapump_sessions 
TO select_catalog_role
/
CREATE OR REPLACE PUBLIC SYNONYM     cdb_datapump_sessions FOR
                                 sys.cdb_datapump_sessions
/

--
-- ----------------------------------------------------------------------------
-- Table used for database utility feature tracking (SQL*Loader, impdp, expdp,
-- metadata API)
-- ----------------------------------------------------------------------------
--
-- ============================================
-- KU_UTLUSE table: Drop, Create, and Populate
-- ============================================
--
SET FEEDBACK 0
exec catdpb_drop(:sts, 'sys.ku_utluse');
SET FEEDBACK 1

CREATE TABLE sys.ku_utluse 
(
 UTLNAME     VARCHAR2(50),
 USECNT      NUMBER,
 ENCRYPTCNT  NUMBER,
 ENCRYPT128  NUMBER,
 ENCRYPT192  NUMBER,
 ENCRYPT256  NUMBER,
 ENCRYPTPWD  NUMBER,
 ENCRYPTDUAL NUMBER,
 ENCRYPTTRAN NUMBER,
 COMPRESSCNT NUMBER,
 COMPRESSBAS NUMBER,
 COMPRESSLOW NUMBER,
 COMPRESSMED NUMBER,
 COMPRESSHGH NUMBER,
 PARALLELCNT NUMBER,
 LAST_USED   TIMESTAMP,
 FULLTTSCNT  NUMBER
)
/

INSERT INTO sys.ku_utluse VALUES
('Oracle Utility Datapump (Export)', 
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, 0)
/
INSERT INTO sys.ku_utluse VALUES
('Oracle Utility Datapump (Import)', 
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, 0)
/
INSERT INTO sys.ku_utluse VALUES
('Oracle Utility SQL Loader (Direct Path Load)',
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, 0)
/
INSERT INTO sys.ku_utluse VALUES
('Oracle Utility Metadata API',
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, 0)
/
INSERT INTO sys.ku_utluse VALUES
('Oracle Utility External Table (ORACLE_DATAPUMP)',
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, 0)
/
INSERT INTO sys.ku_utluse VALUES
('Oracle Utility External Table (ORACLE_LOADER)',
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, 0)
/
INSERT INTO sys.ku_utluse VALUES
('Oracle Utility External Table (ORACLE_BIGSQL)',
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, 0)
/
COMMIT;

--
-- ----------------------------------------------------------------------------
-- Filter List tables: Tables to contain filter list elements 
-- (e.g., TABLE list) on source database during a network job. 
-- ----------------------------------------------------------------------------
-- =============================
-- KU$_LIST_FILTER_TEMP_2 table
-- =============================
-- NOTE:  This is used for 11.2 and later, so if adding columns, add them to 
-- this table.
--
SET FEEDBACK 0
exec catdpb_drop(:sts, 'sys.ku$_list_filter_temp_2');
SET FEEDBACK 1

CREATE GLOBAL TEMPORARY TABLE sys.ku$_list_filter_temp_2
(
 process_order          NUMBER,
 duplicate              NUMBER,
 object_schema          VARCHAR2(128),
 object_name            VARCHAR2(500),
 base_process_order     NUMBER,
 parent_process_order   NUMBER
)
ON COMMIT PRESERVE ROWS
/

GRANT delete,
      insert,
      select 
ON sys.ku$_list_filter_temp_2 
TO PUBLIC
/
--
-- =============================
-- KU$_LIST_FILTER_TEMP table
-- =============================
-- NOTE: This is used for 11.1 only.  *** Do not modify ***
--
SET FEEDBACK 0
exec catdpb_drop(:sts, 'sys.ku$_list_filter_temp');
SET FEEDBACK 1

CREATE GLOBAL TEMPORARY TABLE sys.ku$_list_filter_temp
(
 process_order          NUMBER,
 duplicate              NUMBER,
 object_name            VARCHAR2(500),
 base_process_order     NUMBER,
 parent_process_order   NUMBER
)
ON COMMIT PRESERVE ROWS
/

GRANT delete,
      insert,
      select 
ON sys.ku$_list_filter_temp 
TO PUBLIC
/

--
-- ----------------------------------------------------------------------------
-- Common explain plan table used in Data Pump's data layer 
-- ----------------------------------------------------------------------------
--
SET FEEDBACK 0
exec catdpb_drop(:sts, 'sys.data_pump_xpl_table$');
SET FEEDBACK 1
CREATE GLOBAL TEMPORARY TABLE sys.data_pump_xpl_table$
(statement_id      varchar2(30),
 plan_id           number,
 timestamp         date,
 remarks           varchar2(4000),
 operation         varchar2(30),
 options           varchar2(255),
 object_node       varchar2(128),
 object_owner      varchar2(128),
 object_name       varchar2(128),
 object_alias      varchar2(261),
 object_instance   numeric,
 object_type       varchar2(30),
 optimizer         varchar2(255),
 search_columns    number,
 id                numeric,
 parent_id         numeric,
 depth             numeric,
 position          numeric,
 cost              numeric,
 cardinality       numeric,
 bytes             numeric,
 other_tag         varchar2(255),
 partition_start   varchar2(255),
 partition_stop    varchar2(255),
 partition_id      numeric,
 other             long,
 distribution      varchar2(30),
 cpu_cost          numeric,
 io_cost           numeric,
 temp_space        numeric,
 access_predicates varchar2(4000),
 filter_predicates varchar2(4000),
 projection        varchar2(4000),
 time              numeric,
 qblock_name       varchar2(128),
 other_xml         clob); 

GRANT delete, 
      insert, 
      select,
      update 
ON sys.data_pump_xpl_table$ 
TO PUBLIC
/

--
-- ----------------------------------------------------------------------------
-- Username-to-ID mapping objects.
-- ----------------------------------------------------------------------------
--
-- Drop them, if necessary.
--
SET FEEDBACK 0
exec catdpb_drop(:sts, 'ku$_user_mapping_view_tbl');
exec catdpb_drop(:sts, 'ku$_user_mapping_view', 'view');
SET FEEDBACK 1

-- =============================
-- KU$_USER_MAPPING_VIEW view
-- =============================
--
CREATE OR REPLACE VIEW ku$_user_mapping_view (user#, name) AS
  SELECT user#, name
  FROM   sys.user$
  WHERE  type#=1
/

GRANT flashback,           /* Views in SYS require explicit flashback grants */
      select 
ON ku$_user_mapping_view 
TO select_catalog_role
/
--
-- ================================
-- KU$_USER_MAPPING_VIEW_TBL table
-- ================================
-- Now a table that has the same metadata as the view for views-as-tables
-- export. This table is never populated; export only needs its metadata.
--
CREATE TABLE ku$_user_mapping_view_tbl AS
  SELECT * FROM ku$_user_mapping_view WHERE 0=1
/
GRANT select 
ON ku$_user_mapping_view_tbl 
TO select_catalog_role
/

--
-- ----------------------------------------------------------------------------
-- Data Pump import callout registrations
-- ----------------------------------------------------------------------------
--
-- So the worker can look at impcalloutreg$ from an account that just has
-- IMPFULLDATABASE, grant select on sys.impcalloutreg$ to select_catalog_role.
-- IMPFULLDATABASE has been granted select_catalog_role.
--
GRANT select 
ON sys.impcalloutreg$ 
TO SELECT_CATALOG_ROLE;
--
-- Delete all Data Pump registrations first, then 
-- add a row to impcalloutreg$ to register the user mapping view.
--
--
DELETE FROM sys.impcalloutreg$ where tag='DATAPUMP'
/
INSERT INTO sys.impcalloutreg$ (package, schema, tag, class, level#, flags,
                                tgt_schema, tgt_object, tgt_type)
VALUES ('DBMS_DATAPUMP_UTL', 'SYS',  'DATAPUMP',3,1,2,
          'SYS','KU$_USER_MAPPING_VIEW',4)
/
--
-- Register a system callout that does various things when called post-import:
-- makes calls to transportable fixup routines for TSTZ and encrypted tables, 
-- and drops the user mapping tbl. It has a very high level# to ensure that 
-- it runs last so that the user mapping tbl is available as long as possible.
--
INSERT INTO sys.impcalloutreg$ (package, schema, tag, class, level#, flags,
                                tgt_schema, tgt_object, tgt_type)
  VALUES ('DBMS_DATAPUMP_UTL','SYS','DATAPUMP',1,999999999, 0, '', '', 0)
/
--
-- Delete all Oracle Multimedia registrations first, then add a row to
-- impcalloutreg$ to register the Oracle Multimedia ORDDCM_DOCS table.
--
DELETE FROM sys.impcalloutreg$ where tag='ORDIM'
/
INSERT INTO sys.impcalloutreg$ (package, schema, tag, class, level#, flags,
                                tgt_schema, tgt_object, tgt_type, cmnt)
  VALUES ('ORDIMDPCALLOUTS','SYS','ORDIM',3,1000,0,
          'ORDDATA','ORDDCM_DOCS',2,
          'Oracle Multimedia')
/
COMMIT;

--
-- ----------------------------------------------------------------------------
-- Tables to support EXCLUDE_NOEXP filter
-- ----------------------------------------------------------------------------
-- A table to hold objects that are not to be exported in a full export. This
-- and rows from sys.noexp$ form the complete exclusion set (which is built at
-- Data Pump run time into the global temporary table below). We have to leave
-- SYS.NOEXP$ as-is since external products use it. IMPORTANT: Some metadata 
-- API views do not use this table but instead have their own hard-coded list
-- of schemas to exclude.  When a new schema is added to the exclude list, they
-- must be updated in catmetviews.sql.  Also datapump/ddl/prvtmetd.sql may need
-- to be updated for similar reasons.
--
SET FEEDBACK 0
exec catdpb_drop(:sts, 'sys.ku_noexp_tab');
exec catdpb_drop(:sts, 'sys.ku$noexp_tab');
SET FEEDBACK 1
--
-- =============================
-- KU_NOEXP_TAB table
-- =============================
--
CREATE TABLE sys.ku_noexp_tab
(
 obj_type VARCHAR2(30),
 schema   VARCHAR2(128),
 name     VARCHAR2(128)
)
/
--
-- =============================
-- KU_NOEXP_VIEW view
-- =============================
-- Create a view that incorporates everything in the KU_NOEXP_TAB above and
-- the original catexp SYS.NOEXP$ table. This view is used to populate the
-- global temporary table defined below at runtime. The view *usually* isn't
-- used directly because the union below slows metadata extraction by 10%.
-- It will be used in network mode because the metadata API running on the
-- remote instance can't see our table.
--
CREATE OR REPLACE VIEW sys.ku_noexp_view (obj_type, schema, name) AS
        SELECT  decode(n.obj_type, 2, 'TABLE', 6, 'SEQUENCE', 110, 'XS_ACL',
                       'ERROR'),
                n.owner, n.name
        FROM    sys.noexp$ n
      UNION
        SELECT  k.obj_type, k.schema, k.name
        FROM    sys.ku_noexp_tab k
/

GRANT READ ON sys.ku_noexp_view TO PUBLIC
/
--
-- ====================================
-- KU$NOEXP_TAB global temporary table
-- ====================================
-- The global temp. table used for all local export operations. Each worker
-- doing metadata loads their own private copy which doesn't have to be
-- cleaned up at session end.  File prvtbpw.sql has a dependency on this.
--
CREATE GLOBAL TEMPORARY TABLE sys.ku$noexp_tab ON COMMIT PRESERVE ROWS
  AS SELECT * FROM sys.ku_noexp_view
/
GRANT select,
      insert
ON sys.ku$noexp_tab
TO PUBLIC
/
--
-- ====================================
-- Now populate KU_NOEXP_TAB table
-- ====================================
--
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('TABLESPACE', NULL, 'SYSTEM')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('TABLESPACE', NULL, 'SYSAUX')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('DB_LINK', 'PUBLIC', 'CDB$ROOT.REGRESS.RDBMS.DEV.US.ORACLE.COM')
/
--
-- NOTE: Many object types' exclusion filters use the following SCHEMA rows
--
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SCHEMA', NULL, 'SYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SCHEMA', NULL, 'SYSBACKUP')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SCHEMA', NULL, 'SYSDG')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SCHEMA', NULL, 'SYSKM')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SCHEMA', NULL, 'SYSRAC')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SCHEMA', NULL, 'SYS$UMF')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SCHEMA', NULL, 'ORDSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SCHEMA', NULL, 'EXFSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SCHEMA', NULL, 'MDSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SCHEMA', NULL, 'CTXSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SCHEMA', NULL, 'ORDPLUGINS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SCHEMA', NULL, 'LBACSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SCHEMA', NULL, 'XDB')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SCHEMA', NULL, 'ANONYMOUS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SCHEMA', NULL, 'SI_INFORMTN_SCHEMA')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SCHEMA', NULL, 'DIP')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SCHEMA', NULL, 'DBSNMP')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SCHEMA', NULL, 'DVSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SCHEMA', NULL, 'DVF')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SCHEMA', NULL, 'WMSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SCHEMA', NULL, 'ORACLE_OCM')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
('SCHEMA', NULL, 'AUDSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SCHEMA', NULL, 'XS$NULL')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SCHEMA', NULL, 'TSMSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SCHEMA', NULL, 'APPQOSSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SCHEMA', NULL, 'MGDSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SCHEMA', NULL, 'OJVMSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SCHEMA', NULL, 'ORDDATA')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SCHEMA', NULL, 'GSMUSER')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SCHEMA', NULL, 'GSMCATUSER')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SCHEMA', NULL, 'GSMADMIN_INTERNAL')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SCHEMA', NULL, 'OLAPSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SCHEMA', NULL, 'REMOTE_SCHEDULER_AGENT')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SCHEMA', NULL, 'DBSFWUSER')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SCHEMA', NULL, 'GGSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SCHEMA', NULL, 'APEX_050000')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SCHEMA', NULL, 'APEX_040200')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SCHEMA', NULL, 'APEX_040100')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SCHEMA', NULL, 'APEX_040000')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SCHEMA', NULL, 'APEX_030200')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SCHEMA', NULL, 'FLOWS_030100')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SCHEMA', NULL, 'FLOWS_030000')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SCHEMA', NULL, 'FLOWS_FILES')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SCHEMA', NULL, 'APEX_PUBLIC_USER')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SCHEMA', NULL, 'APEX_LISTENER')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SCHEMA', NULL, 'APEX_REST_PUBLIC_USER')
/
--
-- Roles: Note that most user and role exclusions are now accomplished
-- by the fact that their Oracle-supplied or Common-user bit is set 
-- (user$.spare1 0x100 and 0x80)
--
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('ROLE', NULL, '_NEXT_USER')
/
--
-- Object grants
--
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('OBJECT_GRANT', NULL, 'SYSTEM')
/
--
-- Role grants to Oracle-supplied users are excluded using the SCHEMA
-- entries above. Add ROLE_GRANT rows below only for grants to roles.
--
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('ROLE_GRANT', NULL, 'DATAPUMP_EXP_FULL_DATABASE')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('ROLE_GRANT', NULL, 'DATAPUMP_IMP_FULL_DATABASE')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('ROLE_GRANT', NULL, 'LOGSTDBY_ADMINISTRATOR')
/
--
-- System grants to Oracle-supplied users are excluded using the SCHEMA
-- entries above. Add SYSTEM_GRANT rows below only for grants to roles.
--
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYSTEM_GRANT', NULL, 'AUDIT_ADMIN')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYSTEM_GRANT', NULL, 'AUDIT_VIEWER')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYSTEM_GRANT', NULL, 'CONNECT')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYSTEM_GRANT', NULL, 'RESOURCE')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYSTEM_GRANT', NULL, 'DBA')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYSTEM_GRANT', NULL, '_NEXT_USER')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYSTEM_GRANT', NULL, 'EXP_FULL_DATABASE')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYSTEM_GRANT', NULL, 'IMP_FULL_DATABASE')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYSTEM_GRANT', NULL, 'DATAPUMP_EXP_FULL_DATABASE')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYSTEM_GRANT', NULL, 'DATAPUMP_IMP_FULL_DATABASE')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYSTEM_GRANT', NULL, 'LOGSTDBY_ADMINISTRATOR')
/
--
-- Tables to exclude
--
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('TABLE', 'SYSTEM', 'SQLPLUS_PRODUCT_PROFILE')
/
--
-- Misc objects to exclude
--
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('ROLLBACK_SEGMENT', NULL, 'SYSTEM')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('DIRECTORY', NULL, 'IDR_DIR')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('DIRECTORY', NULL, 'OPATCH_LOG_DIR')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('DIRECTORY', NULL, 'OPATCH_SCRIPT_DIR')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('DIRECTORY', NULL, 'OPATCH_TEMP_DIR')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('DIRECTORY', NULL, 'ORACLE_OCM_CONFIG_DIR')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('DIRECTORY', NULL, 'ORACLE_OCM_CONFIG_DIR2')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('PROFILE', NULL, 'ORA_STIG_PROFILE')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('PROFILE', NULL, 'GSM_PROF')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYNONYM', 'PUBLIC', 'PRODUCT_PROFILE')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYNONYM', 'PUBLIC', 'PRODUCT_USER_PROFILE')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYNONYM', 'SYSTEM', 'PRODUCT_USER_PROFILE')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('VIEW', 'SYSTEM', 'PRODUCT_PRIVS')
/
--
-- There are a couple static (rather unintuitive) on_user_grants required to
-- make the new invoker's rights grant checking work. They are:
-- GRANT INHERIT PRIVILEGES ON USER PUBLIC  TO PUBLIC  and
-- GRANT INHERIT PRIVILEGES ON USER XS$NULL TO PUBLIC
-- Add exclusion rows for these special cases here. Note that the schema rows
-- above are used to exclude all on_user_grants where our internal schemas are
-- the grantee.
--
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('ON_USER_GRANT', NULL, 'PUBLIC')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('ON_USER_GRANT', NULL, 'XS$NULL')
/
COMMIT;
--
-- Globasl temporary table for shard domain index name mapping
--
-- NOTE:  This is used for 12.2 and later.
--
exec catdpb_drop(:sts, 'sys.ku$_shard_domidx_namemap');

CREATE GLOBAL TEMPORARY TABLE ku$_shard_domidx_namemap (
 owner       VARCHAR2(128) default null,   -- owner name (not remapped)
 source_name VARCHAR2(128) default null,   -- name on source shard
 target_name VARCHAR2(128) default null,   -- name on target shard
 type_name   VARCHAR2(128) default null,   -- type name
 part_name   VARCHAR2(128) default null    -- partition name
) 
ON COMMIT PRESERVE ROWS
/
-- since table content is only visible within a session, and we only rely
-- on the context within a sharding specific session, we can safely grant
-- read and insert to PUBLIC.
GRANT READ, INSERT ON sys.ku$_shard_domidx_namemap TO public
/

--
-- ----------------------------------------------------------------------------
-- Cleanup
-- ----------------------------------------------------------------------------
-- 
-- Reset output
--
SET HEADING ON
SET AUTOPRINT OFF
SET FEEDBACK 1

drop procedure catdpb_create;
drop procedure catdpb_drop;

--
-- ------------------
-- End of catdpb.sql
-- ------------------
--
@?/rdbms/admin/sqlsessend.sql
