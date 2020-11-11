Rem
Rem $Header: rdbms/admin/dbmswlm.sql /main/15 2016/06/11 15:37:51 alui Exp $
Rem
Rem dbmswlm.sql
Rem
Rem Copyright (c) 2006, 2016, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmswlm.sql - DBMS_WLM package specification for QoS Management
Rem
Rem    DESCRIPTION
Rem      Creates the package specification for QoS Management
Rem
Rem    NOTES
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmswlm.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmswlm.sql
Rem SQL_PHASE: DBMSWLM
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    alui        05/27/16 - bug 23491507: revoke execute privilege from DBA
Rem    alui        04/18/16 - fix bug 22812962
Rem    alui        11/12/15 - bug 22049157: selective PDB QoS management
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    alui        07/28/12 - fix bug 13460257. Add procedures to support CDB.
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    alui        05/20/11 - add submit_wlmpcinfo for PC rank, ITT, RTT
Rem    alui        02/28/11 - add package call for getting/setting cpu count
Rem                           for instacne caging (bug 11668542)
Rem    alui        01/27/11 - fix bug 11058812
Rem    alui        08/12/08 - add order attribute parameter to
Rem                           add_wlmclassifiers
Rem    alui        07/10/08 - add check_wlmplan
Rem    alui        06/23/08 - add check_rm_plan
Rem    alui        12/14/07 - Add abort_wlmplan
Rem    sourghos    12/06/06 - add checks for large number of requested
Rem                           classifiers
Rem    sourghos    10/04/06 - add error condition for no WRC for a PC
Rem    sourghos    08/14/06 - fix bug 5454700
Rem    sourghos    06/07/06 - remove package body due to new guidelines 
Rem    sourghos    06/06/06 - Add right error numbers 
Rem    sourghos    04/10/06 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql


CREATE OR REPLACE LIBRARY dbms_wlm_lib trusted is static;
/

CREATE OR REPLACE TYPE WLM_CAPABILITY_OBJECT FORCE as OBJECT
(
  capability   VARCHAR2(30),
  value        VARCHAR2(30)
);   
/

CREATE OR REPLACE TYPE WLM_CAPABILITY_ARRAY as
  VARRAY(50) of WLM_CAPABILITY_OBJECT;
/

CREATE OR REPLACE PACKAGE dbms_wlm as

procedure create_wlmplan (num_classifiers IN number);

procedure add_wlmclassifiers (num_clsfrs  IN number,
                              clsfrs      IN varchar2,
                              order_seq   IN number default null); 

procedure submit_wlmplan;

procedure submit_wlmpcs (num_pcs IN number, pcs IN varchar2); 

procedure delete_wlmplan; 

procedure abort_wlmplan;

procedure check_wlmplan;

function check_rm_plan_l return number;

function check_rm_plan (inst_name IN varchar2) return number;

function check_rm_enable return number;

procedure set_dbmap;

procedure set_dbi_dbmap;

procedure set_rm_plan;

procedure set_pdb_rm_plan_l(con_name IN varchar2, con_id IN number);

procedure set_pdb_rm_plan;

procedure set_dbi_rm_plan;

procedure delete_cg_mappings;

procedure update_cg_mappings(attributes IN dbms_rmin.upcgm_table_type,
                             attribute_values IN dbms_rmin.upcgm_table_type,
                             consumer_groups IN dbms_rmin.upcgm_table_type);

procedure up_cg_maps_l;

procedure up_cg_maps;

procedure get_pdb_info(pdb_count out number);

function get_cdb_setting return number;

procedure set_cdb_setting (optionmask IN number);

procedure get_cpu_count (cpu_physical out number,
                         cpu_count out number);

procedure set_cpu_count (cpu_physical out number,
                         cpu_count out number,
                         cpu_count_value in number);

function get_capabilities (cap_version out number) return WLM_CAPABILITY_ARRAY;

procedure submit_wlmpcinfo (num_pcs IN number, pcinfo IN varchar2); 

function get_po_multiplier return number;

