Rem
Rem $Header: rdbms/admin/dbmspexe.sql /main/5 2015/11/13 16:13:29 sylin Exp $
Rem
Rem dbmspexe.sql
Rem
Rem Copyright (c) 2007, 2015, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmspexe.sql - DBMS Parallel EXEcute package
Rem
Rem    DESCRIPTION
Rem      This package contains APIs to chunk a table into smaller units and
Rem      execute those chunks in parallel.
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmspexe.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmspexe.sql
Rem SQL_PHASE: DBMSPEXE
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    sylin       11/06/15 - 22087436: generate_task_name: limit prefix length
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    jmuller     01/29/13 - Fix bug 14312271: Add NO_CHUNKS
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    achoi       10/08/07 - convert back to procedure
Rem    achoi       10/08/07 - add status, exception
Rem    achoi       10/01/07 - revised API
Rem    achoi       09/25/07 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

create or replace package dbms_parallel_execute AUTHID CURRENT_USER AS

  --
  -- Chunk status value
  --
  UNASSIGNED            CONSTANT NUMBER := 0;
  ASSIGNED              CONSTANT NUMBER := 1;
  PROCESSED             CONSTANT NUMBER := 2;
  PROCESSED_WITH_ERROR  CONSTANT NUMBER := 3;


  --
  -- Task Status value
  --
  CREATED               CONSTANT NUMBER := 1;
  CHUNKING              CONSTANT NUMBER := 2;
  CHUNKING_FAILED       CONSTANT NUMBER := 3;
  NO_CHUNKS             CONSTANT NUMBER := 4;
  CHUNKED               CONSTANT NUMBER := 5;
  PROCESSING            CONSTANT NUMBER := 6;
  FINISHED              CONSTANT NUMBER := 7;
  FINISHED_WITH_ERROR   CONSTANT NUMBER := 8;
  CRASHED               CONSTANT NUMBER := 9;


  --
  -- Exceptions
  --
  MISSING_ROLE              EXCEPTION;
    pragma exception_init(MISSING_ROLE,              -29490);
  INVALID_TABLE             EXCEPTION;
    pragma exception_init(INVALID_TABLE,             -29491);
  INVALID_STATE_FOR_CHUNK  EXCEPTION;
    pragma exception_init(INVALID_STATE_FOR_CHUNK,  -29492);
  INVALID_STATUS            EXCEPTION;
    pragma exception_init(INVALID_STATUS,            -29493);
  INVALID_STATE_FOR_RUN    EXCEPTION;
    pragma exception_init(INVALID_STATE_FOR_RUN,    -29494);
  INVALID_STATE_FOR_RESUME EXCEPTION;
    pragma exception_init(INVALID_STATE_FOR_RESUME, -29495);
  DUPLICATE_TASK_NAME      EXCEPTION;
    pragma exception_init(DUPLICATE_TASK_NAME,      -29497);
  TASK_NOT_FOUND           EXCEPTION;
    pragma exception_init(TASK_NOT_FOUND,           -29498);
  CHUNK_NOT_FOUND           EXCEPTION;
    pragma exception_init(CHUNK_NOT_FOUND,           -29499);

  -- bug22087436: ORA-29496 is raised when length of prefix is over 64 bytes
  function generate_task_name(prefix in varchar2 default 'TASK$_')
    return varchar2;

  -- Create/Drop Task Procedure
  procedure create_task(task_name  in varchar2,
                        comment    in varchar2 default null);

  procedure drop_task(task_name in varchar2);


  -- Create/Drop Chunks Procedures
  procedure create_chunks_by_rowid(task_name   in varchar2,
                                   table_owner in varchar2,
                                   table_name  in varchar2,
                                   by_row      in boolean,
                                   chunk_size  in number);

  procedure create_chunks_by_number_col(task_name    in varchar2,
                                        table_owner  in varchar2,
                                        table_name   in varchar2,
                                        table_column in varchar2,
                                        chunk_size   in number);

  procedure create_chunks_by_SQL(task_name in varchar2,
                                 sql_stmt  in clob,
                                 by_rowid  in boolean);

  procedure drop_chunks(task_name in varchar2);


  -- Individual Chunk retrieval and processing Procedures
  procedure get_rowid_chunk(task_name   in  varchar2,
                            chunk_id    out number,
                            start_rowid out rowid,
                            end_rowid   out rowid,
                            any_rows    out boolean);

  procedure get_number_col_chunk(task_name in  varchar2,
                                 chunk_id  out number,
                                 start_id  out number,
                                 end_id    out number,
                                 any_rows  out boolean);

  procedure set_chunk_status(task_name in varchar2,
                             chunk_id  in number,
                             status    in number,
                             err_num   in number   default null,
                             err_msg   in varchar2 default null);

  procedure purge_processed_chunks(task_name in varchar2);


  -- Task Status Retrieval Procesure
  function task_status(task_name in varchar2) return number;


  -- Parallel Execution procedure: run, stop, resume
  procedure run_task(
    task_name                  in varchar2,
    sql_stmt                   in clob,
    language_flag              in number,
    edition                    in varchar2 default NULL,
    apply_crossedition_trigger in varchar2 default NULL,
    fire_apply_trigger         in boolean  default TRUE,
    parallel_level             in number   default 0,
    job_class                  in varchar2 default 'DEFAULT_JOB_CLASS');

  procedure resume_task(
    task_name                  in varchar2,
    sql_stmt                   in clob,
    language_flag              in number,
    edition                    in varchar2 default NULL,
    apply_crossedition_trigger in varchar2 default NULL,
    fire_apply_trigger         in boolean  default TRUE,
    parallel_level             in number   default 0,
    job_class                  in varchar2 default 'DEFAULT_JOB_CLASS',
    force                      in boolean  default FALSE);

  procedure resume_task(task_name in varchar2,
                        force     in boolean default FALSE);

  procedure stop_task(task_name in varchar2);


  -- CUSTOMER SHOULD NOT use this one.
  -- This is an internal routine for parallel execution.
  procedure run_internal_worker(task_name in varchar2,
                                job_name  in varchar2);


  -- Administrative Procedure
  --   All of the following subroutines requires ADM_PARALLEL_EXECUTE role.
  procedure adm_drop_task(task_owner in varchar2,
                          task_name  in varchar2);

  procedure adm_drop_chunks(task_owner in varchar2,
                            task_name  in varchar2);

  function adm_task_status(task_owner in varchar2,
                           task_name  in varchar2) return number;

  procedure adm_stop_task(task_owner in varchar2,
                          task_name  in varchar2);

end;
/


CREATE OR REPLACE PUBLIC SYNONYM dbms_parallel_execute
  FOR dbms_parallel_execute
/
grant execute on dbms_parallel_execute to public
/

@?/rdbms/admin/sqlsessend.sql
