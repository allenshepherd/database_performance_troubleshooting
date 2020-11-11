Rem
Rem $Header: rdbms/admin/catnodp.sql /main/30 2017/10/04 20:16:07 bwright Exp $
Rem
Rem catnodp.sql
Rem
Rem Copyright (c) 2002, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem     catnodp.sql - Drop all DataPump components
Rem
Rem    DESCRIPTION
Rem 
Rem    PARAMETERS
Rem      opt - what option to use when executing this script:
Rem            OBSOLETE: remove obsolete and required objects only
Rem            ALL:      remove all objects (original behavior)
DEFINE opt=&1  
Rem
Rem    NOTES
Rem     This is the central script for dropping Data Pump and MDAPI
Rem     objects during any type of operation.  The new flow looks like:
Rem
Rem     Reload:    catrelod ------+
Rem                               |
Rem                               v
Rem     Upgrade:   catupgrd -> catproc -> catptabs
Rem                                          |
Rem                                          v
Rem     Patch:     dpload -------------> catnodpobs
Rem                                          |
Rem                                          v
Rem                                       catnodp ---> catnomta
Rem                                          ^
Rem                                          |
Rem     Downgrade: catdwgrd -----------> catnodpall
Rem
Rem     Data Pump's AQ tables are now dropped in its own script, catnodpaq.sql.
Rem     This gets invoked in dpload.sql and catnodpall.sql (as well as in
Rem     catdph.sql).
Rem 
Rem     All scripts invoked from catptabs.sql must be able to run in parallel 
Rem     (for upgrade).  Our scripts catnodpobs.sql and catdpb.sql are invoked
Rem     from there.  Therefore, when this script is invoked from catnodpobs 
Rem     with 'OBSOLETE' parameter value, it cannot be dropping any objects 
Rem     referenced in catdpb.sql.
Rem 
Rem     --------------------------------------------
Rem     Data Pump objects that we don't want to drop 
Rem     --------------------------------------------
Rem      1. Roles DATAPUMP_EXP_FULL_DATABASE and DATAPUMP_IMP_FULL_DATABASE.
Rem         The drop-role operation removes that role from every user who
Rem         was granted it.  This cannot be rolled back, nor is there any
Rem         automated way to regrant a role to those users after re-creating 
Rem         the roles. 
Rem      2. Table KU_UTLUSE. It is used for database utility feature tracking 
Rem         (SQL*Loader, impdp, expdp, metadata API).  Downgrade scripts expect
Rem         this table to exist, so don't drop it,
Rem
Rem      Regarding the obs parameter values to the drop procedure:  
Rem      - ALWAYS:  Some objects always need to be dropped in order for
Rem        upgrade/patch/etc to succeed.  For example, always drop our global
Rem        temporary table as well as certain XDB related objects.
Rem      - OBS: Views are created using "create or replace" and this
Rem        effectively drops the old view and creates the new view.  However,
Rem        views that are no longer part of MDAPI (e.g. obsolete) would never
Rem        get dropped if not for doing it here. If the type that describes the
Rem        object view changes, the view gets recompiled and fails, leaving 
Rem        invalid objects.
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem     SQL_SOURCE_FILE: rdbms/admin/catnodp.sql
Rem     SQL_SHIPPED_FILE: rdbms/admin/catnodp.sql
Rem     SQL_PHASE: UPGRADE
Rem     SQL_STARTUP_MODE: UPGRADE
Rem     SQL_IGNORABLE_ERRORS: NONE
Rem     SQL_CALLING_FILE: rdbms/admin/catnodpobs.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    bwright     10/03/17 - RTI 20625267: drop ku$_shard_domidx_namemap
Rem    bwright     09/14/17 - Bug 26797585: Remove disabling of SQL echo
Rem    bwright     08/14/17 - RTI 20496727: catdpb, catnodpobs run concurrently
Rem                           during upgrade, so cannot have any overlaps
Rem    bwright     08/03/17 - Bug 26290098: drop new KUPUTIL synonym
Rem    bwright     08/03/17 - Bug 26570943: Ignore index-does-not-exist error
Rem    bwright     06/13/17 - Bug 25651930: Add OBSOLETE, ALL script options
Rem    raeburns    03/25/17 - Bug 25752691: Use SQL_PHASE DOWNGRADE 
Rem    bwright     09/21/16 - Bug 24704817: Cleanup output from running dpload
Rem    sdipirro    07/01/15 - Fix invalid jobstatus object on downgrade
Rem    sdipirro    05/26/15 - Fix potential lident issue
Rem    tmontgom    05/15/14 - Drop new synonyms, showing up in dpload.sql.
Rem                           Noticed by rapayne as part of Bug 17039620.
Rem    gclaborn    10/19/10 - drop user mapping view stuff
Rem    sdipirro    01/15/08 - New status types for 11.2
Rem    wfisher     02/02/07 - Adding ku$_list_filter_temp
Rem    rburns      08/13/06 - add drop_queue and drop tables
Rem    tbgraves    04/14/04 - drop DBMS_DATAPUMP_UTL package 
Rem    sdipirro    04/16/04 - New dumpfile info type and synonym 
Rem    sdipirro    03/02/04 - New status types and synonyms to drop 
Rem    sdipirro    08/11/03 - Versioning for public types
Rem    ebatbout    06/03/03 - Drop package, kupd$data
Rem    gclaborn    03/09/03 - Drop package kupc$que_int
Rem    gclaborn    12/12/02 - Drop new tables
Rem    gclaborn    12/06/02 - Add new objects
Rem    sdipirro    11/21/02 - Remove obsolete emulation types
Rem    jkaloger    05/28/02 - Add filemgr internal package
Rem    gclaborn    05/24/02 - Add prvt{h|b}pci
Rem    emagrath    05/13/02 - Add Datapump fixed table support
Rem    sdipirro    04/18/02 - Add datapump packages
Rem    gclaborn    04/14/02 - gclaborn_catdp
Rem    gclaborn    04/09/02 - Created
Rem

