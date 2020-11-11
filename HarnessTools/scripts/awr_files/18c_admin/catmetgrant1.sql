Rem Copyright (c) 1987, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem NAME
Rem    CATMETGRANT1.SQL - Grants of the Oracle dictionary for
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
Rem     Put new grants into the smaller of this file or catmetgrant2.sql.
Rem     There are two files strictly for load balancing during || upgrade.
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catmetgrant1.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catmetgrant1.sql
Rem SQL_PHASE: CATMETGRANT1
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdeps.sql
Rem END SQL_FILE_METADATA
Rem
Rem  MODIFIED
Rem     sdavidso   10/20/17 - lrg20624856 add grant for
Rem                           KU$_P2T_DOMIDX_OBJNUM_VIEW
Rem     sdavidso   08/29/17 - bug25453685 move chunk - domain index
Rem     jjanosik   06/22/17 - Bug 24719359: Add support for RADM Policy
Rem                           Expressions
Rem     qinwu      01/19/17 - proj 70151: support db capture and replay auth
Rem     bwright    09/08/16 - Bug 24513141: Remove project 30935 implementation
Rem     sdavidso   02/20/16 - bug22577904 shard P2T - missing constraint
Rem     youyang    02/15/16 - bug22672722:dv support for index functions
Rem     sogugupt   12/03/15 - Remove ku$_find_hidden_cons_t 
Rem     sdavidso   11/24/15 - bug22264616 more move chunk subpart
Rem     smesropi   11/08/15 - Bug 21171628: Rename HCS views
Rem     sdavidso   11/02/15 - bug21869037 chunk move w/subpartitions
Rem     jibyun     11/01/15 - support DIAGNOSTIC auth for Database Vault
Rem     mstasiew   09/25/15 - Bug 21867527: hier cube measure cache
Rem     mstasiew   08/27/15 - Bug 21384694: hier hier attr classifications
Rem     sdavidso   08/17/15 - bug-20756759: lobs, indexes, droppped tables
Rem     tbhukya    08/17/15 - Bug 21555645: Partitioned mapping io table
Rem     sdavidso   08/03/15 - bug21539111: include check constraint for P2T exp
Rem     yanchuan   07/27/15 - Bug 21299533: support for Database Vault
Rem                           Authorization
Rem     sanbhara   06/01/15 - Bug 21158282 - adding ku$_dummy_comm_rule_alts_t
Rem                           and ku$_dummy_comm_rule_alts_v.
Rem     mstasiew   05/14/15 - Bug 20845789: more hcs views
Rem     sdavidso   03/13/15 - proj 56220 - partition transportable
Rem     sdavidso   03/06/15 - Parallel metadata export
Rem     beiyu      12/16/14 - Proj 47091: add grant for views of new HCS objs
Rem     skayoor    11/30/14 - Proj 58196: Change Select priv to Read Priv
Rem     kaizhuan   11/11/14 - Project 46812: support for Database Vault policy
Rem     gclaborn   09/12/14 - 30395: New views for source as tables
Rem     tbhukya    09/10/14 - Bug 13217417: Remove grant on ku$_12_1_index_view
Rem     jibyun     08/05/14 - Project 46812: support for Database Vault policy
Rem     lbarton    04/23/14 - bug 18374198: default on null
Rem     surman     12/29/13 - 13922626: Update SQL metadata
Rem     tbhukya    12/11/13 - Bug 17803321: Add grant to ku$_12_1_index_view
Rem     sdavidso   11/03/13 - bug17718297 - IMC selective column
Rem     lbarton    06/27/13 - bug 16800820: valid-time temporal
Rem     sdavidso   12/24/12 - XbranchMerge sdavidso_bug14490576-2 from
Rem                           st_rdbms_12.1.0.1
Rem     sdavidso   11/01/12 - bug14490576 - 2ndary tables for
Rem                           full/transportable
Rem     lbarton    10/11/12 - bug 14358248: non-privileged parallel export of
Rem                           views-as-tables fails
Rem     lbarton    10/03/12 - bug 10350062: ILM compression and storage tiering
Rem     bwright    10/03/12 - Bug 14679947: Add grant to ku$_object_error_view
Rem     rapayne    09/20/12 - bug 12899189: add grant to new view, 
Rem                           ku$_10_1_table_objnum_view.
Rem     lbarton    07/26/12 - bug 13454387: long varchar
Rem     surman     03/27/12 - 13615447: Add SQL patching tags
Rem     lbarton    10/27/11 - 36954_dpump_tabcluster_zonemap
Rem     lbarton    10/13/11 - bug 13092452: hygiene
Rem     jerrede    09/07/11 - Created for Parallel Upgrade Project #23496
Rem