procedure set_po_multiplier (multiplier IN number);

  -------------
  --  CONSTANTS
  --
  --  Constants for use in calling arguments.


  -------------------------
  --  ERRORS AND EXCEPTIONS
  --
  --  When adding errors remember to add a corresponding exception below.


  err_null_num_classifiers            constant number := -44800;
  err_null_wlm_classifiers            constant number := -44801;
  err_no_new_cls_list                 constant number := -44802;
  err_plan_in_transition              constant number := -44803;
  err_plan_not_created                constant number := -44804;
  err_no_classifier                   constant number := -44805;
  err_extra_classifiers               constant number := -44806;
  err_large_pcname                    constant number := -44807;
  err_large_wrcname                   constant number := -44808;
  err_no_expr_for_classifier          constant number := -44809;
  err_no_param_for_expr               constant number := -44810;
  err_large_service_name              constant number := -44811;
  err_large_module_name               constant number := -44812;
  err_large_action_name               constant number := -44813;
  err_large_prog_name                 constant number := -44814;
  err_large_user_name                 constant number := -44815;
  err_zero_pcs                        constant number := -44816;
  err_large_list                      constant number := -44817;
  err_general_failure                 constant number := -44818;
  err_no_enq                          constant number := -44819;
  err_zero_wcs                        constant number := -44820;
  err_lrg_cls                         constant number := -44821;
  err_rm_plan_not_created             constant number := -44822;
  err_rm_plan_not_inuse               constant number := -44823;
  err_rm_is_off                       constant number := -44824;
  err_plan_unmatched                  constant number := -44825;
  err_extra_pcs                       constant number := -44826;
  err_lrg_pcs                         constant number := -44827;
  
  null_num_classifiers         EXCEPTION;
  PRAGMA EXCEPTION_INIT(null_num_classifiers, -44800);
  null_wlm_classifiers         EXCEPTION;
  PRAGMA EXCEPTION_INIT(null_wlm_classifiers, -44801);
  no_new_cls_list              EXCEPTION;
  PRAGMA EXCEPTION_INIT(no_new_cls_list, -44802);
  plan_in_transition           EXCEPTION;
  PRAGMA EXCEPTION_INIT(plan_in_transition, -44803);
  plan_not_created             EXCEPTION;
  PRAGMA EXCEPTION_INIT(plan_not_created, -44804);
  no_classifier                EXCEPTION;
  PRAGMA EXCEPTION_INIT(no_classifier, -44805);
  extra_classifiers            EXCEPTION;
  PRAGMA EXCEPTION_INIT(extra_classifiers, -44806);
  large_pcname                 EXCEPTION;
  PRAGMA EXCEPTION_INIT(large_pcname, -44807);
  large_wrcname                EXCEPTION;
  PRAGMA EXCEPTION_INIT(large_wrcname, -44808);
  no_expr_for_classifier       EXCEPTION;
  PRAGMA EXCEPTION_INIT(no_expr_for_classifier, -44809);
  no_param_for_expr            EXCEPTION;
  PRAGMA EXCEPTION_INIT(no_param_for_expr, -44810);
  large_service_name           EXCEPTION;
  PRAGMA EXCEPTION_INIT(large_service_name, -44811);
  large_module_name            EXCEPTION;
  PRAGMA EXCEPTION_INIT(large_module_name, -44812);
  large_action_name            EXCEPTION;
  PRAGMA EXCEPTION_INIT(large_action_name, -44813);
  large_prog_name              EXCEPTION;
  PRAGMA EXCEPTION_INIT(large_prog_name, -44814);
  large_user_name              EXCEPTION;
  PRAGMA EXCEPTION_INIT(large_user_name, -44815);
  zero_pcs                     EXCEPTION;
  PRAGMA EXCEPTION_INIT(zero_pcs, -44816);
  large_list                    EXCEPTION;
  PRAGMA EXCEPTION_INIT(large_list, -44817);
  general_failure              EXCEPTION;
  PRAGMA EXCEPTION_INIT(general_failure, -44818);
  no_enq                       EXCEPTION;
  PRAGMA EXCEPTION_INIT(no_enq, -44819);
  zero_wcs                     EXCEPTION;
  PRAGMA EXCEPTION_INIT(zero_wcs, -44820);
  lrg_cls                    EXCEPTION;
  PRAGMA EXCEPTION_INIT(lrg_cls, -44821);     
  rm_plan_not_created        EXCEPTION;
  PRAGMA EXCEPTION_INIT(rm_plan_not_created, -44822);     
  rm_plan_not_inuse          EXCEPTION;
  PRAGMA EXCEPTION_INIT(rm_plan_not_inuse, -44823);     
  rm_is_off                  EXCEPTION;
  PRAGMA EXCEPTION_INIT(rm_is_off, -44824);     
  plan_unmatched             EXCEPTION;
  PRAGMA EXCEPTION_INIT(plan_unmatched, -44825);     
  extra_pcs                  EXCEPTION;
  PRAGMA EXCEPTION_INIT(extra_pcs, -44826);
  lrg_pcs                    EXCEPTION;
  PRAGMA EXCEPTION_INIT(lrg_pcs, -44827);     
end dbms_wlm;
/

create or replace public synonym dbms_wlm for dbms_wlm
/

create or replace public synonym WLM_CAPABILITY_OBJECT
  for WLM_CAPABILITY_OBJECT;
/

create or replace public synonym WLM_CAPABILITY_ARRAY for WLM_CAPABILITY_ARRAY;
/

@?/rdbms/admin/sqlsessend.sql
