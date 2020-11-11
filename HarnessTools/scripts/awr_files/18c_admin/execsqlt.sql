Rem
Rem $Header: rdbms/admin/execsqlt.sql /main/8 2015/09/18 15:24:22 shjoshi Exp $
Rem
Rem execsqlt.sql
Rem
Rem Copyright (c) 2006, 2015, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      execsqlt.sql - EXECutable code for SQL Tuning to run during catproc
Rem
Rem    DESCRIPTION
Rem      This script contains some procedural logic we run during catproc.
Rem
Rem    NOTES
Rem      This must be called AFTER prvtsqlt is loaded.
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/execsqlt.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/execsqlt.sql
Rem SQL_PHASE: EXECSQLT
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/execsvrm.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    shjoshi     09/09/15 - bug20540751: drop auto sqltune program before
Rem                           create
Rem    surman      01/23/14 - 13922626: Update SQL metadata
Rem    kyagoub     06/04/13 - bug#16654392: upgrad/downgrade auto_sql_tuning_prog 
Rem    msabesan    11/06/12 - lrg 8469208 non CDB check added with schedular
Rem                           program
Rem    ddas        05/30/12 - #(13790095) add separate checks for auto sqltune
Rem                           and auto SPM evolve
Rem    arbalakr    05/23/12 - lrg 7000350: Ignore 65040 errors while creating
Rem                           sqltune tasks during db creation(for cdb)
Rem    ddas        09/02/11 - Proj 28394: add SPM evolve advisor
Rem    pbelknap    05/26/06 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

Rem Create the automatic SQL Tuning and automatic SPM evolve tasks
Rem   If the tasks already exist (catproc is being re-run), do not error.
begin
  sys.dbms_sqltune_internal.i_create_auto_tuning_task;
exception
  when others then
    if (sqlcode = -13607 OR    -- task already exists
        sqlcode = -65040) -- operation not allowed inside PDB(lrg 7000350)
    then
      null;
    else
      raise;
    end if;
end;
/

begin
  sys.dbms_spm_internal.i_create_auto_evolve_task;
exception
  when others then
    if (sqlcode = -13607)     -- task already exists
    then
      null;
    else
      raise;
    end if;
end;
/

Rem bug 20540751
Rem First drop the program if it exists. This is because whenever the 
Rem action for the program changes (e.g. it changed in 12.1), the only way
Rem to apply that change during an upgrade is to drop and re-create it.
Rem This drop used to be in a1201000.sql but is now moved here because 
Rem a1201000.sql runs after catproc and dropping stuff in that script means
Rem it wont get re-created automatically.
begin
  dbms_scheduler.drop_program('AUTO_SQL_TUNING_PROG', TRUE);
exception
when others then
  if (sqlcode = -27476)     -- program does not exist
  then
    null;                   -- ignore it
  else
    raise;                  -- non expected errors
  end if;
end;
/

Rem Create our scheduler program
Rem   If the prog already exists (catproc is being re-run), do not error.
begin
  dbms_scheduler.create_program(
    program_name => 'AUTO_SQL_TUNING_PROG',
    program_type => 'PLSQL_BLOCK',
    program_action => 
      q'{DECLARE 
         ename             VARCHAR2(30);
         exec_task         BOOLEAN;
       BEGIN
         -- check if tuning pack is enabled
         exec_task := prvt_advisor.is_pack_enabled(
                        dbms_management_packs.TUNING_PACK);

         -- check if we are in a pdb, 
         -- since auto sqltune is not run in a pdb
         IF (exec_task AND -- tuning pack enabled
         sys_context('userenv', 'con_id') <> 0 AND -- not in non-cdb
         sys_context('userenv', 'con_id') <> 1  ) THEN -- not in root
           exec_task := FALSE;
         END IF;

         -- execute auto sql tuning task
         IF (exec_task) THEN
           ename := dbms_sqltune.execute_tuning_task(
                      'SYS_AUTO_SQL_TUNING_TASK');
         END IF;

         -- check whether we are in non-CDB or a PDB
         -- auto SPM evolve only runs in a non-CDB or a PDB, not the root.
         IF (sys_context('userenv', 'con_id') = 0 OR
             sys_context('userenv', 'con_id') > 2) THEN
           exec_task := TRUE;
         ELSE
           exec_task := FALSE;
         END IF;

         -- execute auto SPM evolve task
         IF (exec_task) THEN
           ename := dbms_spm.execute_evolve_task('SYS_AUTO_SPM_EVOLVE_TASK');
         END IF;
       END;}',
    number_of_arguments => 0,
    enabled => TRUE,
    comments => 'Program to run automatic sql tuning and SPM evolve tasks, see dbmssqlt.sql and dbmsspm.sql');
exception
  when others then
    if (sqlcode = -27477) then   -- program already exists
      null;
    else
      raise;
    end if;
end;
/

@?/rdbms/admin/sqlsessend.sql