----------------------------------------------------------------
--    Procedure to drop object.  Ignore "doesn't exist" errors    
----------------------------------------------------------------
CREATE OR REPLACE PROCEDURE catnodp_drop(
  sts    OUT VARCHAR2,
  opt    IN  VARCHAR2,
  objnam IN  VARCHAR2, 
  objtyp IN  VARCHAR2,
  obs    IN  VARCHAR2 DEFAULT NULL) 
IS
  stmt       VARCHAR2(4000);
  lc_objtyp  VARCHAR2(100) := LOWER(objtyp);
  l_objown   VARCHAR2(6);
  l_objtyp   VARCHAR2(20);
  l_objnam   VARCHAR2(60);
  l_objobs   VARCHAR2(6);
  l_sp       NUMBER;      
BEGIN
  sts := 'Drop ' || INITCAP(lc_objtyp) || ' skipped.'; -- Initial return string

  CASE UPPER(opt)
    WHEN 'TEST' THEN                    -- Return object info. Used for testing
      IF SUBSTR(objtyp, 1, 7) = 'public ' THEN
        l_objown := 'PUBLIC';
        l_objtyp := SUBSTR(objtyp, 8);
      ELSE
        l_objown := 'SYS   ';
        l_objtyp := objtyp;
      END IF;

      l_objtyp := REPLACE(l_objtyp, ' ', '_');

      l_sp := INSTR(objnam, ' ');
      if l_sp > 0 THEN
        l_objnam := SUBSTR(objnam,1,l_sp - 1);
      ELSE
        l_objnam := objnam;
      END IF;

      IF obs IS NOT NULL AND
         SUBSTR(UPPER(obs),1,3) = 'OBS' THEN
        l_objobs := 'OBS   ';
      ELSE
        l_objobs := 'ALWAYS';
      END IF; 

      sts :=
        'TEST: ' || 
        RPAD(UPPER(l_objtyp),10) ||
        RPAD(UPPER(l_objnam),38) || 
        l_objown || ' ' ||
        l_objobs;   
      RETURN;

    WHEN 'OBSOLETE' THEN                  -- Drop obsolete and required objects
      IF (obs IS NULL) THEN                  -- If not obsolete/always, skip it
        RETURN;
      END IF;

    WHEN 'ALL' THEN                     -- Drop all objects (original behavior)
      NULL;

    ELSE                                         -- Unknown options, so skip it
      RETURN;
  END CASE;

  stmt := 'DROP ' || lc_objtyp || ' ' || objnam;       -- Set up drop statement
  IF (lc_objtyp = 'type') THEN
    stmt := stmt || ' FORCE';                            -- Add FORCE for TYPEs
  END IF;

  EXECUTE IMMEDIATE stmt;                                       -- Execute drop
  sts := INITCAP(lc_objtyp) || ' dropped.';             -- Set up return string

