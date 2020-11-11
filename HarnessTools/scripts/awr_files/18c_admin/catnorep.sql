Rem
Rem $Header: rdbms/admin/catnorep.sql /main/7 2015/12/01 13:16:47 jorgrive Exp $
Rem
Rem catnorep.sql
Rem
Rem Copyright (c) 2014, 2015, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catnorep.sql - catnorep
Rem
Rem    DESCRIPTION
Rem      This file removes Advanced Replication objects from the database.
Rem      Advanced Replication is unsupported beyond 12.2.
Rem
Rem    NOTES
Rem    This script is intend to be run during an upgrade.  
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/catnorep.sql 
Rem    SQL_SHIPPED_FILE: 
Rem    SQL_PHASE: CATNOREP
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: a1201000.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    jorgrive    11/13/15 - bug 22204428, drop system.repcat_repobject_base
Rem    jorgrive    09/04/15 - bugs 21701107, 21757487, 20916041
Rem    jorgrive    04/22/15 - bug 20845633: drop synonym dbms_repcat_utl
Rem    jorgrive    03/23/15 - restore dbms_reputil
Rem    jorgrive    01/22/15 - bug 20395316: orphan synonyms
Rem    jorgrive    12/05/14 - drop additional objects
Rem    jorgrive    11/10/14 - Created
Rem
@@?/rdbms/admin/sqlsessstart.sql


DELETE FROM sys.expact$
  WHERE owner='SYSTEM' AND name='REPCAT$_REPSCHEMA'
    AND func_proc='REPCAT_IMPORT_REPSCHEMA_STRING'
/
DELETE FROM exppkgact$ WHERE package = 'DBMS_REFRESH_EXP_SITES'
  AND schema = 'SYS' AND class = 2
/
DELETE FROM exppkgact$ WHERE package = 'DBMS_REFRESH_EXP_LWM'
  AND schema = 'SYS' AND class = 2
/
COMMIT
/

Rem support DROP USER CASCADE
DELETE FROM sys.duc$ WHERE owner='SYS' AND pack='DBMS_REPCAT_UTL' 
  AND proc='DROP_USER_REPSCHEMA' AND operation#=1
/
DELETE FROM sys.duc$ WHERE owner='SYS' and pack='DBMS_REPCAT_RGT_UTL' 
  and proc='DROP_USER_TEMPLATES' and operation#=1
/
commit
/
DELETE FROM exppkgact$ WHERE package = 'DBMS_REPCAT_RGT_EXP'
  AND schema = 'SYS' AND class = 2
/
COMMIT
/

Rem system-level
Rem This should be one of the first system-level actions to be executed,
Rem so set level# to 1.
DELETE FROM exppkgact$ WHERE package = 'DBMS_REPCAT_EXP'
  AND schema = 'SYS' AND class = 1
/
COMMIT
/

Rem schema-level
Rem This should be one of the last schema-level actions to be executed,
Rem so set level# to 5000
DELETE FROM exppkgact$ WHERE package = 'DBMS_REPCAT_EXP'
  AND schema = 'SYS' AND class = 2
/
COMMIT
/

drop public synonym DBMS_REPCAT_DECL;
drop public synonym DBMS_REPCAT_INTERNAL_PACKAGE;
drop public synonym DBMS_REPCAT_INTERNAL;
drop public synonym DBMS_REPUTIL2;
drop public synonym DBMS_DEFERGEN;
drop public synonym DBMS_DEFER_QUERY;
drop public synonym DBMS_DEFER;
drop public synonym DBMS_DEFER_SYS;
drop public synonym DBMS_REPCAT;
drop public synonym DBMS_REPCAT_RGT;
drop public synonym DBMS_REPCAT_ADMIN;
drop public synonym DBMS_OFFLINE_RGT;
drop public synonym DBMS_INTERNAL_REPCAT;
drop public synonym DBMS_REPCAT_AUTH;
drop public synonym DBMS_REPCAT_VALIDATE;
drop public synonym DBMSOBJGWRAPPER;
drop public synonym DBMS_REPCAT_INSTANTIATE;
drop public synonym DBMS_OFFLINE_SNAPSHOT;
drop public synonym DBMS_RECTIFIER_DIFF;
drop public synonym DBMS_OFFLINE_OG;
drop public synonym DBMS_REPCAT_UTL;

