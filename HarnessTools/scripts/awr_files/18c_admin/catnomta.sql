rem
Rem $Header: rdbms/admin/catnomta.sql /main/147 2017/10/22 11:20:36 sdavidso Exp $
Rem
Rem catnomta.sql
Rem
Rem Copyright (c) 2002, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catnomta.sql - Drop all Metadata API objects
Rem
Rem    DESCRIPTION
Rem      Invoked from catnodp as part of unrolling of the Data Pump entirely.
Rem
Rem    PARAMETERS
Rem      opt - what option to use when executing this script:
Rem            OBSOLETE: remove obsolete and required objects only
Rem            ALL:      remove all objects (original behavior)
DEFINE opt=&1
Rem
Rem    NOTES
Rem      Regarding the obs parameter values to drop procedure:  
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
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catnomta.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catnomta.sql
Rem SQL_PHASE: DOWNGRADE
Rem SQL_STARTUP_MODE: UPGRADE
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catnodp.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    sdavidso    10/17/17 - lrg-20624856 - domain index on varray store as
Rem                           table
Rem    sdavidso    08/24/17 - bug 25453685 move chunk support for domain index
Rem    jjanosik    06/22/17 - Bug 24719359: Add support for RADM Policy
Rem                           Expressions
Rem    bwright     06/13/17 - Bug 25651930: Add OBSOLETE, ALL script options.
Rem                           Merge in catnomtt; catnomta invoked only from
Rem                           catnodp. Remove catnomtt, catmet, and catnomet.
Rem    qinwu       01/19/17 - proj 70151: support db capture and replay auth
Rem    jjanosik    10/07/16 - Bug 24661809 - drop new views
Rem    bwright     09/15/16 - Cleanup output from running dpload
Rem    sdavidso    09/14/16 - bug 24662289 - drop KU$_PROCOBJ_LINES_TAB
Rem    bwright     09/08/16 - Bug 24513141: Remove project 30935 implementation
Rem    sdavidso    02/18/16 - bug22577904 shard P2T - missing constraint
Rem    youyang     02/16/16 - bug22672722: add index functions for DV
Rem    jjanosik    02/11/16 - bug 20317926 - drop ku$_12_1_trigger_view
Rem    sdavidso    12/11/15 - bug22264616 more move chunk subpart
Rem    sdavidso    11/19/15 - bug21869037 chunk move w/subpartitions
Rem    smesropi    11/08/15 - Bug 21171628: Rename HCS tables
Rem    jibyun      11/01/15 - support DIAGNOSTIC auth for Database Vault
Rem    mstasiew    09/25/15 - Bug 21867527: hier cube measure cache
Rem    mstasiew    08/31/15 - Bug 21384694: HCS hier hier attr classifications
Rem    mjangir     08/25/15 - bug 21690220: Update SQL metadata
Rem    sdavidso    08/17/15 - bug-20756759: lobs, indexes, droppped tables
Rem    tbhukya     08/17/15 - Bug 21555645: Drop ku$_map_tabpart_view
Rem    tbhukya     08/11/15 - Bug 21474798: Drop synonym ku$_Unpacked_AnyData_t
Rem    sdavidso    08/03/15 - bug21539111: include check constraint for P2T exp
Rem    yanchuan    07/27/15 - Bug 21299533: support for Database Vault
Rem                           Authorization
Rem    sanbhara    06/01/15 - Bug 21158282 - dropping
Rem                           ku$_dummy_comm_rule_alts_v.
Rem    mstasiew    05/13/15 - Bug 20845789: Add more hcs views
Rem    tbhukya     04/09/15 - Bug 20862737: drop view ku$_hcs_src_col_view 
Rem    sdavidso    03/24/15 - lrg-15576931 drop ku$_index_objnum_view
Rem    sdavidso    01/25/15 - proj 56220 - partition transportable
Rem    sdavidso    12/11/14 - parallel export
Rem    beiyu       12/11/14 - Proj 47091: drop views of new HCS objects
Rem    bwright     11/17/14 - Support 'audit policy by granted roles'
Rem    kaizhuan    11/11/14 - Project 46812: support for Database Vault policy
Rem    rapayne     10/20/14 - proj xs grants.
Rem    gclaborn    09/12/14 - 30395: drop views that move plsql src as tables
Rem    tbhukya     09/10/14 - Lrg 13217417: Remove ku$_12_1_index_view
Rem    jibyun      08/06/14 - Project 46812: support for Database Vault policy
Rem    rapayne     04/26/14 - proj 46816: support for new sysrac priv.
Rem    lbarton     04/23/14 - bug 18374198: default on null
Rem    tbhukya     12/11/13 - Bug 17803321: drop ku$_12_1_index_view
Rem    sdavidso    11/03/13 - bug17718297 - IMC selective column
Rem    lbarton     10/02/13 - Project 48787: views to document mdapi transforms
Rem    sdavidso    09/23/13 - proj-47829 don't export READ priv to pre 12.1.0.2
Rem    lbarton     06/27/13 - bug 16800820: valid-time temporal
Rem    rapayne     04/15/13 - bug 16310682: reduce memory for procact_schema
Rem    sdavidso    12/24/12 - XbranchMerge sdavidso_bug14490576-2 from
Rem                           st_rdbms_12.1.0.1
Rem    sdavidso    12/14/12 - drop ku$_ptable_ts_view
Rem    rapayne     11/06/12 - bug 15832675: remove 11_2_view_view
Rem    sdavidso    11/01/12 - bug14490576 - 2ndary tables for
Rem                           full/transportable
Rem    lbarton     10/11/12 - bug 14358248: non-privileged parallel export of
Rem                           views-as-tables fails
Rem    lbarton     10/03/12 - bug 10350062: ILM compression and storage tiering
Rem    bwright     10/03/12 - Bug 14679947: Add import TYPE retry w/o evolution
Rem    rapayne     09/12/12 - bug 13899189: do not fetch tables with virtual
Rem                           columns when version < 11g.
Rem    traney      08/02/12 - 14407652: edition enhancements
Rem    rapayne     08/10/12 - lrg 7071802: new mviews to support secondary
Rem                           materialized views.
Rem    lbarton     07/26/12 - bug 13454387: long varchar
Rem    ssonawan    07/19/12 - bug 13843068: drop ku$_11_2_psw_hist_view
Rem    dgagne      05/24/12 - add oracle supplied view
Rem    rapayne     05/13/12 - lrg 6984241: drop new views.
Rem    rapayne     03/22/12 - Project 39632: CREATE LIBRARY enhancements
Rem    ebatbout    01/30/12 - Project 36950: Code_Base_Grant support
Rem    sdavidso    12/14/11 - add audit policy objects
Rem    ebatbout    11/09/11 - Project 36951: On_User_Grant support
Rem    sdavidso    11/08/11 - lrg 6000876: don't export 12.1 privs to pre-12
Rem    lbarton     10/27/11 - 36954_dpump_tabcluster_zonemap
Rem    lbarton     10/13/11 - bug 13092452: hygiene
Rem    dgagne      09/21/11 - add new drops for stats
Rem    rapayne     08/08/11 - Project 36780: Identity Column support.
Rem    rapayne     07/22/11 - add ku$_xsrls_policy_view
Rem    sdavidso    07/08/11 - add drop of ku_niotable_data_view
Rem    dahlim      06/07/11 - proj 32006: Import/Export support for RADM
Rem    lbarton     04/18/11 - bug 10186633: virtual column
Rem    sdavidso    04/04/11 - Merge full transportable from 11.2.0.3
Rem    lbarton     02/21/11 - ku$_10_2_rogrant_view
Rem    sdavidso    02/17/11 - new flags for impcalloutreg
Rem    gclaborn    02/14/11 - Remove impcallout views not being used
Rem    sdavidso    01/24/11 - merge project 37216 bl1
Rem    sdavidso    01/11/11 - support export of registered packages
Rem    lbarton     01/07/11 - views-as-tables
Rem    sdavidso    12/16/10 - Extend full exp for options
Rem    rapayne     07/20/10 - Triton Security support
Rem    ebatbout    05/25/10 - bug 9491530: drop ku$_10_2_fhtable_view
Rem    lbarton     04/28/10 - bug 9491539: drop ku$_10_2_strmsubcoltype_view
Rem    sdavidso    04/21/10 - bug9480755: export dependant xmlschemas
Rem    sdavidso    04/14/10 - Bug 8847153: reduce resources for xmlschema
Rem    mjangir     01/12/10 - bug 6644244: drop view ku$_map_table_view
Rem    dgagne      12/30/09 - add drops or types and views
Rem    sdavidso    07/14/09 - bug 8352607: support minimize records_per_block
Rem    lbarton     03/26/09 - add EXPORT_PATHS views
Rem    sdavidso    05/06/09 - bug 7597578: support NT partition properties
Rem    sdavidso    03/26/09 - lrg 3841517: drop KU$_XDB_NTABLE_OBJNUM_VIEW
Rem    lbarton     02/18/09 - bug 8252494: ku$_deferred_stg
Rem    sdavidso    10/09/08 - bug 7362589: drop new ku$_schemaobjnum_view
Rem    pknaggs     07/07/08 - bug 6938028: Factor and Rule support for DVPS.
Rem    sdavidso    06/25/08 - lrg 3454005: drop view and type for temp mv_log
Rem    pknaggs     06/24/08 - bug 6938028: Database Vault Protected Schema.
Rem    dgagne      06/16/08 - change 10_2_objgrant to 11_1_objgrant
Rem    lbarton     04/15/08 - bug 6969874: move compare APIs to their own
Rem                           package
Rem    rapayne     03/25/08 - bug 6088114: drop new type related views
Rem    htseng      12/04/07 - drop KU$_EQNTABLE_DATA_VIEW
Rem    lbarton     11/02/07 - bug 6060058: flashback archived tables
Rem    dgagne      10/26/07 - remove ku_10_2_ind_stats_view
Rem    rapayne     07/23/07 - bug ?? - expand type attributes
Rem    dgagne      05/18/07 - remove new types and views
Rem    lbarton     10/05/06 - more interval partitioning
Rem    sdavidso    09/18/06 - MDAPI editions support
Rem    dgagne      08/29/06 - add drops of user pref stat objects
Rem    lbarton     08/31/06 - lrg 2453260: dpstream compatibility
Rem    sdavidso    07/31/06 - drop 10_1_daudit_view
Rem    wesmith     05/23/06 - add ku$_triggerdep_view, ku$_10_2_trigger_view
Rem    dgagne      05/11/06 - add drop view for ku_tab_subname_view and
Rem                           ku$_ind_subname_view
Rem    cchiappa    04/11/06 - ORGANIZATION CUBE tables 
Rem    lbarton     04/06/06 - bug 5120417: ku$_prepost_view 
Rem    dgagne      01/27/06 - add views to get tablespaces based on partitions 
Rem    rapayne     10/07/05 - bug 4628170 - add ku$_all_index_view
Rem    lbarton     05/10/05 - lrg 1852411: drop find_sgi(c)_cols views 
Rem    lbarton     05/03/05 - bug 4338348: ku$_10_1_sysgrant_view
Rem    lbarton     07/28/04 - encryption support 
Rem    lbarton     06/11/04 - versioning support for dblink, statistics 
Rem    dgagne      05/18/04 - add drops for 10_0_1 objects 
Rem    lbarton     01/28/04 - dbms_metadata_build and dbms_metadata_dpbuild 
Rem    htseng      04/15/04 - drop new template partition views
Rem    htseng      04/12/04 - drop new view ku$_qtab_storage_view 
Rem    dgagne      03/10/04 - change drops to match catmeta for statistics 
Rem    dgagne      01/06/04 - drop new view 
Rem    dgagne      12/03/03 - DROP NEW TYPES AND VIEWS 
Rem    lbarton     10/30/03 - alter_proc_view, etc. 
Rem    lbarton     09/18/03 - Bug 3130275: domain index fix 
Rem    lbarton     07/28/03 - Bug 3045926: ku$_procobj_loc(s)
Rem    lbarton     05/27/03 - add MV/MVlogs to transportable_export
Rem    lbarton     05/16/03 - bug 2949397: support INDEXTYPE options
Rem    lbarton     05/07/03 - bug 2944274: bitmap join indexes
Rem    gclaborn    05/20/03 - Add ku$_unload_method_view
Rem    lbarton     04/11/03 - ku$_ntable_bytes_alloc_view
Rem    lbarton     03/17/03 - bug 2837703: fix table_data bytes_alloc
Rem    lbarton     01/30/03 - add types to transportable_export
Rem    lbarton     01/24/03 - sort types
Rem    lbarton     01/09/03 - ku$_ObjNumSet
Rem    nmanappa    12/27/02 - audit default options
Rem    lbarton     12/11/02 - get more trigger metadata
Rem    lbarton     11/12/02 - procedural object changes
Rem    lbarton     10/09/02 - ku_multi_ddls
Rem    lbarton     09/20/02 - add DATAPUMP_PATHMAP view
Rem    lbarton     10/01/02 - add DATAPUMP_REMAP_OBJECTS
Rem    lbarton     08/02/02 - transportable export
Rem    htseng      06/25/02 - add post/pre table action support
Rem    lbarton     07/18/02 - callouts
Rem    lbarton     06/05/02 - bugfix
Rem    lbarton     05/13/02 - bugfix
Rem    lbarton     04/26/02 - domain index support
Rem    htseng      04/26/02 - add procedural objects and actions API.
Rem    lbarton     04/16/02 - add DPSTREAM_TABLE object
Rem    htseng      04/16/02 - add refresh group monitoring support.
Rem    gclaborn    04/14/02 - gclaborn_catdp
Rem    gclaborn    04/10/02 - Created
Rem