EXCEPTION
  WHEN OTHERS THEN
    -- Ignore 'object does not exist' errors
    IF SQLCODE IN (-00942, -01418, -01432, -04043) THEN 
      sts := INITCAP(lc_objtyp) || ' already dropped.';
    ELSE
      RAISE;
    END IF;
END;
/

CREATE OR REPLACE PROCEDURE catnodp_drop_idx(
  sts    OUT VARCHAR2,
  opt    IN  VARCHAR2,
  objnam IN  VARCHAR2, 
  obs    IN  VARCHAR2 DEFAULT NULL)  
IS
BEGIN
  catnodp_drop(sts, opt, objnam, 'index', obs);
END;
/

CREATE OR REPLACE PROCEDURE catnodp_drop_lib(
  sts    OUT VARCHAR2,
  opt    IN  VARCHAR2,
  objnam IN  VARCHAR2, 
  obs    IN  VARCHAR2 DEFAULT NULL)  
IS
BEGIN
  catnodp_drop(sts, opt, objnam, 'library', obs);
END;
/

CREATE OR REPLACE PROCEDURE catnodp_drop_pkg(
  sts    OUT VARCHAR2,
  opt    IN  VARCHAR2,
  objnam IN  VARCHAR2, 
  obs    IN  VARCHAR2 DEFAULT NULL)  
IS
BEGIN
  catnodp_drop(sts, opt, objnam, 'package', obs);
END;
/

CREATE OR REPLACE PROCEDURE catnodp_drop_psyn(
  sts    OUT VARCHAR2,
  opt    IN  VARCHAR2,
  objnam IN  VARCHAR2, 
  obs    IN  VARCHAR2 DEFAULT NULL)  
IS
BEGIN
  catnodp_drop(sts, opt, objnam, 'public synonym', obs);
END;
/

CREATE OR REPLACE PROCEDURE catnodp_drop_type(
  sts    OUT VARCHAR2,
  opt    IN  VARCHAR2,
  objnam IN  VARCHAR2, 
  obs    IN  VARCHAR2 DEFAULT NULL)  
IS
BEGIN
  catnodp_drop(sts, opt, objnam, 'type', obs);
END;
/

CREATE OR REPLACE PROCEDURE catnodp_drop_tbl(
  sts    OUT VARCHAR2,
  opt    IN  VARCHAR2,
  objnam IN  VARCHAR2, 
  obs    IN  VARCHAR2 DEFAULT NULL)  
IS
BEGIN
  catnodp_drop(sts, opt, objnam, 'table', obs);
END;
/

CREATE OR REPLACE PROCEDURE catnodp_drop_view(
  sts    OUT VARCHAR2,
  opt    IN  VARCHAR2,
  objnam IN  VARCHAR2, 
  obs    IN  VARCHAR2 DEFAULT NULL)  
IS
BEGIN
  catnodp_drop(sts, opt, objnam, 'view', obs);
END;
/

CREATE OR REPLACE PROCEDURE catnodp_drop_tps(
  sts    OUT VARCHAR2,
  opt    IN  VARCHAR2,
  objnam IN  VARCHAR2, 
  obs    IN  VARCHAR2 DEFAULT NULL)  
IS
  sts1   VARCHAR2(256);
  sts2   VARCHAR2(256);
BEGIN
  catnodp_drop_psyn(sts1, opt, objnam, obs);
  catnodp_drop_type(sts2, opt, objnam, obs);
  sts := sts1 || CHR(10) || sts2;
END;
/

CREATE OR REPLACE PROCEDURE catnodp_drop_vps(
  sts    OUT VARCHAR2,
  opt    IN  VARCHAR2,
  objnam IN  VARCHAR2, 
  obs    IN  VARCHAR2 DEFAULT NULL)  