drop package DBMS_RECTIFIER_DIFF;
drop package DBMS_OFFLINE_SNAPSHOT;
drop package DBMS_REPCAT_DECL;
drop package DBMS_REPCAT_CACHE;                                                   
drop package DBMS_REPCAT_INTERNAL_PACKAGE;
drop package DBMS_REPCAT_INTERNAL;
drop package DBMS_REPCAT_OUTPUT;
drop package DBMS_REPUTIL2;
drop package DBMS_DEFERGEN ;
drop package DBMS_DEFERGEN_UTIL;
drop package DBMS_DEFER_QUERY;
drop package DBMS_DEFER;
drop package DBMS_DEFER_SYS;
drop package DBMS_REPCAT_OBJ_UTL;
drop package DBMS_REPCAT_UTL;
drop package DBMS_DEFER_QUERY_UTL;
drop package DBMS_DEFER_ENQ_UTL;
drop package DBMS_DEFER_REPCAT;
drop package DBMS_ASYNCRPC_PUSH;
drop package DBMS_DEFER_SYS_PART1;
drop package DBMS_DEFER_INTERNAL_QUERY;
drop package DBMS_DEFER_INTERNAL_SYS;
drop package DBMS_DEFER_QUERY_DEFINER;
drop package DBMS_DEFER_DEFINER;
drop package DBMS_DEFER_SYS_DEFINER;
drop package DBMS_REPCAT_SQL_UTL;
drop package DBMS_REPCAT_COMMON_UTL;
drop package DBMS_REPCAT_SNA;
drop package DBMS_REPCAT_SNA_UTL;
drop package DBMS_REPCAT_UNTRUSTED;
drop package DBMS_REPCAT_ADMIN;
drop package DBMS_REPCAT_FLA;
drop package DBMS_REPCAT_FLA_UTL;
drop package DBMS_OFFLINE_RGT_INTERNAL;
drop package DBMS_OFFLINE_RGT;
drop package DBMS_INTERNAL_REPCAT;
drop package DBMS_REPCAT_AUTH;
drop package SYSTEM.DBMS_REPCAT_AUTH;
drop package DBMS_REPCAT_CONF;
drop package DBMS_REPCAT_MAS;
drop package DBMS_REPCAT_RPC;
drop package DBMS_REPCAT_RPC_UTL;
drop package DBMS_REPCAT_UTL2;
drop package DBMS_REPCAT_UTL3;
drop package DBMS_REPCAT_UTL4;
drop package DBMS_REPCAT_VALIDATE;
drop package DBMSOBJGWRAPPER;
drop package DBMS_REPCAT_FLA_MAS;
drop package DBMS_REPCAT_RQ;
drop package DBMS_REPCAT_ADD_MASTER;
drop package DBMS_OFFLINE_INTERNAL;
drop package DBMS_OFFLINE_UTL;
drop package DBMS_OFFLINE_OG_INTERNAL;
drop package DBMS_REPCAT_MIGRATION;
drop package DBMS_OFFLINE_OG;
drop package DBMS_REPCAT_RGT;
drop package DBMS_REPCAT_RGT_ALT;
drop package DBMS_REPCAT_RGT_CHK;
drop package DBMS_REPCAT_RGT_CUST;
drop package DBMS_REPCAT_RGT_CUST2;
drop package DBMS_REPCAT_RGT_UTL;
drop package DBMS_REPCAT_RGT_EXP;
drop package DBMS_REPCAT_INSTANTIATE;
drop package DBMS_DEFERGEN_LOB;
drop package DBMS_DEFERGEN_AUDIT;
drop package DBMS_DEFERGEN_RESOLUTION;
drop package DBMS_DEFERGEN_PRIORITY;
drop package DBMS_DEFERGEN_INTERNAL;
drop package DBMS_DEFERGEN_WRAP;
drop package DBMS_MAINT_GEN;
drop package DBMSOBJG;
drop package DBMSOBJG2;
drop package DBMSOBJG_DP;
drop package DBMS_REPCAT_SNA_INTERNAL;
drop package DBMS_OFFLINE_SNAPSHOT_INTERNAL;
drop package DBMS_REPCAT_DEFINER;
drop package DBMS_REPCAT_MIG_INTERNAL;
drop package DBMS_REPCAT_EXP;
drop package DBMS_RECTIFIER_FRIENDS;
drop package DBMS_RECTIFIER_DIFF_INTERNAL;
drop package dbms_refresh_exp_lwm;
drop package DBMS_REFRESH_EXP_SITES;