-- Minimize output.  Note SET HEADING OFF and SET AUTOPRINT ON is use to
-- output the result of the drop procedure calls where we pass back the
-- result of the drop operation in the bind variable.  Oracle doc describes
-- this: "To automatically display bind variables referenced in a successful 
-- PL/SQL block or used in an EXECUTE command, use the AUTOPRINT clause of 
-- the SET command".  We use this esoteric method as the procedure cannot
-- use DBMS_OUTPUT to output this information as the DBMS_OUTPUT package is
-- not already loaded/valid by time our scripts are run.
SET FEEDBACK 0
SET HEADING OFF
SET AUTOPRINT ON
VARIABLE sts VARCHAR2(520)

--
-- ----------------------------------------------------------------------------
-- TYPES of Metadata API
-- ----------------------------------------------------------------------------
--
--...Obsolete ones
exec catnodp_drop_type(:sts, '&opt', 'ku$_11_1_objgrant_t',             'OBS');
exec catnodp_drop_type(:sts, '&opt', 'ku$_attr_dim_lkey_grp_list_t',    'OBS');
exec catnodp_drop_type(:sts, '&opt', 'ku$_attr_dim_lkey_grp_t',         'OBS');
exec catnodp_drop_type(:sts, '&opt', 'ku$_column_list_t',               'OBS');
exec catnodp_drop_type(:sts, '&opt', 'ku$_column_t',                    'OBS');
exec catnodp_drop_type(:sts, '&opt', 'ku$_fhtable_t',                   'OBS');
exec catnodp_drop_type(:sts, '&opt', 'ku$_find_hidden_cons_t',          'OBS');
exec catnodp_drop_type(:sts, '&opt', 'ku$_htable_t',                    'OBS');
exec catnodp_drop_type(:sts, '&opt', 'ku$_ind_col_list_t',              'OBS');
exec catnodp_drop_type(:sts, '&opt', 'ku$_ind_col_t',                   'OBS');
exec catnodp_drop_type(:sts, '&opt', 'ku$_ind_subpart_list_t',          'OBS');
exec catnodp_drop_type(:sts, '&opt', 'ku$_ind_subpart_t',               'OBS');
exec catnodp_drop_type(:sts, '&opt', 'ku$_io_ntable_t',                 'OBS');
exec catnodp_drop_type(:sts, '&opt', 'ku$_iotable_t',                   'OBS');
exec catnodp_drop_type(:sts, '&opt', 'ku$_lobfrag_t',                   'OBS');
exec catnodp_drop_type(:sts, '&opt', 'ku$_lobfragindex_t',              'OBS');
exec catnodp_drop_type(:sts, '&opt', 'ku$_pcolumn_list_t',              'OBS');
exec catnodp_drop_type(:sts, '&opt', 'ku$_pcolumn_t',                   'OBS');
exec catnodp_drop_type(:sts, '&opt', 'ku$_pfhtable_t',                  'OBS');
exec catnodp_drop_type(:sts, '&opt', 'ku$_phtable_t',                   'OBS');
exec catnodp_drop_type(:sts, '&opt', 'ku$_piotable_t',                  'OBS');
exec catnodp_drop_type(:sts, '&opt', 'ku$_prim_column_list_t',          'OBS');
exec catnodp_drop_type(:sts, '&opt', 'ku$_prim_column_t',               'OBS');
exec catnodp_drop_type(:sts, '&opt', 'ku$_privname_list_t',             'OBS');
exec catnodp_drop_type(:sts, '&opt', 'ku$_privname_t',                  'OBS');
exec catnodp_drop_type(:sts, '&opt', 'ku$_sgr_sge_t',                   'OBS');
exec catnodp_drop_type(:sts, '&opt', 'ku$_type_versionline_list_t',     'OBS');
exec catnodp_drop_type(:sts, '&opt', 'ku$_type_versionline_t',          'OBS');
--...Types with Public Synonym
exec catnodp_drop_tps (:sts, '&opt', 'ku$_auddef_t');
exec catnodp_drop_tps (:sts, '&opt', 'ku$_audit_default_list_t');
exec catnodp_drop_tps (:sts, '&opt', 'ku$_audit_list_t');
exec catnodp_drop_tps (:sts, '&opt', 'ku$_audobj_t');
exec catnodp_drop_tps (:sts, '&opt', 'ku$_chunk_list_t');
exec catnodp_drop_tps (:sts, '&opt', 'ku$_chunk_t');
exec catnodp_drop_tps (:sts, '&opt', 'ku$_ddl');
exec catnodp_drop_tps (:sts, '&opt', 'ku$_ddls');
exec catnodp_drop_tps (:sts, '&opt', 'ku$_errorline');
exec catnodp_drop_tps (:sts, '&opt', 'ku$_errorlines');
exec catnodp_drop_tps (:sts, '&opt', 'ku$_java_t'); 
exec catnodp_drop_tps (:sts, '&opt', 'ku$_multi_ddl');
exec catnodp_drop_tps (:sts, '&opt', 'ku$_multi_ddls');
exec catnodp_drop_tps (:sts, '&opt', 'ku$_objnumnam');
exec catnodp_drop_tps (:sts, '&opt', 'ku$_objnumnamset');
exec catnodp_drop_tps (:sts, '&opt', 'ku$_objnumpair');
exec catnodp_drop_tps (:sts, '&opt', 'ku$_objnumpairlist');
exec catnodp_drop_tps (:sts, '&opt', 'ku$_objnumset');
exec catnodp_drop_tps (:sts, '&opt', 'ku$_parsed_item');
exec catnodp_drop_tps (:sts, '&opt', 'ku$_parsed_items');
exec catnodp_drop_tps (:sts, '&opt', 'ku$_procobj_line');
exec catnodp_drop_tps (:sts, '&opt', 'ku$_procobj_lines');
exec catnodp_drop_tps (:sts, '&opt', 'ku$_procobj_lines_tab');
exec catnodp_drop_tps (:sts, '&opt', 'ku$_procobj_loc');
exec catnodp_drop_tps (:sts, '&opt', 'ku$_procobj_locs');
exec catnodp_drop_tps (:sts, '&opt', 'ku$_source_list_t');
exec catnodp_drop_tps (:sts, '&opt', 'ku$_source_t');
exec catnodp_drop_tps (:sts, '&opt', 'ku$_submitresult');
exec catnodp_drop_tps (:sts, '&opt', 'ku$_submitresults');
exec catnodp_drop_tps (:sts, '&opt', 'ku$_taction_list_t');
exec catnodp_drop_tps (:sts, '&opt', 'ku$_taction_t');
exec catnodp_drop_tps (:sts, '&opt', 'ku$_unpacked_anydata_t');
exec catnodp_drop_tps (:sts, '&opt', 'ku$_vcnt');
exec catnodp_drop_tps (:sts, '&opt', 'ku$_xmlcolset_t');
--...Types without Public Synonym
exec catnodp_drop_type(:sts, '&opt', 'ku$_10_1_col_stats_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_10_1_col_stats_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_10_1_ind_stats_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_10_1_pind_stats_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_10_1_pind_stats_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_10_1_ptab_stats_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_10_1_spind_stats_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_10_1_spind_stats_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_10_1_tab_ptab_stats_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_10_1_tab_stats_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_10_2_strmcol_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_10_2_strmcol_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_10_2_strmcoltype_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_10_2_strmtable_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_11_2_ind_stats_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_11_2_tab_stats_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_add_snap_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_add_snap_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_alter_proc_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_argument_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_argument_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_assoc_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_audit_act_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_audit_act_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_audit_attr_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_audit_context_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_audit_default_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_audit_namespace_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_audit_namespace_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_audit_obj_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_audit_pol_role_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_audit_pol_role_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_audit_policy_enable_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_audit_policy_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_audit_sys_priv_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_audit_sys_priv_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_audit_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_auditp_obj_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_auditp_obj_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_bytes_alloc_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_cached_stats_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_callout_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_clst_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_clst_zonemap_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_clstcol_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_clstcol_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_clstjoin_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_clstjoin_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_cluster_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_col_stats_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_col_stats_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_collection_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_coltype_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_comment_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_constraint0_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_constraint0_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_constraint1_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_constraint1_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_constraint2_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_constraint2_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_constraint_col_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_constraint_col_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_constraint_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_context_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_credential_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_cube_dim_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_cube_dim_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_cube_fact_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_cube_fact_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_cube_hier_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_cube_hier_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_cube_tab_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_dblink_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_deferred_stg_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_defrole_item_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_defrole_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_defrole_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_dimension_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_directory_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_domidx_2ndtab_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_domidx_2ndtab_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_domidx_plsql_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_exp_pkg_body_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_exp_type_body_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_extloc_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_extloc_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_exttab_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_fba_period_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_fba_period_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_fba_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_fga_policy_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_fga_rel_col_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_fga_rel_col_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_file_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_file_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_find_sgc_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_full_pkg_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_full_type_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_histgrm_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_histgrm_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_hnt_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_hntp_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_identity_col_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_identity_colobj_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_ilm_policy_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_ilm_policy_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_im_colsel_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_im_colsel_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_ind_compart_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_ind_compart_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_ind_part_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_ind_part_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_ind_partobj_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_ind_stats_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_indarraytype_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_indarraytype_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_index_col_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_index_col_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_index_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_index_objnum_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_index_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_indexop_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_indexop_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_indextype_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_insert_ts_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_insert_ts_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_io_table_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_iont_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_iot_partobj_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_java_class_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_java_resource_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_java_source_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_jijoin_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_jijoin_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_jijoin_table_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_jijoin_table_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_job_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_library_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_lob_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_lobcomppart_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_lobcomppart_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_lobfrag_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_lobindex_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_m_view_fh_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_m_view_h_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_m_view_iot_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_m_view_log_fh_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_m_view_log_h_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_m_view_log_pfh_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_m_view_log_ph_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_m_view_log_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_m_view_pfh_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_m_view_ph_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_m_view_piot_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_m_view_scm_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_m_view_scm_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_m_view_srt_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_m_view_srt_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_m_view_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_map_table_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_map_tabpart_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_marker_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_method_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_method_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_monitor_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_mv_deptbl_objnum_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_nt_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_nt_parent_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_nt_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_ntpart_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_ntpart_parent_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_ntpart_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_objgrant_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_objgrant_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_objnum');
exec catnodp_drop_type(:sts, '&opt', 'ku$_objpkg_privs_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_objpkg_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_oidindex_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_opancillary_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_opancillary_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_oparg_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_oparg_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_opbinding_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_opbinding_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_operator_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_opqtype_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_option_objnum_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_outline_hint_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_outline_hint_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_outline_node_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_outline_node_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_outline_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_ov_table_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_ov_tabpart_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_ov_tabpart_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_part_col_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_part_col_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_partition_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_partlob_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_partobj_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_pind_stats_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_pind_stats_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_piot_part_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_piot_part_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_pkref_constraint_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_pkref_constraint_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_plugts_blk_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_plugts_tablespace_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_post_data_table_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_prepost_table_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_proc_objnum_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_proc_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_procact_instance_t'); 
exec catnodp_drop_type(:sts, '&opt', 'ku$_procact_instance_tbl_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_procact_schema_t'); 
exec catnodp_drop_type(:sts, '&opt', 'ku$_procact_t'); 
exec catnodp_drop_type(:sts, '&opt', 'ku$_procc_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_procdepobj_t'); 
exec catnodp_drop_type(:sts, '&opt', 'ku$_procdepobja_t'); 
exec catnodp_drop_type(:sts, '&opt', 'ku$_procdepobjg_t'); 
exec catnodp_drop_type(:sts, '&opt', 'ku$_procinfo_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_procjava_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_procobj_audit_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_procobj_grant_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_procobj_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_procobjact_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_procplsql_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_profile_attr_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_profile_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_profile_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_proxy_role_item_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_proxy_role_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_proxy_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_psw_hist_item_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_psw_hist_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_psw_hist_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_ptab_stats_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_qtab_storage_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_qtrans_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_queue_table_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_queues_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_ref_constraint_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_refcol_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_refcol_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_refgroup_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_resocost_item_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_resocost_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_resocost_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_rls_assoc_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_rls_associations_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_rls_context_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_rls_group_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_rls_policy_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_rls_policy_objnum_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_rls_policy_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_rls_sec_rel_col_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_rls_sec_rel_col_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_rmgr_consumer_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_rmgr_init_consumer_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_rmgr_plan_direct_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_rmgr_plan_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_rogrant_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_role_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_rollback_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_schemaobj_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_sequence_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_sgi_col_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_sgi_col_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_simple_col_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_simple_col_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_simple_type_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_slog_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_slog_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_spind_stats_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_spind_stats_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_storage_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_strmcol_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_strmcol_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_strmcoltype_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_strmsubcoltype_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_strmsubcoltype_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_strmtable_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_subcoltype_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_subcoltype_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_switch_compiler_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_synonym_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_sysgrant_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_tab_bytes_alloc_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_tab_col_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_tab_col_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_tab_column_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_tab_column_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_tab_compart_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_tab_compart_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_tab_part_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_tab_part_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_tab_partobj_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_tab_ptab_stats_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_tab_stats_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_tab_subpart_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_tab_subpart_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_tab_tsubpart_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_tab_tsubpart_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_tabclst_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_tabcluster_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_table_data_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_table_objnum_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_table_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_tablespace_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_tbs_ilm_policy_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_temp_subpart_t'); 
exec catnodp_drop_type(:sts, '&opt', 'ku$_temp_subpartdata_t'); 
exec catnodp_drop_type(:sts, '&opt', 'ku$_temp_subpartlob_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_temp_subpartlobfrg_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_tlob_comppart_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_tlob_comppart_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_trigger_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_triggercol_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_triggercol_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_triggerdep_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_triggerdep_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_trlink_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_tsquota_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_type_attr_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_type_attr_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_type_body_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_type_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_up_stats_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_up_stats_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_user_editioning_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_user_editioning_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_user_pref_stats_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_user_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_view_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_xmlschema_elmt_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_xmlschema_t');
--...Triton security
exec catnodp_drop_type(:sts, '&opt', 'ku$_xsace_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_xsace_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_xsacepriv_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_xsacepriv_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_xsacl_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_xsaclparam_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_xsaclparam_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_xsaggpriv_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_xsaggpriv_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_xsattrsec_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_xsattrsec_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_xsgrant_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_xsinst_acl_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_xsinst_inh_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_xsinst_inhkey_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_xsinst_rule_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_xsinstacl_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_xsinstinh_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_xsinstinhkey_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_xsinstset_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_xsinstset_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_xsnspace_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_xsnstmpl_attr_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_xsnstmpl_attr_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_xsobj_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_xsobj_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_xsolap_policy_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_xsolap_policy_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_xspolicy_param_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_xspolicy_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_xsprin_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_xspriv_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_xspriv_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_xsrgrant_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_xsrole_grant_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_xsrole_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_xsroleset_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_xssclass_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_xssecclsh_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_xssecclsh_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_xsuser_t');
--...RADM (12c project 32006)
exec catnodp_drop_type(:sts, '&opt', 'ku$_radm_fptm_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_radm_mc_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_radm_mc_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_radm_policy_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_radm_policy_expr_t');
--...DATA VAULT 
--......DV Protected Schema (Bug 6938028)
exec catnodp_drop_type(:sts, '&opt', 'ku$_dummy_comm_rule_alts_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_dummy_command_rule_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_dummy_factor_link_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_dummy_factor_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_dummy_factor_type_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_dummy_identity_map_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_dummy_identity_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_dummy_isr_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_dummy_isrm_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_dummy_realm_auth_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_dummy_realm_member_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_dummy_realm_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_dummy_role_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_dummy_rule_set_member_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_dummy_rule_set_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_dummy_rule_t');
--......DV Policy (Project 46812)
exec catnodp_drop_type(:sts, '&opt', 'ku$_dummy_policy_obj_c_alts_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_dummy_policy_obj_c_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_dummy_policy_obj_r_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_dummy_policy_owner_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_dummy_policy_t');
--......DV Authorization (Bug 21299533)
exec catnodp_drop_type(:sts, '&opt', 'ku$_dummy_dv_accts_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_dummy_dv_auth_dbcapture_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_dummy_dv_auth_dbreplay_t')
exec catnodp_drop_type(:sts, '&opt', 'ku$_dummy_dv_auth_ddl_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_dummy_dv_auth_diag_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_dummy_dv_auth_dp_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_dummy_dv_auth_job_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_dummy_dv_auth_maint_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_dummy_dv_auth_prep_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_dummy_dv_auth_proxy_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_dummy_dv_auth_tts_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_dummy_dv_index_func_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_dummy_dv_oradebug_t');
--...On_User_Grants (12c project 36951) 
exec catnodp_drop_type(:sts, '&opt', 'ku$_on_user_grant_t');
--...Code_Base_Grants(12c project 36950) 
exec catnodp_drop_type(:sts, '&opt', 'ku$_analytic_view_dim_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_analytic_view_dim_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_analytic_view_hiers_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_analytic_view_hiers_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_analytic_view_keys_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_analytic_view_keys_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_analytic_view_meas_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_analytic_view_meas_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_analytic_view_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_attr_dim_attr_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_attr_dim_attr_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_attr_dim_join_path_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_attr_dim_join_path_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_attr_dim_lvl_key_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_attr_dim_lvl_key_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_attr_dim_lvl_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_attr_dim_lvl_ordby_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_attr_dim_lvl_ordby_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_attr_dim_lvl_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_attribute_dimension_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_code_base_grant_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_hcs_av_cache_lvgp_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_hcs_av_cache_lvgp_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_hcs_av_cache_lvl_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_hcs_av_cache_lvl_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_hcs_av_cache_meas_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_hcs_av_cache_meas_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_hcs_av_cache_mlst_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_hcs_av_cache_mlst_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_hcs_clsfctn_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_hcs_clsfctn_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_hcs_src_col_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_hcs_src_col_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_hcs_src_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_hcs_src_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_hier_hier_attr_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_hier_hier_attr_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_hier_join_path_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_hier_join_path_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_hier_lvl_list_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_hier_lvl_t');
exec catnodp_drop_type(:sts, '&opt', 'ku$_hierarchy_t');

