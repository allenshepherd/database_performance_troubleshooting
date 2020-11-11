Rem
Rem $Header: plsql/admin/dbmscov.sql /main/9 2017/07/20 14:37:35 mahrajag Exp $
Rem
Rem dbmscov.sql
Rem
Rem Copyright (c) 2015, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmscov.sql - PL/SQL API for Basic Block Code Coverage Collection
Rem
Rem    DESCRIPTION
Rem      This Package specifies the PL/SQL API for the collection of code 
Rem      coverage data of PL/SQL applications at the basic block level.
Rem      A basic block is defined as a single entry single exit block of
Rem      PL/SQL code in a user's program.
Rem
Rem    NOTES
Rem      This package must be installed as SYS.
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: plsql/admin/dbmscov.sql 
Rem    SQL_SHIPPED_FILE:rdbms/admin/dbmscov.sql
Rem    SQL_PHASE:DBMSCOV 
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/catpdbms.sql 
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    mahrajag    06/20/17 - Bug 26240812
Rem    mahrajag    04/21/17 - Bug 25833172
Rem    mahrajag    08/08/16 - Make Start_Coverage a function that returns a 
Rem                           runid
Rem    mahrajag    07/27/16 - Cleanup the public API
Rem    mahrajag    05/18/16 - Add create_coverage_tables
Rem    mahrajag    01/19/16 - Fix public synonym pointing to lib
Rem    mahrajag    11/03/15 - make run_comment not null
Rem    mahrajag    06/16/15 - Add event 8402
Rem    mahrajag    05/21/15 - PL/SQL Basic Block Code Coverage
Rem    mahrajag    05/21/15 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

create or replace package sys.dbms_plsql_code_coverage
  authid current_user is

  --------------
  --  OVERVIEW
  --
  --  This package provides APIs for collecting code coverage information
  --  at the basic block level of PL/SQL applications. Here basic block
  --  refers to a single entry single exit block of PL/SQL code. 
  --  PL/SQL developers want to know how well their test infrastructure
  --  exercised their code. A typical code coverage run in a session 
  --  involves calls to :
  --    start_coverage
  --     run pl/sql code
  --    stop_coverage 
  --  Stopping coverage flushes the coverage data to a table

  coverage_error exception ;
  pragma exception_init(coverage_error, -8402);

  -- START_COVERAGE
  --
  -- This function starts coverage data collection at the basic block level 
  -- in the user's session.
  --
  --
  -- PARAMETERS:
  --   run_comment - Allows the user to uniquely identify the run in a scope 
  --                 that includes runs done in several databases. 
  -- RETURN
  --               - A unique runid for this particular run.

  function  start_coverage(run_comment IN varchar2) return number;


  -- STOP_COVERAGE
  --
  -- This procedure stops basic block coverage data collection.
  --
  procedure stop_coverage;

  
  -- CREATE_COVERAGE_TABLES
  -- This procedure creates the coverage tables.
  --
  -- PARAMETERS:
  --  force_it               -If force_it is false and coverage tables are 
  --                          present then a coverage error is raised. If 
  --                          force_it is true then it silently creates tables.
  --                          If tables already exist then they are dropped and
  --                          new tables are created.
  --
  procedure create_coverage_tables(force_it IN boolean := false);


end dbms_plsql_code_coverage;
/

show errors;

grant execute on sys.dbms_plsql_code_coverage to public;
create or replace public synonym dbms_plsql_code_coverage for 
       sys.dbms_plsql_code_coverage;

@?/rdbms/admin/sqlsessend.sql