IS
  sts1   VARCHAR2(256);
  sts2   VARCHAR2(256);
BEGIN
  catnodp_drop_psyn(sts1, opt, objnam, obs);
  catnodp_drop_view(sts2, opt, objnam, obs);
  sts := sts1 || CHR(10) || sts2;
END;
/

CREATE OR REPLACE PROCEDURE catnodp_drop_pkgps(
  sts    OUT VARCHAR2,
  opt    IN  VARCHAR2,
  objnam IN  VARCHAR2, 
  obs    IN  VARCHAR2 DEFAULT NULL)  
IS
  sts1   VARCHAR2(256);
  sts2   VARCHAR2(256);
BEGIN
  catnodp_drop_psyn(sts1, opt, objnam, obs);
  catnodp_drop_pkg (sts2, opt, objnam, obs);
  sts := sts1 || CHR(10) || sts2;
END;
/

----------------------------------------------
-- First, drop all Metadata API objects
----------------------------------------------
@@catnomta.sql '&opt'

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
SET FEEDBACK 0
SET HEADING OFF
SET AUTOPRINT ON
VARIABLE sts VARCHAR2(520)

--
-- ----------------------------------------------------------------------------
-- TYPES
-- ----------------------------------------------------------------------------
--
--...Obsolete ones
exec catnodp_drop_type(:sts, '&opt', 'kupc$_encrypted_pwd',             'OBS');

