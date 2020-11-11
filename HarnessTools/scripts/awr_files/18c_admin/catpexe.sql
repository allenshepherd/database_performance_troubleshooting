Rem
Rem $Header: rdbms/admin/catpexe.sql /main/7 2016/02/11 12:06:38 jmuller Exp $
Rem
Rem catpexe.sql
Rem
Rem Copyright (c) 2007, 2016, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catpexe.sql - CATalog script for DBMS_PARALLEL_EXECUTE
Rem
Rem    DESCRIPTION
Rem      It creates a role, tables and views for DBMS_PARALLEL_EXECUTE
Rem      package.
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catpexe.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catpexe.sql
Rem SQL_PHASE: CATPEXE
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catptabs.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    jmuller     12/01/15 - Fix bug 21097449: named index on
Rem                           dbms_parallel_execute_chunks$.chunk_id
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    jmuller     10/16/12 - Fix bug 14698700: add index to
Rem                           DBMS_PARALLEL_EXECUTE_CHUNKS$
Rem    anighosh    07/30/12 - #(14296972): Stretch identifier
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    traney      04/05/11 - 35209: long identifiers dictionary upgrade
Rem    achoi       11/01/07 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

-- Administrator Role for DBMS_PARALLEL_EXECUTE.ADM_ subprograms
create role ADM_PARALLEL_EXECUTE_TASK;

Rem EDITION - the edition name. If the edition name was quoted, the quotes are
Rem stored as well.
Rem
Rem APPLY_CROSSEDITION_TRIGGER - the name of the cross edition trigger to apply.
Rem If the trigger name was quoted, the quotes are stored as well.
Rem
Rem Since identifier columns in Oracle are now 128 bytes in length, the edition
Rem column needs to be 130.

-- Create the DBMS_PARALLEL_EXECUTE_TASK$ table
CREATE TABLE DBMS_PARALLEL_EXECUTE_TASK$ 
                 (TASK_OWNER#                NUMBER        NOT NULL,
                  TASK_NAME                  VARCHAR2(128) NOT NULL, 
                  CHUNK_TYPE                 NUMBER        NOT NULL,
                  STATUS                     NUMBER        NOT NULL,
                  TABLE_OWNER                VARCHAR2(128),
                  TABLE_NAME                 VARCHAR2(128),
                  NUMBER_COLUMN              VARCHAR2(128),
                  CMT                        VARCHAR2(4000),
                  JOB_PREFIX                 VARCHAR2(128),
                  STOP_FLAG                  NUMBER,
                  SQL_STMT                   CLOB,
                  LANGUAGE_FLAG              NUMBER,
                  EDITION                    VARCHAR2(130),
                  APPLY_CROSSEDITION_TRIGGER VARCHAR2(130),
                  FIRE_APPLY_TRIGGER         VARCHAR2(10),
                  PARALLEL_LEVEL             NUMBER,
                  JOB_CLASS                  VARCHAR2(128),
                    CONSTRAINT PK_DBMS_PARALLEL_EXECUTE_1
                      PRIMARY KEY (TASK_OWNER#, TASK_NAME)
                 );

-- Create DBMS_PARALLEL_EXECUTE_CHUNKS$ table
-- [21097449] Name the primary key constraint so we can use it in a hint.
CREATE TABLE DBMS_PARALLEL_EXECUTE_CHUNKS$
                 (CHUNK_ID       NUMBER        NOT NULL,
                  TASK_OWNER#    NUMBER        NOT NULL,
                  TASK_NAME      VARCHAR2(128) NOT NULL,
                  STATUS         NUMBER        NOT NULL,
                  START_ROWID    ROWID,
                  END_ROWID      ROWID,
                  START_ID       NUMBER,
                  END_ID         NUMBER,
                  JOB_NAME       VARCHAR2(128),
                  START_TS       TIMESTAMP,
                  END_TS         TIMESTAMP,
                  ERROR_CODE     NUMBER,
                  ERROR_MESSAGE  VARCHAR2(4000),
                    CONSTRAINT I_DBMS_PARALLEL_EXECUTE_CHUNK1
                      PRIMARY KEY (CHUNK_ID),
                    CONSTRAINT FK_DBMS_PARALLEL_EXECUTE_1
                      FOREIGN KEY (TASK_OWNER#, TASK_NAME)
                      REFERENCES DBMS_PARALLEL_EXECUTE_TASK$
                                   (TASK_OWNER#, TASK_NAME)
                      ON DELETE CASCADE
                 );

-- [14698700] Create index on DBMS_PARALLEL_EXECUTE_CHUNKS$.  [Note that the
-- trailing '$' must be dropped to keep the index name within bounds.]
create index i_dbms_parallel_execute_chunks on dbms_parallel_execute_chunks$ 
  (task_owner#, task_name, status);

-- Create DBMS_PARALLEL_EXECUTE_SEQ$ sequence
create sequence dbms_parallel_execute_seq$;



@?/rdbms/admin/sqlsessend.sql
