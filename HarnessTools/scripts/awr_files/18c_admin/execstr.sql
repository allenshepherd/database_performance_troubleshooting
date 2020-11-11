Rem
Rem $Header: rdbms/admin/execstr.sql /main/5 2014/02/20 12:45:55 surman Exp $
Rem
Rem execstr.sql
Rem
Rem Copyright (c) 2006, 2014, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      execstr.sql - Execute anonymous blocks for STReam
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/execstr.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/execstr.sql
Rem SQL_PHASE: EXECSTR
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpexec.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    elu         08/31/11 - procedure LCR
Rem    rmao        12/09/08 - add daily job to clean automatic split/merge
Rem                         - job history
Rem    rmao        12/09/08 - add daily job to clean recoverable scripts
Rem    jinwu       11/13/06 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

Rem The following 'Rule evaluation context' block is moved from dbmslcr
Rem because of its dependency on the body package of SYS.DBMS_RULE_ADM

--------------------------
-- Rule evaluation context
--------------------------
-- {ROW,DDL}_VARIABLE_VALUE_FUNCTION converts AnyData to its LCR type
-- evaluation_context_function handles bookkeeping information, e.g.,
-- source data dictionary, commit/rollback.
DECLARE
  vt sys.re$variable_type_list;
BEGIN
  vt := sys.re$variable_type_list(
    sys.re$variable_type('DML', 'SYS.LCR$_ROW_RECORD', 
       'SYS.DBMS_STREAMS_INTERNAL.ROW_VARIABLE_VALUE_FUNCTION',
       'SYS.DBMS_STREAMS_INTERNAL.ROW_FAST_EVALUATION_FUNCTION'),
    sys.re$variable_type('DDL', 'SYS.LCR$_DDL_RECORD',
       'SYS.DBMS_STREAMS_INTERNAL.DDL_VARIABLE_VALUE_FUNCTION',
       'SYS.DBMS_STREAMS_INTERNAL.DDL_FAST_EVALUATION_FUNCTION'),
    sys.re$variable_type('PROC', 'SYS.LCR$_PROCEDURE_RECORD',
       'SYS.DBMS_STREAMS_INTERNAL.PROC_VARIABLE_VALUE_FUNCTION',
       'SYS.DBMS_STREAMS_INTERNAL.PROC_FAST_EVALUATION_FUNCTION'),
    sys.re$variable_type(NULL, 'SYS.ANYDATA',
       NULL,
       'SYS.DBMS_STREAMS_INTERNAL.ANYDATA_FAST_EVAL_FUNCTION'));

  dbms_rule_adm.create_evaluation_context(
    evaluation_context_name=>'SYS.STREAMS$_EVALUATION_CONTEXT',
    variable_types=>vt,
    evaluation_function=>
      'SYS.DBMS_STREAMS_INTERNAL.EVALUATION_CONTEXT_FUNCTION');
EXCEPTION WHEN OTHERS THEN
  IF SQLCODE = -24145 THEN
    -- If the evaluation context already exists, then for upgrade, reset the
    -- evaluation context variables to include procedure LCRs
    dbms_rule_adm.alter_evaluation_context(
      evaluation_context_name=>'SYS.STREAMS$_EVALUATION_CONTEXT',
      variable_types=>vt);
  ELSE
    RAISE;
  END IF;
END;
/

begin
dbms_rule_adm.grant_object_privilege(
   privilege=>dbms_rule_adm.EXECUTE_ON_EVALUATION_CONTEXT,
   object_name=>'SYS.STREAMS$_EVALUATION_CONTEXT',
   grantee=>'PUBLIC', grant_option=>FALSE);
end;
/
------------------------------
-- END Rule evaluation context
------------------------------


Rem The following block is moved from catpstr.sql because of
Rem its dependency on SYS.DEFAULT_JOB_CLASS

-- Create auto-purge job for file groups
BEGIN
  dbms_scheduler.create_job(
  job_name        => 'FGR$AUTOPURGE_JOB',
  job_type        => 'PLSQL_BLOCK',
  job_action      => 'sys.dbms_file_group.purge_file_group(NULL);',
  repeat_interval => 'freq=daily;byhour=0;byminute=0;bysecond=0',
  enabled         => FALSE,
  comments        => 'file group auto-purge job');

  dbms_scheduler.set_attribute('FGR$AUTOPURGE_JOB',
    'FOLLOW_DEFAULT_TIMEZONE',TRUE);
EXCEPTION WHEN others THEN
    IF sqlcode = -27477 THEN
       NULL;
    ELSE RAISE;
    END IF;
END;
/


Rem From catstrt.sql

/* Register internal action context export function with the rules
 * engine.  The first parameter should match
 * dbms_streams_decl.inttrans_rule_id. 
 */ 
BEGIN
  sys.dbms_ruleadm_internal.register_internal_actx('streams_it',
           'sys.dbms_logrep_exp.internal_transform_export');
EXCEPTION WHEN OTHERS THEN NULL;
END;
/


-- Create daily job to clean recoverable scripts
-- enable job initially to avoid enable/disable job when change view
BEGIN
  dbms_scheduler.create_job(
  job_name        => 'RSE$CLEAN_RECOVERABLE_SCRIPT',
  job_type        => 'PLSQL_BLOCK',
  job_action      => 'sys.dbms_streams_auto_int.clean_recoverable_script;',
  repeat_interval => 'freq=daily;byhour=0;byminute=0;bysecond=0',
  enabled         => TRUE,
  comments        => 'auto clean job for recoverable script');

  dbms_scheduler.set_attribute('RSE$CLEAN_RECOVERABLE_SCRIPT',
    'FOLLOW_DEFAULT_TIMEZONE',TRUE);
EXCEPTION WHEN others THEN
  -- ignore if job already created
  IF sqlcode != -27477 THEN
    RAISE;
  END IF;
END;
/

-- Create daily job to clean auto split merge views
-- enable job initially to avoid enable/disable job when change view
BEGIN
  dbms_scheduler.create_job(
  job_name        => 'SM$CLEAN_AUTO_SPLIT_MERGE',
  job_type        => 'PLSQL_BLOCK',
  job_action      => 'sys.dbms_streams_auto_int.clean_auto_split_merge;',
  repeat_interval => 'freq=daily;byhour=0;byminute=0;bysecond=0',
  enabled         => TRUE,
  comments        => 'auto clean job for auto split merge');

  dbms_scheduler.set_attribute('SM$CLEAN_AUTO_SPLIT_MERGE',
    'FOLLOW_DEFAULT_TIMEZONE',TRUE);
EXCEPTION WHEN others THEN
  -- ignore if job already created
  IF sqlcode != -27477 THEN
    RAISE;
  END IF;
END;
/

@?/rdbms/admin/sqlsessend.sql