--
-- ----------------------------------------------------------------------------
-- VIEWS of Metadata API
-- ----------------------------------------------------------------------------
--
--...Obsolete
exec catnodp_drop_view(:sts, '&opt', 'ku$_10_1_audit_view',             'OBS');
exec catnodp_drop_view(:sts, '&opt', 'ku$_11_1_objgrant_view',          'OBS');
exec catnodp_drop_view(:sts, '&opt', 'ku$_12_1_index_view',             'OBS');
exec catnodp_drop_view(:sts, '&opt', 'ku$_attr_dim_lkey_grp_view',      'OBS');
exec catnodp_drop_view(:sts, '&opt', 'ku$_function_src',                'OBS');
exec catnodp_drop_view(:sts, '&opt', 'ku$_hdeptable_objnum_view',       'OBS');
exec catnodp_drop_view(:sts, '&opt', 'ku$_histgrm_max_view',            'OBS');
exec catnodp_drop_view(:sts, '&opt', 'ku$_histgrm_min_view',            'OBS');
exec catnodp_drop_view(:sts, '&opt', 'ku$_htable_objnum_view',          'OBS');
exec catnodp_drop_view(:sts, '&opt', 'ku$_ndeptable_objnum_view',       'OBS');
exec catnodp_drop_view(:sts, '&opt', 'ku$_objnum_index_view',           'OBS');
exec catnodp_drop_view(:sts, '&opt', 'ku$_option_objnum_dummy_view',    'OBS');
exec catnodp_drop_view(:sts, '&opt', 'ku$_option_package_objnum_view',  'OBS');
exec catnodp_drop_view(:sts, '&opt', 'ku$_option_table_objnum_view',    'OBS');
exec catnodp_drop_view(:sts, '&opt', 'ku$_pkg_body_src',                'OBS');
exec catnodp_drop_view(:sts, '&opt', 'ku$_pkg_spec_src',                'OBS');
exec catnodp_drop_view(:sts, '&opt', 'ku$_plugts_early_ts_view',        'OBS');
exec catnodp_drop_view(:sts, '&opt', 'ku$_procedure_src',               'OBS');
exec catnodp_drop_view(:sts, '&opt', 'ku$_ptab_col_stats_view',         'OBS');
exec catnodp_drop_view(:sts, '&opt', 'ku$_sgr_sge_view',                'OBS');
exec catnodp_drop_view(:sts, '&opt', 'ku$_synonym_objnum_view',         'OBS');
exec catnodp_drop_view(:sts, '&opt', 'ku$_tab_col_stats_view',          'OBS');
exec catnodp_drop_view(:sts, '&opt', 'ku$_tts_partlobview',             'OBS');
exec catnodp_drop_view(:sts, '&opt', 'ku$_tts_subpartlobview',          'OBS');
exec catnodp_drop_view(:sts, '&opt', 'ku$_view_status_view',            'OBS');
--...Always drop
exec catnodp_drop_view(:sts, '&opt', 'ku$_exp_xmlschema_view',       'ALWAYS');
exec catnodp_drop_view(:sts, '&opt', 'ku$_table_xmlschema_view',     'ALWAYS');
exec catnodp_drop_view(:sts, '&opt', 'ku$_xmlschema_elmt_view',      'ALWAYS');
exec catnodp_drop_view(:sts, '&opt', 'ku$_xmlschema_types_view',     'ALWAYS');
exec catnodp_drop_view(:sts, '&opt', 'ku$_xmlschema_view',           'ALWAYS');
--...Views with Public Synonymns
exec catnodp_drop_vps (:sts, '&opt', 'database_export_objects');
exec catnodp_drop_vps (:sts, '&opt', 'database_export_paths');
exec catnodp_drop_vps (:sts, '&opt', 'datapump_object_connect');
exec catnodp_drop_vps (:sts, '&opt', 'datapump_pathmap');
exec catnodp_drop_vps (:sts, '&opt', 'datapump_paths');
exec catnodp_drop_vps (:sts, '&opt', 'datapump_paths_version');
exec catnodp_drop_vps (:sts, '&opt', 'datapump_remap_objects');
exec catnodp_drop_vps (:sts, '&opt', 'datapump_table_data');
exec catnodp_drop_vps (:sts, '&opt', 'dba_export_objects');
exec catnodp_drop_vps (:sts, '&opt', 'dba_export_paths');
exec catnodp_drop_vps (:sts, '&opt', 'dbms_metadata_parse_items');
exec catnodp_drop_vps (:sts, '&opt', 'dbms_metadata_transform_params');
exec catnodp_drop_vps (:sts, '&opt', 'dbms_metadata_transforms');
exec catnodp_drop_vps (:sts, '&opt', 'schema_export_objects');
exec catnodp_drop_vps (:sts, '&opt', 'schema_export_paths');
exec catnodp_drop_vps (:sts, '&opt', 'table_export_objects');
exec catnodp_drop_vps (:sts, '&opt', 'table_export_paths');
exec catnodp_drop_vps (:sts, '&opt', 'tablespace_export_objects');
exec catnodp_drop_vps (:sts, '&opt', 'tablespace_export_paths');
exec catnodp_drop_vps (:sts, '&opt', 'transportable_export_objects');
exec catnodp_drop_vps (:sts, '&opt', 'transportable_export_paths');
--...Views without Public Synonym
exec catnodp_drop_view(:sts, '&opt', 'ku$_10_1_comment_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_10_1_dblink_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_10_1_fhtable_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_10_1_histgrm_max_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_10_1_histgrm_min_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_10_1_htable_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_10_1_ind_stats_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_10_1_iotable_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_10_1_objgrant_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_10_1_pfhtable_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_10_1_phtable_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_10_1_pind_stats_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_10_1_piotable_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_10_1_proxy_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_10_1_ptab_col_stats_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_10_1_ptab_stats_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_10_1_spind_stats_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_10_1_sysgrant_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_10_1_tab_col_stats_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_10_1_tab_only_stats_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_10_1_tab_stats_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_10_1_table_data_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_10_1_table_objnum_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_10_2_fhtable_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_10_2_ind_stats_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_10_2_index_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_10_2_rogrant_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_10_2_strmcol_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_10_2_strmcoltype_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_10_2_strmsubcoltype_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_10_2_strmtable_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_10_2_tab_col_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_10_2_tab_stats_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_10_2_table_data_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_10_2_trigger_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_11_2_audit_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_11_2_deptbl_objnum_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_11_2_ind_stats_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_11_2_ntable_objnum_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_11_2_psw_hist_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_11_2_rogrant_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_11_2_sysgrant_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_11_2_tab_stats_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_11_2_table_objnum_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_11_2_trigger_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_11_2_view_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_11_2_xdb_ntbl_objnum_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_12_1_sysgrant_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_12_1_trigger_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_12audit_policy_enable_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_2nd_table_objnum_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_2ndtab_info_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_acptable_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_add_snap_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_all_index_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_alter_func_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_alter_pkgbdy_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_alter_pkgspc_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_alter_proc_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_argument_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_assoc_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_audcontext_namespace_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_audcontext_user_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_audit_context_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_audit_default_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_audit_obj_base_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_audit_obj_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_audit_policy_enable_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_audit_policy_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_audit_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_base_proc_objnum_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_base_proc_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_bytes_alloc_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_clst_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_clst_zonemap_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_clstcol_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_clstjoin_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_clu_ts_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_cluster_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_col_stats_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_collection_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_coltype_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_column_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_comment_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_constraint0_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_constraint1_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_constraint2_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_constraint_col_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_constraint_exists_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_constraint_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_context_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_credential_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_cube_fact_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_cube_tab_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_dblink_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_deferred_stg_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_defrole_list_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_defrole_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_deptable_objnum_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_deptypes_base_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_deptypes_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_depviews_base_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_depviews_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_dimension_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_directory_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_domidx_2ndtab_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_domidx_objnum_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_p2t_domidx_objnum_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_domidx_partition_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_domidx_plsql_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_edition_obj_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_edition_proc_exists_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_edition_schemaobj_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_edition_trig_exists_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_end_plugts_blk_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_eqntable_bytes_alloc_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_eqntable_data_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_exp_pkg_body_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_exp_type_body_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_expact_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_exppkgact_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_exppkgobj_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_expreg');
exec catnodp_drop_view(:sts, '&opt', 'ku$_exttab_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_fba_period_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_fba_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_fga_policy_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_fhtable_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_file_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_find_attrcol_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_find_hidden_cons_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_find_ntab_attrcol_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_find_sgc_cols_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_find_sgc_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_find_sgcol_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_find_sgi_cols_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_full_pkg_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_full_type_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_func_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_histgrm_view')
exec catnodp_drop_view(:sts, '&opt', 'ku$_hnt_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_hntp_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_htable_bytes_alloc_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_htable_data_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_htable_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_htpart_bytes_alloc_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_htpart_data_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_htspart_bytes_alloc_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_htspart_data_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_idcol_seq_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_identity_col_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_identity_colobj_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_ilm_policy_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_ilm_policy_view2');
exec catnodp_drop_view(:sts, '&opt', 'ku$_im_colsel_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_inc_type_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_ind_cache_stats_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_ind_col_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_ind_compart_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_ind_exists_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_ind_part_col_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_ind_part_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_ind_partobj_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_ind_stats_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_ind_subname_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_ind_subpart_col_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_ind_subpart_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_ind_ts_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_indarraytype_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_index_col_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_index_objnum_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_index_partition_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_index_subpartition_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_index_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_indexop_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_indextype_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_insert_ts_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_instance_callout_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_iont_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_iot_partobj_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_iotable_bytes_alloc_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_iotable_data_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_iotable_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_iotpart_bytes_alloc_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_iotpart_data_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_java_class_view ');
exec catnodp_drop_view(:sts, '&opt', 'ku$_java_objnum_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_java_resource_view ');
exec catnodp_drop_view(:sts, '&opt', 'ku$_java_source_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_jijoin_table_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_jijoin_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_job_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_library_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_lob_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_lobcomppart_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_lobfrag_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_lobfragindex_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_lobindex_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_m_view_fh_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_m_view_h_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_m_view_iot_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_m_view_log_fh_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_m_view_log_h_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_m_view_log_pfh_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_m_view_log_ph_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_m_view_log_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_m_view_pfh_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_m_view_ph_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_m_view_piot_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_m_view_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_m_view_view_base');
exec catnodp_drop_view(:sts, '&opt', 'ku$_m_zonemap_fh_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_m_zonemap_h_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_m_zonemap_iot_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_m_zonemap_pfh_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_m_zonemap_ph_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_m_zonemap_piot_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_m_zonemap_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_map_table_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_map_tabpart_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_marker_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_method_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_monitor_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_mv_deptbl_objnum_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_mv_ts_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_mvl_ts_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_mvlprop_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_mvprop_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_mzprop_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_niotable_data_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_nt_parent_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_ntable_bytes_alloc_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_ntable_data_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_ntable_objnum_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_ntpart_parent_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_ntpart_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_object_error_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_objgrant_exists_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_objgrant_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_objpkg_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_oidindex_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_opancillary_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_opbinding_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_operator_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_opqtype_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_option_objnum_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_option_view_objnum_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_oracle_supplied_obj_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_outline_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_ov_table_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_ov_tabpart_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_p2t_con1a_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_p2t_con1b_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_p2t_constraint1_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_p2t_constraint2_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_p2tcolumn_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_p2tlob_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_p2tpartcol_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_part_col_names_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_partition_est_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_partition_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_partlob_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_partobj_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_pcolumn_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_pfhtable_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_pfhtabprop_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_phtable_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_pind_stats_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_piot_part_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_piotable_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_piotlobfrag_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_pkg_objnum_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_pkg_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_pkgbdy_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_pkref_constraint_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_plugts_begin_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_plugts_blk_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_plugts_checkpl_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_plugts_early_tblsp_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_plugts_tablespace_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_plugts_tsname_full_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_plugts_tsname_index_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_plugts_tsname_indexp_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_plugts_tsname_table_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_plugts_tsname_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_post_data_table_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_post_table_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_pre_table_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_prepost_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_prim_column_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_proc_audit_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_proc_exists_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_proc_grant_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_proc_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_procact_instance_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_procact_schema_pkg_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_procact_schema_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_procact_sys_pkg_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_procact_sys_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_procc_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_procdepobj_audit_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_procdepobj_grant_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_procdepobj_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_procinfo_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_procjava_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_procobj_audit_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_procobj_grant_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_procobj_objnum_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_procobj_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_procobjact_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_procplsql_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_profile_attr_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_profile_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_proxy_role_list_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_proxy_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_psw_hist_list_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_psw_hist_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_ptab_stats_view')
exec catnodp_drop_view(:sts, '&opt', 'ku$_ptable_ts_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_pwdvfc_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_qtab_storage_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_qtrans_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_queue_table_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_queues_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_ref_constraint_exists_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_ref_constraint_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_ref_par_level_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_refgroup_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_refparttabprop_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_resocost_list_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_resocost_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_rls_context_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_rls_group_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_rls_policy_objnum_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_rls_policy_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_rmgr_consumer_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_rmgr_init_consumer_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_rmgr_plan_direct_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_rmgr_plan_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_rogrant_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_role_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_rollback_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_schema_callout_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_schemaobj_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_schemaobjnum_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_seq_in_default_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_sequence_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_simple_col_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_simple_pkref_col_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_simple_setid_col_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_simple_type_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_sp2t_con1a_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_sp2t_constraint1_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_sp2tcolumn_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_sp2tlob_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_sp2tpartcol_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_spind_stats_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_storage_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_strmcol_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_strmcoltype_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_strmsubcoltype_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_strmtable_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_subcoltype_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_sublobfrag_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_sublobfragindex_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_subpartition_est_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_subpartition_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_switch_compiler_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_syn_exists_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_synonym_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_syscallout_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_sysgrant_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_tab_cache_stats_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_tab_col_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_tab_compart_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_tab_only_stats_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_tab_part_col_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_tab_part_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_tab_partobj_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_tab_stats_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_tab_subname_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_tab_subpart_col_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_tab_subpart_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_tab_ts_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_tab_tsubpart_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_tabclst_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_tabcluster_col_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_tabcluster_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_table_data_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_table_est_view');  
exec catnodp_drop_view(:sts, '&opt', 'ku$_table_objnum_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_table_types_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_tablespace_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_tabprop_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_tbs_ilm_policy_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_temp_subpart_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_temp_subpartdata_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_temp_subpartlob_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_temp_subpartlobfrg_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_tlob_comppart_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_trig_exists_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_trigger_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_triggercol_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_triggerdep_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_trlink_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_tsquota_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_tts_idx_tablespace_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_tts_idxview');
exec catnodp_drop_view(:sts, '&opt', 'ku$_tts_ind_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_tts_indpartview');
exec catnodp_drop_view(:sts, '&opt', 'ku$_tts_indsubpartview');
exec catnodp_drop_view(:sts, '&opt', 'ku$_tts_mv_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_tts_mvl_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_tts_tab_tablespace_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_tts_tabpartview');
exec catnodp_drop_view(:sts, '&opt', 'ku$_tts_tabsubpartview');
exec catnodp_drop_view(:sts, '&opt', 'ku$_tts_tabview');
exec catnodp_drop_view(:sts, '&opt', 'ku$_tts_types_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_tts_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_ttsp_idx_tablespace_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_ttsp_indpartview');
exec catnodp_drop_view(:sts, '&opt', 'ku$_ttsp_indsubpartview');
exec catnodp_drop_view(:sts, '&opt', 'ku$_type_attr_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_type_body_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_type_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_unload_method_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_up_stats_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_user_pref_stats_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_user_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_view_exists_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_view_objnum_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_view_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_viewprop_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_xdb_ntable_objnum_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_xmlschema_special_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_zm_view_fh_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_zm_view_h_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_zm_view_iot_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_zm_view_pfh_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_zm_view_ph_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_zm_view_piot_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_zm_view_view');
--...Triton Security related views'
exec catnodp_drop_view(:sts, '&opt', 'ku$_user_base_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_user_editioning_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_xsace_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_xsacepriv_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_xsacl_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_xsaclparam_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_xsaggpriv_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_xsattrsec_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_xsgrant_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_xsinst_acl_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_xsinst_inh_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_xsinst_inhkey_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_xsinst_rule_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_xsinstset_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_xsnspace_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_xsnstmpl_attr_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_xsobj_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_xsolap_policy_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_xspolicy_param_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_xspolicy_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_xsprin_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_xspriv_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_xsrls_policy_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_xsrole_grant_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_xsrole_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_xsroleset_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_xssclass_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_xssecclsh_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_xsuser_view');
--...RADM (12c project 32006)
exec catnodp_drop_view(:sts, '&opt', 'ku$_radm_fptm_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_radm_mc_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_radm_policy_expr_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_radm_policy_view');
--...DATA VAULT
--......DV Protected Schema (Bug 6938028)
exec catnodp_drop_view(:sts, '&opt', 'ku$_dummy_comm_rule_alts_v');
exec catnodp_drop_view(:sts, '&opt', 'ku$_dummy_command_rule_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_dummy_factor_link_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_dummy_factor_type_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_dummy_factor_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_dummy_identity_map_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_dummy_identity_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_dummy_isr_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_dummy_isrm_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_dummy_realm_auth_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_dummy_realm_member_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_dummy_realm_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_dummy_role_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_dummy_rule_set_member_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_dummy_rule_set_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_dummy_rule_view');
--......DV policy (Project 46812)
exec catnodp_drop_view(:sts, '&opt', 'ku$_dummy_policy_obj_c_alts_v');
exec catnodp_drop_view(:sts, '&opt', 'ku$_dummy_policy_obj_c_v');
exec catnodp_drop_view(:sts, '&opt', 'ku$_dummy_policy_obj_r_v');
exec catnodp_drop_view(:sts, '&opt', 'ku$_dummy_policy_owner_v');
exec catnodp_drop_view(:sts, '&opt', 'ku$_dummy_policy_v'); 
--......DV Authorization (Bug 21299533)
exec catnodp_drop_view(:sts, '&opt', 'ku$_dummy_dv_accts_v');
exec catnodp_drop_view(:sts, '&opt', 'ku$_dummy_dv_auth_dbcapture_v');
exec catnodp_drop_view(:sts, '&opt', 'ku$_dummy_dv_auth_dbreplay_v');
exec catnodp_drop_view(:sts, '&opt', 'ku$_dummy_dv_auth_ddl_v');
exec catnodp_drop_view(:sts, '&opt', 'ku$_dummy_dv_auth_diag_v');
exec catnodp_drop_view(:sts, '&opt', 'ku$_dummy_dv_auth_dp_v');
exec catnodp_drop_view(:sts, '&opt', 'ku$_dummy_dv_auth_job_v');
exec catnodp_drop_view(:sts, '&opt', 'ku$_dummy_dv_auth_maint_v');
exec catnodp_drop_view(:sts, '&opt', 'ku$_dummy_dv_auth_prep_v');
exec catnodp_drop_view(:sts, '&opt', 'ku$_dummy_dv_auth_proxy_v');
exec catnodp_drop_view(:sts, '&opt', 'ku$_dummy_dv_auth_tts_v');
exec catnodp_drop_view(:sts, '&opt', 'ku$_dummy_dv_index_func_v');
exec catnodp_drop_view(:sts, '&opt', 'ku$_dummy_dv_oradebug_v');
--...HCS attribute dimension/hierarchy/analytic
exec catnodp_drop_view(:sts, '&opt', 'ku$_analytic_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_analytic_view_dim_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_analytic_view_hiers_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_analytic_view_keys_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_analytic_view_meas_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_attr_dim_attr_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_attr_dim_join_path_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_attr_dim_lvl_key_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_attr_dim_lvl_ordby_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_attr_dim_lvl_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_attribute_dimension_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_hcs_av_cache_dst_mslst');
exec catnodp_drop_view(:sts, '&opt', 'ku$_hcs_av_cache_lvgp_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_hcs_av_cache_lvl_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_hcs_av_cache_meas_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_hcs_av_cache_mlst_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_hcs_clsfctn_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_hcs_src_col_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_hcs_src_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_hier_hier_attr_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_hier_join_path_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_hier_lvl_view');
exec catnodp_drop_view(:sts, '&opt', 'ku$_hierarchy_view');
--...On User grants (12c project 36951)
exec catnodp_drop_view(:sts, '&opt', 'ku$_on_user_grant_view');
--...Code_Base grants (12c project 36950)
exec catnodp_drop_view(:sts, '&opt', 'ku$_code_base_grant_view');
--...Catalog views
exec catnodp_drop_view(:sts, '&opt', 'datapump_ddl_transform_params');
exec catnodp_drop_view(:sts, '&opt', 'dbms_metadata_all_parse_items');
exec catnodp_drop_view(:sts, '&opt', 'dbms_metadata_all_tparams');
exec catnodp_drop_view(:sts, '&opt', 'dbms_metadata_all_transforms');
exec catnodp_drop_view(:sts, '&opt', 'dbms_metadata_tparams_base');
--
-- ----------------------------------------------------------------------------
-- INDEXES of Metadata API
-- ----------------------------------------------------------------------------
--
--...Always drop (index on global temporary table)
exec catnodp_drop_idx (:sts, '&opt', 'ku$xktfbue_i',                 'ALWAYS');
--
-- ----------------------------------------------------------------------------
-- TABLES of Metadata API
-- ----------------------------------------------------------------------------
--
--...Obsolete ones
exec catnodp_drop_tbl (:sts, '&opt', 'ku$_plsql_src_tbl force',         'OBS');
--...Always drop
exec catnodp_drop_tbl (:sts, '&opt', 'ku$xktfbue',                   'ALWAYS');

--
-- ----------------------------------------------------------------------------
-- PACKAGES of Metadata API
-- ----------------------------------------------------------------------------
--...Packages with Public Synonym
exec catnodp_drop_pkgps(:sts,'&opt', 'dbms_metadata');
exec catnodp_drop_pkgps(:sts,'&opt', 'dbms_metadata_build');
exec catnodp_drop_pkgps(:sts,'&opt', 'dbms_metadata_diff');
exec catnodp_drop_pkgps(:sts,'&opt', 'dbms_metadata_dpbuild');
--...Packages without Public Synonym
exec catnodp_drop_pkg (:sts, '&opt', 'dbms_metadata_int');
exec catnodp_drop_pkg (:sts, '&opt', 'dbms_metadata_util');

--
-- Reset output
--
SET HEADING ON
SET AUTOPRINT OFF
SET FEEDBACK 1

