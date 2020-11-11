Rem Copyright (c) 2002, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsdm.sql - dbms Data Mining
Rem
Rem    DESCRIPTION
Rem      This package provides routines for Data Mining operations
Rem      in an Oracle Server.
Rem
Rem    NOTES
Rem      The procedural option is needed to use this package. This package
Rem      must be created under SYS. Operations provided by this package
Rem      are performed under the current calling user, not under the package
Rem      owner SYS.
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmsdm.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmsdm.sql
Rem SQL_PHASE: DBMSDM
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/dbmsodm.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY) 
REM    amozes      05/03/17 - #(25992244): enable tablespace override
REM    bmilenov    04/21/17 - fix a typo in NNET_ACTIVATIONS_LINEAR
REM    amozes      04/13/17 - #(25889903): support model without details
REM    yacheche    03/27/17 - bug-25772511: bad sample size in association rule
REM    nihao       03/23/17 - add nnet_regularizer_none
REM    amozes      02/14/17 - serialized export/import
REM    gayyappa    12/28/16 - add random forest
REM    ffeli       12/12/16 - Add algorithm registration functions
REM    jyarmus     10/20/16 - add exponential smoothing optimization criteria
REM    bmilenov    11/16/16 - bug-25107216: ADMM with LBFGS solver
REM    nihao       09/21/16 - add neural network
REM    yacheche    09/08/16 - add CUR settings
REM    mmcracke    08/01/16 - #(24354682) Remove default_setting_type reference
REM    nihao       03/28/16 - add CUR
REM    gayyappa    11/16/15 - add ODMS_PARTITION_BUILD_TYPE 
REM    mmcracke    11/06/15 - #(21918919) Bug fix
REM    nihao       10/15/15 - add glm sparse solver
REM    gayyappa    08/31/15 - add CLAS_MAX_SUP_BINS
REM    nihao       08/19/15 - bug-21393905: glm solver setting.
REM    mmcampos    08/15/15 - Bug 21459062 - Add new SVD solver settings
REM    qinwan      08/09/15 - add R model parameter name constant
REM    bmilenov    07/06/15 - Add prep shift and scale constants
REM    bmilenov    06/19/15 - bug-18328797: missing value delete row
REM    bmilenov    04/20/15 - bug-20877814: SVM solver setting
REM    bmilenov    03/09/15 - bug-20671066: sampling settings
REM    nihao       02/20/15 - bug 20471864: put GLMS_DIAGNOSTICS_TABLE_NAME back
REM    dbai        02/19/15 - bug-20145900: Add new AR settings
REM    bmilenov    01/12/15 - bug-20201889: Add regularizer setting for SVM
REM    mmcampos    01/02/15 - Add extra SVD settings
REM    bmilenov    11/14/14 - Add ESA settings
REM    bmilenov    09/22/14 - GLM SGD settings
REM    qinwan      09/17/14 - move rq types to separate file
REM    qinwan      08/18/14 - add R model dm$rqMod_DetailImpl type declaration
REM    jyarmus     07/10/14 - change GLM row diagnostics setting
REM    surman      12/29/13 - 13922626: Update SQL metadata
REM    mmcracke    07/29/13 - bug 17221590 rename model versioning
REM    jyarmus     03/25/13 - bug 16528667
REM    xbarr       10/09/12 - bug 14737891
REM    jyarmus     07/19/12 - bug 14250749
REM    jyarmus     05/24/12 - fix bug 14112868
REM    surman      03/27/12 - 13615447: Add SQL patching tags
REM    pstengar    11/08/11 - bug 13071710: remove MAX_DOCTERMS
REM    bmilenov    10/12/11 - bug-13083060: introduce approximate computation
REM                           in EM
REM    amozes      10/13/11 - revert default topn for clustering
REM    bmilenov    10/03/11 - Bug-10354925: make approximate computation an ODM
REM                           level setting
Rem    xbarr       09/22/11 - add tablespace_remap
REM    bmilenov    08/18/11 - bug-12878833: fix EM setting inconsistency
REM    xbarr       07/20/11 - remove ABN
REM    mmcracke    07/12/11 - #(11666638) topn attributes added to
REM                           get_model_details_km/oc/em
REM    bmilenov    04/28/11 - Add Expectation Maximization
REM    pstengar    12/10/10 - add settings for text support
REM    jyarmus     08/24/10 - Change name of model pruning setting to
REM                           glms_prune_model and add setting
REM                           glms_feature_acceptance
REM    pstengar    07/28/10 - Bug 9948278: PMML import, add parameter for
REM                           "strict" syntax check
REM    jyarmus     12/24/09 - add setting to enable/disable final model pruning
REM    pstengar    07/31/09 - add PMML import
REM    bmilenov    06/15/09 - Bug-8661316: Add a new scoring setting to NMF
REM    amozes      05/06/08 - #(6868134): add force to drop_model
REM    bmilenov    10/04/07 - Add get_model_details_svd
REM    bmilenov    09/24/07 - Add SVD constants
REM    ramkrish    04/17/07 - add xnal input to create_model
REM    jyarmus     03/20/08 - add GLM feature identification setting
REM    dmukhin     03/04/08 - bug 6620177: ADP coefficients reversal
REM    pstengar    10/23/07 - bug 6439266: add score_criterion_type parameter
REM    jyarmus     07/09/07 - add feature selection and feature generation to
REM                           glm
REM    dmukhin     02/09/07 - bug 5854733: remove coefficient reverse xform
REM    jyarmus     01/30/07 - add glm setting VIF for ridge
REM    dmukhin     12/13/06 - bug 5557333: AR scoping
REM    dmukhin     11/13/06 - lob performance
REM    dmukhin     10/06/06 - bug 5462460: alter reverse expression
REM    bmilenov    08/16/06 - Change missing value treatment constants
REM    bmilenov    08/07/06 - Bug #5447741 - GLM setting cleanup
REM    amozes      06/08/06 - add transform_coeff to NMF and SVM 
REM    amozes      05/23/06 - add get_model_transformations 
REM    bmilenov    05/25/06 - Add get_model_details_global 
REM    dmukhin     05/11/06 - prj 18876: scoring cost matrix
REM    dmukhin     03/27/06 - ADP: stack interface
REM    ramkrish    03/24/06 - add GLM 
REM    mmcracke    03/31/05 - Change public synonyms from DMSYS to SYS 
REM    mmcracke    02/07/05 - Add max_rule_length filter to 
REM                           get_association_rules. 
REM    gtang       02/04/05 - Fix bug #4107224 
REM    mmcracke    01/13/05 - Remove obsolete SVM delete_class API call 
REM    mmcracke    12/15/04 - Remove reference to DMSYS. 
REM    mmcracke    11/03/04 - Add filtering items to get_assocation_rules. 
REM    mmcracke    09/03/04 - Change name of topn parameter. 
REM    mmcracke    08/05/04 - Add top-N parameter to get_association_rules. 
REM    amozes      08/04/04 - make TREES singular 
REM    bmilenov    08/03/04 - Introduce SVM outlier rate setting
REM    xbarr       06/25/04 - xbarr_dm_rdbms_migration
REM    gtang       05/19/04 - add get_model_details_oc
REM    cbhagwat    05/19/04 - Remove ref to predictor variance
REM    jyarmus     05/14/04 - fix active learning parameter values
REM    bmilenov    05/10/04 - create constant for default kernel
REM    jyarmus     05/10/04 - add active learning
REM    amozes      04/21/04 - add support for decision tree builds 
REM    mmcracke    03/12/04 - Add delete_class API call for SVM
REM    gtang       02/18/04 - Adding O-Cluster model
REM    pstengar    10/31/03 - fixed order of parameters in create_model
REM    ramkrish    10/23/03 - replace predictor_variance w/ ai_mdl
REM    hyoon       10/22/03 - to add MDL for AI
REM    cbhagwat    10/17/03 - feature select renamed to feature_extract
REM    cbhagwat    09/23/03 - svm comments
REM    cbhagwat    09/15/03 - Remove NMFS_STOP_CRITERIA
REM    ramkrish    09/08/03 - Add get_model_details_svm
REM    cbhagwat    09/05/03 - KMN setting fixes
REM    pstengar    08/29/03 - Removed exposure of get_model_details
REM    cbhagwat    07/29/03 - Add settings (Attr Imp)
REM    cbhagwat    07/21/03 - Fix 3058974
REM    ramkrish    07/15/03 - fix rules for KM
REM    ramkrish    07/11/03 - remove compute_rules/histograms settings
REM    ramkrish    06/22/03 - chg BUILD to CREATE_MODEL
REM    gtang       06/16/03 - Change import_model() signature
REM    ramkrish    06/13/03 - remove get_target_values
REM    pstengar    06/02/03 - Added get_model_details returning XMLType
REM    gtang       06/04/03 - Fix tabulation in one line
REM    gtang       05/30/03 - change type of modelnames to varchar2
REM                           in import_model()
REM    ramkrish    05/30/03 - add get_frequent_itemsets
REM    ramkrish    05/29/03 - get_model_details_ar to get_association_rules
REM    cbhagwat    05/21/03 - kmns settings changes
REM    pstengar    05/19/03 - removed precesion_recall since
REM                           multi target is not supported
REM    pstengar    05/15/03 - Added get_default_settings table FUNCTION
REM                           and moved defaults to dmp_sec
REM    ramkrish    05/09/03 - code review changes
REM    cbhagwat    04/28/03 - renaming svms_tolerance
REM    pstengar    04/22/03 - Made dm_kmn_conv_tolerance NUMBER type
REM    cbhagwat    04/18/03 - approx => regression
REM    pstengar    04/17/03 - Removed "p_" from parameter names
REM    cbhagwat    04/16/03 - Package name change
REM    cbhagwat    04/08/03 - new input params in rank_apply
REM    pstengar    04/07/03 - Added parameters to compute specifications
REM    pstengar    04/03/03 - Made get_model_signature pipelined
REM    gtang       04/02/03 - Add model export/import
REM    pstengar    03/31/03 - Added get_model_settings
REM    cbhagwat    03/31/03 - Add nmf stop criteria enum
REM    ramkrish    03/27/03 - add get_model_details_abn
REM    cbhagwat    03/26/03 - remove named exceptions
REM    bbloom      03/24/03 - Fix constants for ABNS model types to be
REM                           strings rather than numbers
REM    pstengar    03/20/03 - Added cost matrix parameter to compute functions
REM    cbhagwat    03/25/03 - Desupport CLAS_COST_MATRIX setting
REM    bbloom      03/20/03 - Change "abns_nb_predictors" TO
REM                           "abns_max_nb_predictors"
REM    cbhagwat    03/20/03 - Adding rank_apply
REM    cbhagwat    03/14/03 - change complexity and std dev default for svm
REM    bbloom      03/04/03 - Fix algo_adaptive_bayes_network
REM    pstengar    03/03/03 - Added "DM_" prefix to public types
REM    mmcracke    03/03/03 - implement get_model_details_nmf
REM    bbloom      02/24/03 - Add default values for abn_param
REM    bbloom      02/20/03 - Add constants for ABN
REM    cbhagwat    02/20/03 - kmn-build
REM    cbhagwat    02/18/03 - add get_model_details_nb
REM    cbhagwat    02/13/03 - removing DATA_ settings
REM    mmcracke    02/12/03 - Add additional nmf default params
REM    pstengar    02/10/03 - Modified compute_confusion_matrix AND
REM                           compute lift signatures
REM    ramkrish    02/10/03 - add named exceptions
REM    cbhagwat    02/12/03 - km => cl
REM    cbhagwat    02/10/03 - Adding k-means get_model_details code
REM    cbhagwat    02/06/03 - change max ar rule length to 20
REM    cbhagwat    02/03/03 - change order
REM    ramkrish    01/30/03 - cleanup API signatures - add eval templates
REM    cbhagwat    01/29/03 - take data prep out
REM    cbhagwat    01/17/03 - implement get_model_details_ar
REM    cbhagwat    01/14/03 - Adding nmf constants
REM    ramkrish    01/10/03 - add get_model_details_ar
REM    cbhagwat    01/10/03 - continue svm
REM    cbhagwat    01/07/03 - supporting svm
REM    ramkrish    12/28/02 - fix comments on settings table
REM    cbhagwat    12/24/02 - code AR
REM    cbhagwat    12/17/02 - fix errors
REM    cbhagwat    12/16/02 - adding svm stubs
REM    pstengar    12/11/02 - Added get_target_values function
REM    cbhagwat    12/09/02 - case-id compulsory
REM    cbhagwat    12/03/02 - Changing lift signature
REM    cbhagwat    11/05/02 - name changes
REM    ramkrish    11/04/02 - fix signatures
REM    ramkrish    11/01/02 - reflect review comments
REM    cbhagwat    09/19/02 - defining constants etc
REM    cbhagwat    09/16/02 - Skeleton for pl/sql api
REM    mmcampos    04/15/02 - Add header and settings and enums constants
REM    dmukhin     02/15/02 - add more prototypes  
REM    ramkrish    01/11/02 - Creation    
Rem