-- drop views and tables
drop public synonym defcall;
drop view defcall;
drop public synonym user_repschema;
drop view user_repschema;
drop view "_DEFSCHEDULE";
drop view "_ALL_REPCOLUMN";
drop view "_ALL_REPGROUPED_COLUMN";
drop view "_ALL_REPCOLUMN_GROUP";
drop view "_ALL_REPRESOLUTION";
drop view "_ALL_REPPARAMETER_COLUMN";
drop view "_ALL_REPCONFLICT";
drop view "_ALL_REPFLAVOR_OBJECTS";
drop public synonym "_ALL_INSTANTIATION_DDL";
drop view "_ALL_INSTANTIATION_DDL";
drop public synonym "_ALL_REPEXTENSIONS";
drop view "_ALL_REPEXTENSIONS";
drop public synonym "_ALL_REPSITES_NEW";
drop view "_ALL_REPSITES_NEW";
drop view "_DEFTRANDEST";

drop view repcat$_cdef;
drop public synonym cdb_repsites_new;
drop view cdb_repsites_new;
drop public synonym dba_repsites_new;
drop view dba_repsites_new;
drop public synonym cdb_repextensions;
drop view cdb_repextensions;
drop public synonym dba_repextensions;
drop view dba_repextensions;
drop table system.repcat$_sites_new;
drop table system.repcat$_extension;
drop table system.repcat$_instantiation_ddl;
drop public synonym cdb_repcat_exceptions;
drop view cdb_repcat_exceptions;
drop public synonym dba_repcat_exceptions;
drop view dba_repcat_exceptions;
drop table system.repcat$_exceptions;
drop public synonym cdb_template_targets;
drop view cdb_template_targets;
drop public synonym dba_template_targets;
drop view dba_template_targets;
drop table system.repcat$_template_targets;
drop table system.repcat$_runtime_parms;
drop table system.repcat$_site_objects;
drop public synonym user_repcat_template_sites;
drop view user_repcat_template_sites;
drop public synonym all_repcat_template_sites;
drop view all_repcat_template_sites;
drop public synonym cdb_repcat_template_sites;
drop view cdb_repcat_template_sites;
drop public synonym dba_repcat_template_sites;
drop view dba_repcat_template_sites;
drop table system.repcat$_template_sites;
drop public synonym user_repcat_user_parm_values;
drop view user_repcat_user_parm_values;
drop public synonym all_repcat_user_parm_values;
drop view all_repcat_user_parm_values;
drop public synonym cdb_repcat_user_parm_values;
drop view cdb_repcat_user_parm_values;
drop public synonym dba_repcat_user_parm_values;
drop view dba_repcat_user_parm_values;
drop table system.repcat$_user_parm_values;
drop table system.repcat$_object_parms;
drop public synonym user_repcat_template_parms;
drop view user_repcat_template_parms;
drop public synonym all_repcat_template_parms;
drop view all_repcat_template_parms;
drop public synonym cdb_repcat_template_parms;
drop view cdb_repcat_template_parms;
drop public synonym dba_repcat_template_parms;
drop view dba_repcat_template_parms;
drop table system.repcat$_template_parms;
drop public synonym user_repcat_template_objects;
drop view user_repcat_template_objects;
drop public synonym all_repcat_template_objects;
drop view all_repcat_template_objects;
drop public synonym cdb_repcat_template_objects;
drop view cdb_repcat_template_objects;
drop public synonym dba_repcat_template_objects;
drop view dba_repcat_template_objects;
drop table system.repcat$_template_objects;
drop public synonym cdb_template_refgroups;
drop view cdb_template_refgroups;
drop public synonym dba_template_refgroups;
drop view dba_template_refgroups;
drop table system.repcat$_template_refgroups;
drop table system.repcat$_object_types;
drop public synonym user_repcat_refresh_templates;
drop view user_repcat_refresh_templates;
drop public synonym all_repcat_refresh_templates;
drop view all_repcat_refresh_templates;
drop public synonym user_repcat_user_authorization;
drop view user_repcat_user_authorization;
drop public synonym all_repcat_user_authorizations;
drop view all_repcat_user_authorizations;
drop public synonym cdb_repcat_user_authorizations;
drop view cdb_repcat_user_authorizations;
drop public synonym dba_repcat_user_authorizations;
drop view dba_repcat_user_authorizations;
drop table system.repcat$_user_authorizations;
drop public synonym cdb_repcat_refresh_templates;
drop view cdb_repcat_refresh_templates;
drop public synonym dba_repcat_refresh_templates;
drop view dba_repcat_refresh_templates;
drop table system.repcat$_refresh_templates;
drop table system.repcat$_template_types;
drop table system.repcat$_template_status;
drop public synonym user_repflavor_columns;
drop view user_repflavor_columns;
drop public synonym all_repflavor_columns;
drop view all_repflavor_columns;
drop public synonym cdb_repflavor_columns;
drop view cdb_repflavor_columns;
drop public synonym dba_repflavor_columns;
drop view dba_repflavor_columns;
drop view repcat_repflavor_columns;
drop public synonym user_repflavor_objects;
drop view user_repflavor_objects;
drop public synonym all_repflavor_objects;
drop view all_repflavor_objects;
drop public synonym cdb_repflavor_objects;
drop view cdb_repflavor_objects;
drop public synonym dba_repflavor_objects;
drop view dba_repflavor_objects;
drop public synonym user_repflavors;
drop view user_repflavors;
drop public synonym all_repflavors;
drop view all_repflavors;
drop public synonym cdb_repflavors;
drop view cdb_repflavors;
drop public synonym dba_repflavors;
drop view dba_repflavors;
drop public synonym user_repaudit_column;
drop view user_repaudit_column;
drop public synonym all_repaudit_column;
drop view all_repaudit_column;
drop public synonym cdb_repaudit_column;
drop view cdb_repaudit_column;
drop public synonym dba_repaudit_column;
drop view dba_repaudit_column;
drop table system.repcat$_audit_column;
drop public synonym user_repaudit_attribute;
drop view user_repaudit_attribute;
drop public synonym all_repaudit_attribute;
drop view all_repaudit_attribute;
drop public synonym cdb_repaudit_attribute;
drop view cdb_repaudit_attribute;
drop public synonym dba_repaudit_attribute;
drop view dba_repaudit_attribute;
drop table system.repcat$_audit_attribute;
drop public synonym user_repparameter_column;
drop view user_repparameter_column;
drop public synonym all_repparameter_column;
drop view all_repparameter_column;
drop public synonym cdb_repparameter_column;
drop view cdb_repparameter_column;
drop public synonym dba_repparameter_column;
drop view dba_repparameter_column;
drop table system.repcat$_parameter_column;
drop public synonym user_represol_stats_control;
drop view user_represol_stats_control;
drop public synonym all_represol_stats_control;
drop view all_represol_stats_control;
drop public synonym cdb_represol_stats_control;
drop view cdb_represol_stats_control;
drop public synonym dba_represol_stats_control;
drop view dba_represol_stats_control;
drop table system.repcat$_resol_stats_control;
drop public synonym user_represolution_statistics;
drop view user_represolution_statistics;
drop public synonym all_represolution_statistics;
drop view all_represolution_statistics;
drop public synonym cdb_represolution_statistics;
drop view cdb_represolution_statistics;
drop public synonym dba_represolution_statistics;
drop view dba_represolution_statistics;
drop table system.repcat$_resolution_statistics;
drop public synonym user_represolution;
drop view user_represolution;
drop public synonym all_represolution;
drop view all_represolution;
drop public synonym cdb_represolution;
drop view cdb_represolution;
drop public synonym dba_represolution;
drop view dba_represolution;
drop table system.repcat$_resolution;
drop public synonym user_represolution_method;
drop view user_represolution_method;
drop public synonym all_represolution_method;
drop view all_represolution_method;
drop public synonym cdb_represolution_method;
drop view cdb_represolution_method;
drop public synonym dba_represolution_method;
drop view dba_represolution_method;
drop table system.repcat$_resolution_method;
drop public synonym user_repconflict;
drop view user_repconflict;
drop public synonym all_repconflict;
drop view all_repconflict;
drop public synonym cdb_repconflict;
drop view cdb_repconflict;
drop public synonym dba_repconflict;
drop view dba_repconflict;
drop table system.repcat$_conflict;
drop public synonym user_repgrouped_column;
drop view user_repgrouped_column;
drop public synonym all_repgrouped_column;
drop view all_repgrouped_column;
drop public synonym cdb_repgrouped_column;
drop view cdb_repgrouped_column;
drop public synonym dba_repgrouped_column;
drop view dba_repgrouped_column;
drop table system.repcat$_grouped_column;
drop public synonym user_repcolumn_group;
drop view user_repcolumn_group;
drop public synonym all_repcolumn_group;
drop view all_repcolumn_group;
drop public synonym cdb_repcolumn_group;
drop view cdb_repcolumn_group;
drop public synonym dba_repcolumn_group;
drop view dba_repcolumn_group;
drop table system.repcat$_column_group;
drop public synonym user_reppriority;
drop view user_reppriority;
drop public synonym all_reppriority;
drop view all_reppriority;
drop view cdb_reppriority;
drop public synonym dba_reppriority;
drop view dba_reppriority;
drop view all_reppriority_group;
drop public synonym all_reppriority_group;
drop public synonym user_reppriority_group;
drop public synonym cdb_reppriority_group;
drop view cdb_reppriority_group;
drop public synonym dba_reppriority_group;
drop view dba_reppriority_group;
drop view user_reppriority_group;
drop public synonym cdb_repddl;
drop view cdb_repddl;
drop public synonym dba_repddl;
drop view dba_repddl;
drop public synonym all_repddl;
drop view all_repddl;
drop public synonym user_repddl;
drop view user_repddl;
drop public synonym cdb_repcatlog;
drop view cdb_repcatlog;
drop public synonym dba_repcatlog;
drop view dba_repcatlog;
drop public synonym all_repcatlog;
drop view all_repcatlog;
drop public synonym user_repcatlog;
drop view user_repcatlog;
drop public synonym cdb_repgenerated;
drop view cdb_repgenerated;
drop public synonym dba_repgenerated;
drop view dba_repgenerated;
drop view all_repgenerated;
drop public synonym user_repgenerated;
drop view user_repgenerated;
drop view cdb_repgenobjects;
drop public synonym dba_repgenobjects;
drop view dba_repgenobjects;
drop public synonym all_repgenobjects;
drop view all_repgenobjects;
drop public synonym user_repgenobjects;
drop view user_repgenobjects;
drop public synonym all_repkey_columns;
drop view all_repkey_columns;
drop public synonym user_repkey_columns;
drop view user_repkey_columns;
drop view cdb_repkey_columns;
drop view dba_repkey_columns;
drop public synonym cdb_repprop;
drop view cdb_repprop;
drop view dba_repprop;
drop view all_repprop;
drop view user_repprop;
drop public synonym user_repcolumn;
drop view user_repcolumn;
drop public synonym all_repcolumn;
drop view all_repcolumn;
drop view cdb_repcolumn;
drop public synonym dba_repcolumn;
drop view dba_repcolumn;
drop view repcat_repcolumn_base;
drop view cdb_repobject;
drop view dba_repobject;
drop view all_repobject;
drop view user_repobject;
drop view cdb_repschema;
drop view dba_repschema;
drop view all_repschema;
drop view cdb_repsites;
drop view dba_repsites;
drop view all_repsites;
drop view user_repsites;
drop view cdb_repcat;
drop public synonym dba_repgroup;
drop public synonym dba_repcat;
drop view dba_repcat;
drop view cdb_repgroup;
drop view dba_repgroup;
drop public synonym all_repgroup;
drop public synonym all_repcat;
drop view all_repcat;
drop view all_repgroup;
drop public synonym user_repgroup;
drop public synonym user_repcat;
drop view user_repcat;
drop view user_repgroup;
drop view user_repgroup_privileges;
drop view cdb_repgroup_privileges;
drop view dba_repgroup_privileges;
drop view all_repgroup_privileges;
drop table system.repcat$_repgroup_privs;
drop table system.repcat$_ddl;
drop view repcat_repcatlog;
drop table system.repcat$_repcatlog;
drop view repcat_repprop;
drop table system.repcat$_repprop;
drop view repcat_repobject;
drop view repcat_generated;
drop table system.repcat$_generated;
drop table system.repcat$_key_columns;
drop table system.repcat$_repcolumn;
drop view repcat_repobject_base;
drop table system.repcat$_repobject;
drop view cdb_registered_mview_groups;
drop view dba_registered_mview_groups;
drop table system.repcat$_snapgroup;
drop view repcat_repschema;
drop table system.repcat$_repschema;
drop view repcat_repcat;
drop table system.repcat$_flavor_objects;
drop table system.repcat$_priority;
drop table system.repcat$_priority_group;
drop table system.repcat$_flavors;
drop table system.repcat$_repcat;
drop view dba_registered_snapshot_groups;
drop public synonym dba_registered_snapshot_groups;
drop view cdb_registered_snapshot_groups;
drop public synonym cdb_registered_snapshot_groups;
drop view defcalldest;
drop public synonym defcalldest;
--
drop table system.def$_calldest;
drop table system.def$_error;
drop table system.def$_destination;
drop table system.def$_defaultdest;
drop table system.def$_lob;
drop table system.def$_propagator;
drop table system.def$_origin;
drop table system.def$_pushed_transactions;
drop synonym def$_calldest;
drop synonym def$_error;
drop view defschedule;
drop public synonym defschedule;
drop view deferror;
drop public synonym deferror;
drop  view deferrcount;
drop public synonym deferrcount;
drop synonym def$_defaultdest;
drop view defdefaultdest;
drop public synonym defdefaultdest;
drop synonym def$_lob;
drop view deflob;
drop public synonym deflob ;
drop view defpropagator;
drop public synonym defpropagator;
drop view dba_ias_templates;
drop public synonym dba_ias_templates ;
drop view cdb_ias_templates;
drop public synonym cdb_ias_templates;
drop view dba_ias_objects_base;
drop view cdb_ias_objects_base;
drop public synonym cdb_ias_objects_base;
drop view dba_ias_objects_exp;
drop view cdb_ias_objects_exp;
drop public synonym cdb_ias_objects_exp;
drop view dba_ias_objects;
drop public synonym dba_ias_objects;
drop view cdb_ias_objects;
drop public synonym cdb_ias_objects;
drop view  dba_ias_sites;
drop public synonym dba_ias_sites;
drop view cdb_ias_sites;
drop public synonym cdb_ias_sites;
drop view cdb_ias_constraint_exp;
drop public synonym cdb_ias_constraint_exp;
drop view dba_ias_gen_stmts;
drop public synonym dba_ias_gen_stmts;
drop view cdb_ias_gen_stmts;
drop public synonym cdb_ias_gen_stmts;
drop view dba_ias_gen_stmts_exp;
drop view cdb_ias_gen_stmts_exp;
drop public synonym cdb_ias_gen_stmts_exp;
drop view dba_ias_pregen_stmts;
drop view cdb_ias_pregen_stmts;
drop public synonym cdb_ias_pregen_stmts;
drop view dba_ias_postgen_stmts;
drop view cdb_ias_postgen_stmts;
drop public synonym cdb_ias_postgen_stmts;
drop view dba_ias_constraint_exp;
drop public synonym dba_registered_mview_groups;
drop public synonym cdb_registered_mview_groups;
drop public synonym all_repgroup_privileges;
drop public synonym dba_repgroup_privileges;
drop public synonym cdb_repgroup_privileges;
drop public synonym user_repgroup_privileges;
drop public synonym cdb_repgroup;
drop public synonym user_repsites;
drop public synonym all_repsites;
drop public synonym dba_repsites;
drop public synonym cdb_repsites;
drop public synonym all_repschema;
drop public synonym dba_repschema;
drop public synonym cdb_repschema;
drop public synonym user_repobject;
drop public synonym all_repobject;
drop public synonym dba_repobject;
drop public synonym cdb_repobject;
drop public synonym cdb_repcolumn;
drop public synonym user_repprop;
drop public synonym all_repprop;
drop public synonym dba_repprop;
drop public synonym dba_repkey_columns;
drop public synonym cdb_repkey_columns;
drop public synonym cdb_repgenobjects;
drop public synonym all_repgenerated;
drop public synonym cdb_reppriority;