--...Always drop (related to persistable AQ msgs)
--......With Public Synonym
exec catnodp_drop_tps (:sts, '&opt', 'ku$_logentry1010',             'ALWAYS');
exec catnodp_drop_tps (:sts, '&opt', 'ku$_logline1010',              'ALWAYS');
--......Without Public Synonym
exec catnodp_drop_type(:sts, '&opt', 'kupc$_add_device',             'ALWAYS');
exec catnodp_drop_type(:sts, '&opt', 'kupc$_add_file',               'ALWAYS');
exec catnodp_drop_type(:sts, '&opt', 'kupc$_api_ack',                'ALWAYS');
exec catnodp_drop_type(:sts, '&opt', 'kupc$_bad_file',               'ALWAYS');
exec catnodp_drop_type(:sts, '&opt', 'kupc$_complete_imp_object',    'ALWAYS');
exec catnodp_drop_type(:sts, '&opt', 'kupc$_data_filter',            'ALWAYS');
exec catnodp_drop_type(:sts, '&opt', 'kupc$_data_remap',             'ALWAYS');
exec catnodp_drop_type(:sts, '&opt', 'kupc$_device_ident',           'ALWAYS');
exec catnodp_drop_type(:sts, '&opt', 'kupc$_disk_file',              'ALWAYS');
exec catnodp_drop_type(:sts, '&opt', 'kupc$_encoded_pwd',            'ALWAYS');
exec catnodp_drop_type(:sts, '&opt', 'kupc$_estimate_job',           'ALWAYS');
exec catnodp_drop_type(:sts, '&opt', 'kupc$_exit',                   'ALWAYS');
exec catnodp_drop_type(:sts, '&opt', 'kupc$_file_list',              'ALWAYS');
exec catnodp_drop_type(:sts, '&opt', 'kupc$_fileinfo',               'ALWAYS');
exec catnodp_drop_type(:sts, '&opt', 'kupc$_filelist',               'ALWAYS');
exec catnodp_drop_type(:sts, '&opt', 'kupc$_fixup_virtual_column',   'ALWAYS');
exec catnodp_drop_type(:sts, '&opt', 'kupc$_get_work',               'ALWAYS');
exec catnodp_drop_type(:sts, '&opt', 'kupc$_jobinfo',                'ALWAYS');
exec catnodp_drop_type(:sts, '&opt', 'kupc$_load_data',              'ALWAYS');
exec catnodp_drop_type(:sts, '&opt', 'kupc$_load_metadata',          'ALWAYS');
exec catnodp_drop_type(:sts, '&opt', 'kupc$_lobpieces',              'ALWAYS');
exec catnodp_drop_type(:sts, '&opt', 'kupc$_log_entry',              'ALWAYS');
exec catnodp_drop_type(:sts, '&opt', 'kupc$_log_error',              'ALWAYS');
exec catnodp_drop_type(:sts, '&opt', 'kupc$_logentries',             'ALWAYS');
exec catnodp_drop_type(:sts, '&opt', 'kupc$_master_key_exchange',    'ALWAYS');
exec catnodp_drop_type(:sts, '&opt', 'kupc$_master_msg',             'ALWAYS');
exec catnodp_drop_type(:sts, '&opt', 'kupc$_mastererror',            'ALWAYS');
exec catnodp_drop_type(:sts, '&opt', 'kupc$_masterjobinfo',          'ALWAYS');
exec catnodp_drop_type(:sts, '&opt', 'kupc$_message',                'ALWAYS');
exec catnodp_drop_type(:sts, '&opt', 'kupc$_metadata_filter',        'ALWAYS');
exec catnodp_drop_type(:sts, '&opt', 'kupc$_metadata_remap',         'ALWAYS');
exec catnodp_drop_type(:sts, '&opt', 'kupc$_metadata_transform',     'ALWAYS');
exec catnodp_drop_type(:sts, '&opt', 'kupc$_open',                   'ALWAYS');
exec catnodp_drop_type(:sts, '&opt', 'kupc$_post_mt_init',           'ALWAYS');
exec catnodp_drop_type(:sts, '&opt', 'kupc$_prepare_data',           'ALWAYS');
exec catnodp_drop_type(:sts, '&opt', 'kupc$_recomp',                 'ALWAYS');
exec catnodp_drop_type(:sts, '&opt', 'kupc$_release_files',          'ALWAYS');
exec catnodp_drop_type(:sts, '&opt', 'kupc$_restart',                'ALWAYS');
exec catnodp_drop_type(:sts, '&opt', 'kupc$_restore_logging',        'ALWAYS');
exec catnodp_drop_type(:sts, '&opt', 'kupc$_sequential_file',        'ALWAYS');
exec catnodp_drop_type(:sts, '&opt', 'kupc$_set_parallel',           'ALWAYS');
exec catnodp_drop_type(:sts, '&opt', 'kupc$_set_parameter',          'ALWAYS');
exec catnodp_drop_type(:sts, '&opt', 'kupc$_shadow_key_exchange',    'ALWAYS');
exec catnodp_drop_type(:sts, '&opt', 'kupc$_shadow_msg',             'ALWAYS');
exec catnodp_drop_type(:sts, '&opt', 'kupc$_sql_file_job',           'ALWAYS');
exec catnodp_drop_type(:sts, '&opt', 'kupc$_start_job',              'ALWAYS');
exec catnodp_drop_type(:sts, '&opt', 'kupc$_stop_job',               'ALWAYS');
exec catnodp_drop_type(:sts, '&opt', 'kupc$_stop_worker',            'ALWAYS');
exec catnodp_drop_type(:sts, '&opt', 'kupc$_table_data',             'ALWAYS');
exec catnodp_drop_type(:sts, '&opt', 'kupc$_table_data_array',       'ALWAYS');
exec catnodp_drop_type(:sts, '&opt', 'kupc$_table_datas',            'ALWAYS');
exec catnodp_drop_type(:sts, '&opt', 'kupc$_type_comp_ready',        'ALWAYS');
exec catnodp_drop_type(:sts, '&opt', 'kupc$_unload_data',            'ALWAYS');
exec catnodp_drop_type(:sts, '&opt', 'kupc$_unload_metadata',        'ALWAYS');
exec catnodp_drop_type(:sts, '&opt', 'kupc$_worker_exit',            'ALWAYS');
exec catnodp_drop_type(:sts, '&opt', 'kupc$_worker_file',            'ALWAYS');
exec catnodp_drop_type(:sts, '&opt', 'kupc$_worker_file_list',       'ALWAYS');
exec catnodp_drop_type(:sts, '&opt', 'kupc$_worker_get_pwd',         'ALWAYS');
exec catnodp_drop_type(:sts, '&opt', 'kupc$_worker_log_entry',       'ALWAYS');
exec catnodp_drop_type(:sts, '&opt', 'kupc$_worker_msg',             'ALWAYS');
exec catnodp_drop_type(:sts, '&opt', 'kupc$_workererror',            'ALWAYS');
--...with Public Synonym 
exec catnodp_drop_tps (:sts, '&opt', 'ku$_dumpfile1010');
exec catnodp_drop_tps (:sts, '&opt', 'ku$_dumpfileset1010');
exec catnodp_drop_tps (:sts, '&opt', 'ku$_jobdesc1010');
exec catnodp_drop_tps (:sts, '&opt', 'ku$_jobdesc1020');
exec catnodp_drop_tps (:sts, '&opt', 'ku$_jobdesc1210');
exec catnodp_drop_tps (:sts, '&opt', 'ku$_jobdesc1220');
exec catnodp_drop_tps (:sts, '&opt', 'ku$_jobstatus1010');
exec catnodp_drop_tps (:sts, '&opt', 'ku$_jobstatus1020');
exec catnodp_drop_tps (:sts, '&opt', 'ku$_jobstatus1120');
exec catnodp_drop_tps (:sts, '&opt', 'ku$_jobstatus1210');
exec catnodp_drop_tps (:sts, '&opt', 'ku$_jobstatus1220');
exec catnodp_drop_tps (:sts, '&opt', 'ku$_paramvalue1010');
exec catnodp_drop_tps (:sts, '&opt', 'ku$_paramvalues1010');
exec catnodp_drop_tps (:sts, '&opt', 'ku$_status1010');
exec catnodp_drop_tps (:sts, '&opt', 'ku$_status1020');
exec catnodp_drop_tps (:sts, '&opt', 'ku$_status1120');
exec catnodp_drop_tps (:sts, '&opt', 'ku$_status1210');
exec catnodp_drop_tps (:sts, '&opt', 'ku$_status1220');
exec catnodp_drop_tps (:sts, '&opt', 'ku$_workerstatus1010');
exec catnodp_drop_tps (:sts, '&opt', 'ku$_workerstatus1020');
exec catnodp_drop_tps (:sts, '&opt', 'ku$_workerstatus1120');
exec catnodp_drop_tps (:sts, '&opt', 'ku$_workerstatus1210'); 
exec catnodp_drop_tps (:sts, '&opt', 'ku$_workerstatus1220');
exec catnodp_drop_tps (:sts, '&opt', 'ku$_workerstatuslist1010');
exec catnodp_drop_tps (:sts, '&opt', 'ku$_workerstatuslist1020');
exec catnodp_drop_tps (:sts, '&opt', 'ku$_workerstatuslist1120');
exec catnodp_drop_tps (:sts, '&opt', 'ku$_workerstatuslist1210'); 
exec catnodp_drop_tps (:sts, '&opt', 'ku$_workerstatuslist1220');
--...without Public Synonym 
exec catnodp_drop_type(:sts, '&opt', 'ku$_dropcollist');
exec catnodp_drop_type(:sts, '&opt', 'ku$_dumpfile_info');
exec catnodp_drop_type(:sts, '&opt', 'ku$_dumpfile_item');
exec catnodp_drop_type(:sts, '&opt', 'kupc$_mdfilepiece');
exec catnodp_drop_type(:sts, '&opt', 'kupc$_mdfilepiecelist');
exec catnodp_drop_type(:sts, '&opt', 'kupc$_mdreploffsets');
exec catnodp_drop_type(:sts, '&opt', 'kupc$_mdreploffsetslist');
exec catnodp_drop_type(:sts, '&opt', 'kupc$_mt_col_info');
exec catnodp_drop_type(:sts, '&opt', 'kupc$_mt_col_info_list');
exec catnodp_drop_type(:sts, '&opt', 'kupc$_mt_info');
exec catnodp_drop_type(:sts, '&opt', 'kupc$_mt_info_list');
exec catnodp_drop_type(:sts, '&opt', 'kupc$_par_con');

