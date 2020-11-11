Rem ##########################################################################
Rem 
Rem Copyright (c) 2001, 2016, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catodm.sql
Rem
Rem    DESCRIPTION
Rem      Run all sql scripts for Data Mining Installation 
Rem
Rem    RETURNS
Rem 
Rem    NOTES
Rem      This script must be run while connected as SYS   
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catodm.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catodm.sql
Rem SQL_PHASE: CATODM
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catptabs.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem       raeburns 02/29/16 - Bug 22820096: revert ALTER TYPE to default
Rem                           CASCADE
Rem       raeburns 09/17/15 - bug 21834837: move alter types from c1201000.sql
Rem       jiawang  08/24/15 - remove "WITH GRANT OPTION"
Rem       amozes   10/15/14 - project 36570: long identifiers
Rem       surman   12/29/13 - 13922626: Update SQL metadata
Rem       pstengar 04/04/12 - #(13904079): add types for SYS_DM_TEXT_DF()
Rem       surman   03/27/12 - 13615447: Add SQL patching tags
Rem       bmilenov 02/17/12 - bug-13713471: add mapped feature to SVD
Rem       xbarr    06/01/11 - remove abn_detail types
Rem       bmilenov 05/09/11 - Add EM get_model_details_em_comp types
Rem       xbarr    02/22/11 - add 12g export procedural objects
Rem       amozes   10/06/10 - #(10122250) fix OIDs
Rem       mmcracke 05/11/09 - proj 32331.1 support native double in DMF
Rem       xbarr    05/21/10 - bug 9738851: remove dmsys datapump callout 
Rem       jyarmus  11/09/07 - add feature expression to dm_glm_coeff type
Rem       bmilenov 10/04/07 - Add get_model_details_svm output type
Rem       dmukhin  12/08/06 - bug 5557333: AR scoping
Rem       dmukhin  10/27/06 - bug 5462460: alter reverse expression
Rem       mmcracke 08/03/06 - Remove OC persistence object types
Rem       bmilenov 07/19/06 - Rename fields in dm_glm_coeff 
Rem       bmilenov 07/17/06 - Add 3 output column to dm_glm_coeff 
Rem       bmilenov 06/19/06 - Add more columns to dm_glm_coeff type 
Rem       bmilenov 05/30/06 - Change output type of get_model_details_glm 
Rem       bmilenov 05/23/06 - Change GLM get model details types 
Rem       ramkrish 03/27/06 - add GLM
Rem       mmcracke 05/23/06 - Move ora_mining_tables_nt type here. 
Rem       xbarr    05/22/06 - Merge odmcrt.sql to catodm.sql 
Rem       amozes   05/15/06 - support scoping for nested data 
Rem       dmukhin  05/12/06 - prj 18876: scoring cost matrix 
Rem       dmukhin  03/24/06 - ADP: add types 
Rem       mmcracke 03/10/06 - dmsyssch.sql table creates moved to ddm.bsq
Rem       mmcracke 03/10/06 - dmsyssch.sql type creates moved here
Rem       mmcracke 03/10/06 - dmsyssch.sql view creates moved to catalog.sql
Rem       mmcracke 03/10/06 - all dbmsdmxxx.sql moved to dbmsodm.sql
Rem       mmcracke 03/10/06 - all prvtdmxxx.plb moved to prvtodm.sql
Rem       mmcracke 03/08/06 - Create ODM TYPES here
Rem       mmcracke 09/29/05 - Change DMSYS to SYS 
Rem       xbarr    11/05/04 - remove validation proc from dmsys 
Rem       pstengar 08/24/04 - add prvtdmpa.plb 
Rem       fcay     06/30/04 - Use dbmsdmpa.sql 
Rem       svenkaya 06/29/04 - added prvtdmj 
Rem       xbarr    06/28/04 - run dmsyssch.sql only 
Rem       xbarr    06/23/04 - Merge dmpproc to dmproc, remove dmapi/dmutil
Rem       mmcracke 06/21/04 - Merge dmpsyssch.sql into dmsyssch.sql 
Rem       cbhagwat 06/18/04 - Change blast name
Rem       amozes   06/23/04 - remove hard tabs
Rem       cbhagwat 06/09/04 - code reorg
Rem       xbarr    06/07/04 - update ojdm
Rem       xbarr    10/20/03 - update pmml dtd loading 
Rem       fcay     06/23/03 - Update copyright notice
Rem       xbarr    06/02/03 - remove dmpsysup 
Rem       xbarr    03/10/03 - add dmcl.plb 
Rem       xbarr    03/08/03 - remove odmerr.sql 
Rem       xbarr    02/26/03 - fix error in odm.log 
Rem       xbarr    02/03/03 - add odmproc      
Rem       xbarr    01/27/03 - add dmpsysup 
Rem       xbarr    01/06/03 - add PL/SQL api code for Beta
Rem       xbarr    11/19/02 - add blast 
Rem       xbarr    10/10/02 - remove odmcrt from script. To be run by dminst
Rem       xbarr    09/25/02 - xbarr_txn104463
Rem       xbarr    09/24/02 - updated for 10i installation to be called by odminst 
Rem       xbarr    09/24/02 - replicated from 9202 branch
Rem       xbarr    08/02/02 - xbarr_txn102957
Rem       xbarr    06/06/02 - relocate odmdbmig script to in dm/admin/odmu901.sql
Rem       xbarr    03/12/02 - add dmerrtbl_mig 
Rem       xbarr    03/08/02 - add registry information in dba_registry 
Rem       xbarr    03/07/02 - add error table loading
Rem       xbarr    03/07/02 - use separate sqlldr related file
Rem       xbarr    03/07/02 - remove odmupd line
Rem       xbarr    01/24/02 - add dmmig.sql for R2 privileges 
Rem       xbarr    01/21/02 - add PMML dataset addition 
Rem       xbarr    01/14/02 - commented out dmupd. Will be replaced by dmconfig
Rem       xbarr    01/14/02 - use .plb 
Rem       xbarr    12/10/01 - Merged xbarr_update_shipit
Rem       xbarr    12/04/01 - Merged xbarr_migration_scripts
Rem
Rem    xbarr    12/10/01 - Updated script name and location
Rem    xbarr    12/03/01 - Updated to be called by ODMA
Rem    xbarr    10/27/01 - Creation
Rem
Rem #########################################################################

