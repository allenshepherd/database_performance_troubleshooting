Rem Copyright (c) 1987, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem NAME
Rem    CATMETGRANT2.SQL - Grants of the Oracle dictionary for
Rem                       Metadata API.
Rem  FUNCTION
Rem     Grants privileges on views, objects and types of
Rem     the Oracle dictionary for use by the DataPump Metadata API.
Rem  NOTES
Rem     Must be run when connected to SYS or INTERNAL.
Rem     IMPORTANT! Keep the files catnomtt.sql and catnomta.sql in synch with
Rem     this file. These are invoked by catnodp.sql during downgrade.
Rem
Rem     All types must have EXECUTE granted to PUBLIC.
Rem     All top-level views used by the mdAPI to actually fetch full object
Rem     metadata (eg, KU$_TABLE_VIEW) must have SELECT granted to PUBLIC, but
Rem     must have CURRENT_USERID checking security clause.
Rem     All views subordinate to the top level views (eg, KU$_SCHEMAOBJ_VIEW)
Rem     must have SELECT granted to SELECT_CATALOG_ROLE.
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catmetgrant2.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catmetgrant2.sql
Rem SQL_PHASE: CATMETGRANT2
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpexec.sql
Rem END SQL_FILE_METADATA
Rem
Rem  MODIFIED
Rem     mjangir    03/27/17 - 23181020: adding ku$_xsolap_policy_list_t
Rem     sdavidso   01/19/17 - bug25225293 make procact_instance work with CBO
Rem     jjanosik   10/07/16 - Bug 24661809: Add grants for new types and views
Rem                           for procedural actions and objects
Rem     jjanosik   05/03/16 - bug 18083463 - change audit_view get rid of old
Rem                           versioned audit_views
Rem     mjangir    04/25/16 - Bug 22763372: adding ku$_rls_policy_list_t
Rem     jjanosik   02/02/16 - bug 20317926 - add grant for new trigger view
Rem     jjanosik   11/23/15 - rti 18756088 - add exp_full_database to audit
Rem                           views
Rem     jjanosik   09/23/15 - bug 13611733: Change some grants
Rem     sdavidso   03/06/15 - Parallel metadata export
Rem     rapayne    10/20/14 - bug 20164836: support for RAS schema level priv
Rem                           grants.
Rem     skayoor    11/30/14 - Proj 58196: Change Select priv to Read Priv
Rem     bwright    11/17/14 - Support 'audit policy by granted roles'
Rem     sdavidso   09/10/14 - bug14821907: find tablespaces: table
Rem     rapayne    04/26/14 - proj 46816: support for new sysrac priv.
Rem     surman     12/29/13 - 13922626: Update SQL metadata
Rem     rapayne    11/24/13 - Bug 15916457: add grant for new objgrant_list_t
Rem     sdavidso   10/15/13 - proj-47829 don't export READ/READ ALL TABLES to
Rem                           pre 12.1
Rem     lbarton    10/02/13 - Project 48787: views to document mdapi transforms
Rem     rapayne    04/15/13 - bug 16310682: reduce memory for procact_schema
Rem     rapayne    11/06/12 - bug 15832675: create 11_2_view_view to exclude
Rem                           views with bequeath current_user.
Rem     traney     08/02/12 - 14407652: edition enhancements
Rem     rapayne    08/10/12 - lrg 7071802: new mviews to support secondary
Rem                           materialized views.
Rem     lbarton    07/26/12 - bug 13454387: long varchar
Rem     ssonawan   07/19/12 - bug 13843068: add ku$_11_2_psw_hist_view
Rem     surman     03/27/12 - 13615447: Add SQL patching tags
Rem     sdavidso   01/31/12 - bug 11840083: reduce memory for procact_system
Rem     rapayne    01/02/12 - add credential objects
Rem     ebatbout   01/31/12 - Proj. 36950: Give select and execute privileges
Rem                           on code_base_grant type and view to public.
Rem     sdavidso   12/14/11 - add audit policy objects
Rem     lbarton    11/30/11 - 36954_dpump_tabcluster_zonemap
Rem     ebatbout   11/09/11 - Proj. 36951: Give select privilege to view,
Rem                           ku$_on_user_grant_view
Rem     sdavidso   11/03/11 - lrg 6000876: no export 12.1 privs to pre-12
Rem     dgagne     09/20/11 - add new stat grants
Rem     jerrede    09/07/11 - Created for Parallel Upgrade Project #23496
Rem