drop public synonym gv$replqueue;
drop view sys.gv_$replqueue;
drop public synonym v$replqueue;
drop view sys.v_$replqueue;

drop public synonym gv$replprop;
drop view sys.gv_$replprop;
drop public synonym v$replprop;
drop view sys.v_$replprop;

drop synonym def$_aqcall;
drop synonym def$_schedule;
drop view deftran;
drop public synonym deftran;
drop view deftrandest;
drop public synonym deftrandest;
drop procedure system.ora$_sys_rep_auth;

drop sequence system.repcat$_flavors_s;
drop sequence system.repcat$_flavor_name_s;
drop sequence system.repcat$_repprop_key;
drop sequence system.repcat_log_sequence;
drop sequence system.repcat$_refresh_templates_s;
drop sequence system.repcat$_user_authorizations_s;
drop sequence system.repcat$_template_refgroups_s;
drop sequence system.repcat$_template_parms_s;
drop sequence system.repcat$_template_objects_s;
drop sequence system.repcat$_user_parm_values_s;
drop sequence system.repcat$_template_sites_s;
drop sequence system.repcat$_temp_output_s;
drop sequence system.repcat$_runtime_parms_s;
drop sequence system.template$_targets_s;
drop sequence system.repcat$_exceptions_s;

drop type system.repcat$_object_null_vector;
drop public synonym cdb_repcat;
drop public synonym repcat_repcolumn_base;

