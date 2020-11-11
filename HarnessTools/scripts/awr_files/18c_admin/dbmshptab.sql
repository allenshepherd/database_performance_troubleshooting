Rem
Rem $Header: rdbms/admin/dbmshptab.sql /main/8 2017/05/28 22:46:04 stanaya Exp $
Rem
Rem dbmshptab.sql
Rem
Rem Copyright (c) 2005, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmshptab.sql - dbms hierarchical profiler table creation
Rem
Rem    DESCRIPTION
Rem       Create tables for the dbms hierarchical profiler
Rem
Rem    NOTES
Rem      The following tables are required to collect data:
Rem        dbmshp_runs
Rem          information on hierarchical profiler runs
Rem
Rem        dbmshp_function_info -
Rem          information on each function profiled
Rem
Rem        dbmshp_parent_child_info -
Rem          parent-child level profiler information
Rem
Rem      The dbmshp_runnumber sequence is used for generating unique
Rem      run numbers.
Rem
Rem      The tables and sequence can be created in the schema for each user
Rem      who wants to gather profiler data. Alternately these tables can be
Rem      created in a central schema. In the latter case the user creating
Rem      these objects is responsible for granting appropriate privileges
Rem      (insert,update on the tables and select on the sequence) to all
Rem      users who want to store data in the tables. Appropriate synonyms
Rem      must also be created so the tables are visible from other user
Rem      schemas.
Rem
Rem      THIS SCRIPT DELETES ALL EXISTING DATA!
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/dbmshptab.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/dbmshptab.sql
Rem    SQL_PHASE: UTILITY
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    sylin       01/11/17 - deprecate the script
Rem    sylin       03/17/15 - SQL ID support
Rem    sylin       08/26/14 - longer identifiers
Rem    sylin       06/12/13 - long identifier
Rem    sylin       07/30/07 - Modify foreign key constraints with on delete
Rem                           cascade clause
Rem    kmuthukk    06/13/06 - fix comments 
Rem    sylin       03/15/05 - Created
Rem

drop table dbmshp_runs                     cascade constraints;
drop table dbmshp_function_info            cascade constraints;
drop table dbmshp_parent_child_info        cascade constraints;

drop sequence dbmshp_runnumber;

DOC
  The use of dbmshptab.sql script has been deprecated. 

  call dbms_hprof.create_tables to create the hierarchical profiler tables
  and sequences.
#