--
-- ----------------------------------------------------------------------------
-- VIEWS
-- ----------------------------------------------------------------------------
--...With public synonym
exec catnodp_drop_vps(:sts, '&opt', 'cdb_datapump_jobs');
exec catnodp_drop_vps(:sts, '&opt', 'cdb_datapump_sessions');
exec catnodp_drop_vps(:sts, '&opt', 'dba_datapump_jobs');
exec catnodp_drop_vps(:sts, '&opt', 'dba_datapump_sessions');
exec catnodp_drop_vps(:sts, '&opt', 'user_datapump_jobs');
--...Without public synonym
exec catnodp_drop_view(:sts, '&opt', 'gv_$datapump_job');
exec catnodp_drop_view(:sts, '&opt', 'gv_$datapump_session');
exec catnodp_drop_view(:sts, '&opt', 'ku$_all_tsltz_tab_cols');
exec catnodp_drop_view(:sts, '&opt', 'ku$_all_tsltz_tables');
exec catnodp_drop_view(:sts, '&opt', 'ku$_child_nested_tab_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_object_status_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_refpar_level');
exec catnodp_drop_view(:sts, '&opt', 'ku$_table_exists_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_user_mapping_view');
exec catnodp_drop_view(:sts, '&opt', 'ku_noexp_view');
exec catnodp_drop_view(:sts, '&opt', 'v_$datapump_job');
exec catnodp_drop_view(:sts, '&opt', 'v_$datapump_session');
--
-- ----------------------------------------------------------------------------
-- TABLES 
-- ----------------------------------------------------------------------------
--
--...Obsolete ones
exec catnodp_drop_tbl (:sts, '&opt', 'ku$_expdp_impdp_master_10_1',     'OBS');
exec catnodp_drop_tbl (:sts, '&opt', 'ku$_expdp_impdp_master_11_1',     'OBS');
--...Support for VIEW-AS-TABLE
exec catnodp_drop_tbl (:sts, '&opt', 'ku$_user_mapping_view_tbl');
--...Support EXCLUDE_NOEXP filter
exec catnodp_drop_tbl (:sts, '&opt', 'ku_noexp_tab');
exec catnodp_drop_tbl (:sts, '&opt', 'ku$noexp_tab');
--...Support very long list filters
exec catnodp_drop_tbl (:sts, '&opt', 'ku$_list_filter_temp');
exec catnodp_drop_tbl (:sts, '&opt', 'ku$_list_filter_temp_2');
--...Sharding related
exec catnodp_drop_tbl (:sts, '&opt', 'ku$_shard_domidx_namemap');