/* Bug 21701107: invalid repcat objects after upgrade */ 
drop view "_DBA_REPL_NESTED_TABLE_NAMES";
drop view "_ALL_REPL_NESTED_TABLE_NAMES";
drop view "_USER_REPL_NESTED_TABLE_NAMES";
drop library dbms_repcat_internal_pkg_lib;
drop library dbms_defer_enq_utl_lib;
drop library dbms_defer_query_utl_lib;

-- Drop VPD policies for repcat

BEGIN
  DECLARE
    has_policy NUMBER;
    polname varchar2(128) := 'repcat_policy';
    owner varchar2(128) := 'system';
    functionname varchar2(128) := 'dbms_repcat_admin.repcat_isdba';
    type array_t is table of varchar2(128);
    repcat_objs array_t := array_t('repcat$_repcat', 'repcat$_repschema', 
         'repcat$_flavors','repcat$_snapgroup','repcat$_repobject',
         'repcat$_repcolumn','repcat$_key_columns','repcat$_generated',
         'repcat$_repprop', 'repcat$_repcatlog', 'repcat$_ddl',
         'repcat$_priority_group', 'repcat$_priority',
         'repcat$_column_group', 'repcat$_grouped_column','repcat$_conflict',
         'repcat$_resolution_method', 'repcat$_resolution', 
         'repcat$_resolution_statistics', 'repcat$_resol_stats_control', 
         'repcat$_parameter_column', 'repcat$_audit_attribute', 
         'repcat$_audit_column','repcat$_flavor_objects',
         'repcat$_template_status','repcat$_template_types', 
         'repcat$_refresh_templates', 'repcat$_user_authorizations',
         'repcat$_object_types', 'repcat$_template_refgroups',
         'repcat$_template_objects', 'repcat$_template_parms',
         'repcat$_object_parms','repcat$_user_parm_values',
         'repcat$_template_sites', 'repcat$_site_objects',
         'repcat$_runtime_parms','repcat$_template_targets','repcat$_exceptions',
         'repcat$_instantiation_ddl', 'repcat$_extension', 'repcat$_sites_new',
         'def$_calldest', 'def$_error', 'def$_defaultdest', 'def$_destination',
         'def$_lob', 'def$_propagator', 'def$_origin', 
         'def$_pushed_transactions');
  BEGIN
    for i in 1..repcat_objs.count loop        
      -- We try to delete the policy in case we are re-running this script.
      has_policy := 0;
      SELECT count(*) into has_policy FROM all_policies
                     WHERE OBJECT_OWNER = upper(owner)
                     AND OBJECT_NAME =  upper(repcat_objs(i))
                     AND POLICY_NAME = upper(polname);
      
      IF 1 = has_policy
      THEN                
              dbms_rls.drop_policy(owner, repcat_objs(i), polname);
      END IF; 
  END loop;        