@@?/rdbms/admin/sqlsessstart.sql

grant execute on ku$_opbinding_list_t to public
/
grant select on ku$_opbinding_view to select_catalog_role
/
grant execute on ku$_operator_t to public
/
grant read on ku$_operator_view to public
/
grant execute on ku$_indexop_t to public
/
grant execute on ku$_indexop_list_t to public
/
grant select on ku$_indexop_view to select_catalog_role
/
grant execute on ku$_indarraytype_t to public
/
grant execute on ku$_indarraytype_list_t to public
/
grant select on ku$_indarraytype_view to select_catalog_role
/
grant execute on ku$_indextype_t to public
/
grant read on ku$_indextype_view to public
/
grant execute on ku$_objgrant_t to public
/
grant execute on ku$_objgrant_list_t to public
/
grant read on ku$_objgrant_view to public
/
grant read on ku$_10_1_objgrant_view to public
/
grant execute on ku$_sysgrant_t to public
/
grant read on ku$_sysgrant_view to public
/
grant read on ku$_10_1_sysgrant_view to public
/
grant read on ku$_11_2_sysgrant_view to public
/
grant read on ku$_12_1_sysgrant_view to public
/
grant execute on ku$_triggercol_t to public
/
grant execute on ku$_triggercol_list_t to public
/
grant select on ku$_triggercol_view to select_catalog_role
/
grant execute on ku$_triggerdep_t to public
/
grant execute on ku$_triggerdep_list_t to public
/
grant select on ku$_triggerdep_view to select_catalog_role
/
grant execute on ku$_trigger_t to public
/
grant read on ku$_trigger_view to public
/
grant read on ku$_12_1_trigger_view to public
/
grant read on ku$_11_2_trigger_view to public
/
grant read on ku$_10_2_trigger_view to public
/
grant execute on ku$_view_t to public
/
grant read on ku$_11_2_view_view to public
/
grant read on ku$_view_view to public
/
grant read on ku$_view_objnum_view to public
/
grant select on ku$_depviews_base_view to select_catalog_role
/
grant read on ku$_depviews_view to public
/
grant execute on ku$_outline_hint_t to public
/
grant execute on ku$_outline_hint_list_t to public
/
grant execute on ku$_outline_node_t to public
/
grant execute on ku$_outline_node_list_t to public
/
grant execute on ku$_outline_t to public
/
grant read on ku$_outline_view to public
/
grant execute on ku$_synonym_t to public
/
grant read on ku$_synonym_view to public
/
grant execute on ku$_directory_t to public
/
grant read on ku$_directory_view to public
/
grant execute on ku$_rollback_t to public
/
grant read on ku$_rollback_view to public
/
grant execute on ku$_dblink_t to public
/
grant read on ku$_dblink_view to public
/
grant read on ku$_10_1_dblink_view to public
/
grant execute on ku$_trlink_t to public
/
grant read on ku$_trlink_view to public
/
grant execute on ku$_fga_rel_col_t to public
/
grant execute on ku$_fga_rel_col_list_t to public
/
grant execute on ku$_fga_policy_t to public
/
grant read on ku$_fga_policy_view to public
/
grant execute on ku$_rls_sec_rel_col_t to public
/
grant execute on ku$_rls_sec_rel_col_list_t to public
/
grant execute on ku$_rls_associations_t to public
/
grant execute on ku$_rls_assoc_list_t to public
/
grant execute on ku$_rls_policy_objnum_t to public
/
grant read on ku$_rls_policy_objnum_view to PUBLIC
/
grant execute on ku$_rls_policy_t to public
/
grant execute on ku$_rls_policy_list_t to public
/
grant read on ku$_rls_policy_view to PUBLIC
/
grant execute on ku$_rls_group_t to public
/
grant read on ku$_rls_group_view to PUBLIC
/
grant execute on ku$_rls_context_t to public
/
grant read on ku$_rls_context_view to PUBLIC
/
grant execute on ku$_m_view_scm_t to public
/
grant execute on ku$_m_view_scm_list_t to public
/
grant execute on ku$_m_view_srt_t to public
/
grant execute on ku$_m_view_srt_list_t to public
/
grant execute on ku$_m_view_t to public
/
grant execute on ku$_m_view_h_t to public
/
grant execute on ku$_m_view_ph_t to public
/
grant execute on ku$_m_view_fh_t to public
/
grant execute on ku$_m_view_pfh_t to public
/
grant execute on ku$_m_view_iot_t to public
/
grant execute on ku$_m_view_piot_t to public
/
grant read on ku$_m_view_view to public
/
grant read on ku$_zm_view_view to public
/
grant read on ku$_m_view_view_base to public
/
grant read on ku$_m_view_h_view to public
/
grant read on ku$_zm_view_h_view to public
/
grant read on ku$_m_view_ph_view to public
/
grant read on ku$_zm_view_ph_view to public
/
grant read on ku$_m_view_fh_view to public
/
grant read on ku$_zm_view_fh_view to public
/
grant read on ku$_m_view_pfh_view to public
/
grant read on ku$_zm_view_pfh_view to public
/
grant read on ku$_m_view_iot_view to public
/
grant read on ku$_zm_view_iot_view to public
/
grant read on ku$_m_view_piot_view to public
/
grant read on ku$_zm_view_piot_view to public
/
grant read on ku$_m_zonemap_view to public
/
grant read on ku$_m_zonemap_h_view to public
/
grant read on ku$_m_zonemap_ph_view to public
/
grant read on ku$_m_zonemap_fh_view to public
/
grant read on ku$_m_zonemap_pfh_view to public
/
grant read on ku$_m_zonemap_iot_view to public
/
grant read on ku$_m_zonemap_piot_view to public
/
grant execute on ku$_refcol_t to public
/
grant execute on ku$_refcol_list_t to public
/
grant execute on ku$_slog_t to public
/
grant execute on ku$_slog_list_t to public
/
grant execute on ku$_m_view_log_t to public
/
grant execute on ku$_m_view_log_h_t to public
/
grant execute on ku$_m_view_log_ph_t to public
/
grant execute on ku$_m_view_log_fh_t to public
/
grant execute on ku$_m_view_log_pfh_t to public
/
grant select on ku$_m_view_log_view to select_catalog_role;
grant read on ku$_m_view_log_h_view to public
/
grant read on ku$_m_view_log_ph_view to public
/
grant read on ku$_m_view_log_fh_view to public
/
grant read on ku$_m_view_log_pfh_view to public
/
grant execute on ku$_library_t to public
/
grant read on ku$_library_view to public
/
grant execute on ku$_xsprin_t to public
/
grant read on ku$_xsprin_view to public
/
grant execute on ku$_xsobj_t to public
/
grant execute on ku$_xsobj_list_t to public
/
grant read on ku$_xsobj_view to public
/
grant execute on ku$_xsuser_t to public
/
grant read on ku$_xsuser_view to public
/
grant execute on ku$_xsgrant_t to public
/
grant read on ku$_xsgrant_view to public
/
grant execute on ku$_xsrole_grant_t to public
/
grant read on ku$_xsrole_grant_view to public
/
grant execute on ku$_xsrgrant_list_t to public
/
grant execute on ku$_xsrole_t to public
/
grant read on ku$_xsrole_view to public
/
grant execute on ku$_xsroleset_t to public
/
grant read on ku$_xsroleset_view to public
/
grant execute on ku$_xsaggpriv_t to public
/
grant read on ku$_xsaggpriv_view to public
/
grant execute on ku$_xsaggpriv_list_t to public
/
grant execute on ku$_xspriv_t to public
/
grant read on ku$_xspriv_view to public
/
grant execute on ku$_xspriv_list_t to public
/
grant execute on ku$_xsacepriv_t to public
/
grant read on ku$_xsacepriv_view to public
/
grant execute on ku$_xsacepriv_list_t to public
/
grant execute on ku$_xssecclsh_t to public
/
grant execute on ku$_xssecclsh_list_t to public
/
grant read on ku$_xssecclsh_view to public
/
grant execute on ku$_xssclass_t to public
/
grant read on ku$_xssclass_view to public
/
grant execute on ku$_xsace_t to public
/
grant execute on ku$_xsace_list_t to public
/
grant read on ku$_xsace_view to public
/
grant execute on ku$_xsaclparam_t to public
/
grant read on ku$_xsaclparam_view to public
/
grant execute on ku$_xsaclparam_list_t to public
/
grant execute on ku$_xsacl_t to public
/
grant read on ku$_xsacl_view to public
/
grant execute on ku$_xspolicy_param_t to public
/
grant read on ku$_xspolicy_param_view to public
/
grant execute on ku$_xsinst_acl_t to public
/
grant read on ku$_xsinst_acl_view to public
/
grant execute on ku$_xsinstacl_list_t to public
/
grant execute on ku$_xsinst_rule_t to public
/
grant read on ku$_xsinst_rule_view to public
/
grant execute on ku$_xsinst_inhkey_t to public
/
grant read on ku$_xsinst_inhkey_view to public
/
grant execute on ku$_xsinstinhkey_list_t to public
/
grant execute on ku$_xsinst_inh_t to public
/
grant read on ku$_xsinst_inh_view to public
/
grant execute on ku$_xsinstinh_list_t to public
/
grant execute on ku$_xsattrsec_list_t to public
/
grant read on ku$_xsattrsec_view to public
/
grant execute on ku$_xsinstset_t to public
/
grant execute on ku$_xsinstset_list_t to public
/
grant read on ku$_xsinstset_view to public
/
grant execute on ku$_xsolap_policy_t to public
/
grant execute on ku$_xsolap_policy_list_t to public
/
grant read on ku$_xsolap_policy_view to public
/
grant read on ku$_xsrls_policy_view to PUBLIC
/
grant execute on ku$_xspolicy_t to public
/
grant read on ku$_xspolicy_view to public
/
grant execute on ku$_xsnstmpl_attr_t to public
/
grant read on ku$_xsnstmpl_attr_view to public
/
grant execute on ku$_xsnstmpl_attr_list_t to public
/
grant execute on ku$_xsnspace_t to public
/
grant read on ku$_xsnspace_view to public
/
grant execute on ku$_user_t to public
/
grant read on ku$_user_view to public
/
grant execute on ku$_role_t to public
/
grant read on ku$_role_view to public
/
grant execute on ku$_profile_attr_t to public
/
grant select on ku$_profile_attr_view to select_catalog_role
/
grant execute on ku$_profile_list_t to public
/
grant execute on ku$_profile_t to public
/
grant read on ku$_profile_view to public
/
grant execute on ku$_defrole_item_t to public
/
grant select on ku$_defrole_list_view to select_catalog_role
/
grant execute on ku$_defrole_list_t to public
/
grant execute on ku$_defrole_t to public
/
grant read on ku$_defrole_view to public
/
grant execute on ku$_proxy_role_item_t to public
/
grant select on ku$_proxy_role_list_view to select_catalog_role
/
grant execute on ku$_proxy_role_list_t to public
/
grant execute on ku$_proxy_t to public
/
grant read on ku$_proxy_view to public
/
grant read on ku$_10_1_proxy_view to public
/
grant execute on ku$_rogrant_t to public
/
grant read on ku$_rogrant_view to public
/
grant read on ku$_11_2_rogrant_view to public
/
grant read on ku$_10_2_rogrant_view to public
/
grant execute on ku$_tsquota_t to public
/
grant read on ku$_tsquota_view to public
/
grant execute on ku$_resocost_item_t to public
/
grant select on ku$_resocost_list_view to select_catalog_role
/
grant execute on ku$_resocost_list_t to public
/
grant execute on ku$_resocost_t to public
/
grant select on ku$_resocost_view to  select_catalog_role
/
grant execute on ku$_sequence_t to public
/
grant read on ku$_sequence_view to public
/
grant execute on ku$_context_t to public
/
grant read on ku$_context_view to public
/
grant execute on ku$_dimension_t to public
/
grant read on ku$_dimension_view to public
/
grant execute on ku$_assoc_t to public
/
grant read on ku$_assoc_view to public
/
grant select on ku$_pwdvfc_view to select_catalog_role
/
grant execute on ku$_comment_t to public
/
grant read on ku$_comment_view to public
/
grant read on ku$_10_1_comment_view to public
/
grant execute on ku$_cluster_t to public
/
grant read on ku$_cluster_view to public;
grant execute on ku$_audit_t to public
/
grant read on sys.ku$_audit_view to public;
grant read on sys.ku$_11_2_audit_view to public;
/
grant execute on ku$_audit_obj_t to public
/
grant select on sys.ku$_audit_obj_base_view to select_catalog_role;
grant read on sys.ku$_audit_obj_view to public;
grant execute on ku$_audit_default_t to public
/
grant select on sys.ku$_audit_default_view to select_catalog_role
/
grant read on ku$_java_objnum_view to public
/
grant execute on ku$_java_source_t to public
/
grant read on ku$_java_source_view to public
/
grant execute on ku$_qtab_storage_t to public
/
grant select on ku$_qtab_storage_view to select_catalog_role
/
grant execute on ku$_queue_table_t to public
/
grant read on ku$_queue_table_view to public
/
grant execute on ku$_queues_t to public
/
grant read on ku$_queues_view to public
/
grant execute on ku$_qtrans_t to public
/
grant read on ku$_qtrans_view to       public
/
grant execute on ku$_job_t to public
/
grant read on ku$_job_view to public
/
grant execute on ku$_histgrm_t to public
/
grant execute on ku$_histgrm_list_t to public
/
grant select on ku$_histgrm_view to select_catalog_role
/
grant select on ku$_10_1_histgrm_min_view to select_catalog_role
/
grant select on ku$_10_1_histgrm_max_view to select_catalog_role
/
grant execute on ku$_col_stats_t to public
/
grant execute on ku$_col_stats_list_t to public
/
grant execute on ku$_10_1_col_stats_t to public
/
grant execute on ku$_10_1_col_stats_list_t to public
/
grant select on ku$_col_stats_view to select_catalog_role
/
grant select on ku$_10_1_tab_col_stats_view to select_catalog_role
/
grant select on ku$_10_1_ptab_col_stats_view to select_catalog_role
/
grant execute on ku$_cached_stats_t to public
/
grant select on ku$_tab_cache_stats_view to select_catalog_role
/
grant select on ku$_ind_cache_stats_view to select_catalog_role
/
grant execute on ku$_tab_ptab_stats_t to public
/
grant execute on ku$_ptab_stats_list_t to public
/
grant execute on ku$_10_1_tab_ptab_stats_t to public
/
grant execute on ku$_10_1_ptab_stats_list_t to public
/
grant select on ku$_tab_only_stats_view to select_catalog_role
/
grant select on ku$_10_1_tab_only_stats_view to select_catalog_role
/
grant select on ku$_ptab_stats_view to select_catalog_role
/
grant select on ku$_10_1_ptab_stats_view to select_catalog_role
/
grant execute on ku$_tab_col_t to public
/
grant execute on ku$_tab_col_list_t to public
/
grant select on ku$_tab_col_view to select_catalog_role
/
grant select on ku$_10_2_tab_col_view to select_catalog_role
/
grant execute on ku$_tab_stats_t to public
/
grant execute on ku$_11_2_tab_stats_t to public
/
grant execute on ku$_10_1_tab_stats_t to public
/
grant read on ku$_tab_stats_view to public
/
grant read on ku$_11_2_tab_stats_view to public
/
grant read on ku$_10_2_tab_stats_view to public
/
grant read on ku$_10_1_tab_stats_view to public
/
grant execute on ku$_spind_stats_t to public
/
grant execute on ku$_spind_stats_list_t to public
/
grant execute on ku$_10_1_spind_stats_t to public
/
grant execute on ku$_10_1_spind_stats_list_t to public
/
grant select on ku$_spind_stats_view to select_catalog_role
/
grant select on ku$_10_1_spind_stats_view to select_catalog_role
/
grant execute on ku$_pind_stats_t to public
/
grant execute on ku$_pind_stats_list_t to public
/
grant execute on ku$_10_1_pind_stats_t to public
/
grant execute on ku$_10_1_pind_stats_list_t to public
/
grant select on ku$_pind_stats_view to select_catalog_role
/
grant select on ku$_10_1_pind_stats_view to select_catalog_role
/
grant select on ku$_ind_col_view to select_catalog_role
/
grant execute on ku$_ind_stats_t to public
/
grant execute on ku$_11_2_ind_stats_t to public
/
grant execute on ku$_10_1_ind_stats_t to public
/
grant read on ku$_ind_stats_view to public
/
grant read on ku$_11_2_ind_stats_view to public
/
grant read on ku$_10_2_ind_stats_view to public
/
grant read on ku$_10_1_ind_stats_view to public
/
grant execute on ku$_sgi_col_t to public
/
grant execute on ku$_sgi_col_list_t to public
/
grant select on ku$_find_sgc_cols_view to select_catalog_role;
grant select on ku$_find_sgi_cols_view to select_catalog_role;
grant execute on ku$_find_sgc_t to public
/
grant read on ku$_find_sgc_view to public
/
grant read on ku$_find_sgcol_view to public
/
grant read on ku$_find_attrcol_view to public
/
grant read on ku$_find_ntab_attrcol_view to public
/
grant execute on ku$_up_stats_t to public
/
grant execute on ku$_up_stats_list_t to public
/
grant select on ku$_up_stats_view to select_catalog_role
/
grant execute on ku$_user_pref_stats_t to public
/
grant read on ku$_user_pref_stats_view to public
/
grant execute on ku$_java_class_t to public
/
grant read on ku$_java_class_view to public
/
grant execute on ku$_java_resource_t to public
/
grant read on ku$_java_resource_view to public
/
grant execute on ku$_add_snap_t to public
/
grant execute on ku$_add_snap_list_t to public
/
grant select on ku$_add_snap_view to select_catalog_role
/
grant execute on ku$_refgroup_t to public
/
grant read on ku$_refgroup_view to public
/
grant execute on ku$_monitor_t to  select_catalog_role
/
grant read on ku$_monitor_view to public
/
grant execute on ku$_rmgr_plan_t to public
/
grant select on ku$_rmgr_plan_view to select_catalog_role
/
grant execute on ku$_rmgr_plan_direct_t to public
/
grant select on ku$_rmgr_plan_direct_view to select_catalog_role
/
grant execute on ku$_rmgr_consumer_t to public
/
grant select on ku$_rmgr_consumer_view to select_catalog_role
/
grant execute on ku$_rmgr_init_consumer_t to public
/
grant select on ku$_rmgr_init_consumer_view to select_catalog_role
/
grant execute on ku$_psw_hist_item_t to public
/
grant select on ku$_psw_hist_list_view to EXP_FULL_DATABASE
/
grant execute on ku$_psw_hist_list_t to public
/
grant execute on ku$_psw_hist_t to public
/
grant select on ku$_psw_hist_view to EXP_FULL_DATABASE
/
grant select on ku$_11_2_psw_hist_view to EXP_FULL_DATABASE
/
grant execute on ku$_objpkg_t to public
/
grant read on ku$_objpkg_view to public
/
grant execute on ku$_objpkg_privs_t to public
/
grant select on ku$_proc_grant_view to select_catalog_role
/
grant select on ku$_proc_audit_view to select_catalog_role
/
grant read on ku$_exppkgobj_view to select_catalog_role
/
grant read on ku$_exppkgact_view to select_catalog_role
/
grant execute on ku$_procobj_t to public
/
grant read on ku$_procobj_view to public
/
grant read on ku$_procobj_objnum_view to public
/
grant execute on ku$_procobj_grant_t to public
/
grant read on ku$_procobj_grant_view to public
/
grant execute on ku$_procobj_audit_t to public
/
grant read on ku$_procobj_audit_view to public
/
grant execute on ku$_procdepobj_t to public
/
grant read on ku$_procdepobj_view to public
/
grant execute on ku$_procdepobjg_t to public
/
grant read on ku$_procdepobj_grant_view to public
/
grant execute on ku$_procdepobja_t to public
/
grant read on ku$_procdepobj_audit_view to public
/
grant select on ku$_prepost_view to select_catalog_role
/
grant execute on ku$_procobjact_t to public
/
grant read on ku$_procobjact_view to public
/
grant execute on ku$_procact_t to public
/
grant select on ku$_procact_sys_view to select_catalog_role
/
grant select on ku$_procact_sys_pkg_view to select_catalog_role
/
grant execute on ku$_procact_schema_t to public
/
grant read on ku$_procact_schema_view to public
/
grant read on ku$_procact_schema_pkg_view to public
/
grant execute on ku$_procact_instance_t to public
/
grant execute on ku$_procact_instance_tbl_t to public
/
grant read on ku$_procact_instance_view to public
/
grant select on ku$_expact_view to select_catalog_role
/
grant execute on ku$_prepost_table_t to public
/
grant read on ku$_pre_table_view to public
/
grant read on ku$_post_table_view to public
/
grant execute on ku$_callout_t to public
/
grant select on ku$_syscallout_view to select_catalog_role
/
grant read on ku$_schema_callout_view to public
/
grant read on ku$_instance_callout_view to public
/
grant select on ku$_tts_tabview to select_catalog_role
/
grant select on ku$_tts_tabpartview to select_catalog_role
/
grant select on ku$_tts_tabsubpartview to select_catalog_role
/
grant select on ku$_tts_tab_tablespace_view to select_catalog_role
/
grant select on ku$_tts_idxview to select_catalog_role
/
grant select on ku$_tts_indpartview to select_catalog_role
/
grant select on ku$_ttsp_indpartview to select_catalog_role
/
grant select on ku$_tts_indsubpartview to select_catalog_role
/
grant select on ku$_ttsp_indsubpartview to select_catalog_role
/
grant select on ku$_tts_idx_tablespace_view to select_catalog_role
/
grant select on ku$_ttsp_idx_tablespace_view to select_catalog_role
/
grant read on ku$_plugts_begin_view to public
/
grant read on ku$_plugts_tsname_full_view to public
/
grant read on ku$_plugts_tsname_table_view to public
/
grant read on ku$_plugts_tsname_index_view to public
/
grant read on ku$_plugts_tsname_indexp_view to public
/
grant read on ku$_plugts_tsname_view to public
/
grant read on ku$_plugts_checkpl_view to public
/
grant execute on ku$_plugts_blk_t to public
/
grant read on ku$_plugts_blk_view to public
/
grant read on ku$_end_plugts_blk_view to public
/
grant select on ku$_plugts_early_tblsp_view to select_catalog_role
/
grant execute on ku$_plugts_tablespace_t to public
/
grant select on ku$_plugts_tablespace_view to select_catalog_role
/
grant read on DATAPUMP_PATHS_VERSION to public
/
grant read on DATAPUMP_PATHS to public
/
grant read on DATAPUMP_PATHMAP to public
/
grant read on DATAPUMP_TABLE_DATA to public
/
grant read on DATAPUMP_OBJECT_CONNECT to public
/
grant read on DATAPUMP_DDL_TRANSFORM_PARAMS to public
/
grant select on DBA_EXPORT_OBJECTS to select_catalog_role
/
grant read on TABLE_EXPORT_OBJECTS to public
/
grant read on SCHEMA_EXPORT_OBJECTS to public
/
grant read on DATABASE_EXPORT_OBJECTS to public
/
grant read on TABLESPACE_EXPORT_OBJECTS to public
/
grant read on TRANSPORTABLE_EXPORT_OBJECTS to public
/
grant select on DBA_EXPORT_PATHS to select_catalog_role
/
grant read on TABLE_EXPORT_PATHS to public
/
grant read on SCHEMA_EXPORT_PATHS to public
/
grant read on DATABASE_EXPORT_PATHS to public
/
grant read on TABLESPACE_EXPORT_PATHS to public
/
grant read on TRANSPORTABLE_EXPORT_PATHS to public
/
grant read on DATAPUMP_REMAP_OBJECTS to public
/
grant select on dbms_metadata_all_transforms to select_catalog_role
/
grant read on dbms_metadata_transforms to public
/
grant read on dbms_metadata_transform_params to public
/
grant select on dbms_metadata_all_tparams to select_catalog_role
/
grant read on dbms_metadata_parse_items to public
/
grant select on dbms_metadata_all_parse_items to select_catalog_role
/
grant select on dbms_metadata_tparams_base to select_catalog_role
/
grant execute on ku$_audit_act_list_t to public;
grant execute on ku$_audit_act_t to public;
grant execute on ku$_audit_attr_list_t to public;
grant execute on ku$_audit_context_t to public;
grant execute on ku$_audit_namespace_list_t to public;
grant execute on ku$_audit_namespace_t to public;
grant execute on ku$_audit_pol_role_list_t to public;
grant execute on ku$_audit_pol_role_t to public;
grant execute on ku$_audit_policy_enable_t to public;
grant execute on ku$_audit_policy_t to public;
grant execute on ku$_audit_sys_priv_list_t to public;
grant execute on ku$_audit_sys_priv_t to public;
grant execute on ku$_auditp_obj_list_t to public;
grant execute on ku$_auditp_obj_t to public;
grant select on ku$_audcontext_namespace_view to select_catalog_role;
grant select on ku$_audcontext_user_view to select_catalog_role;
grant read on ku$_audit_context_view to exp_full_database;
grant read on ku$_audit_policy_enable_view to exp_full_database;
grant read on ku$_12audit_policy_enable_view to exp_full_database;
grant read on ku$_audit_policy_view to exp_full_database;

grant execute on ku$_on_user_grant_t to public
/
grant read on ku$_on_user_grant_view to public
/
grant execute on ku$_code_base_grant_t to public
/
grant read on ku$_code_base_grant_view to public
/
grant execute on ku$_credential_t to public;
grant read on ku$_credential_view to public;
grant execute on ku$_user_editioning_t to public;
grant execute on ku$_user_editioning_list_t to public;
grant read on ku$_user_editioning_view to public;
grant read on ku$_user_base_view to public;

@?/rdbms/admin/sqlsessend.sql