--
-- ----------------------------------------------------------------------------
-- PUBLIC SYNONYMS
-- ----------------------------------------------------------------------------
--
--...Fixed synonyms
exec catnodp_drop_psyn(:sts, '&opt', 'gv$datapump_job');
exec catnodp_drop_psyn(:sts, '&opt', 'gv$datapump_session');
exec catnodp_drop_psyn(:sts, '&opt', 'v$datapump_job');
exec catnodp_drop_psyn(:sts, '&opt', 'v$datapump_session');
--...DBMS_DATAPUMP.GET_STATUS synonyms 
exec catnodp_drop_psyn(:sts, '&opt', 'ku$_dumpfile');
exec catnodp_drop_psyn(:sts, '&opt', 'ku$_dumpfile1020');
exec catnodp_drop_psyn(:sts, '&opt', 'ku$_dumpfile_info');
exec catnodp_drop_psyn(:sts, '&opt', 'ku$_dumpfile_item');
exec catnodp_drop_psyn(:sts, '&opt', 'ku$_dumpfileset');
exec catnodp_drop_psyn(:sts, '&opt', 'ku$_dumpfileset1020');
exec catnodp_drop_psyn(:sts, '&opt', 'ku$_jobdesc');
exec catnodp_drop_psyn(:sts, '&opt', 'ku$_jobstatus');
exec catnodp_drop_psyn(:sts, '&opt', 'ku$_logentry');
exec catnodp_drop_psyn(:sts, '&opt', 'ku$_logentry1020');
exec catnodp_drop_psyn(:sts, '&opt', 'ku$_logline');
exec catnodp_drop_psyn(:sts, '&opt', 'ku$_logline1020');
exec catnodp_drop_psyn(:sts, '&opt', 'ku$_paramvalue');
exec catnodp_drop_psyn(:sts, '&opt', 'ku$_paramvalue1020');
exec catnodp_drop_psyn(:sts, '&opt', 'ku$_paramvalues');
exec catnodp_drop_psyn(:sts, '&opt', 'ku$_paramvalues1020');
exec catnodp_drop_psyn(:sts, '&opt', 'ku$_status');
exec catnodp_drop_psyn(:sts, '&opt', 'ku$_workerstatus' );
exec catnodp_drop_psyn(:sts, '&opt', 'ku$_workerstatuslist');
exec catnodp_drop_psyn(:sts, '&opt', 'kupcc');
exec catnodp_drop_psyn(:sts, '&opt', 'kuputil');
--...DataPump package and master table object type
exec catnodp_drop_psyn(:sts, '&opt', 'dbms_datapump');
--
-- ----------------------------------------------------------------------------
-- FUNCTIONS
-- ----------------------------------------------------------------------------
--
exec catnodp_drop     (:sts, '&opt', 'kupc$_tab_mt_cols', 'function');