END;

-- we need a separate policy for repcat$_repgroup_privs,
-- since it's used in the previous policy function.
DECLARE
  has_policy NUMBER;
  polname varchar2(128) := 'repcat_policy';
  owner varchar2(128) := 'system';
  functionname varchar2(128) := 'dbms_repcat_admin.repgroup_privs_fun';
  type array_t is table of varchar2(128);
  repcat_objs array_t := array_t('repcat$_repgroup_privs');
 BEGIN
    for i in 1..repcat_objs.count loop
      -- We try to delete the policy in case we are re-running this script.
      has_policy := 0;
      SELECT count(*) into has_policy FROM all_policies
                     WHERE OBJECT_OWNER = upper(owner)
                     AND OBJECT_NAME =  upper(repcat_objs(i))
                     AND POLICY_NAME = upper(polname);
      
      IF 1 = has_policy
      THEN                
              dbms_rls.drop_policy(owner, repcat_objs(i), polname);
      END IF;    
    END loop;        
  END;
END;
/

declare
p_options dbms_aqadm.aq$_purge_options_t ;
begin
  p_options.block := TRUE;
  p_options.delivery_mode := dbms_aq.PERSISTENT;

  dbms_aqadm.purge_queue_table(
          queue_table     => 'SYSTEM.DEF$_AQCALL',
          purge_condition => NULL,
          purge_options   => p_options);

  dbms_aqadm.purge_queue_table(
          queue_table     => 'SYSTEM.DEF$_AQERROR',
          purge_condition => NULL,
          purge_options   => p_options);

 -- Bug 21757487: call drop_queue_table
 dbms_aqadm.stop_queue('system.def$_aqcall');
 dbms_aqadm.drop_queue('system.def$_aqcall');
 dbms_aqadm.drop_queue_table('system.def$_aqcall');

 dbms_aqadm.stop_queue('system.def$_aqerror');
 dbms_aqadm.drop_queue('system.def$_aqerror'); 
 dbms_aqadm.drop_queue_table('system.def$_aqerror');

  -- if we re-run catnorep, they won't exist
  EXCEPTION WHEN OTHERS THEN  
   IF sqlcode = -24010 THEN
     NULL;
   END IF;
