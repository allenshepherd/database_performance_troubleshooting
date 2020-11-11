Rem
Rem $Header: rdbms/admin/execqopi.sql /main/11 2017/06/15 23:27:08 prprprak Exp $
Rem
Rem execqopi.sql
Rem
Rem Copyright (c) 2012, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      execqopi.sql - Job creation
Rem
Rem    DESCRIPTION
Rem      Queryable patch inventory job creation
Rem
Rem    NOTES
Rem      .
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/execqopi.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/execqopi.sql
Rem SQL_PHASE: EXECQOPI
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpexec.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    prprprak    05/08/17 - #25991099 Put log directory outside ORACLE_HOME
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    dkoppar     09/17/13 - #17344263 add sanyty checks
Rem    dkoppar     08/26/13 - #17352756 add widnows platform 12
Rem    dkoppar     03/09/12 - create job only if needed
Rem    tbhukya     07/13/12 - Remove unnecessary code
Rem    tbhukya     05/24/12 - Enable job code
Rem    tbhukya     05/23/12 - Disbale job code
Rem    tbhukya     05/08/12 - Main job name for each nodes
Rem    surman      04/13/12 - 13615447: Add SQL patching tags
Rem    tbhukya     01/09/12 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql


variable opatch_log_dir varchar2(1000);
variable opatch_script_dir varchar2(1000);
variable opatch_inst_dir varchar2(1000);


-- Create directories for log, script files with correct patch
DECLARE
  pf_id  NUMBER := 0;
  not_win BOOLEAN := TRUE;

  PLATFORM_WINDOWS32      CONSTANT BINARY_INTEGER := 7;
  PLATFORM_WINDOWSIA64    CONSTANT BINARY_INTEGER := 8;
  PLATFORM_WINDOWS64      CONSTANT BINARY_INTEGER := 12;
  PLATFORM_OPENVMS        CONSTANT BINARY_INTEGER := 15;
BEGIN
  select value into :opatch_log_dir
               from v$parameter
               where name='user_dump_dest';

  SELECT platform_id INTO pf_id FROM v$database;
  dbms_system.get_env( 'ORACLE_HOME', :opatch_script_dir );

  IF pf_id = PLATFORM_WINDOWS32 THEN
    not_win := FALSE;
  ELSIF pf_id = PLATFORM_WINDOWSIA64 THEN
    not_win := FALSE;
  ELSIF pf_id = PLATFORM_WINDOWS64 THEN
    not_win := FALSE;
  END IF;

  :opatch_inst_dir := :opatch_script_dir;
  IF not_win THEN
    :opatch_script_dir := :opatch_script_dir || '/QOpatch';
    :opatch_inst_dir   := :opatch_inst_dir || '/OPatch';
  ELSE
    :opatch_script_dir := :opatch_script_dir || '\QOpatch';
    :opatch_inst_dir   := :opatch_inst_dir || '\OPatch';
  END IF;


  -- single quotes in :opatch_log_dir and :opatch_script_dir
  -- would need extra quoting
  execute immediate 'CREATE OR REPLACE directory opatch_log_dir AS ''' ||
                     :opatch_log_dir || '''';
  execute immediate 'CREATE OR REPLACE directory opatch_script_dir AS ''' ||
                     :opatch_script_dir || '''';
  execute immediate 'CREATE OR REPLACE directory opatch_inst_dir AS ''' ||
                     :opatch_inst_dir || '''';
END;
/

--
-- Create jobs on different RAC nodes if it is a RAC env
-- o.w. create job on current env.
--


DECLARE
  v_code  NUMBER;
  exist   NUMBER;  
  v_errm  VARCHAR2(64);
  jobname VARCHAR2(128);
BEGIN

  jobname := 'LOAD_OPATCH_INVENTORY';

  select count(*) into exist
      from   dba_scheduler_jobs
      where  job_name=jobname AND owner='SYS';

  if exist = 0 then
    -- Create job on current oracle home
    DBMS_SCHEDULER.CREATE_JOB (
      job_name        => 'Load_opatch_inventory',
      job_type        => 'PLSQL_BLOCK',
      job_action      => 'BEGIN dbms_qopatch.opatch_inv_refresh_job(); END;',
      start_date      => SYSTIMESTAMP,
      auto_drop       => FALSE,
      comments         => 'Load opatch inventory on request');
  end if;

   EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
    v_code := SQLCODE;
    v_errm := SUBSTR(SQLERRM, 1, 64);
    DBMS_OUTPUT.PUT_LINE('Error code ' || v_code || ': ' || v_errm);
    raise;
END;
/

show errors


@?/rdbms/admin/sqlsessend.sql