@@?/rdbms/admin/sqlsessstart.sql

grant execute on ku$_schemaobj_t to public
/
grant select on ku$_schemaobj_view to select_catalog_role
/
grant select on ku$_schemaobjnum_view to select_catalog_role
/
grant select on ku$_edition_schemaobj_view to select_catalog_role;
grant select on ku$_edition_obj_view to select_catalog_role;
grant execute on ku$_storage_t to public
/
grant select on ku$_storage_view to select_catalog_role
/
grant execute on ku$_deferred_stg_t to public
/
grant select on ku$_deferred_stg_view to select_catalog_role
/
grant execute on ku$_file_t to public
/
grant select on ku$_file_view to select_catalog_role
/
grant execute on ku$_file_list_t to public
/
grant execute on ku$_tablespace_t to public
/
grant read on ku$_tablespace_view to public
/
grant execute on ku$_switch_compiler_t to public
/
grant read on ku$_switch_compiler_view to public
/
grant execute on ku$_simple_type_t to public
/
grant read on ku$_simple_type_view to public
/
grant execute on ku$_collection_t to public
/
grant read on ku$_collection_view to public
/
grant execute on ku$_argument_t to public
/
grant execute on ku$_argument_list_t to public
/
grant read on ku$_argument_view to public
/
grant execute on ku$_procinfo_t to public
/
grant read on ku$_procinfo_view to public
/
grant execute on ku$_procjava_t to public
/
grant read on ku$_procjava_view to public
/
grant execute on ku$_procc_t to public
/
grant read on ku$_procc_view to public
/
grant execute on ku$_procplsql_t to public
/
grant read on ku$_procplsql_view to public
/
grant execute on ku$_method_list_t to public
/
grant read on ku$_method_view to public
/
grant execute  on ku$_type_attr_t to public
/
grant execute on ku$_type_attr_list_t to public
/
grant read on ku$_type_attr_view to public
/
grant execute on ku$_type_t to public
/
grant read on ku$_type_view to public
/
grant execute on ku$_type_body_t to public
/
grant read on ku$_type_body_view to public
/
grant execute on ku$_full_type_t to public
/
grant read on ku$_full_type_view to public
/
grant execute on ku$_exp_type_body_t to public
/
grant read on ku$_exp_type_body_view to public
/
grant read on ku$_inc_type_view to public
/
grant select on ku$_deptypes_base_view to select_catalog_role
/
grant read on ku$_deptypes_view to public
/
grant execute on ku$_simple_col_t to public
/
grant execute on ku$_simple_col_list_t to public
/
grant select on ku$_simple_col_view to select_catalog_role
/
grant select on ku$_simple_setid_col_view to select_catalog_role
/
grant select on ku$_simple_pkref_col_view to select_catalog_role
/
grant execute on ku$_index_col_t to public
/
grant execute on ku$_index_col_list_t to public
/
grant select on ku$_index_col_view to select_catalog_role
/
grant execute on ku$_lobindex_t to public
/
grant select on ku$_lobindex_view to select_catalog_role
/
grant execute on ku$_lob_t to public
/
grant select on ku$_lob_view to select_catalog_role
/
grant select on ku$_p2tlob_view to select_catalog_role
/
grant select on ku$_sp2tlob_view to select_catalog_role
/
grant execute on ku$_partlob_t to public
/
grant select on ku$_partlob_view to select_catalog_role
/
grant select on ku$_lobfragindex_view to select_catalog_role
/
grant select on ku$_sublobfragindex_view to select_catalog_role
/
grant execute on ku$_lobfrag_list_t to public
/
grant select on ku$_lobfrag_view to select_catalog_role
/
grant select on ku$_piotlobfrag_view to select_catalog_role
/
grant select on ku$_sublobfrag_view to select_catalog_role
/
grant execute on ku$_lobcomppart_t to public
/
grant execute on ku$_lobcomppart_list_t to public
/
grant select on ku$_lobcomppart_view to select_catalog_role
/
grant execute on ku$_tlob_comppart_t to public
/
grant execute on ku$_tlob_comppart_list_t to public
/
grant select on ku$_tlob_comppart_view to select_catalog_role
/
grant execute on ku$_temp_subpart_t to public
/
grant select on ku$_temp_subpart_view to select_catalog_role
/
grant execute on ku$_temp_subpartdata_t to public
/
GRANT READ ON  ku$_temp_subpartdata_view TO PUBLIC;
grant execute on ku$_temp_subpartlobfrg_t to public
/
grant select on ku$_temp_subpartlobfrg_view to select_catalog_role
/
grant execute on ku$_temp_subpartlob_t to public
/
GRANT READ ON  ku$_temp_subpartlob_view TO PUBLIC;
grant execute on ku$_hntp_t to public
/
grant select on ku$_hntp_view to select_catalog_role
/
grant execute on ku$_ntpart_t to public
/
grant select on ku$_ntpart_view to select_catalog_role
/
grant execute on ku$_ntpart_list_t to public
/
grant execute on ku$_ntpart_parent_t to public
/
grant select on ku$_ntpart_parent_view to select_catalog_role
/
grant execute on ku$_ind_part_t to public
/
grant execute on ku$_ind_part_list_t to public
/
grant select on ku$_ind_part_view to select_catalog_role
/
grant execute on ku$_piot_part_t to public
/
grant execute on ku$_piot_part_list_t to public
/
grant select on ku$_piot_part_view to select_catalog_role
/
grant execute on ku$_tab_part_t to public
/
grant execute on ku$_tab_part_list_t to public
/
grant select on ku$_tab_part_view to select_catalog_role
/
grant execute on ku$_tab_subpart_t to public
/
grant execute on ku$_tab_subpart_list_t to public
/
grant select on ku$_tab_subpart_view to select_catalog_role
/
grant execute on ku$_tab_tsubpart_t to public
/
grant execute on ku$_tab_tsubpart_list_t to public
/
grant select on ku$_tab_tsubpart_view to select_catalog_role
/
grant execute on ku$_tab_compart_t to public
/
grant execute on ku$_tab_compart_list_t to public
/
grant select on ku$_tab_compart_view to select_catalog_role
/
grant select on ku$_ind_subpart_view to select_catalog_role
/
grant execute on ku$_ind_compart_t to public
/
grant execute on ku$_ind_compart_list_t to public
/
grant select on ku$_ind_compart_view to select_catalog_role
/
grant execute on ku$_part_col_t to public
/
grant execute on ku$_part_col_list_t to public
/
grant select on ku$_tab_part_col_view to select_catalog_role
/
grant select on ku$_tab_subpart_col_view to select_catalog_role
/
grant select on ku$_ind_part_col_view to select_catalog_role
/
grant select on ku$_ind_subpart_col_view to select_catalog_role
/
grant execute on ku$_insert_ts_t to public
/
grant execute on ku$_insert_ts_list_t to public
/
grant select on ku$_insert_ts_view to select_catalog_role
/
grant execute on ku$_partobj_t to public
/
grant select on ku$_partobj_view to select_catalog_role
/
grant execute on ku$_tab_partobj_t to public
/
grant select on ku$_tab_partobj_view to select_catalog_role
/
grant execute on ku$_ind_partobj_t to public
/
grant select on ku$_ind_partobj_view to select_catalog_role
/
grant execute on ku$_domidx_2ndtab_t to public
/
grant execute on ku$_domidx_2ndtab_list_t to public
/
grant select on ku$_domidx_2ndtab_view to select_catalog_role
/
grant read on ku$_2ndtab_info_view to public
/
grant execute on  ku$_domidx_plsql_t to public
/
grant select on ku$_domidx_plsql_view to select_catalog_role
/
grant execute on ku$_jijoin_table_t to public
/
grant execute on ku$_jijoin_table_list_t to public
/
grant select on ku$_jijoin_table_view to select_catalog_role
/
grant execute on ku$_jijoin_t to public
/
grant execute on ku$_jijoin_list_t to public
/
grant select on ku$_jijoin_view to select_catalog_role
/
grant execute on ku$_index_t to public
/
grant execute on ku$_index_list_t to public
/
grant read on ku$_all_index_view to public
/
grant read on ku$_index_partition_view to public
/
grant read on ku$_domidx_partition_view to public
/
grant read on ku$_index_subpartition_view to public
/
grant read on ku$_index_view to public
/
grant read on ku$_index_objnum_view to public
/ 
grant read on ku$_10_2_index_view to public
/
grant execute on ku$_constraint_col_t to public
/
grant select on ku$_constraint_col_view to select_catalog_role
/
grant execute on ku$_constraint_col_list_t to public
/
grant execute on ku$_im_colsel_t to public
/
grant execute on ku$_im_colsel_list_t to public
/
grant execute on ku$_constraint0_t to public
/
grant execute on ku$_constraint0_list_t to public
/
grant execute on ku$_constraint1_t to public
/
grant execute on ku$_constraint1_list_t to public
/
grant execute on ku$_constraint2_t to public
/
grant execute on ku$_constraint2_list_t to public
/
grant select on ku$_im_colsel_view to select_catalog_role
/
grant select on ku$_constraint0_view to select_catalog_role
/
grant select on ku$_constraint1_view to select_catalog_role
/
grant select on ku$_p2t_constraint1_view to select_catalog_role
/
grant select on ku$_p2t_con1a_view to select_catalog_role
/
grant select on ku$_p2t_con1b_view to select_catalog_role
/
grant select on ku$_sp2t_constraint1_view to select_catalog_role
/
grant select on ku$_sp2t_con1a_view to select_catalog_role
/
grant select on ku$_constraint2_view to select_catalog_role
/
grant select on ku$_p2t_constraint2_view to select_catalog_role
/
grant execute on ku$_pkref_constraint_t to public
/
grant execute on ku$_pkref_constraint_list_t to public
/
grant select on ku$_pkref_constraint_view to select_catalog_role
/
grant execute on ku$_constraint_t to public
/
grant read on ku$_constraint_view to public
/
grant execute on ku$_ref_constraint_t to public
/
grant read on ku$_ref_constraint_view to public
/
grant read on ku$_find_hidden_cons_view to public
/
grant select on ku$_prim_column_view to select_catalog_role
/
grant execute on ku$_subcoltype_t to public
/
grant execute on ku$_subcoltype_list_t to public
/
grant select on ku$_subcoltype_view to select_catalog_role
/
grant execute on ku$_coltype_t to public
/
grant select on ku$_coltype_view to select_catalog_role
/
grant execute on ku$_xmlschema_t to public
/
grant read on ku$_xmlschema_view to public
/
grant read on ku$_exp_xmlschema_view to public
/
grant execute on ku$_xmlschema_elmt_t to public
/
grant select on ku$_xmlschema_elmt_view to select_catalog_role
/
grant read on ku$_xmlschema_special_view to public
/
grant execute on ku$_opqtype_t to public
/
grant select on ku$_opqtype_view to select_catalog_role
/
grant execute on ku$_radm_policy_expr_t to public
/
grant select on ku$_radm_policy_expr_view to select_catalog_role
/
grant execute on ku$_radm_mc_t to public
/
grant execute on ku$_radm_mc_list_t to public
/
grant select on ku$_radm_mc_view to select_catalog_role
/
grant execute on ku$_radm_policy_t to public
/
grant select on ku$_radm_policy_view to select_catalog_role
/
grant execute on ku$_radm_fptm_t to public
/
grant select on ku$_radm_fptm_view to select_catalog_role
/
grant execute on ku$_dummy_isr_t to public
/
grant select on ku$_dummy_isr_view to select_catalog_role
/
grant execute on ku$_dummy_isrm_t to public
/
grant select on ku$_dummy_isrm_view to select_catalog_role
/
grant execute on ku$_dummy_realm_t to public
/
grant select on ku$_dummy_realm_view to select_catalog_role
/
grant execute on ku$_dummy_realm_member_t to public
/
grant select on ku$_dummy_realm_member_view to select_catalog_role
/
grant execute on ku$_dummy_realm_auth_t to public
/
grant select on ku$_dummy_realm_auth_view to select_catalog_role
/
grant execute on ku$_dummy_rule_t to public
/
grant select on ku$_dummy_rule_view to select_catalog_role
/
grant execute on ku$_dummy_rule_set_t to public
/
grant select on ku$_dummy_rule_set_view to select_catalog_role
/
grant execute on ku$_dummy_rule_set_member_t to public
/
grant select on ku$_dummy_rule_set_member_view to select_catalog_role
/
grant execute on ku$_dummy_command_rule_t to public
/
grant select on ku$_dummy_command_rule_view to select_catalog_role
/
grant execute on ku$_dummy_comm_rule_alts_t to public
/
grant select on ku$_dummy_comm_rule_alts_v to select_catalog_role
/
grant execute on ku$_dummy_role_t to public
/
grant select on ku$_dummy_role_view to select_catalog_role
/
grant execute on ku$_dummy_factor_t to public
/
grant select on ku$_dummy_factor_view to select_catalog_role
/
grant execute on ku$_dummy_factor_link_t to public
/
grant select on ku$_dummy_factor_link_view to select_catalog_role
/
grant execute on ku$_dummy_factor_type_t to public
/
grant select on ku$_dummy_factor_type_view to select_catalog_role
/
grant execute on ku$_dummy_identity_t to public
/
grant select on ku$_dummy_identity_view to select_catalog_role
/
grant execute on ku$_dummy_identity_map_t to public
/
grant select on ku$_dummy_identity_map_view to select_catalog_role
/
grant execute on ku$_dummy_policy_t to public
/
grant select on ku$_dummy_policy_v to select_catalog_role
/
grant execute on ku$_dummy_policy_obj_r_t to public
/
grant select on ku$_dummy_policy_obj_r_v to select_catalog_role
/
grant execute on ku$_dummy_policy_obj_c_t to public
/
grant select on ku$_dummy_policy_obj_c_v to select_catalog_role
/
grant execute on ku$_dummy_policy_obj_c_alts_t to public
/
grant select on ku$_dummy_policy_obj_c_alts_v to select_catalog_role
/
grant execute on ku$_dummy_policy_owner_t to public
/
grant select on ku$_dummy_policy_owner_v to select_catalog_role
/
grant execute on ku$_dummy_dv_auth_dp_t to public
/
grant select on ku$_dummy_dv_auth_dp_v to select_catalog_role
/
grant execute on ku$_dummy_dv_auth_tts_t to public
/
grant select on ku$_dummy_dv_auth_tts_v to select_catalog_role
/
grant execute on ku$_dummy_dv_auth_job_t to public
/
grant select on ku$_dummy_dv_auth_job_v to select_catalog_role
/
grant execute on ku$_dummy_dv_auth_proxy_t to public
/
grant select on ku$_dummy_dv_auth_proxy_v to select_catalog_role
/
grant execute on ku$_dummy_dv_auth_ddl_t to public
/
grant select on ku$_dummy_dv_auth_ddl_v to select_catalog_role
/
grant execute on ku$_dummy_dv_auth_prep_t to public
/
grant select on ku$_dummy_dv_auth_prep_v to select_catalog_role
/
grant execute on ku$_dummy_dv_auth_maint_t to public
/
grant select on ku$_dummy_dv_auth_maint_v to select_catalog_role
/
grant execute on ku$_dummy_dv_auth_diag_t to public
/
grant select on ku$_dummy_dv_auth_diag_v to select_catalog_role
/
grant execute on ku$_dummy_dv_index_func_t to public
/
grant select on ku$_dummy_dv_index_func_v to select_catalog_role
/
grant execute on ku$_dummy_dv_oradebug_t to public
/
grant select on ku$_dummy_dv_oradebug_v to select_catalog_role
/
grant execute on ku$_dummy_dv_accts_t to public
/
grant select on ku$_dummy_dv_accts_v to select_catalog_role
/
grant execute on ku$_dummy_dv_auth_dbcapture_t to public
/
grant select on ku$_dummy_dv_auth_dbcapture_v to select_catalog_role
/
grant execute on ku$_dummy_dv_auth_dbreplay_t to public
/
grant select on ku$_dummy_dv_auth_dbreplay_v to select_catalog_role
/
grant select on ku$_table_xmlschema_view  to select_catalog_role
/
grant execute on ku$_oidindex_t to public
/
grant select on ku$_oidindex_view to select_catalog_role
/
grant select on ku$_column_view to select_catalog_role
/
grant select on ku$_pcolumn_view to select_catalog_role
/
grant select on ku$_p2tcolumn_view to select_catalog_role
/
grant select on ku$_p2tpartcol_view to select_catalog_role
/
grant select on ku$_sp2tcolumn_view to select_catalog_role
/
grant select on ku$_sp2tpartcol_view to select_catalog_role
/
grant execute on ku$_ov_table_t to public
/
grant select on ku$_ov_table_view to select_catalog_role
/
grant execute on ku$_map_table_t to public
/
grant select on ku$_map_table_view to select_catalog_role
/
grant execute on ku$_hnt_t to public
/
grant select on ku$_hnt_view to select_catalog_role
/
grant execute on ku$_iont_t to public
/
grant select on ku$_iont_view to select_catalog_role
/
grant execute on ku$_nt_t to public
/
grant execute on ku$_nt_list_t to public
/
grant execute on ku$_nt_parent_t to public
/
grant select on ku$_nt_parent_view to select_catalog_role
/
grant execute on ku$_tabcluster_t to public
/
grant select on ku$_tabcluster_col_view to select_catalog_role
/
grant select on ku$_tabcluster_view to select_catalog_role
/
grant execute on ku$_clstcol_t to public
/
grant select on ku$_clstcol_view to select_catalog_role
/
grant execute on ku$_clstcol_list_t to public
/
grant execute on ku$_clstjoin_t to public
/
grant execute on ku$_clstjoin_list_t to public
/
grant select on ku$_clstjoin_view to select_catalog_role
/
grant execute on ku$_clst_zonemap_t to public
/
grant select on ku$_clst_zonemap_view to select_catalog_role
/
grant execute on ku$_clst_t to public
/
grant select on ku$_clst_view to select_catalog_role
/
grant execute on ku$_tabclst_t to public
/
grant read on ku$_tabclst_view to public
/
grant execute on ku$_ilm_policy_t to public
/
grant execute on ku$_ilm_policy_list_t to public
/
grant select on ku$_ilm_policy_view to select_catalog_role
/
grant select on ku$_ilm_policy_view2 to select_catalog_role
/
grant select on ku$_tbs_ilm_policy_view to select_catalog_role
/
grant execute on ku$_extloc_t to public
/
grant execute on ku$_extloc_list_t to public
/
grant execute on ku$_exttab_t to public
/
grant read on ku$_exttab_view to public
/
grant execute on ku$_cube_fact_t to public
/
grant execute on ku$_cube_fact_list_t to public
/
grant execute on ku$_cube_hier_t to public
/
grant execute on ku$_cube_hier_list_t to public
/
grant execute on ku$_cube_dim_t to public
/
grant execute on ku$_cube_dim_list_t to public
/
grant execute on ku$_cube_tab_t to public
/
grant select on ku$_cube_fact_view to select_catalog_role
/
grant select on ku$_cube_tab_view to select_catalog_role
/
grant execute on ku$_fba_t to public
/
grant select on ku$_fba_view to select_catalog_role
/
grant execute on ku$_fba_period_t to public
/
grant select on ku$_fba_period_view to select_catalog_role
/
grant read on ku$_htable_view to public
/
grant read on ku$_10_1_htable_view to public
/
grant read on ku$_phtable_view to public
/
grant read on ku$_10_1_phtable_view to public
/
grant read on ku$_fhtable_view to public
/
grant read on ku$_10_2_fhtable_view to public
/
grant read on ku$_10_1_fhtable_view to public
/
grant read on ku$_pfhtable_view to public
/
grant read on ku$_10_1_pfhtable_view to public
/
grant read on ku$_ref_par_level_view to public
/
grant read on ku$_acptable_view to public
/
grant read on ku$_iotable_view to public
/
grant read on ku$_10_1_iotable_view to public
/
grant execute on ku$_ov_tabpart_t to public
/
grant execute on ku$_ov_tabpart_list_t to public
/
grant select on ku$_ov_tabpart_view to select_catalog_role
/
grant execute on ku$_map_tabpart_list_t to public
/
grant select on ku$_map_tabpart_view to select_catalog_role
/
grant execute on ku$_iot_partobj_t to public
/
grant select on ku$_iot_partobj_view to select_catalog_role
/
grant read on ku$_piotable_view to public
/
grant read on ku$_10_1_piotable_view to public
/
grant execute on ku$_partition_t to public
/
grant read on ku$_partition_view to public
/
grant read on ku$_subpartition_view to public
/
grant execute on ku$_table_objnum_t to public
/
grant read on ku$_table_objnum_view to public
/
grant read on ku$_2nd_table_objnum_view to public
/
grant select on ku$_ptable_ts_view to select_catalog_role
/
grant read on ku$_11_2_table_objnum_view to public
/
grant read on ku$_10_1_table_objnum_view to public
/
grant read on ku$_ntable_objnum_view to public
/
grant read on ku$_11_2_ntable_objnum_view to public
/
grant read on ku$_xdb_ntable_objnum_view to public
/
grant read on ku$_11_2_xdb_ntbl_objnum_view to public
/
grant read on ku$_deptable_objnum_view to public
/
grant read on ku$_11_2_deptbl_objnum_view to public
/
grant select on ku$_table_types_view to select_catalog_role
/
grant select on ku$_xmlschema_types_view to select_catalog_role
/
grant select on ku$_tts_types_view to select_catalog_role
/
grant read on ku$_domidx_objnum_view to public
/
grant read on ku$_p2t_domidx_objnum_view to public
/
grant execute on  ku$_option_objnum_t to public
/
grant select on  ku$_expreg to select_catalog_role
/
grant select on ku$_option_objnum_view to select_catalog_role
/
grant select on ku$_option_view_objnum_view to select_catalog_role
/
grant execute on  ku$_marker_t to public
/
grant read on ku$_marker_view to public
/
grant read on ku$_tabprop_view to public
/
grant read on sys.ku$_viewprop_view to public
/
grant read on sys.ku$_view_exists_view to public
/
grant read on sys.ku$_pfhtabprop_view to public
/
grant read on sys.ku$_refparttabprop_view to public
/
grant read on sys.ku$_mvprop_view to public
/
grant read on sys.ku$_mvlprop_view to public
/
grant read on sys.ku$_mzprop_view to public
/
grant read on sys.ku$_syn_exists_view to public
/
grant read on sys.ku$_objgrant_exists_view to public
/
grant read on sys.ku$_constraint_exists_view to public
/
grant read on sys.ku$_ref_constraint_exists_view to public
/
grant read on sys.ku$_ind_exists_view to public
/
grant read on sys.ku$_trig_exists_view to public
/
grant read on sys.ku$_edition_trig_exists_view to public
/
grant read on sys.ku$_proc_exists_view to public
/
grant read on sys.ku$_edition_proc_exists_view to public
/
grant read on sys.ku$_seq_in_default_view to public
/
grant select on sys.ku$_tts_view to select_catalog_role;
grant read on sys.ku$_tab_ts_view to public
/
grant select on sys.ku$_tts_ind_view to select_catalog_role;
grant read on sys.ku$_ind_ts_view to public
/
grant read on sys.ku$_clu_ts_view to public
/
grant select on sys.ku$_tts_mv_view to select_catalog_role
/
grant read on sys.ku$_mv_ts_view to public
/
grant execute on ku$_mv_deptbl_objnum_t to public
/
grant read on sys.ku$_mv_deptbl_objnum_view to public
/
grant select on sys.ku$_tts_mvl_view to select_catalog_role
/
grant read on sys.ku$_mvl_ts_view to public
/
grant select on ku$_unload_method_view to select_catalog_role;
GRANT READ ON sys.ku$xktfbue TO PUBLIC
/
GRANT INSERT ON sys.ku$xktfbue TO PUBLIC
/
grant execute on ku$_bytes_alloc_t to public
/
grant select on ku$_bytes_alloc_view to select_catalog_role
/
grant execute on ku$_tab_bytes_alloc_t to public
/
grant execute on ku$_table_data_t to public
/
grant select on ku$_htable_bytes_alloc_view to select_catalog_role
/
grant read on ku$_htable_data_view to public
/
grant select on ku$_htpart_bytes_alloc_view to select_catalog_role
/
grant read on ku$_htpart_data_view to public
/
grant select on ku$_htspart_bytes_alloc_view to select_catalog_role
/
grant read on ku$_htspart_data_view to public
/
grant select on ku$_iotable_bytes_alloc_view to select_catalog_role
/
grant read on ku$_iotable_data_view to public
/
grant select on ku$_iotpart_bytes_alloc_view to select_catalog_role
/
grant read on ku$_iotpart_data_view to public
/
grant select on ku$_ntable_bytes_alloc_view to select_catalog_role
/
grant read on ku$_ntable_data_view to public
/
grant read on ku$_niotable_data_view to public
/
grant select on ku$_eqntable_bytes_alloc_view to select_catalog_role
/
grant read on ku$_eqntable_data_view to public
/
grant read on ku$_table_data_view to public
/
grant read on ku$_10_2_table_data_view to public
/
grant read on ku$_10_1_table_data_view to public
/
grant read on ku$_tab_subname_view to public;
grant read on ku$_ind_subname_view to public;
grant execute on ku$_post_data_table_t to public
/
grant read on ku$_post_data_table_view to public
/
grant execute on ku$_strmsubcoltype_t to public
/
grant execute on ku$_strmsubcoltype_list_t to public
/
grant select on ku$_strmsubcoltype_view to select_catalog_role
/
grant execute on ku$_strmcoltype_t to public
/
grant select on ku$_strmcoltype_view to select_catalog_role
/
grant select on ku$_10_2_strmsubcoltype_view to select_catalog_role
/
grant execute on ku$_10_2_strmcoltype_t to public
/
grant select on ku$_10_2_strmcoltype_view to select_catalog_role
/
grant execute on ku$_strmcol_t to public
/
grant execute on ku$_strmcol_list_t to public
/
grant select on ku$_strmcol_view to select_catalog_role
/
grant execute on ku$_10_2_strmcol_t to public
/
grant execute on ku$_10_2_strmcol_list_t to public
/
grant select on ku$_10_2_strmcol_view to select_catalog_role
/
grant execute on ku$_strmtable_t to public
/
grant read on ku$_strmtable_view to public
/
grant execute on ku$_10_2_strmtable_t to public
/
grant read on ku$_10_2_strmtable_view to public
/
grant execute on ku$_proc_t to public
/
grant select on ku$_base_proc_view to select_catalog_role
/
grant execute on ku$_proc_objnum_t to public
/
grant select on ku$_base_proc_objnum_view to select_catalog_role
/
grant read on ku$_proc_view to public
/
grant read on ku$_func_view to public
/
grant read on ku$_pkg_objnum_view to public
/
grant read on ku$_pkg_view to public
/
grant read on ku$_pkgbdy_view to public
/
grant execute on ku$_full_pkg_t to public
/
grant read on ku$_full_pkg_view to public
/
grant execute on ku$_exp_pkg_body_t to public
/
grant read on ku$_exp_pkg_body_view to public
/
grant execute on ku$_alter_proc_t to public
/
grant read on ku$_alter_proc_view to public
/
grant read on ku$_alter_func_view to public
/
grant read on ku$_alter_pkgspc_view to public
/
grant read on ku$_alter_pkgbdy_view to public
/
grant execute on ku$_oparg_t to public
/
grant execute on ku$_oparg_list_t to public
/
grant execute on ku$_opancillary_t to public
/
grant execute on ku$_opancillary_list_t to public
/
grant select on ku$_opancillary_view to select_catalog_role
/
grant execute on ku$_opbinding_t to public
/
grant read on ku$_object_error_view to public
/
grant execute on ku$_attribute_dimension_t to public
/
grant read on ku$_attribute_dimension_view to public
/
grant execute on ku$_hierarchy_t to public
/
grant read on ku$_hierarchy_view to public
/
grant execute on ku$_analytic_view_t to public
/
grant read on ku$_analytic_view to public
/
grant execute on ku$_attr_dim_lvl_ordby_t to public
/
grant execute on ku$_attr_dim_lvl_ordby_list_t to public
/
grant select on ku$_attr_dim_lvl_ordby_view to select_catalog_role
/
grant execute on ku$_attr_dim_lvl_t to public
/
grant execute on ku$_attr_dim_lvl_list_t to public
/
grant select on ku$_attr_dim_lvl_view to select_catalog_role
/
grant execute on ku$_attr_dim_attr_t to public
/
grant execute on ku$_attr_dim_attr_list_t to public
/
grant select on ku$_attr_dim_attr_view to select_catalog_role
/
grant execute on ku$_hier_lvl_t to public
/
grant execute on ku$_hier_lvl_list_t to public
/
grant select on ku$_hier_lvl_view to select_catalog_role
/
grant execute on ku$_hier_hier_attr_t to public
/
grant execute on ku$_hier_hier_attr_list_t to public
/
grant select on ku$_hier_hier_attr_view to select_catalog_role
/
grant execute on ku$_analytic_view_keys_t to public
/
grant execute on ku$_analytic_view_keys_list_t to public
/
grant select on ku$_analytic_view_keys_view to select_catalog_role
/
grant execute on ku$_analytic_view_hiers_t to public
/
grant execute on ku$_analytic_view_hiers_list_t to public
/
grant select on ku$_analytic_view_hiers_view to select_catalog_role
/
grant execute on ku$_analytic_view_dim_t to public
/
grant execute on ku$_analytic_view_dim_list_t to public
/
grant select on ku$_analytic_view_dim_view to select_catalog_role
/
grant execute on ku$_analytic_view_meas_t to public
/
grant execute on ku$_analytic_view_meas_list_t to public
/
grant select on ku$_analytic_view_meas_view to select_catalog_role
/
grant select on ku$_hcs_av_cache_dst_mslst to select_catalog_role
/
grant execute on ku$_hcs_av_cache_meas_t to public
/
grant execute on ku$_hcs_av_cache_meas_list_t to public
/
grant select on ku$_hcs_av_cache_meas_view to select_catalog_role
/
grant execute on ku$_hcs_av_cache_lvl_t to public
/
grant execute on ku$_hcs_av_cache_lvl_list_t to public
/
grant select on ku$_hcs_av_cache_lvl_view to select_catalog_role
/
grant execute on ku$_hcs_av_cache_lvgp_t to public
/
grant execute on ku$_hcs_av_cache_lvgp_list_t to public
/
grant select on ku$_hcs_av_cache_lvgp_view to select_catalog_role
/
grant execute on ku$_hcs_av_cache_mlst_t to public
/
grant execute on ku$_hcs_av_cache_mlst_list_t to public
/
grant select on ku$_hcs_av_cache_mlst_view to select_catalog_role
/
grant execute on ku$_attr_dim_join_path_t to public
/
grant execute on ku$_attr_dim_join_path_list_t to public
/
grant select on ku$_attr_dim_join_path_view to select_catalog_role
/
grant execute on ku$_hier_join_path_t to public
/
grant execute on ku$_hier_join_path_list_t to public
/
grant select on ku$_hier_join_path_view to select_catalog_role
/
grant execute on ku$_hcs_clsfctn_t to public
/
grant execute on ku$_hcs_clsfctn_list_t to public
/
grant select on ku$_hcs_clsfctn_view to select_catalog_role
/
grant execute on ku$_hcs_src_t to public
/
grant execute on ku$_hcs_src_list_t to public
/
grant select on ku$_hcs_src_view to select_catalog_role
/
grant execute on ku$_attr_dim_lvl_key_t to public
/
grant execute on ku$_attr_dim_lvl_key_list_t to public
/
grant execute on ku$_hcs_src_col_t to public
/
grant select on ku$_hcs_src_col_view to select_catalog_role
/
grant select on ku$_attr_dim_lvl_key_view to select_catalog_role
/


@?/rdbms/admin/sqlsessend.sql