@@?/rdbms/admin/sqlsessstart.sql
  
REM ********************************************************************
REM THE FUNCTIONS SUPPLIED BY THIS PACKAGE AND ITS EXTERNAL INTERFACE
REM ARE RESERVED BY ORACLE AND ARE SUBJECT TO CHANGE IN FUTURE RELEASES.
REM ********************************************************************

REM ********************************************************************
REM THIS PACKAGE MUST NOT BE MODIFIED BY THE CUSTOMER.  DOING SO COULD
REM CAUSE INTERNAL ERRORS AND SECURITY VIOLATIONS IN THE RDBMS.
REM ********************************************************************

REM ********************************************************************
REM THIS PACKAGE MUST BE CREATED UNDER DMSYS.
REM ********************************************************************


CREATE OR REPLACE PACKAGE dbms_data_mining AUTHID CURRENT_USER AS

  ------------
  --  OVERVIEW
  --
  --     This package provides general purpose routines for Data Mining
  --     operations viz.
  --     . CREATE a MODEL against build data.
  --     . DROP an existing MODEL.
  --     . RENAME an existing MODEL.  
  --     . COMPUTE various metrics to test a model against the APPLY
  --       results on test data, with cost inputs
  --     . APPLY a model to (production) mining data
  --     . RANK the APPLY results based on cost and other factors
  --     . GET the MODEL SIGNATURE - i.e. retrieve the attributes
  --       that constitute the model and their relevant characteristics.
  --     . GET the MODEL DETAILS - i.e. retrieve the contents of
  --       the model - the specific patterns and rules that were used
  --       in making the prediction (in the case of predictive models),
  --       and/or the declarative rules (in the case of declarative models).
  --
  
  ------------------------
  -- RULES AND LIMITATIONS
  --
  --     The following rules apply in the specification of functions and 
  --     procedures in this package.
  --
  --     A function/procedure will raise an INVALID_ARGVAL exception if the
  --     the following restrictions are not followed in specifying values
  --     for parameters (unless otherwise specified):
  --
  --     1. Every BUILD operation MUST have the mining function
  --        name specified at the minimum.
  --     2. All schema object names, except models, should be maximum
  --        30 bytes in size.
  --     3. All model names should be maximum 25 bytes in size.
  --     4. The SETTINGS discussed below under CONSTANTS represent the name
  --        tags and values that act as column values in a user-created
  --        Settings Table, with a fixed schema and column types:
  --   
  --        SETTING_NAME  SETTING_VALUE
  --        varchar2(30)  varchar2(30)
  --
  --     5. For numerical settings, use TO_CHAR() to store them in the
  --        SETTING_VALUE column - the API will interpret the values.
  --
  --
  
  -----------
  -- SECURITY
  -- 
  --     Privileges are associated with the the caller of the procedures/
  --     functions in this package as follows:
  --     If the caller is an anonymous PL/SQL block, the procedures/functions
  --     are run with the privilege of the current user. 
  --     If the caller is a stored procedure, the procedures/functions are run
  --     using the privileges of the owner of the stored procedure.
  --

  ------------
  -- CONSTANTS
  --
  -- General Settings - Begin ------------------------------------------------

  -- Data Prep: Setting Names 
  prep_auto                CONSTANT VARCHAR2(30) := 'PREP_AUTO';

  -- Data Prep: Setting Values for prep_auto
  prep_auto_off            CONSTANT VARCHAR2(30) := 'OFF';
  prep_auto_on             CONSTANT VARCHAR2(30) := 'ON';
  
  -- normalization settings
  -- 2D numeric columns scale
  prep_scale_2dnum         CONSTANT VARCHAR2(30) := 'PREP_SCALE_2DNUM';
  -- values for prep_scale_2dnum
  prep_scale_stddev        CONSTANT VARCHAR2(30) := 'PREP_SCALE_STDDEV';
  prep_scale_range         CONSTANT VARCHAR2(30) := 'PREP_SCALE_RANGE';
  -- nested numeric columns scale
  prep_scale_nnum          CONSTANT VARCHAR2(30) := 'PREP_SCALE_NNUM';
  -- value for prep_scale_nnum
  prep_scale_maxabs        CONSTANT VARCHAR2(30) := 'PREP_SCALE_MAXABS';
  -- 2D numeric shift
  prep_shift_2dnum         CONSTANT VARCHAR2(30) := 'PREP_SHIFT_2DNUM';
  -- values for prep_shift_2dnum
  prep_shift_mean          CONSTANT VARCHAR2(30) := 'PREP_SHIFT_MEAN';
  prep_shift_min           CONSTANT VARCHAR2(30) := 'PREP_SHIFT_MIN';
  
  -- Score Criterion Type: Setting Values for score_criterion_type
  score_criterion_probability CONSTANT VARCHAR2(30) := 'PROBABILITY';
  score_criterion_cost        CONSTANT VARCHAR2(30) := 'COST';

  -- Row Weights - Setting Name
  odms_row_weight_column_name    CONSTANT VARCHAR2(30) :=
    'ODMS_ROW_WEIGHT_COLUMN_NAME';

  -- Cost Matrix
  cost_matrix_type_score   CONSTANT VARCHAR2(30) := 'SCORE';
  cost_matrix_type_create  CONSTANT VARCHAR2(30) := 'CREATE';

  -- Missing Value Treatment - Setting Name
  odms_missing_value_treatment   CONSTANT VARCHAR2(30) :=
    'ODMS_MISSING_VALUE_TREATMENT';

  -- Missing Value Treatment: Setting Values for ODMS_MISSING_VALUE_TREATMENT
  odms_missing_value_mean_mode   CONSTANT VARCHAR2(30) := 
    'ODMS_MISSING_VALUE_MEAN_MODE';
  odms_missing_value_delete_row  CONSTANT VARCHAR2(30) := 
    'ODMS_MISSING_VALUE_DELETE_ROW';
  odms_missing_value_auto  CONSTANT VARCHAR2(30) := 
    'ODMS_MISSING_VALUE_AUTO';

  -- Transactional training data format: Setting Names
  odms_item_id_column_name       CONSTANT VARCHAR2(30) :=
    'ODMS_ITEM_ID_COLUMN_NAME';
  odms_item_value_column_name    CONSTANT VARCHAR2(30) :=
    'ODMS_ITEM_VALUE_COLUMN_NAME';

  -- Unstructured Text Setting Names
  odms_text_policy_name          CONSTANT VARCHAR2(30) :=
    'ODMS_TEXT_POLICY_NAME';
  odms_text_max_features         CONSTANT VARCHAR2(30) :=
    'ODMS_TEXT_MAX_FEATURES';
  odms_text_min_documents        CONSTANT VARCHAR2(30) :=
    'ODMS_TEXT_MIN_DOCUMENTS';
  
  
  -- Approximate computation
  odms_approximate_computation CONSTANT VARCHAR2(30) := 
                                             'ODMS_APPROXIMATE_COMPUTATION';
  -- Setting values for odms_approximate_computation
  odms_appr_comp_enable     CONSTANT VARCHAR2(30) := 'ODMS_APPR_COMP_ENABLE';
  odms_appr_comp_disable    CONSTANT VARCHAR2(30) := 'ODMS_APPR_COMP_DISABLE';
  
  -- Sampling
  odms_sampling             CONSTANT VARCHAR2(30) := 'ODMS_SAMPLING';
  -- Setting values for odms_sampling
  odms_sampling_enable      CONSTANT VARCHAR2(30) := 'ODMS_SAMPLING_ENABLE';
  odms_sampling_disable     CONSTANT VARCHAR2(30) := 'ODMS_SAMPLING_DISABLE';
  
  -- Sample size
  odms_sample_size          CONSTANT VARCHAR2(30) := 'ODMS_SAMPLE_SIZE';
  
  -- Partitioning
  odms_partition_columns    CONSTANT VARCHAR2(30) := 'ODMS_PARTITION_COLUMNS';
  
  -- Max partition columns
  odms_max_partitions       CONSTANT VARCHAR2(30) := 'ODMS_MAX_PARTITIONS';

  -- Max sup bins ---
  clas_max_sup_bins         CONSTANT VARCHAR2(30) := 'CLAS_MAX_SUP_BINS';
 
  --Partition build type (inter/intra/hybrid)
  odms_partition_build_type  CONSTANT VARCHAR2(30) := 
                                      'ODMS_PARTITION_BUILD_TYPE'; 
  odms_partition_build_inter CONSTANT VARCHAR2(30) := 
                                      'ODMS_PARTITION_BUILD_INTER'; 
  odms_partition_build_intra CONSTANT VARCHAR2(30) := 
                                      'ODMS_PARTITION_BUILD_INTRA'; 
  odms_partition_build_hybrid CONSTANT VARCHAR2(30) := 
                                      'ODMS_PARTITION_BUILD_HYBRID';

  -- random seed
  odms_random_seed CONSTANT VARCHAR2(30):= 'ODMS_RANDOM_SEED'; 

  -- retain information for details (default is enable)
  odms_details         CONSTANT VARCHAR2(30):= 'ODMS_DETAILS'; 
  odms_enable          CONSTANT VARCHAR2(30):= 'ODMS_ENABLE';
  odms_disable         CONSTANT VARCHAR2(30):= 'ODMS_DISABLE';

  -- override default tablespace
  odms_tablespace_name CONSTANT VARCHAR2(30):= 'ODMS_TABLESPACE_NAME'; 

  -- General Settings - End -------------------------------------------------
  
  -----------   Function and Algorithm Settings - Begin ---------------------

  -- FUNCTION NAME (input as CREATE_MODEL parameter)
  --
  classification           CONSTANT VARCHAR2(30) := 'CLASSIFICATION';
  regression               CONSTANT VARCHAR2(30) := 'REGRESSION';
  clustering               CONSTANT VARCHAR2(30) := 'CLUSTERING';
  association              CONSTANT VARCHAR2(30) := 'ASSOCIATION';
  feature_extraction       CONSTANT VARCHAR2(30) := 'FEATURE_EXTRACTION';
  attribute_importance     CONSTANT VARCHAR2(30) := 'ATTRIBUTE_IMPORTANCE';
  time_series              CONSTANT VARCHAR2(30) := 'TIME_SERIES';

  -- FUNCTION: Setting Names (input to settings_name column in settings table)
  clas_priors_table_name   CONSTANT VARCHAR2(30) := 'CLAS_PRIORS_TABLE_NAME';
  clas_weights_table_name  CONSTANT VARCHAR2(30) := 'CLAS_WEIGHTS_TABLE_NAME';
  clas_cost_table_name     CONSTANT VARCHAR2(30) := 'CLAS_COST_TABLE_NAME';
  -- Balanced weights (boolean: on/off) */
  clas_weights_balanced    CONSTANT VARCHAR2(30) := 'CLAS_WEIGHTS_BALANCED';
  clas_weights_bal_off     CONSTANT VARCHAR2(30) := 'OFF';
  clas_weights_bal_on      CONSTANT VARCHAR2(30) := 'ON';  
  
  -- AR: Setting Names
  asso_max_rule_length     CONSTANT VARCHAR2(30) := 'ASSO_MAX_RULE_LENGTH';
  asso_min_confidence      CONSTANT VARCHAR2(30) := 'ASSO_MIN_CONFIDENCE';
  asso_min_support         CONSTANT VARCHAR2(30) := 'ASSO_MIN_SUPPORT';
  asso_min_support_int     CONSTANT VARCHAR2(30) := 'ASSO_MIN_SUPPORT_INT';
  asso_min_rev_confidence  CONSTANT VARCHAR2(30) := 'ASSO_MIN_REV_CONFIDENCE';
  asso_in_rules            CONSTANT VARCHAR2(30) := 'ASSO_IN_RULES';
  asso_ex_rules            CONSTANT VARCHAR2(30) := 'ASSO_EX_RULES';
  asso_ant_in_rules        CONSTANT VARCHAR2(30) := 'ASSO_ANT_IN_RULES';
  asso_ant_ex_rules        CONSTANT VARCHAR2(30) := 'ASSO_ANT_EX_RULES';
  asso_cons_in_rules       CONSTANT VARCHAR2(30) := 'ASSO_CONS_IN_RULES';
  asso_cons_ex_rules       CONSTANT VARCHAR2(30) := 'ASSO_CONS_EX_RULES';
  asso_aggregates          CONSTANT VARCHAR2(30) := 'ASSO_AGGREGATES';
  asso_abs_error           CONSTANT VARCHAR2(30) := 'ASSO_ABS_ERROR';
  asso_conf_level          CONSTANT VARCHAR2(30) := 'ASSO_CONF_LEVEL';

  feat_num_features        CONSTANT VARCHAR2(30) := 'FEAT_NUM_FEATURES';
  clus_num_clusters        CONSTANT VARCHAR2(30) := 'CLUS_NUM_CLUSTERS';
  
  -- ALGORITHM Setting Name (input to settings_name column in settings table)
  --
  algo_name CONSTANT VARCHAR2(30) := 'ALGO_NAME';
  
  -- ALGORITHM: Setting Values for algo_name
  algo_naive_bayes               CONSTANT VARCHAR2(30) :=
    'ALGO_NAIVE_BAYES';
  algo_adaptive_bayes_network    CONSTANT VARCHAR2(30) :=
    'ALGO_ADAPTIVE_BAYES_NETWORK';
  algo_support_vector_machines   CONSTANT VARCHAR2(30) :=
    'ALGO_SUPPORT_VECTOR_MACHINES';
  algo_nonnegative_matrix_factor CONSTANT VARCHAR2(30) :=
    'ALGO_NONNEGATIVE_MATRIX_FACTOR';
  algo_apriori_association_rules CONSTANT VARCHAR2(30) :=
     'ALGO_APRIORI_ASSOCIATION_RULES';
  algo_kmeans                    CONSTANT VARCHAR2(30) :=
    'ALGO_KMEANS';
  algo_ocluster                  CONSTANT VARCHAR2(30) :=
    'ALGO_O_CLUSTER'; 
  algo_ai_mdl                    CONSTANT VARCHAR2(30) :=
    'ALGO_AI_MDL';
  algo_decision_tree             CONSTANT VARCHAR2(30) :=
    'ALGO_DECISION_TREE';
  algo_random_forest             CONSTANT VARCHAR2(30) :=
      'ALGO_RANDOM_FOREST';
  algo_generalized_linear_model  CONSTANT VARCHAR2(30) :=
    'ALGO_GENERALIZED_LINEAR_MODEL';
  algo_singular_value_decomp     CONSTANT VARCHAR2(30) :=
    'ALGO_SINGULAR_VALUE_DECOMP';  
  algo_expectation_maximization  CONSTANT VARCHAR2(30) :=
    'ALGO_EXPECTATION_MAXIMIZATION';
  algo_explicit_semantic_analys  CONSTANT VARCHAR2(30) :=
    'ALGO_EXPLICIT_SEMANTIC_ANALYS';
  algo_neural_network            CONSTANT VARCHAR2(30) :=
    'ALGO_NEURAL_NETWORK';
  algo_cur_decomposition         CONSTANT VARCHAR2(30) :=
    'ALGO_CUR_DECOMPOSITION';
  algo_exponential_smoothing     CONSTANT VARCHAR2(30) :=
     'ALGO_EXPONENTIAL_SMOOTHING';
  
  -- ALGORITHM SETTINGS AND VALUES
  --
  -- ABN: Setting Names
  abns_model_type          CONSTANT VARCHAR2(30) := 'ABNS_MODEL_TYPE';
  abns_max_build_minutes   CONSTANT VARCHAR2(30) := 'ABNS_MAX_BUILD_MINUTES';
  abns_max_predictors      CONSTANT VARCHAR2(30) := 'ABNS_MAX_PREDICTORS';
  abns_max_nb_predictors   CONSTANT VARCHAR2(30) := 'ABNS_MAX_NB_PREDICTORS';

  -- ABN: Setting Values for abns_model_type
  abns_multi_feature       CONSTANT VARCHAR2(30) := 'ABNS_MULTI_FEATURE';
  abns_single_feature      CONSTANT VARCHAR2(30) := 'ABNS_SINGLE_FEATURE';
  abns_naive_bayes         CONSTANT VARCHAR2(30) := 'ABNS_NAIVE_BAYES';
  
  -- NB: Setting Names
  nabs_pairwise_threshold  CONSTANT VARCHAR2(30) := 'NABS_PAIRWISE_THRESHOLD';
  nabs_singleton_threshold CONSTANT VARCHAR2(30) := 'NABS_SINGLETON_THRESHOLD';
  
  -- SVM: Setting Names
  -- NOTE: svms_epsilon applies only for SVM Regression
  --       svms_complexity_factor applies to both 
  --       svms_std_dev applies only for Gaussian Kernels
  --       kernel_cache_size to Gaussian kernels only
  svms_conv_tolerance      CONSTANT VARCHAR2(30) := 'SVMS_CONV_TOLERANCE';
  svms_std_dev             CONSTANT VARCHAR2(30) := 'SVMS_STD_DEV';
  svms_complexity_factor   CONSTANT VARCHAR2(30) := 'SVMS_COMPLEXITY_FACTOR';
  svms_kernel_cache_size   CONSTANT VARCHAR2(30) := 'SVMS_KERNEL_CACHE_SIZE';
  svms_epsilon             CONSTANT VARCHAR2(30) := 'SVMS_EPSILON';
  svms_kernel_function     CONSTANT VARCHAR2(30) := 'SVMS_KERNEL_FUNCTION';
  svms_active_learning     CONSTANT VARCHAR2(30) := 'SVMS_ACTIVE_LEARNING';
  svms_outlier_rate        CONSTANT VARCHAR2(30) := 'SVMS_OUTLIER_RATE';
  svms_num_iterations      CONSTANT VARCHAR2(30) := 'SVMS_NUM_ITERATIONS';
  svms_num_pivots          CONSTANT VARCHAR2(30) := 'SVMS_NUM_PIVOTS';
  svms_batch_rows          CONSTANT VARCHAR2(30) := 'SVMS_BATCH_ROWS';
  svms_regularizer         CONSTANT VARCHAR2(30) := 'SVMS_REGULARIZER';
  svms_solver              CONSTANT VARCHAR2(30) := 'SVMS_SOLVER';
  
  -- SVM: Setting Values for svms_kernel_function
  svms_linear              CONSTANT VARCHAR2(30) := 'SVMS_LINEAR';
  svms_gaussian            CONSTANT VARCHAR2(30) := 'SVMS_GAUSSIAN';
  
  -- SVM: Setting Values for svms_active_learning
  svms_al_enable           CONSTANT VARCHAR2(30) := 'SVMS_AL_ENABLE';
  svms_al_disable          CONSTANT VARCHAR2(30) := 'SVMS_AL_DISABLE';
  
  -- SVM: Setting Values for svms_regularizer
  svms_regularizer_l1      CONSTANT VARCHAR2(30) := 'SVMS_REGULARIZER_L1';
  svms_regularizer_l2      CONSTANT VARCHAR2(30) := 'SVMS_REGULARIZER_L2';
  
  -- SVM: Setting Values for svms_solver
  svms_solver_sgd      CONSTANT VARCHAR2(30) := 'SVMS_SOLVER_SGD';
  svms_solver_ipm      CONSTANT VARCHAR2(30) := 'SVMS_SOLVER_IPM';
  
  -- KMNS: Setting Names
  kmns_distance            CONSTANT VARCHAR2(30) := 'KMNS_DISTANCE';
  kmns_iterations          CONSTANT VARCHAR2(30) := 'KMNS_ITERATIONS';
  kmns_conv_tolerance      CONSTANT VARCHAR2(30) := 'KMNS_CONV_TOLERANCE';
  kmns_split_criterion     CONSTANT VARCHAR2(30) := 'KMNS_SPLIT_CRITERION';
  kmns_min_pct_attr_support CONSTANT VARCHAR2(30):= 'KMNS_MIN_PCT_ATTR_SUPPORT'; 
  kmns_block_growth        CONSTANT VARCHAR2(30) := 'KMNS_BLOCK_GROWTH';
  kmns_num_bins            CONSTANT VARCHAR2(30) := 'KMNS_NUM_BINS';
  kmns_details             CONSTANT VARCHAR2(30) := 'KMNS_DETAILS';
  kmns_random_seed         CONSTANT VARCHAR2(30) := 'KMNS_RANDOM_SEED';
  
  -- KMNS: Setting Values for kmns_distance
  kmns_euclidean           CONSTANT VARCHAR2(30) := 'KMNS_EUCLIDEAN';
  kmns_cosine              CONSTANT VARCHAR2(30) := 'KMNS_COSINE';
  kmns_fast_cosine         CONSTANT VARCHAR2(30) := 'KMNS_FAST_COSINE';
  
  -- KMNS: Setting Values for kmns_split_criterion
  kmns_size                CONSTANT VARCHAR2(30) := 'KMNS_SIZE';   
  kmns_variance            CONSTANT VARCHAR2(30) := 'KMNS_VARIANCE';
  
  -- KMNS: Setting Values for kmns_details
  kmns_details_none        CONSTANT VARCHAR2(30) := 'KMNS_DETAILS_NONE';
  kmns_details_hierarchy   CONSTANT VARCHAR2(30) := 'KMNS_DETAILS_HIERARCHY';
  kmns_details_all         CONSTANT VARCHAR2(30) := 'KMNS_DETAILS_ALL';
  
  -- NMF: Setting Names
  nmfs_num_iterations      CONSTANT VARCHAR2(30) := 'NMFS_NUM_ITERATIONS';
  nmfs_conv_tolerance      CONSTANT VARCHAR2(30) := 'NMFS_CONV_TOLERANCE';
  nmfs_random_seed         CONSTANT VARCHAR2(30) := 'NMFS_RANDOM_SEED';     
  nmfs_nonnegative_scoring CONSTANT VARCHAR2(30) := 
                                          'NMFS_NONNEGATIVE_SCORING';
  -- Setting values for NMFS_NONNEGATIVE_SCORING
  nmfs_nonneg_scoring_enable CONSTANT VARCHAR2(30) := 
                                          'NMFS_NONNEG_SCORING_ENABLE';
  nmfs_nonneg_scoring_disable CONSTANT VARCHAR2(30) := 
                                          'NMFS_NONNEG_SCORING_DISABLE';
  
  -- OCLT: Setting Names for O-Cluster
  oclt_sensitivity         CONSTANT VARCHAR2(30) := 'OCLT_SENSITIVITY';
  oclt_max_buffer          CONSTANT VARCHAR2(30) := 'OCLT_MAX_BUFFER';

  -- TREE: Setting Names
  tree_impurity_metric     CONSTANT VARCHAR2(30) := 'TREE_IMPURITY_METRIC';
  tree_term_max_depth      CONSTANT VARCHAR2(30) := 'TREE_TERM_MAX_DEPTH';
  tree_term_minrec_split   CONSTANT VARCHAR2(30) := 'TREE_TERM_MINREC_SPLIT';
  tree_term_minpct_split   CONSTANT VARCHAR2(30) := 'TREE_TERM_MINPCT_SPLIT';
  tree_term_minrec_node    CONSTANT VARCHAR2(30) := 'TREE_TERM_MINREC_NODE';
  tree_term_minpct_node    CONSTANT VARCHAR2(30) := 'TREE_TERM_MINPCT_NODE';

  -- TREE: Setting Values for tree_impurity_metric
  tree_impurity_gini       CONSTANT VARCHAR2(30) := 'TREE_IMPURITY_GINI';
  tree_impurity_entropy    CONSTANT VARCHAR2(30) := 'TREE_IMPURITY_ENTROPY';

  -- RANDOM FOREST: Setting Names
  rfor_mtry              CONSTANT VARCHAR2(30) := 'RFOR_MTRY';
  rfor_num_trees         CONSTANT VARCHAR2(30) := 'RFOR_NUM_TREES';
  rfor_sampling_ratio    CONSTANT VARCHAR2(30) := 'RFOR_SAMPLING_RATIO';

  -- GLM: Setting Names
  glms_ridge_regression    CONSTANT VARCHAR2(30) := 'GLMS_RIDGE_REGRESSION';
  glms_row_diagnostics     CONSTANT VARCHAR2(30) := 'GLMS_ROW_DIAGNOSTICS';
  glms_diagnostics_table_name    CONSTANT VARCHAR2(30) :=
    'GLMS_DIAGNOSTICS_TABLE_NAME';
  glms_reference_class_name      CONSTANT VARCHAR2(30) :=
    'GLMS_REFERENCE_CLASS_NAME';
  glms_ridge_value     CONSTANT VARCHAR2(30) := 'GLMS_RIDGE_VALUE';
  glms_conf_level     CONSTANT VARCHAR2(30) := 'GLMS_CONF_LEVEL';
  glms_vif_for_ridge     CONSTANT VARCHAR2(30) := 'GLMS_VIF_FOR_RIDGE';
  glms_solver            CONSTANT VARCHAR2(30) := 'GLMS_SOLVER';
  glms_sparse_solver     CONSTANT VARCHAR2(30) := 'GLMS_SPARSE_SOLVER';
    
  -- GLM: Setting Values for glms_ridge_regression
  glms_ridge_reg_enable    CONSTANT VARCHAR2(30) := 'GLMS_RIDGE_REG_ENABLE';
  glms_ridge_reg_disable   CONSTANT VARCHAR2(30) := 'GLMS_RIDGE_REG_DISABLE';
  
  -- GLM: Setting Values for glms_row_diagnostics
  glms_row_diag_enable    CONSTANT VARCHAR2(30) := 'GLMS_ROW_DIAG_ENABLE';
  glms_row_diag_disable    CONSTANT VARCHAR2(30) := 'GLMS_ROW_DIAG_DISABLE';
  
  -- GLM: Setting Values for glms_vif_for_ridge
  glms_vif_ridge_enable    CONSTANT VARCHAR2(30) := 'GLMS_VIF_RIDGE_ENABLE';
  glms_vif_ridge_disable   CONSTANT VARCHAR2(30) := 'GLMS_VIF_RIDGE_DISABLE';
  
  -- GLM: Setting Values for glms_ftr_selection
  glms_ftr_selection         CONSTANT VARCHAR2(30) := 'GLMS_FTR_SELECTION';
  glms_ftr_selection_enable  CONSTANT VARCHAR2(30) := 
    'GLMS_FTR_SELECTION_ENABLE';
  glms_ftr_selection_disable  CONSTANT VARCHAR2(30) := 
    'GLMS_FTR_SELECTION_DISABLE';
  
  -- GLM: Setting Values for glms_ftr_sel_crit
  glms_ftr_sel_crit CONSTANT VARCHAR2(30) := 'GLMS_FTR_SEL_CRIT';
  glms_ftr_sel_aic  CONSTANT VARCHAR2(30) := 'GLMS_FTR_SEL_AIC';
  glms_ftr_sel_sbic  CONSTANT VARCHAR2(30) := 'GLMS_FTR_SEL_SBIC';
  glms_ftr_sel_ric  CONSTANT VARCHAR2(30) := 'GLMS_FTR_SEL_RIC';
  glms_ftr_sel_alpha_inv  CONSTANT VARCHAR2(30) := 'GLMS_FTR_SEL_ALPHA_INV';
  
  -- GLM: Setting Values for glms_feature_generation
  glms_ftr_generation CONSTANT VARCHAR2(30) := 'GLMS_FTR_GENERATION';
  glms_ftr_generation_enable  CONSTANT VARCHAR2(30) := 
    'GLMS_FTR_GENERATION_ENABLE';
  glms_ftr_generation_disable  CONSTANT VARCHAR2(30) := 
    'GLMS_FTR_GENERATION_DISABLE';  
  
  -- GLM: Setting Values for glms_feature_gen
  glms_ftr_gen_method CONSTANT VARCHAR2(30) := 'GLMS_FTR_GEN_METHOD';
  glms_ftr_gen_quadratic CONSTANT VARCHAR2(30) := 'GLMS_FTR_GEN_QUADRATIC';
  glms_ftr_gen_cubic CONSTANT VARCHAR2(30) := 'GLMS_FTR_GEN_CUBIC';
  
  -- GLM: feature selection categorical value handling
  glms_select_block CONSTANT VARCHAR2(30) := 'GLMS_SELECT_BLOCK';
  glms_select_block_disable CONSTANT VARCHAR2(30) := 'GLMS_SELECT_BLOCK_DISABLE';
  glms_select_block_enable CONSTANT VARCHAR2(30) := 'GLMS_SELECT_BLOCK_ENABLE';
  
  -- GLM: feature selection - max features selected
  glms_max_features CONSTANT VARCHAR2(30) := 'GLMS_MAX_FEATURES';
  
  -- GLM: feature identification - whether row sampling is used in the
  --      selection of feature
  glms_ftr_identification CONSTANT VARCHAR2(30) := 'GLMS_FTR_IDENTIFICATION';
  glms_ftr_ident_quick  CONSTANT VARCHAR2(30) := 
    'GLMS_FTR_IDENT_QUICK';
  glms_ftr_ident_complete  CONSTANT VARCHAR2(30) := 
    'GLMS_FTR_IDENT_COMPLETE';
  
  -- GLM: model pruning - whether the final model features will be
  --      pruned using t-statistics
  glms_prune_model CONSTANT VARCHAR2(30) := 'GLMS_PRUNE_MODEL';
  glms_prune_model_enable CONSTANT VARCHAR2(30) := 'GLMS_PRUNE_MODEL_ENABLE';
  glms_prune_model_disable CONSTANT VARCHAR2(30) := 'GLMS_PRUNE_MODEL_DISABLE';
  
  -- GLM: feature acceptance - whether partitioning the data into feature 
  --      ordering and feature selection sets will be used (strict) or
  --      not (relaxed
  glms_ftr_acceptance CONSTANT VARCHAR2(30) := 'GLMS_FTR_ACCEPTANCE';  
  glms_ftr_acceptance_strict CONSTANT VARCHAR2(30) := 
    'GLMS_FTR_ACCEPTANCE_STRICT';
  glms_ftr_acceptance_relaxed CONSTANT VARCHAR2(30) := 
    'GLMS_FTR_ACCEPTANCE_RELAXED';
  
  -- GLM: convergence tolerance
  glms_conv_tolerance CONSTANT VARCHAR2(30) := 'GLMS_CONV_TOLERANCE';
  -- GLM: number of iterations
  glms_num_iterations CONSTANT VARCHAR2(30) := 'GLMS_NUM_ITERATIONS';
  -- GLM: number of rows in a batch
  glms_batch_rows     CONSTANT VARCHAR2(30) := 'GLMS_BATCH_ROWS';
  
  -- GLM: Setting Values for glms_solver
  glms_solver_sgd    CONSTANT VARCHAR2(30) := 'GLMS_SOLVER_SGD';
  glms_solver_chol   CONSTANT VARCHAR2(30) := 'GLMS_SOLVER_CHOL';
  glms_solver_qr     CONSTANT VARCHAR2(30) := 'GLMS_SOLVER_QR';
  glms_solver_lbfgs_admm  CONSTANT VARCHAR2(30) := 'GLMS_SOLVER_LBFGS_ADMM';
  
  -- GLM: Setting Values for glms_sparse_solver
  glms_sparse_solver_enable CONSTANT VARCHAR2(30) := 'GLMS_SPARSE_SOLVER_ENABLE';
  glms_sparse_solver_disable CONSTANT VARCHAR2(30) := 'GLMS_SPARSE_SOLVER_DISABLE';
  
  -- SVD
  -- max number of features allowed
  svds_max_num_features    CONSTANT NUMBER       := 2500;
  
  svds_scoring_mode        CONSTANT VARCHAR2(30) := 'SVDS_SCORING_MODE';
  -- SVD: Setting values for svds_scoring_mode
  svds_scoring_svd         CONSTANT VARCHAR2(30) := 'SVDS_SCORING_SVD';
  svds_scoring_pca         CONSTANT VARCHAR2(30) := 'SVDS_SCORING_PCA';
  
  svds_u_matrix_output     CONSTANT VARCHAR2(30) := 'SVDS_U_MATRIX_OUTPUT';
  -- SVD: Setting values for svds_u_matrix_output
  svds_u_matrix_enable     CONSTANT VARCHAR2(30) := 'SVDS_U_MATRIX_ENABLE';
  svds_u_matrix_disable    CONSTANT VARCHAR2(30) := 'SVDS_U_MATRIX_DISABLE';
  
  -- SVD: tolerance
  svds_tolerance           CONSTANT VARCHAR2(30) := 'SVDS_TOLERANCE';
  
  -- SVD: Random seed
  svds_random_seed         CONSTANT VARCHAR2(30) := 'SVDS_RANDOM_SEED'; 
  
  -- SVD: Oversampling
  svds_over_sampling       CONSTANT VARCHAR2(30) := 'SVDS_OVER_SAMPLING'; 
  
  -- SVD: Power iterations
  svds_power_iterations    CONSTANT VARCHAR2(30) := 'SVDS_POWER_ITERATIONS'; 
  
  -- SVD: Solver
  svds_solver              CONSTANT VARCHAR2(30) := 'SVDS_SOLVER'; 
  svds_solver_data_driven  CONSTANT VARCHAR2(30) := 'SVDS_SOLVER_DATA_DRIVEN';
  svds_solver_tssvd        CONSTANT VARCHAR2(30) := 'SVDS_SOLVER_TSSVD'; 
  svds_solver_ssvd         CONSTANT VARCHAR2(30) := 'SVDS_SOLVER_SSVD'; 
  svds_solver_tseigen      CONSTANT VARCHAR2(30) := 'SVDS_SOLVER_TSEIGEN'; 
  svds_solver_steigen      CONSTANT VARCHAR2(30) := 'SVDS_SOLVER_STEIGEN'; 

  -- EM
  -- number of components
  emcs_num_components        CONSTANT VARCHAR2(30) := 'EMCS_NUM_COMPONENTS';
  
  -- high-level component clustering
  emcs_cluster_components    CONSTANT VARCHAR2(30) := 
                                                  'EMCS_CLUSTER_COMPONENTS';
  -- values for emcs_cluster_components
  emcs_cluster_comp_enable   CONSTANT VARCHAR2(30) :=   
                                                  'EMCS_CLUSTER_COMP_ENABLE';
  emcs_cluster_comp_disable  CONSTANT VARCHAR2(30) :=
                                                  'EMCS_CLUSTER_COMP_DISABLE';
  
  -- high-level cluster threshold
  emcs_cluster_thresh        CONSTANT VARCHAR2(30) := 'EMCS_CLUSTER_THRESH';
  
  -- max number of 2D attributes
  emcs_max_num_attr_2d       CONSTANT VARCHAR2(30) := 'EMCS_MAX_NUM_ATTR_2D';
  
  -- number of projections
  emcs_num_projections       CONSTANT VARCHAR2(30) := 'EMCS_NUM_PROJECTIONS';
  
  -- number of quantile bins
  emcs_num_quantile_bins     CONSTANT VARCHAR2(30) := 'EMCS_NUM_QUANTILE_BINS';
  
  -- number of topN bins
  emcs_num_topn_bins         CONSTANT VARCHAR2(30) := 'EMCS_NUM_TOPN_BINS';
  
  -- number of equi-width bins
  emcs_num_equiwidth_bins    CONSTANT VARCHAR2(30) := 
                                                  'EMCS_NUM_EQUIWIDTH_BINS';
  
  -- minimum percentage attribute support
  emcs_min_pct_attr_support  CONSTANT VARCHAR2(30) := 
                                                  'EMCS_MIN_PCT_ATTR_SUPPORT';
  -- full covariance (next release)
--  emcs_full_covariance       CONSTANT VARCHAR2(30) := 'EMCS_FULL_COVARIANCE';
  -- values for emcs_full_covariance
--  emcs_full_cov_enable       CONSTANT VARCHAR2(30) := 'EMCS_FULL_COV_ENABLE';
--  emcs_full_cov_disable      CONSTANT VARCHAR2(30) := 'EMCS_FULL_COV_DISABLE';
  
  -- cluster statistics
  emcs_cluster_statistics       CONSTANT VARCHAR2(30) := 'EMCS_CLUSTER_STATISTICS';
  -- values for emcs_cluster_statistics
  emcs_clus_stats_enable       CONSTANT VARCHAR2(30) := 'EMCS_CLUS_STATS_ENABLE';
  emcs_clus_stats_disable      CONSTANT VARCHAR2(30) := 'EMCS_CLUS_STATS_DISABLE';

  -- distribution for modeling numerical attributes
  emcs_num_distribution      CONSTANT VARCHAR2(30) := 'EMCS_NUM_DISTRIBUTION';
  -- values for emcs_num_distribution
  emcs_num_distr_bernoulli   CONSTANT VARCHAR2(30) := 
                                                   'EMCS_NUM_DISTR_BERNOULLI';
  emcs_num_distr_gaussian    CONSTANT VARCHAR2(30) := 
                                                   'EMCS_NUM_DISTR_GAUSSIAN';
  emcs_num_distr_system      CONSTANT VARCHAR2(30) := 'EMCS_NUM_DISTR_SYSTEM';
  
  -- number of iterations
  emcs_num_iterations        CONSTANT VARCHAR2(30) := 'EMCS_NUM_ITERATIONS';
  
  -- required log likelihood improvement
  emcs_loglike_improvement   CONSTANT VARCHAR2(30) := 
                                                   'EMCS_LOGLIKE_IMPROVEMENT';
  
  -- linkage function
  emcs_linkage_function       CONSTANT VARCHAR2(30) := 'EMCS_LINKAGE_FUNCTION';
  -- values for linkage function
  emcs_linkage_single        CONSTANT VARCHAR2(30) := 'EMCS_LINKAGE_SINGLE';
  emcs_linkage_average       CONSTANT VARCHAR2(30) := 'EMCS_LINKAGE_AVERAGE';
  emcs_linkage_complete      CONSTANT VARCHAR2(30) := 'EMCS_LINKAGE_COMPLETE';
  
  -- attribute filtering
  emcs_attribute_filter      CONSTANT VARCHAR2(30) := 'EMCS_ATTRIBUTE_FILTER';
  -- values for attribute filtering
  emcs_attr_filter_enable    CONSTANT VARCHAR2(30) := 
                                                  'EMCS_ATTR_FILTER_ENABLE';
  emcs_attr_filter_disable   CONSTANT VARCHAR2(30) := 
                                                  'EMCS_ATTR_FILTER_DISABLE';
  -- convergence criterion
  emcs_convergence_criterion CONSTANT VARCHAR2(30) := 
                                                  'EMCS_CONVERGENCE_CRITERION';
  -- values for convergence criterion
  emcs_conv_crit_heldaside   CONSTANT VARCHAR2(30) := 
                                                  'EMCS_CONV_CRIT_HELDASIDE';
  emcs_conv_crit_bic         CONSTANT VARCHAR2(30) := 
                                                  'EMCS_CONV_CRIT_BIC';  
  -- random seed
  emcs_random_seed           CONSTANT VARCHAR2(30) := 'EMCS_RANDOM_SEED';
  
  -- model search
  emcs_model_search          CONSTANT VARCHAR2(30) := 'EMCS_MODEL_SEARCH';
  -- values for model search
  emcs_model_search_enable   CONSTANT VARCHAR2(30) := 
                                                  'EMCS_MODEL_SEARCH_ENABLE';
  emcs_model_search_disable  CONSTANT VARCHAR2(30) := 
                                                  'EMCS_MODEL_SEARCH_DISABLE';
  
  -- remove components
  emcs_remove_components     CONSTANT VARCHAR2(30) := 'EMCS_REMOVE_COMPONENTS';
  -- values for remove components
  emcs_remove_comps_enable   CONSTANT VARCHAR2(30) := 
                                                  'EMCS_REMOVE_COMPS_ENABLE';
  emcs_remove_comps_disable  CONSTANT VARCHAR2(30) := 
                                                  'EMCS_REMOVE_COMPS_DISABLE';
  
  -- ESA
  esas_value_threshold       CONSTANT VARCHAR2(30) := 'ESAS_VALUE_THRESHOLD';
  esas_min_items             CONSTANT VARCHAR2(30) := 'ESAS_MIN_ITEMS';
  esas_topn_features         CONSTANT VARCHAR2(30) := 'ESAS_TOPN_FEATURES';
  
  -- ADMM
  admm_iterations            CONSTANT VARCHAR2(30) := 'ADMM_ITERATIONS';
  admm_consensus             CONSTANT VARCHAR2(30) := 'ADMM_CONSENSUS';
  admm_tolerance             CONSTANT VARCHAR2(30) := 'ADMM_TOLERANCE';
  
  -- LBFGS
  lbfgs_history_depth     CONSTANT VARCHAR2(30) := 'LBFGS_HISTORY_DEPTH';
  lbfgs_scale_hessian     CONSTANT VARCHAR2(30) := 'LBFGS_SCALE_HESSIAN';
  lbfgs_scale_hessian_enable  CONSTANT VARCHAR2(30) := 
                                                 'LBFGS_SCALE_HESSIAN_ENABLE';
  lbfgs_scale_hessian_disable CONSTANT VARCHAR2(30) := 
                                                 'LBFGS_SCALE_HESSIAN_DISABLE';
  lbfgs_gradient_tolerance    CONSTANT VARCHAR2(30) := 
                                                 'LBFGS_GRADIENT_TOLERANCE';

  -- RGLU:  Setting Values
  ralg_build_function   CONSTANT VARCHAR2(30) := 'RALG_BUILD_FUNCTION';
  ralg_build_parameter  CONSTANT VARCHAR2(30) := 'RALG_BUILD_PARAMETER';
  ralg_score_function   CONSTANT VARCHAR2(30) := 'RALG_SCORE_FUNCTION';
  ralg_details_function CONSTANT VARCHAR2(30) := 'RALG_DETAILS_FUNCTION';
  ralg_details_format   CONSTANT VARCHAR2(30) := 'RALG_DETAILS_FORMAT';
  ralg_weight_function  CONSTANT VARCHAR2(30) := 'RALG_WEIGHT_FUNCTION';
  ralg_featurematrix_function CONSTANT VARCHAR2(30) 
                                       := 'RALG_FEATUREMATRIX_FUNCTION';
  ralg_clustercenter_function CONSTANT VARCHAR2(30) 
                                       := 'RALG_CLUSTERCENTER_FUNCTION';
  r_formula CONSTANT VARCHAR2(30) 
                                       := 'R_FORMULA';

  -- NNET
  nnet_hidden_layers          CONSTANT VARCHAR2(30) := 'NNET_HIDDEN_LAYERS';
  nnet_nodes_per_layer        CONSTANT VARCHAR2(30) := 'NNET_NODES_PER_LAYER';
  nnet_iterations             CONSTANT VARCHAR2(30) := 'NNET_ITERATIONS';
  nnet_tolerance              CONSTANT VARCHAR2(30) := 'NNET_TOLERANCE';
  nnet_activations            CONSTANT VARCHAR2(30) := 'NNET_ACTIVATIONS';
  nnet_activations_log_sig  CONSTANT VARCHAR2(30) := 
                                                 'NNET_ACTIVATIONS_LOG_SIG';
  nnet_activations_linear  CONSTANT VARCHAR2(30) := 'NNET_ACTIVATIONS_LINEAR';
  nnet_activations_tanh    CONSTANT VARCHAR2(30) := 'NNET_ACTIVATIONS_TANH';
  nnet_activations_arctan  CONSTANT VARCHAR2(30) := 'NNET_ACTIVATIONS_ARCTAN';
  nnet_activations_bipolar_sig CONSTANT VARCHAR2(30) := 
                                                'NNET_ACTIVATIONS_BIPOLAR_SIG';
  nnet_regularizer         CONSTANT VARCHAR2(30) := 'NNET_REGULARIZER';
  nnet_regularizer_heldaside  CONSTANT VARCHAR2(30) := 
                                                  'NNET_REGULARIZER_HELDASIDE';
  nnet_regularizer_l2      CONSTANT VARCHAR2(30) := 'NNET_REGULARIZER_L2';
  nnet_regularizer_none    CONSTANT VARCHAR2(30) := 'NNET_REGULARIZER_NONE';
  nnet_heldaside_ratio     CONSTANT VARCHAR2(30) := 'NNET_HELDASIDE_RATIO';
  nnet_heldaside_max_fail  CONSTANT VARCHAR2(30) := 'NNET_HELDASIDE_MAX_FAIL';
  nnet_reg_lambda          CONSTANT VARCHAR2(30) := 'NNET_REG_LAMBDA';
  nnet_weight_lower_bound   CONSTANT VARCHAR2(30) := 'NNET_WEIGHT_LOWER_BOUND';
  nnet_weight_upper_bound   CONSTANT VARCHAR2(30) := 'NNET_WEIGHT_UPPER_BOUND';

  -- CUR
  -- approximated number of selected attributes
  curs_approx_attr_num CONSTANT VARCHAR2(30) := 'CURS_APPROX_ATTR_NUM';

  -- row importance
  curs_row_importance CONSTANT VARCHAR2(30) := 'CURS_ROW_IMPORTANCE';
  
  -- row importance values
  curs_row_imp_enable CONSTANT VARCHAR2(30) := 'CURS_ROW_IMP_ENABLE';
  curs_row_imp_disable CONSTANT VARCHAR2(30) := 'CURS_ROW_IMP_DISABLE';

  -- approximated number of selected rows
  curs_approx_row_num CONSTANT VARCHAR2(30) := 'CURS_APPROX_ROW_NUM';

  -- SVD rank
  curs_svd_rank CONSTANT VARCHAR2(30) := 'CURS_SVD_RANK';
  
  -- EXSM
  exsm_model            CONSTANT VARCHAR2(30) := 'EXSM_MODEL';
  exsm_simple           CONSTANT VARCHAR2(30) := 'EXSM_SIMPLE';
  exsm_simple_mult      CONSTANT VARCHAR2(30) := 'EXSM_SIMPLE_MULT_ERR';
  exsm_holt             CONSTANT VARCHAR2(30) := 'EXSM_HOLT';
  exsm_holt_dmp         CONSTANT VARCHAR2(30) := 'EXSM_HOLT_DAMPED';
  exsm_mul_trnd         CONSTANT VARCHAR2(30) := 'EXSM_MULT_TREND';
  exsm_multrd_dmp       CONSTANT VARCHAR2(30) := 'EXSM_MULT_TREND_DAMPED';
  exsm_seas_add         CONSTANT VARCHAR2(30) := 'EXSM_SEASON_ADD';
  exsm_seas_mul         CONSTANT VARCHAR2(30) := 'EXSM_SEASON_MUL';
  exsm_hw               CONSTANT VARCHAR2(30) := 'EXSM_WINTERS';
  exsm_hw_dmp           CONSTANT VARCHAR2(30) := 'EXSM_WINTERS_DAMPED';
  exsm_hw_addsea        CONSTANT VARCHAR2(30) := 'EXSM_ADDWINTERS';
  exsm_dhw_addsea       CONSTANT VARCHAR2(30) := 'EXSM_ADDWINTERS_DAMPED';
  exsm_hwmt             CONSTANT VARCHAR2(30) := 'EXSM_WINTERS_MUL_TREND';
  exsm_hwmt_dmp         CONSTANT VARCHAR2(30) := 'EXSM_WINTERS_MUL_TREND_DMP';
  exsm_seasonality      CONSTANT VARCHAR2(30) := 'EXSM_SEASONALITY';
  exsm_interval         CONSTANT VARCHAR2(30) := 'EXSM_INTERVAL';
  exsm_interval_year    CONSTANT VARCHAR2(30) := 'EXSM_INTERVAL_YEAR';
  exsm_interval_qtr     CONSTANT VARCHAR2(30) := 'EXSM_INTERVAL_QTR';
  exsm_interval_month   CONSTANT VARCHAR2(30) := 'EXSM_INTERVAL_MONTH';
  exsm_interval_week    CONSTANT VARCHAR2(30) := 'EXSM_INTERVAL_WEEK';
  exsm_interval_day     CONSTANT VARCHAR2(30) := 'EXSM_INTERVAL_DAY';
  exsm_interval_hour    CONSTANT VARCHAR2(30) := 'EXSM_INTERVAL_HOUR';
  exsm_interval_min     CONSTANT VARCHAR2(30) := 'EXSM_INTERVAL_MINUTE';
  exsm_interval_sec     CONSTANT VARCHAR2(30) := 'EXSM_INTERVAL_SECOND';
  exsm_accumulate       CONSTANT VARCHAR2(30) := 'EXSM_ACCUMULATE';
  exsm_accu_total       CONSTANT VARCHAR2(30) := 'EXSM_ACCU_TOTAL';
  exsm_accu_std         CONSTANT VARCHAR2(30) := 'EXSM_ACCU_STD';
  exsm_accu_max         CONSTANT VARCHAR2(30) := 'EXSM_ACCU_MAX';
  exsm_accu_min         CONSTANT VARCHAR2(30) := 'EXSM_ACCU_MIN';
  exsm_accu_avg         CONSTANT VARCHAR2(30) := 'EXSM_ACCU_AVG';
  exsm_accu_median      CONSTANT VARCHAR2(30) := 'EXSM_ACCU_MEDIAN';
  exsm_accu_count       CONSTANT VARCHAR2(30) := 'EXSM_ACCU_COUNT';
  exsm_setmissing       CONSTANT VARCHAR2(30) := 'EXSM_SETMISSING';
  exsm_miss_min         CONSTANT VARCHAR2(30) := 'EXSM_MISS_MIN';
  exsm_miss_max         CONSTANT VARCHAR2(30) := 'EXSM_MISS_MAX';
  exsm_miss_avg         CONSTANT VARCHAR2(30) := 'EXSM_MISS_AVG';
  exsm_miss_median      CONSTANT VARCHAR2(30) := 'EXSM_MISS_MEDIAN';
  exsm_miss_last        CONSTANT VARCHAR2(30) := 'EXSM_MISS_LAST';
  exsm_miss_first       CONSTANT VARCHAR2(30) := 'EXSM_MISS_FIRST';
  exsm_miss_prev        CONSTANT VARCHAR2(30) := 'EXSM_MISS_PREV';
  exsm_miss_next        CONSTANT VARCHAR2(30) := 'EXSM_MISS_NEXT';
  exsm_miss_auto        CONSTANT VARCHAR2(30) := 'EXSM_MISS_AUTO';
  exsm_prediction_step  CONSTANT VARCHAR2(30) := 'EXSM_PREDICTION_STEP';
  exsm_opt_criterion    CONSTANT VARCHAR2(30) := 'EXSM_OPTIMIZATION_CRIT';
  exsm_opt_crit_lik     CONSTANT VARCHAR2(30) := 'EXSM_OPT_CRIT_LIK';
  exsm_opt_crit_mse     CONSTANT VARCHAR2(30) := 'EXSM_OPT_CRIT_MSE';
  exsm_opt_crit_amse    CONSTANT VARCHAR2(30) := 'EXSM_OPT_CRIT_AMSE';
  exsm_opt_crit_sig     CONSTANT VARCHAR2(30) := 'EXSM_OPT_CRIT_SIG';
  exsm_opt_crit_mae     CONSTANT VARCHAR2(30) := 'EXSM_OPT_CRIT_MAE';
  exsm_nmse             CONSTANT VARCHAR2(30) := 'EXSM_NMSE';
  exsm_confidence_level CONSTANT VARCHAR2(30) := 'EXSM_CONFIDENCE_LEVEL';

  -----------   Function and Algorithm Settings - End ------------------------

  TYPE SETTING_LIST IS TABLE OF CLOB INDEX BY VARCHAR2(30);

  --------------
  -- LOCAL TYPES
  --
  SUBTYPE TRANSFORM_LIST IS dbms_data_mining_transform.TRANSFORM_LIST;

  ---------------------------
  -- PROCEDURES AND FUNCTIONS
  --
  PROCEDURE apply(model_name          IN VARCHAR2,
                  data_table_name     IN VARCHAR2,
                  case_id_column_name IN VARCHAR2,
                  result_table_name   IN VARCHAR2,
                  data_schema_name    IN VARCHAR2 DEFAULT NULL);
 
  PROCEDURE compute_confusion_matrix(
                  accuracy                    OUT NUMBER,
                  apply_result_table_name     IN  VARCHAR2,
                  target_table_name           IN  VARCHAR2,
                  case_id_column_name         IN  VARCHAR2,
                  target_column_name          IN  VARCHAR2,
                  confusion_matrix_table_name IN  VARCHAR2,
                  score_column_name           IN  VARCHAR2 DEFAULT
                                                             'PREDICTION',
                  score_criterion_column_name IN  VARCHAR2 DEFAULT
                                                             'PROBABILITY',
                  cost_matrix_table_name      IN  VARCHAR2 DEFAULT NULL,
                  apply_result_schema_name    IN  VARCHAR2 DEFAULT NULL,
                  target_schema_name          IN  VARCHAR2 DEFAULT NULL,
                  cost_matrix_schema_name     IN  VARCHAR2 DEFAULT NULL,
                  score_criterion_type        IN  VARCHAR2 DEFAULT NULL);
  
  PROCEDURE compute_confusion_matrix_part(
                  accuracy                    OUT DM_NESTED_NUMERICALS,
                  apply_result_table_name     IN  VARCHAR2,
                  target_table_name           IN  VARCHAR2,
                  case_id_column_name         IN  VARCHAR2,
                  target_column_name          IN  VARCHAR2,
                  confusion_matrix_table_name IN  VARCHAR2,
                  score_column_name           IN  VARCHAR2 DEFAULT
                                                             'PREDICTION',
                  score_criterion_column_name IN  VARCHAR2 DEFAULT
                                                             'PROBABILITY',
                  score_partition_column_name IN  VARCHAR2 DEFAULT
                                                             'PARTITION_NAME',
                  cost_matrix_table_name      IN  VARCHAR2 DEFAULT NULL,
                  apply_result_schema_name    IN  VARCHAR2 DEFAULT NULL,
                  target_schema_name          IN  VARCHAR2 DEFAULT NULL,
                  cost_matrix_schema_name     IN  VARCHAR2 DEFAULT NULL,
                  score_criterion_type        IN  VARCHAR2 DEFAULT NULL);

  PROCEDURE compute_lift(
                  apply_result_table_name     IN VARCHAR2,
                  target_table_name           IN VARCHAR2,
                  case_id_column_name         IN VARCHAR2,
                  target_column_name          IN VARCHAR2,
                  lift_table_name             IN VARCHAR2,
                  positive_target_value       IN VARCHAR2,
                  score_column_name           IN VARCHAR2 DEFAULT
                                                            'PREDICTION',
                  score_criterion_column_name IN VARCHAR2 DEFAULT
                                                            'PROBABILITY',
                  num_quantiles               IN NUMBER   DEFAULT 10,
                  cost_matrix_table_name      IN VARCHAR2 DEFAULT NULL,
                  apply_result_schema_name    IN VARCHAR2 DEFAULT NULL,
                  target_schema_name          IN VARCHAR2 DEFAULT NULL,
                  cost_matrix_schema_name     IN VARCHAR2 DEFAULT NULL,
                  score_criterion_type        IN VARCHAR2 DEFAULT NULL);

  PROCEDURE compute_lift_part(
                  apply_result_table_name     IN VARCHAR2,
                  target_table_name           IN VARCHAR2,
                  case_id_column_name         IN VARCHAR2,
                  target_column_name          IN VARCHAR2,
                  lift_table_name             IN VARCHAR2,
                  positive_target_value       IN VARCHAR2,
                  score_column_name           IN VARCHAR2 DEFAULT 'PREDICTION',
                  score_criterion_column_name IN VARCHAR2 DEFAULT 'PROBABILITY',
                  score_partition_column_name IN VARCHAR2 DEFAULT 'PARTITION_NAME', 
                  num_quantiles               IN NUMBER   DEFAULT 10,
                  cost_matrix_table_name      IN VARCHAR2 DEFAULT NULL,
                  apply_result_schema_name    IN VARCHAR2 DEFAULT NULL,
                  target_schema_name          IN VARCHAR2 DEFAULT NULL,
                  cost_matrix_schema_name     IN VARCHAR2 DEFAULT NULL,
                  score_criterion_type        IN VARCHAR2 DEFAULT NULL);
 
  PROCEDURE compute_roc(
                  roc_area_under_curve        OUT NUMBER,
                  apply_result_table_name     IN  VARCHAR2,
                  target_table_name           IN  VARCHAR2,
                  case_id_column_name         IN  VARCHAR2,
                  target_column_name          IN  VARCHAR2,
                  roc_table_name              IN  VARCHAR2,
                  positive_target_value       IN  VARCHAR2,
                  score_column_name           IN  VARCHAR2 DEFAULT
                                                             'PREDICTION',
                  score_criterion_column_name IN  VARCHAR2 DEFAULT
                                                             'PROBABILITY',
                  apply_result_schema_name    IN  VARCHAR2 DEFAULT NULL,
                  target_schema_name          IN  VARCHAR2 DEFAULT NULL);

  PROCEDURE compute_roc_part(
                  roc_area_under_curve        OUT DM_NESTED_NUMERICALS,
                  apply_result_table_name     IN  VARCHAR2,
                  target_table_name           IN  VARCHAR2,
                  case_id_column_name         IN  VARCHAR2,
                  target_column_name          IN  VARCHAR2,
                  roc_table_name              IN  VARCHAR2,
                  positive_target_value       IN  VARCHAR2,
                  score_column_name           IN  VARCHAR2 DEFAULT 'PREDICTION',
                  score_criterion_column_name IN  VARCHAR2 DEFAULT 'PROBABILITY',
                  score_partition_column_name IN  VARCHAR2 DEFAULT 'PARTITION_NAME',
                  apply_result_schema_name    IN  VARCHAR2 DEFAULT NULL,
                  target_schema_name          IN  VARCHAR2 DEFAULT NULL);

  PROCEDURE register_algorithm (
                     algorithm_name           IN VARCHAR2,
                     algorithm_metadata       IN CLOB,
                     algorithm_description    IN VARCHAR2 DEFAULT NULL);

  PROCEDURE drop_algorithm ( algorithm_name IN VARCHAR2,
                             cascade        IN BOOLEAN DEFAULT FALSE);
  
  PROCEDURE create_model(
                  model_name            IN VARCHAR2,
                  mining_function       IN VARCHAR2,
                  data_table_name       IN VARCHAR2,
                  case_id_column_name   IN VARCHAR2,
                  target_column_name    IN VARCHAR2 DEFAULT NULL,
                  settings_table_name   IN VARCHAR2 DEFAULT NULL,
                  data_schema_name      IN VARCHAR2 DEFAULT NULL,
                  settings_schema_name  IN VARCHAR2 DEFAULT NULL,
                  xform_list            IN TRANSFORM_LIST DEFAULT NULL);

  PROCEDURE create_model2(
                  model_name            IN VARCHAR2,
                  mining_function       IN VARCHAR2,
                  data_query            IN CLOB,
                  set_list              IN SETTING_LIST,
                  case_id_column_name   IN VARCHAR2 DEFAULT NULL,
                  target_column_name    IN VARCHAR2 DEFAULT NULL,
                  xform_list            IN TRANSFORM_LIST DEFAULT NULL);

  PROCEDURE drop_model(model_name IN VARCHAR2,
                       force      IN BOOLEAN DEFAULT FALSE);

  PROCEDURE export_model (filename      IN VARCHAR2,
                          directory     IN VARCHAR2,
                          model_filter  IN VARCHAR2 DEFAULT NULL,
                          filesize      IN VARCHAR2 DEFAULT NULL,
                          operation     IN VARCHAR2 DEFAULT NULL,
                          remote_link   IN VARCHAR2 DEFAULT NULL,
                          jobname       IN VARCHAR2 DEFAULT NULL);

  PROCEDURE export_sermodel (model_data     IN OUT NOCOPY BLOB,
                             model_name     IN VARCHAR2,
                             partition_name IN VARCHAR2 DEFAULT NULL);

  -- XML (PMML) versions of get model details
  FUNCTION get_model_details_xml(model_name IN VARCHAR2,
                                 partition_name IN VARCHAR2 DEFAULT NULL)
  RETURN XMLType;

  -- Specifying topn orders by confidence DESC, support DESC
  --   otherwise by rule_id
  FUNCTION get_association_rules(model_name       IN VARCHAR2,
                                 topn             IN NUMBER DEFAULT NULL,
                                 rule_id          IN INTEGER DEFAULT NULL,
                                 min_confidence   IN NUMBER DEFAULT NULL,
                                 min_support      IN NUMBER DEFAULT NULL,
                                 max_rule_length  IN INTEGER DEFAULT NULL,
                                 min_rule_length  IN INTEGER DEFAULT NULL,
                                 sort_order       IN ORA_MINING_VARCHAR2_NT DEFAULT NULL,
                                 antecedent_items IN DM_ITEMS DEFAULT NULL,
                                 consequent_items IN DM_ITEMS DEFAULT NULL,
                                 min_lift         IN NUMBER DEFAULT NULL,
                                 partition_name   IN VARCHAR2 DEFAULT NULL)
  RETURN DM_Rules PIPELINED;

  -- Specifying topn orders by support DESC otherwise there
  --   is no ordering
  FUNCTION get_frequent_itemsets(model_name IN VARCHAR2,
                                 topn IN NUMBER DEFAULT NULL,
                                 max_itemset_length IN NUMBER DEFAULT NULL,
                                 partition_name     IN VARCHAR2 DEFAULT NULL)
  RETURN DM_ItemSets PIPELINED;
  
  FUNCTION get_model_details_ai(model_name IN VARCHAR2,
                                partition_name IN VARCHAR2 DEFAULT NULL)
  RETURN dm_ranked_attributes pipelined;
  
  FUNCTION get_model_details_glm(model_name IN VARCHAR2,
                                 partition_name IN VARCHAR2 DEFAULT NULL)
  RETURN DM_GLM_Coeff_Set PIPELINED;
  
  FUNCTION get_model_details_svd(model_name IN VARCHAR2,
                                 matrix_type IN VARCHAR2 DEFAULT NULL,
                                 partition_name VARCHAR2 DEFAULT NULL)
   RETURN DM_SVD_MATRIX_Set PIPELINED;

  FUNCTION get_model_details_km(model_name VARCHAR2,
                                cluster_id NUMBER   DEFAULT NULL,
                                attribute  VARCHAR2 DEFAULT NULL,
                                centroid   NUMBER   DEFAULT 1,
                                histogram  NUMBER   DEFAULT 1,
                                rules      NUMBER   DEFAULT 2,
                                attribute_subname  VARCHAR2 DEFAULT NULL,
                                topn_attributes NUMBER DEFAULT NULL,
                                partition_name VARCHAR2 DEFAULT NULL)
  RETURN dm_clusters PIPELINED;
 
  FUNCTION get_model_details_nb(model_name IN VARCHAR2,
                                partition_name IN VARCHAR2 DEFAULT NULL)
  RETURN DM_NB_Details PIPELINED;

  FUNCTION get_model_details_nmf(model_name IN VARCHAR2,
                                 partition_name VARCHAR2 DEFAULT NULL)
   RETURN DM_NMF_Feature_Set PIPELINED;

  FUNCTION get_model_details_oc(model_name VARCHAR2,
                                cluster_id NUMBER   DEFAULT NULL,
                                attribute  VARCHAR2 DEFAULT NULL,
                                centroid   NUMBER   DEFAULT 1,
                                histogram  NUMBER   DEFAULT 1,
                                rules      NUMBER   DEFAULT 2,
                                topn_attributes NUMBER DEFAULT NULL,
                                partition_name VARCHAR2 DEFAULT NULL)
  RETURN dm_clusters PIPELINED;

  FUNCTION get_model_details_svm(model_name   VARCHAR2,
                                 reverse_coef NUMBER DEFAULT 0,
                                 partition_name VARCHAR2 DEFAULT NULL)
  RETURN DM_SVM_Linear_Coeff_Set PIPELINED;
  
  FUNCTION get_model_details_em(model_name VARCHAR2,
                                cluster_id NUMBER   DEFAULT NULL,
                                attribute  VARCHAR2 DEFAULT NULL,
                                centroid   NUMBER   DEFAULT 1,
                                histogram  NUMBER   DEFAULT 1,
                                rules      NUMBER   DEFAULT 2,
                                attribute_subname  VARCHAR2 DEFAULT NULL,
                                topn_attributes NUMBER DEFAULT NULL,
                                partition_name IN VARCHAR2 DEFAULT NULL)
  RETURN dm_clusters PIPELINED;
  
  FUNCTION get_model_details_em_comp(model_name IN VARCHAR2,
                                     partition_name IN VARCHAR2 DEFAULT NULL)
  RETURN DM_EM_COMPONENT_SET PIPELINED;
  
  FUNCTION get_model_details_em_proj(model_name IN VARCHAR2,
                                     partition_name IN VARCHAR2 DEFAULT NULL)
  RETURN DM_EM_PROJECTION_SET PIPELINED;
  
  FUNCTION get_model_details_global(model_name IN VARCHAR2,
                                    partition_name IN VARCHAR2 DEFAULT NULL)
  RETURN DM_model_global_details PIPELINED;
  
  FUNCTION get_model_settings(model_name IN VARCHAR2)
  RETURN DM_Model_Settings PIPELINED;

  FUNCTION get_default_settings
  RETURN DM_Model_Settings PIPELINED;

  FUNCTION get_model_signature(model_name IN VARCHAR2)
  RETURN DM_Model_Signature PIPELINED;
  
  FUNCTION get_model_transformations(model_name IN VARCHAR2,
                                     partition_name IN VARCHAR2 DEFAULT NULL)
  RETURN DM_Transforms PIPELINED;
  
  PROCEDURE get_transform_list(xform_list   OUT NOCOPY TRANSFORM_LIST,
                               model_xforms IN DM_TRANSFORMS);

  PROCEDURE import_model (filename         IN VARCHAR2,
                          directory        IN VARCHAR2,
                          model_filter     IN VARCHAR2 DEFAULT NULL,
                          operation        IN VARCHAR2 DEFAULT NULL,
                          remote_link      IN VARCHAR2 DEFAULT NULL,
                          jobname          IN VARCHAR2 DEFAULT NULL,
                          schema_remap     IN VARCHAR2 DEFAULT NULL,
                          tablespace_remap IN VARCHAR2 DEFAULT NULL);  
 
  PROCEDURE import_model (model_name      IN VARCHAR2,
                          pmmldoc         IN XMLTYPE,
                          strict_check    IN BOOLEAN DEFAULT FALSE); 
  
  PROCEDURE import_sermodel (model_data     IN BLOB,
                             model_name     IN VARCHAR2);

  PROCEDURE rank_apply(apply_result_table_name     IN VARCHAR2,
                       case_id_column_name         IN VARCHAR2,
                       score_column_name           IN VARCHAR2,
                       score_criterion_column_name IN VARCHAR2,
                       ranked_apply_table_name     IN VARCHAR2,
                       top_n                       IN INTEGER  DEFAULT 1,
                       cost_matrix_table_name      IN VARCHAR2 DEFAULT NULL,
                       apply_result_schema_name    IN VARCHAR2 DEFAULT NULL,
                       cost_matrix_schema_name     IN VARCHAR2 DEFAULT NULL);

  PROCEDURE rename_model(model_name     IN VARCHAR2,
                         new_model_name IN VARCHAR2,
                         versioned_model_name IN VARCHAR2 DEFAULT NULL);

  PROCEDURE add_cost_matrix(model_name              IN VARCHAR2,
                            cost_matrix_table_name  IN VARCHAR2,
                            cost_matrix_schema_name IN VARCHAR2 DEFAULT NULL,
                            partition_name          IN VARCHAR2 DEFAULT NULL);

  PROCEDURE remove_cost_matrix(model_name IN VARCHAR2,
                            partition_name          IN VARCHAR2 DEFAULT NULL);

  FUNCTION get_model_cost_matrix(model_name  IN VARCHAR2,
                                 matrix_type IN VARCHAR2 
                                                DEFAULT cost_matrix_type_score,
                            partition_name          IN VARCHAR2 DEFAULT NULL)
  RETURN DM_COST_MATRIX PIPELINED;

  PROCEDURE alter_reverse_expression(
    model_name                     VARCHAR2,
    expression                     CLOB,
    attribute_name                 VARCHAR2 DEFAULT NULL,
    attribute_subname              VARCHAR2 DEFAULT NULL);

  PROCEDURE drop_partition(
    model_name                     VARCHAR2,
    partition_name                 VARCHAR2);

  PROCEDURE add_partition(
    model_name                     VARCHAR2,
    data_query                     CLOB,
    add_options                    VARCHAR2 DEFAULT 'ERROR');

  FUNCTION get_model_r_function(model_name      IN VARCHAR2,
                                r_function_type IN VARCHAR2)
  RETURN VARCHAR2;

  FUNCTION get_model_details_ra(model_name IN VARCHAR2, 
                                par_cur    IN SYS_REFCURSOR, 
                                out_qry    IN VARCHAR2, 
                                view_num   IN NUMBER DEFAULT -1)
  RETURN SYS.AnyDataSet
  PIPELINED USING SYS.dm$rqMod_DetailImpl;

  FUNCTION fetch_alg_schema
  RETURN CLOB;

END dbms_data_mining;
/
CREATE OR REPLACE PUBLIC SYNONYM dbms_data_mining FOR sys.dbms_data_mining
/
GRANT EXECUTE ON dbms_data_mining TO PUBLIC
/
SHOW ERRORS

@?/rdbms/admin/sqlsessend.sql