--
-- ----------------------------------------------------------------------------
-- PACKAGES
-- ----------------------------------------------------------------------------
--
--...API packages
exec catnodp_drop_pkg (:sts, '&opt', 'dbms_datapump');
exec catnodp_drop_pkg (:sts, '&opt', 'dbms_datapump_int');
exec catnodp_drop_pkg (:sts, '&opt', 'dbms_datapump_utl');
--...private internal packages
exec catnodp_drop_pkg (:sts, '&opt', 'kupcc');
exec catnodp_drop_pkg (:sts, '&opt', 'kupc$queue');
exec catnodp_drop_pkg (:sts, '&opt', 'kupc$queue_int');
exec catnodp_drop_pkg (:sts, '&opt', 'kupc$que_int');
exec catnodp_drop_pkg (:sts, '&opt', 'kupf$file');
exec catnodp_drop_pkg (:sts, '&opt', 'kupf$file_int');
exec catnodp_drop_pkg (:sts, '&opt', 'kupm$mcp');
exec catnodp_drop_pkg (:sts, '&opt', 'kupp$proc');
exec catnodp_drop_pkg (:sts, '&opt', 'kupu$utilities');
exec catnodp_drop_pkg (:sts, '&opt', 'kupu$utilities_int');
exec catnodp_drop_pkg (:sts, '&opt', 'kupv$ft');
exec catnodp_drop_pkg (:sts, '&opt', 'kupv$ft_int');
exec catnodp_drop_pkg (:sts, '&opt', 'kupw$worker');
exec catnodp_drop_pkg (:sts, '&opt', 'kupd$data');
exec catnodp_drop_pkg (:sts, '&opt', 'kupd$data_int');
--
-- ----------------------------------------------------------------------------
-- LIBRARIES -  DataPump private libraries
-- ----------------------------------------------------------------------------
--
exec catnodp_drop_lib (:sts, '&opt', 'dbms_datapump_dv_lib');
exec catnodp_drop_lib (:sts, '&opt', 'kupclib');
exec catnodp_drop_lib (:sts, '&opt', 'kupdlib');
exec catnodp_drop_lib (:sts, '&opt', 'kupflib');
exec catnodp_drop_lib (:sts, '&opt', 'kupp_proc_lib');
exec catnodp_drop_lib (:sts, '&opt', 'kupulib');
exec catnodp_drop_lib (:sts, '&opt', 'kupvlib');

-- Done with temporary procedures.  Drop first the ones that call others.
DROP PROCEDURE catnodp_drop_tps;
DROP PROCEDURE catnodp_drop_vps;
DROP PROCEDURE catnodp_drop_pkgps;

DROP PROCEDURE catnodp_drop_idx;
DROP PROCEDURE catnodp_drop_lib;
DROP PROCEDURE catnodp_drop_pkg;
DROP PROCEDURE catnodp_drop_psyn;
DROP PROCEDURE catnodp_drop_type;
DROP PROCEDURE catnodp_drop_tbl;
DROP PROCEDURE catnodp_drop_view;
-- Drop last as all others refer to this
DROP PROCEDURE catnodp_drop;

--
-- Reset output
--
SET HEADING ON
SET AUTOPRINT OFF
SET FEEDBACK 1