end;
/

BEGIN
  execute immediate 'drop package DBMS_LOGREP_DEF_PROC';
  execute immediate 'drop public synonym DBMS_LOGREP_DEF_PROC';

  EXCEPTION WHEN OTHERS THEN  
   IF sqlcode = -4043 OR sqlcode = -1432 THEN
     NULL;
   END IF;
END;
/

/* BUG 20916041: the following views could be found under system */
BEGIN
  execute immediate 'drop view SYSTEM.dba_registered_snapshot_groups';
  EXCEPTION WHEN OTHERS THEN 
   IF sqlcode = -942 THEN NULL; END IF;
END;
/

BEGIN
  execute immediate 'drop view SYSTEM."_DEFTRANDEST"';
  EXCEPTION WHEN OTHERS THEN 
   IF sqlcode = -942 THEN NULL; END IF;
END;
/

BEGIN
  execute immediate 'drop view SYSTEM.defcalldest';
  EXCEPTION WHEN OTHERS THEN 
   IF sqlcode = -942 THEN NULL; END IF;
END;
/

BEGIN
  execute immediate 'drop view SYSTEM.deftrandest';
  EXCEPTION WHEN OTHERS THEN 
   IF sqlcode = -942 THEN NULL; END IF;
END;
/

/* BUG 22204428 */ 
BEGIN
  execute immediate 'drop view SYSTEM.repcat_repobject_base';
  EXCEPTION WHEN OTHERS THEN 
   IF sqlcode = -942 THEN NULL; END IF;
END;
/

@?/rdbms/admin/sqlsessend.sql