@@?/rdbms/admin/sqlsessstart.sql

Rem The following OIDs are reserved for Oracle Data Mining Types.
Rem All types that are created and may be used by the end user (and
Rem therefore migrated between databases) should be created with a
Rem unique OID from the below range:
Rem from ko.h
Rem * 0x00000000 0x00000000 0x00000000 0x00021100 to
Rem * 0x00000000 0x00000000 0x00000000 0x000211FF is for TOIDs for DM types.

alter session set current_schema = "SYS";

Rem PL/SQL API exp/imp privilegs

DELETE FROM exppkgact$
        WHERE package='DBMS_DM_MODEL_EXP'
          AND class IN (2,3,6)
          AND level# IN (1000,2000,4000);

Rem Register export procedural object for model export 

DELETE FROM sys.exppkgobj$
      WHERE package = 'DBMS_DM_MODEL_EXP' 
      AND   schema = 'SYS';

INSERT INTO sys.exppkgobj$ (package, schema, class, type#, prepost, level#)
       VALUES ('DBMS_DM_MODEL_EXP', 'SYS', 3, 82, 1, 1000);
commit;

-- ORA_MINING_NUMBER_NT
create type ora_mining_number_nt 
OID '00000000000000000000000000021100' as table of number
/
create or replace public synonym ora_mining_number_nt
for sys.ora_mining_number_nt
/
grant execute on ora_mining_number_nt to public  
/
-- ORA_MINING_VARCHAR2_NT
create type ora_mining_varchar2_nt
OID '00000000000000000000000000021101' as table of varchar2(4000)
/
create or replace public synonym ora_mining_varchar2_nt
for sys.ora_mining_varchar2_nt
/
grant execute on ora_mining_varchar2_nt to public  
/
-- ORA_MINING_TABLE_TYPE
create type ora_mining_table_type
OID '00000000000000000000000000021102' as object
  (table_name varchar2(30),
   table_type varchar2(30))
/
create or replace public synonym ora_mining_table_type
for sys.ora_mining_table_type
/
grant execute on ora_mining_table_type to public  
/
-- ORA_MINING_TABLES_NT
create type ora_mining_tables_nt
OID '00000000000000000000000000021103' as
table of sys.ora_mining_table_type
/
create or replace public synonym ora_mining_tables_nt
for sys.ora_mining_tables_nt
/
grant execute on ora_mining_tables_nt to public
/
-- DM_MODEL_SIGNATURE_ATTRIBUTE
create type dm_model_signature_attribute
OID '00000000000000000000000000021104' as object
  (attribute_name        varchar2(30)
  ,attribute_type        varchar2(106))
/
create or replace public synonym dm_model_signature_attribute
  for sys.dm_model_signature_attribute
/
grant execute on dm_model_signature_attribute to public  
/
-- DM_MODEL_SIGNATURE
create type dm_model_signature
OID '00000000000000000000000000021105'
  as table of dm_model_signature_attribute
/
create or replace public synonym dm_model_signature
  for sys.dm_model_signature
/
grant execute on dm_model_signature to public  
/
-- DM_MODEL_SETTING
create type dm_model_setting
OID '00000000000000000000000000021106' as object
  (setting_name          varchar2(30)
  ,setting_value         varchar2(128))
/
create or replace public synonym dm_model_setting
  for sys.dm_model_setting
/
grant execute on dm_model_setting to public  
/
-- DM_MODEL_SETTINGS
create type dm_model_settings
OID '00000000000000000000000000021107'
  as table of dm_model_setting
/
create or replace public synonym dm_model_settings
  for sys.dm_model_settings
/
grant execute on dm_model_settings to public  
/
-- DM_PREDICATE
create type dm_predicate 
OID '00000000000000000000000000021108'
authid current_user as object
  (attribute_name        varchar2(4000)
  ,attribute_subname     varchar2(4000)
  ,conditional_operator  char(2) /* =, <>, <, >, <=, >= */
  ,attribute_num_value   number
  ,attribute_str_value   varchar2(4000)
  ,attribute_support     number
  ,attribute_confidence  number)
/
create or replace public synonym dm_predicate
  for sys.dm_predicate
/
grant execute on dm_predicate to public  
/
-- DM_PREDICATES
create type dm_predicates
OID '00000000000000000000000000021109' as table of dm_predicate
/
create or replace public synonym dm_predicates
  for sys.dm_predicates
/
grant execute on dm_predicates to public   
/
-- DM_RULE
create type dm_rule
OID '0000000000000000000000000002110A' as object
  (rule_id               integer
  ,antecedent            dm_predicates
  ,consequent            dm_predicates 
  ,rule_support          number
  ,rule_confidence       number
  ,rule_lift             number
  ,antecedent_support    number
  ,consequent_support    number
  ,number_of_items       integer)
/
create or replace public synonym dm_rule
  for sys.dm_rule
/
grant execute on dm_rule to public  
/
-- DM_RULES
create type dm_rules
OID '0000000000000000000000000002110B' as table of dm_rule
/
create or replace public synonym dm_rules
  for sys.dm_rules
/
grant execute on dm_rules to public  
/
-- DM_ITEM
create type dm_item
OID '0000000000000000000000000002110C' as object (
  attribute_name        varchar2(4000),
  attribute_subname     varchar2(4000),
  attribute_num_value   number,
  attribute_str_value   varchar2(4000))
/
create or replace public synonym dm_item
  for sys.dm_item
/
grant execute on dm_item to public  
/
-- DM_ITEMS
create type dm_items
OID '0000000000000000000000000002110D' as table of dm_item
/
create or replace public synonym dm_items
  for sys.dm_items
/
grant execute on dm_items to public  
/
-- DM_ITEMSET
create type dm_itemset
OID '0000000000000000000000000002110E' as object
  (itemset_id            integer
  ,items                 dm_items
  ,support               number
  ,number_of_items       number)
/
create or replace public synonym dm_itemset
  for sys.dm_itemset
/
grant execute on dm_itemset to public  
/
-- DM_ITEMSETS
create type dm_itemsets
OID '0000000000000000000000000002110F' as table of dm_itemset
/
create or replace public synonym dm_itemsets
  for sys.dm_itemsets
/
grant execute on dm_itemsets to public  
/
-- DM_CENTROID
create type dm_centroid
OID '00000000000000000000000000021110' as object
  (attribute_name        varchar2(4000)
  ,attribute_subname     varchar2(4000)
  ,mean                  number
  ,mode_value            varchar2(4000)
  ,variance              number)
/
create or replace public synonym dm_centroid
  for sys.dm_centroid
/
grant execute on dm_centroid to public  
/
-- DM_CENTROIDS
create type dm_centroids
OID '00000000000000000000000000021111' as table of dm_centroid
/
create or replace public synonym dm_centroids
  for sys.dm_centroids
/
grant execute on dm_centroids to public  
/
-- DM_HISTOGRAM_BIN
create type dm_histogram_bin
OID '00000000000000000000000000021112' as object
  (attribute_name        varchar2(4000)
  ,attribute_subname     varchar2(4000)
  ,bin_id                number
  ,lower_bound           number
  ,upper_bound           number
  ,label                 varchar2(4000)
  ,count                 number)
/
create or replace public synonym dm_histogram_bin
  for sys.dm_histogram_bin
/
grant execute on dm_histogram_bin to public  
/
-- DM_HISTOGRAMS
create type dm_histograms
OID '00000000000000000000000000021113' as table of dm_histogram_bin
/
create or replace public synonym dm_histograms
  for sys.dm_histograms
/
grant execute on dm_histograms to public  
/
-- DM_CHILD
create type dm_child
OID '00000000000000000000000000021114' as object
  (id                    number)
/
create or replace public synonym dm_child
  for sys.dm_child
/
grant execute on dm_child to public  
/
-- DM_CHILDREN
create type dm_children
OID '00000000000000000000000000021115' as table of dm_child
/
create or replace public synonym dm_children
  for sys.dm_children
/
grant execute on dm_children to public  
/
-- DM_CLUSTER
create type dm_cluster
OID '00000000000000000000000000021116' as object
  (id                    number
  ,cluster_id            varchar2(4000)
  ,record_count          number
  ,parent                number
  ,tree_level            number
  ,dispersion            number
  ,split_predicate       dm_predicates
  ,child                 dm_children
  ,centroid              dm_centroids
  ,histogram             dm_histograms
  ,rule                  dm_rule)
/
create or replace public synonym dm_cluster
  for sys.dm_cluster
/
grant execute on dm_cluster to public    
/
-- DM_CLUSTERS
create type dm_clusters
OID '00000000000000000000000000021117' as table of dm_cluster
/
create or replace public synonym dm_clusters
  for sys.dm_clusters
/
grant execute on dm_clusters to public  
/
-- DM_CONDITIONAL
create type dm_conditional
OID '00000000000000000000000000021118' as object
  (attribute_name        varchar2(4000)
  ,attribute_subname     varchar2(4000)
  ,attribute_str_value   varchar2(4000)
  ,attribute_num_value   number
  ,conditional_probability number)
/
create or replace public synonym dm_conditional
  for sys.dm_conditional
/
grant execute on dm_conditional to public  
/
-- DM_CONDITIONALS
create type dm_conditionals
OID '00000000000000000000000000021119' as table of dm_conditional
/
create or replace public synonym dm_conditionals
  for sys.dm_conditionals
/
grant execute on dm_conditionals to public  
/
-- DM_NB_DETAIL
create type dm_nb_detail
OID '0000000000000000000000000002111A' as object
  (target_attribute_name varchar2(30)
  ,target_attribute_str_value varchar2(4000)
  ,target_attribute_num_value number
  ,prior_probability     number
  ,conditionals          dm_conditionals)
/
create or replace public synonym dm_nb_detail
  for sys.dm_nb_detail
/
grant execute on dm_nb_detail to public  
/
-- DM_NB_DETAILS
create type dm_nb_details
OID '0000000000000000000000000002111B' as table of dm_nb_detail 
/
create or replace public synonym dm_nb_details
  for sys.dm_nb_details
/
grant execute on dm_nb_details to public  
/
-- DM_NMF_ATTRIBUTE
create type dm_nmf_attribute
OID '0000000000000000000000000002111E' as object
  (attribute_name        varchar2(4000)
  ,attribute_subname     varchar2(4000)
  ,attribute_value       varchar2(4000)
  ,coefficient           number)
/  
create or replace public synonym dm_nmf_attribute
  for sys.dm_nmf_attribute
/
grant execute on dm_nmf_attribute to public  
/
-- DM_NMF_ATTRIBUTE_SET
create type dm_nmf_attribute_set
OID '0000000000000000000000000002111F' as table of dm_nmf_attribute
/
create or replace public synonym dm_nmf_attribute_set
  for sys.dm_nmf_attribute_set
/
grant execute on dm_nmf_attribute_set to public  
/
-- DM_NMF_FEATURE
create type dm_nmf_feature
OID '00000000000000000000000000021120' as object
  (feature_id            number
  ,mapped_feature_id     varchar2(4000)
  ,attribute_set         dm_nmf_attribute_set)
/
create or replace public synonym dm_nmf_feature
  for sys.dm_nmf_feature
/
grant execute on dm_nmf_feature to public  
/
-- DM_NMF_FEATURE_SET
create type dm_nmf_feature_set
OID '00000000000000000000000000021121' as table of dm_nmf_feature
/
create or replace public synonym dm_nmf_feature_set
  for sys.dm_nmf_feature_set
/
grant execute on dm_nmf_feature_set to public  
/
-- DM_SVM_ATTRIBUTE 
create type dm_svm_attribute
OID '00000000000000000000000000021122' as object
  (attribute_name        varchar2(4000)
  ,attribute_subname     varchar2(4000)
  ,attribute_value       varchar2(4000)
  ,coefficient           number)
/
create or replace public synonym dm_svm_attribute
  for sys.dm_svm_attribute
/
grant execute on dm_svm_attribute to public  
/
-- DM_SVM_ATTRIBUTE_SET
create type dm_svm_attribute_set
OID '00000000000000000000000000021123' as table of dm_svm_attribute
/
create or replace public synonym dm_svm_attribute_set
  for sys.dm_svm_attribute_set
/
grant execute on dm_svm_attribute_set to public  
/
-- DM_SVM_LINEAR_COEFF
create type dm_svm_linear_coeff
OID '00000000000000000000000000021124' as object
  (class                 varchar2(4000)
  ,attribute_set         dm_svm_attribute_set)
/
create or replace public synonym dm_svm_linear_coeff
  for sys.dm_svm_linear_coeff
/
grant execute on dm_svm_linear_coeff to public  
/
-- DM_SVM_LINEAR_COEFF_SET
create type dm_svm_linear_coeff_set
OID '00000000000000000000000000021125' as table of dm_svm_linear_coeff
/
create or replace public synonym dm_svm_linear_coeff_set
  for sys.dm_svm_linear_coeff_set
/
grant execute on dm_svm_linear_coeff_set to public  
/
-- DM_GLM_COEFF
create type dm_glm_coeff
OID '00000000000000000000000000021126' as object
  (class                 varchar2(4000)
  ,attribute_name        VARCHAR2(4000)
  ,attribute_subname    VARCHAR2(4000)
  ,attribute_value       VARCHAR2(4000)
  ,feature_expression    VARCHAR2(4000)
  ,coefficient           NUMBER
  ,std_error             NUMBER
  ,test_statistic        NUMBER
  ,p_value               NUMBER
  ,vif                   NUMBER
  ,std_coefficient       NUMBER
  ,lower_coeff_limit     NUMBER
  ,upper_coeff_limit     NUMBER
  ,exp_coefficient       BINARY_DOUBLE
  ,exp_lower_coeff_limit BINARY_DOUBLE
  ,exp_upper_coeff_limit BINARY_DOUBLE
  )
/
create or replace public synonym dm_glm_coeff
  for sys.dm_glm_coeff
/
grant execute on dm_glm_coeff to public  
/
-- DM_GLM_COEFF_SET
create type dm_glm_coeff_set
OID '00000000000000000000000000021127' as table of dm_glm_coeff
/
create or replace public synonym dm_glm_coeff_set
  for sys.dm_glm_coeff_set
/
grant execute on dm_glm_coeff_set to public  
/
-- DM_SVD_MATRIX
create type dm_svd_matrix 
OID '00000000000000000000000000021128' as object
  (matrix_type           CHAR(1)
  ,feature_id            NUMBER
  ,mapped_feature_id     VARCHAR2(4000)
  ,attribute_name        VARCHAR2(4000)
  ,attribute_subname     VARCHAR2(4000)
  ,case_id               VARCHAR2(4000)
  ,value                 NUMBER
  ,variance              number
  ,pct_cum_variance      NUMBER
  )
/
create or replace public synonym dm_svd_matrix
  for sys.dm_svd_matrix
/
grant execute on dm_svd_matrix to public  
/
-- DM_SVD_MATRIX_SET
create type dm_svd_matrix_set 
OID '00000000000000000000000000021129' as table of dm_svd_matrix
/
create or replace public synonym dm_svd_matrix_set
  for sys.dm_svd_matrix_set
/
grant execute on dm_svd_matrix_set to public  
/
-- DM_MODEL_GLOBAL_DETAIL
create type dm_model_global_detail
OID '0000000000000000000000000002112A' as object
  (global_detail_name    VARCHAR2(30)
  ,global_detail_value   number)
/
create or replace public synonym dm_model_global_detail
  for sys.dm_model_global_detail
/
grant execute on dm_model_global_detail to public  
/
-- DM_MODEL_GLOBAL_DETAILS
create type dm_model_global_details
OID '0000000000000000000000000002112B' as table of dm_model_global_detail 
/
create or replace public synonym dm_model_global_details
  for sys.dm_model_global_details
/
grant execute on dm_model_global_details to public  
/
-- dm_nested_numerical
create type dm_nested_numerical
OID '0000000000000000000000000002112C' as object
  (attribute_name        varchar2(4000)
  ,value                 number)
/
create or replace public synonym dm_nested_numerical
  for sys.dm_nested_numerical
/
grant execute on dm_nested_numerical to public  
/
-- DM_NESTED_NUMERICALS
create type dm_nested_numericals
OID '0000000000000000000000000002112D'
  as table of dm_nested_numerical
/
create or replace public synonym dm_nested_numericals
  for sys.dm_nested_numericals
/
grant execute on dm_nested_numericals to public  
/
-- DM_NESTED_CATEGORICAL
create type dm_nested_categorical
OID '0000000000000000000000000002112E' as object
  (attribute_name        varchar2(4000)
  ,value                 varchar2(4000))
/
create or replace public synonym dm_nested_categorical
  for sys.dm_nested_categorical
/
grant execute on dm_nested_categorical to public  
/
-- DM_NESTED_CATEGORICALS
create type dm_nested_categoricals
OID '0000000000000000000000000002112F'
  as table of dm_nested_categorical
/
create or replace public synonym dm_nested_categoricals
  for sys.dm_nested_categoricals
/
grant execute on dm_nested_categoricals to public  
/
-- DM_RANKED_ATTRIBUTE
create type dm_ranked_attribute
OID '00000000000000000000000000021130' as object
  (attribute_name        varchar2(4000),
   attribute_subname     varchar2(4000),
   importance_value      number,
   rank                  number(38))
/
create or replace public synonym dm_ranked_attribute
  for sys.dm_ranked_attribute  
/
grant execute on dm_ranked_attribute to public  
/
-- DM_RANKED_ATTRIBUTES
create type dm_ranked_attributes
OID '00000000000000000000000000021131'
  as table of dm_ranked_attribute
/
create or replace public synonym dm_ranked_attributes
  for sys.dm_ranked_attributes
/
grant execute on dm_ranked_attributes to public  
/
-- DM_TRANSFORM
create type dm_transform
OID '00000000000000000000000000021132' as object (
  attribute_name        varchar2(4000),
  attribute_subname     varchar2(4000),
  expression            clob,
  reverse_expression    clob)
/
create or replace public synonym dm_transform for sys.dm_transform
/
grant execute on dm_transform to public  
/
-- DM_TRANSFORMS
create type dm_transforms
OID '00000000000000000000000000021133' as table of dm_transform
/
create or replace public synonym dm_transforms for sys.dm_transforms
/
grant execute on dm_transforms to public  
/
-- DM_COST_ELEMENT
create type dm_cost_element
OID '00000000000000000000000000021134' as object (
  actual      varchar2(4000),
  predicted   varchar2(4000),
  cost        number)
/
create or replace public synonym dm_cost_element for sys.dm_cost_element
/
grant execute on dm_cost_element to public  
/
-- DM_COST_MATRIX
create type dm_cost_matrix
OID '00000000000000000000000000021135' as table of dm_cost_element
/
create or replace public synonym dm_cost_matrix for sys.dm_cost_matrix
/
grant execute on dm_cost_matrix to public  
/
-- DM_NESTED_BINARY_FLOAT
create type dm_nested_binary_float
OID '00000000000000000000000000021136' as object
  (attribute_name        varchar2(4000)
  ,value                 binary_float)
/
create or replace public synonym dm_nested_binary_float
  for sys.dm_nested_binary_float
/
grant execute on dm_nested_binary_float to public  
/
-- DM_NESTED_BINARY_FLOATS
create type dm_nested_binary_floats
OID '00000000000000000000000000021137'
  as table of dm_nested_binary_float
/
create or replace public synonym dm_nested_binary_floats
  for sys.dm_nested_binary_floats
/
grant execute on dm_nested_binary_floats to public  
/
-- DM_NESTED_BINARY_DOUBLE
create type dm_nested_binary_double
OID '00000000000000000000000000021138' as object
  (attribute_name        varchar2(4000)
  ,value                 binary_double)
/
create or replace public synonym dm_nested_binary_double
  for sys.dm_nested_binary_double
/
grant execute on dm_nested_binary_double to public  
/
-- DM_NESTED_BINARY_DOUBLES
create type dm_nested_binary_doubles
OID '00000000000000000000000000021139'
  as table of dm_nested_binary_double
/
create or replace public synonym dm_nested_binary_doubles
  for sys.dm_nested_binary_doubles
/
grant execute on dm_nested_binary_doubles to public  
/
-- DM_EM_COMPONENT
create type dm_em_component 
OID '00000000000000000000000000021140' as object
  (info_type             VARCHAR2(30)
  ,component_id          NUMBER
  ,cluster_id            NUMBER
  ,attribute_name        VARCHAR2(4000)
  ,covariate_name        VARCHAR2(4000)
  ,attribute_value       VARCHAR2(4000)
  ,value                 NUMBER
  )
/
create or replace public synonym dm_em_component
  for sys.dm_em_component
/
grant execute on dm_em_component to public  
/
-- DM_EM_COMPONENT_SET
create type dm_em_component_set 
OID '00000000000000000000000000021141' as table of dm_em_component
/
create or replace public synonym dm_em_component_set
  for sys.dm_em_component_set
/
grant execute on dm_em_component_set to public  
/
-- DM_EM_PROJECTION
create type dm_em_projection
OID '00000000000000000000000000021142' as object
  (feature_name          VARCHAR2(4000)
  ,attribute_name        VARCHAR2(4000)
  ,attribute_subname     VARCHAR2(4000)
  ,attribute_value       VARCHAR2(4000)
  ,coefficient           NUMBER
  )
/
create or replace public synonym dm_em_projection
  for sys.dm_em_projection
/
grant execute on dm_em_projection to public  
/
-- DM_EM_PROJECTION_SET
create type dm_em_projection_set 
OID '00000000000000000000000000021143' as table of dm_em_projection
/
create or replace public synonym dm_em_projection_set
  for sys.dm_em_projection_set
/
grant execute on dm_em_projection_set to public  
/
-- DM_MODEL_TEXT_DF
create type DM_MODEL_TEXT_DF
OID '00000000000000000000000000021144' as object
  (attribute_name      varchar2(30)
  ,feature_name        varchar2(4000)
  ,frequency           number)
/
create or replace public synonym DM_MODEL_TEXT_DF
  for sys.DM_MODEL_TEXT_DF
/
grant execute on DM_MODEL_TEXT_DF to public  
/
-- DM_MODEL_TEXT_DFS
create type DM_MODEL_TEXT_DFS
OID '00000000000000000000000000021145'
  as table of DM_MODEL_TEXT_DF
/
create or replace public synonym DM_MODEL_TEXT_DFS
  for sys.DM_MODEL_TEXT_DFS
/
grant execute on DM_MODEL_TEXT_DFS to public  
/

-- DM_RQMODEL_RAW_NT
create type DM_RQMODEL_RAW_NT
OID '00000000000000000000000000021146' as table of RAW(2000)
/

-- ALTER TYPEs for 12.2
alter type ora_mining_table_type
 modify attribute table_name varchar2(130) cascade;
alter type dm_model_signature_attribute
 modify attribute attribute_name varchar2(130) cascade;
alter type dm_model_setting
 modify attribute setting_value varchar2(4000) cascade;
alter type dm_nb_detail
 modify attribute target_attribute_name varchar2(130) cascade;
alter type DM_MODEL_TEXT_DF
 modify attribute attribute_name varchar2(130) cascade;

@?/rdbms/admin/sqlsessend.sql
