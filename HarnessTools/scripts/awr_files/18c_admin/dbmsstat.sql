Rem
Rem dbmsstat.sql
Rem
Rem Copyright (c) 1998, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsstat.sql - statistics gathering package
Rem
Rem    DESCRIPTION
Rem      This package provides a mechanism for users to view and modify
Rem      optimizer statistics gathered for database objects.
Rem
Rem    NOTES
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmsstat.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmsstat.sql
Rem SQL_PHASE: DBMSSTAT
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: ORA-01921
Rem SQL_CALLING_FILE: rdbms/admin/catpspec.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    cwidodo     07/11/17 - #(25463265): add function for each type of
Rem                           convert_raw* procedure
Rem    yuyzhang    05/18/17 - #(26051674): add two preferences ROOT_TRIGGER_PDB
Rem                                        and COORDINATOR_TRIGGER_SHARD
Rem    schakkap    04/25/17 - #(25369636): postprocess_stats signature change
Rem    cwidodo     03/29/17 - #(25547690): fix configure_advisor_filter 
Rem                           description
Rem    yuyzhang    02/08/17 - proj# 57499: overload the gather_table_stats
Rem                           procedure to a function
Rem    schakkap    08/14/16 - #(22498954): fix stats advisor comments
Rem    hosu        07/18/16 - 24310144: make null_numtab a constant
Rem    ddas        06/16/16 - #(21480262) add save_inmemory_stats()
Rem    hosu        12/07/15 - add comments for new incremental_staleness
Rem                           preference value
Rem    schakkap    11/03/15 - #(21306422) Add WAIT_TIME_TO_UPDATE_STATS
Rem    schakkap    11/02/15 - #(22081245) Add UPDATE_GLOBAL_STATS
Rem    makataok    06/25/15 - 21253805: column_need_hist prototype change
Rem    ddas        06/17/15 - proj 47170: persistent IMC statistics
Rem    schakkap    06/12/15 - #(21171382) add auto_stat_extensions preferece
Rem    makataok    05/26/15 - #20921713: column_need_hist
Rem    karpurus    05/05/15 - #(20853862) Modify signatue of
Rem                           get/set_table_stats
Rem    karpurus    04/03/15 - #(20562261):postprocess_stats signature change
Rem    jiayan      10/15/14 - Proj 48821: add new preference 
Rem                           APPROXIMATE_NDV_ALGORITHM
Rem    jmuller     10/06/14 - Fix bug 18376894 (sort of): publicize
Rem                           quick_estimate_rowcnt()
Rem    jiayan      12/01/14 - proj 44162: add preference_overrides_parameter
Rem                           and new statistics advisor procedures
Rem    jiayan      09/15/14 - proj 44162: Stats Advisor
Rem    schakkap    07/15/14 - proj 46828: Add scan rate
Rem    schakkap    05/09/14 - #(18720801) add stat_category preference
Rem    hosu        02/05/14 - 17946915: add comments for 'gather auto' options
Rem                           in gather_dictionary/database/schema_stats
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    avangala    08/06/13 - Bug 16851194: add RECLAIM_SYNOPSIS
Rem    hosu        08/02/13 - 17264990: USER name in *_pending_stats defaults
Rem                           to null
Rem    jiayan      06/16/13 - #(16694760): add support for pending system stats
Rem    sylin       05/22/13 - long identifiers
Rem    sepeng      03/15/13 - #(16475397): use get_prefs instead of get_param
Rem                           to get correct DOP/method_opt
Rem    acakmak     10/30/12 - update comments on StatRec.bkvals
Rem    schakkap    09/19/12 - #(14607573) fix comments of copy_table_stats
Rem    schakkap    08/13/12 - #(14471033) add transfer_stats
Rem    hosu        06/26/12 - 14022989: add options preference for
Rem                           gather_table_stats
Rem    acakmak     06/25/12 - Modify comments on concurrent stats gathering
Rem                           preference values
Rem    hosu        06/11/12 - 9735061: add stat_category to delete_*_stats
Rem    hosu        06/11/12 - 14029064: postprocess_stats signature change
Rem    hosu        05/11/12 - 13957757: introduce incremental_staleness pref
Rem    schakkap    05/02/12 - #(13967041) add comment on time_limit
Rem    hosu        05/01/12 - 14008020: gen_selmap signature change
Rem    mzait       04/30/12 - #(10248538) gather_system_stats - EXADATA value
Rem                           for gather_mode parameter
Rem    hosu        04/04/12 - lrg 6698831: add incremental_level preference
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    acakmak     03/16/12 - #13816872: support limiting stats reports to
Rem                           include latest N operations
Rem    acakmak     11/04/11 - change default format to TEXT in reporting
Rem                           functions
Rem    mzait       10/27/11 - #(13262857) add preference for LRU size to
Rem                           compute clustering factor
Rem    hosu        10/10/11 - change signature of gen_selmap
Rem    savallu     09/23/11 - p#(autodop_31271): gather processing rates
Rem    savallu     09/15/11 - p#(autodop_31271): Add functions
Rem    acakmak     08/29/11 - project 31794: New histogram types
Rem    schakkap    09/14/11 - #(9316756) export and import for datapump
Rem    acakmak     07/31/11 - project 31794: concurrent stats gathering
Rem    hosu        07/11/11 - project 31794: more schema level types for online
Rem                           stats gathering support
Rem    acakmak     04/24/11 - #(10279045): add PURGE_ALL 
Rem    jmuller     10/21/10 - Fix bug 8643797: compilation warnings
Rem    hosu        03/31/11 - project 31794: online stats gathering
Rem    mzait       10/12/10 - #(10194490) import statistics as pending if
Rem                           publish is false
Rem    schakkap    05/18/10 - #(9577300) add create_extended_stats overload
Rem                           reset_col_usage, report_col_usage
Rem    hosu        05/17/10 - 8733965: add stat_category to
Rem                           import/export_*_stats
Rem    schakkap    03/10/09 - #(7116357) fix APPROX_GLOBAL definition
Rem    hosu        11/03/08 - add comments for import_*_stats
Rem    mzait       08/20/08 - #(7116357) document extension to APPROX_GLOBAL
Rem    schakkap    04/25/08 - #(6221403) add comments about compatible param
Rem                           requirements when creating extension
Rem    mzait       03/21/08 - add seed_column_usage
Rem    schakkap    02/07/08 - add/fix comments
Rem    mzait       01/16/08 - #(6718212) add merge_col_usage
Rem    mzait       05/03/07 - publish_pending_stats - add no_invalidate 
Rem                           parameter delete_pending_stats  - null is default
Rem                           for tabname
Rem    schakkap    06/16/07 - lrg-2936177: convert diff stats to a table
Rem                           function
Rem    hosu        05/10/07 - obsolete reset_param_defaults; add reset_global
Rem                           _pref_defaults
Rem    hosu        05/10/07 - add obj_filter_list for gathering stats on a 
Rem                           group of objects
Rem    hosu        04/19/07 - change parameters related to default 
Rem                           preferences
Rem    mzait       05/02/07 - changes comments to remove reference to private
Rem                           stats
Rem    hosu        01/09/07 - update comments
Rem    mzait       02/08/07 - replace private by pending
Rem    mzait       09/01/06 - add diff_private_stats
Rem    femekci     10/30/06 - Adding the scale factor to copy_table_stats()
Rem    schakkap    09/28/06 - add comments for *extended_stats procedures
Rem    mzait       09/04/06 - fix spec of new procedures
Rem    schakkap    05/09/06 - extended stats 
Rem    mzait       05/30/06 - Support for separation between gather and 
Rem                           publish 
Rem    mzait       05/06/06 - Add support to USE the statistics preferences 
Rem    mzait       05/04/06 - Add support for statistics preferences
Rem    schakkap    03/21/05 - add diff stats procedures 
Rem    schakkap    10/02/06 - col_stat_type argument to delete_column_stats
Rem    schakkap    03/03/05 - #(4219954) force for gather*stats 
Rem    mtakahar    09/15/04 - add cleanup_stats_job_proc
Rem    schakkap    09/01/04 - #(3867864): no_invalidate for restore 
Rem    schakkap    06/03/04 - add reset_param_defaults 
Rem    dgagne      06/23/04 - allow stats table to be global temporary 
Rem    schakkap    12/23/03 - add comments for restore 
Rem    schakkap    12/09/03 - granularity and AUTOSTATS_TARGET for set_param
Rem    schakkap    10/28/03 - AUTO_INVALIDATE
Rem    schakkap    09/29/03 - [get|set]_param 
Rem    schakkap    08/26/03 - lock, copy partition stats 
Rem    schakkap    08/04/03 - gather_sys => true
Rem    schakkap    06/02/03 - make stats retention configurable
Rem    schakkap    01/15/03 - restore stats
Rem    mtyulene    01/07/03 - add gather cache stats
Rem    schakkap    12/31/02 - lock/unlock statistics
Rem    mtakahar    09/10/02 - automated statistics collection
Rem    schakkap    11/20/02 - statistics on dictionary
Rem    mtyulene    10/03/02 - add support for cache stats
Rem    mdcallag    10/22/02 - support binary_float and binary_double
Rem    schakkap    09/09/02 - gather/delete/export/import_fixed_objects_stats
Rem    mtakahar    09/25/02 - add AUTO_DEGREE/granularity='AUTO'
Rem    mtakahar    08/07/02 - make alter_*_tab_monitoring no-op
Rem    mtyulene    01/22/02 - change default gathering_mode in 
Rem                           gather_system_stats to NOWORKLOAD
Rem    mtakahar    01/31/02 - #(2200979): removed gather_index_stats overload
Rem    schakkap    10/12/01 - add gather_fixed.
Rem    mtakahar    10/15/01 - remove 'drop role gather_system_statistics'
Rem    ayoaz       09/24/01 - support user statistics
Rem    mtakahar    09/26/01 - gather_index_stats enhancements
Rem    mtakahar    07/20/01 - IOT guess quality
Rem    mtakahar    07/23/01 - #(1107252): add gather_temp
Rem    mtyulene    05/30/01 - #(1805416): create role gather_system_statistics 
Rem    gviswana    05/24/01 - CREATE OR REPLACE SYNONYM
Rem    mtakahar    03/28/01 - alter_*_tab_monitoring
Rem    mtakahar    03/26/01 - flush_database_monitoring_info
Rem    mtakahar    02/14/01 - add no_invalidate
Rem    mtakahar    02/20/01 - add gather_sys arg
Rem    mtakahar    11/15/00 - add options=>'GATHER AUTO' and 'LIST AUTO'
Rem    mtakahar    10/17/00 - add DEFAULT_DEGREE
Rem    mtyulene    09/05/00 - add *_system_stats procedures
Rem    amozes      07/28/99 - simple gather stats                              
Rem    amozes      06/15/99 - #(909413) split create_stat_table errors         
Rem    amozes      03/08/99 - add upgrade_stat_table                           
Rem    amozes      10/29/98 - bug 755475: string buffer to small               
Rem    amozes      10/21/98 - bug 598799
Rem    amozes      09/11/98 - add statown to most procedures                   
Rem    amozes      07/22/98 - add generate stats functionality                 
Rem    ncramesh    08/07/98 - change for sqlplus
Rem    amozes      06/16/98 - add dbms_stats library                           
Rem    ddas        05/06/98 - add purity pragmas
Rem    amozes      04/30/98 - auto_gather_stats feature support                
Rem    amozes      03/26/98 - new subpartition and func index options          
Rem    amozes      03/23/98 - allow flags to be passed in for import           
Rem    amozes      02/16/98 - delete functionality
Rem    amozes      01/14/98 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql


create or replace package dbms_stats authid current_user is

--
-- This package provides a mechanism for users to view and modify
-- optimizer statistics gathered for database objects.
-- The statistics can reside in two different locations:
--  1) in the dictionary
--  2) in a table created in the user's schema for this purpose
-- Only statistics stored in the dictionary itself will have an
-- impact on the cost-based optimizer.
--
-- This package also facilitates the gathering of some statistics 
-- in parallel.
-- 
-- The package is divided into three main sections:
--  1) procedures which set/get individual stats.
--  2) procedures which transfer stats between the dictionary and
--     user stat tables.
--  3) procedures which gather certain classes of optimizer statistics
--     and have improved (or equivalent) performance characteristics as 
--     compared to the analyze command.
--
-- Most of the procedures include the three parameters: statown,
-- stattab, and statid.  
-- These parameters are provided to allow users to store statistics in 
-- their own tables (outside of the dictionary) which will not affect 
-- the optimizer.  Users can thereby maintain and experiment with "sets" 
-- of statistics without fear of permanently changing good dictionary 
-- statistics.  The stattab parameter is used to specify the name of a 
-- table in which to hold statistics and is assumed to reside in the same
-- schema as the object for which statistics are collected (unless the
-- statown parameter is specified).  Users may create 
-- multiple such tables with different stattab identifiers to hold separate 
-- sets of statistics.  Additionally, users can maintain different sets of 
-- statistics within a single stattab by making use of the statid 
-- parameter (which can help avoid cluttering the user's schema).
--
-- For all of the set/get procedures, if stattab is not provided (i.e., null), 
-- the operation will work directly on the dictionary statistics; therefore, 
-- users need not create these statistics tables if they only plan to 
-- modify the dictionary directly.  However, if stattab is not null, 
-- then the set/get operation will work on the specified user statistics 
-- table, not the dictionary.
--
-- lock_*_stats/unlock_*_stats procedures: When statistics on a table is
-- locked, all the statistics depending on the table, including table
-- statistics, column statistics, histograms and statistics on all
-- dependent indexes, are considered to be locked. 
-- set_*, delete_*, import_*, gather_* procedures that modify statistics
-- in dictionary of an individual table/index/column will raise an error 
-- if statistics of the object is locked. Procedures that operates on
-- multiple objects (eg: gather_schema_stats) will skip modifying the
-- statistics of an object if it is locked. Most of the procedures have
-- force argument to override the lock. 
-- 
-- Whenever statistics in dictionary are modified, old versions of statistics 
-- are saved automatically for future restoring. Statistics can be restored 
-- using RESTORE procedures. These procedures use a time stamp as an argument 
-- and restore statistics as of that time stamp.
-- There are dictionary views that display the time of statistics 
-- modifications. These views are useful in determining the time stamp to 
-- be used for statistics restoration. 
--
--     Catalog view DBA_OPTSTAT_OPERATIONS contain history of 
--     statistics operations performed at schema and database level 
--     using DBMS_STATS. 
--
--     The views *_TAB_STATS_HISTORY views (ALL, DBA, or USER) contain 
--     history of table statistics modifications. 
--
-- The old statistics are purged automatically at regular intervals based on 
-- the statistics history retention setting and the time of the recent 
-- analyze of the system. Retention is configurable using the
-- ALTER_STATS_HISTORY_RETENTION procedure. The default value is 31 days, 
-- which means that you would be able to restore the optimizer statistics to 
-- any time in last 31 days. 
-- Automatic purging is enabled when STATISTICS_LEVEL parameter is set 
-- to TYPICAL or ALL. If automatic purging is disabled, the old versions 
-- of statistics need to be purged manually using the PURGE_STATS procedure. 
--
-- Other related functions:
--   GET_STATS_HISTORY_RETENTION: This function can be used to get the 
--     current statistics history retention value. 
--   GET_STATS_HISTORY_AVAILABILITY: This function gets the oldest time stamp 
--     where statistics history is available. Users cannot restore statistics 
--     to a time stamp older than the oldest time stamp. 
--
--
-- When a dbms_stats subprogram modifies or deletes the statistics
-- for an object, all the dependent cursors are invalidated by
-- default and corresponding statements are subject to recompilation
-- next time so that new statistics have immediate effects.  This
-- behavior can be altered with the no_invalidate argument when
-- applicable.
--
-- Extended Statistics: This package allows you to collect statistics for
-- column groups and expressions (known as "statistics extensions"). The
-- statistics collected for column groups and expressions are called
-- "extended statistics". Statistics on Column groups are used by optimizer for
-- accounting correlation between columns. For example, if query has predicates
-- c1=1 and c2=1 and if there are statistics on (c1, c2), optimizer will use
-- this statistics for estimating the combined selectivity of the predicates.
-- The expression statistics are used by optimizer for estimating selectivity 
-- of predicates on those expressions. The extended statistics are similar to
-- column statistics and the procedures that take columns names will accept
-- extension names in place of column names.
--
-- The following procedures can be used for managing extensions.
--      create_extended_stats    - create extensions manually or based on
--                                 groups of columns seen in workload.
--      drop_extended_stats      - drop an extension
--      show_extended_stats_name - show name of an extension
--
--      seed_col_usage           - record usage of column (group)s in a
--                                 workload
--      reset_col_usage          - delete recorded column (group)s usage
--                                 information
--      report_col_usage         - generate a report of column group(s) 
--                                 usage.
--
-- Comparing statistics:
--
-- diff_table_stats_* functions can be used to compare statistics for a table
-- from two different sources. The statistics can be from
--
--   - two different user statistics tables
--   - a single user statistics table containing two sets of
--     statistics that can be identified using statid's
--   - a user statistics table and dictionary
--   - history
--   - pending statistics

-- The functions also compares the statistics of the dependent objects
-- (indexes, columns, partitions).
-- They displays statistics of the object(s) from both sources if the
-- difference between those statistics exceeds a certain threshold (%).
-- The threshold can be specified as an argument to the function, with
-- a default of 10%.
-- The statistics corresponding to the first source (stattab1 or time1)
-- will be used as basis for computing the diff percentage.
--
-- Pending Statistics:
--
-- Optimizer statistics are gathered and saved in a pending state for tables 
-- that have FALSE value for the PUBLISH preference (see set_*_prefs()).
-- The default value of the PUBLISH preference is TRUE.
-- Pending statistics can be published, exported, or deleted. 
-- See the section corresponding to each of these procedures for details.
-- 
-- Pending statistics are not used by the Query Optimizer unless parameter 
-- optimizer_use_pending_statistics is set to TRUE (system or session level). 
-- The default value of this parameter is FALSE. 
-- Pending statistics provide a mechanism to verify the impact of the new 
-- statistics on query plans before making them available for general use.
--
-- There are two scenarios to verify the query plans:
-- 1. export the pending statistics (use export_pending_stats) to a test 
--    system, then run the query workload and check the performance or plans.
-- 2. set optimizer_use_pending_statistics to TRUE in a session on the system
--    where pending statistics have been gathered, run the workload, and
--    check the performance or plans.
--
-- Once the performance or query plans have been verified, the pending 
-- statistics can be published (run publish_pending_stats) if the performance 
-- are acceptable or delete (run delete_pending_stats) if not.
--
-- Related procedures:
--   publish_pending_stats
--   export_pending_stats
--   delete_pending_stats 
--
-- Calibration Statistics (Processing Rates):
-- 
-- The calibration statistics or the processing rates are added as part of the
-- AutoDOP project. They are used to compute the DOP based on the CPU 
-- cost of the operators in the plan. These stats are exposed using the view
-- v$optimizer_processing_rate. The PL/SQL procedures which can be used
-- to manipulate them are set_processing_rate(), delete_processing_rate() and
-- gather_processing_rate(). There are three sources to these stats:
-- default (default values), manual (set by the user using 
-- set_processing_rate()), calibration (values obtained by running 
-- gather_processing_rate()).
-- 
-- Nearly all the procedures in this package (more specifically, the
-- set_*, delete_*, export_*, import_*, gather_*, and *_stat_table
-- procedures) commit the current transaction, perform the operation, 
-- and then commit again.
--

/* 
  Optimizer Statistics Advisor:
  
  The Optimizer Statistics Advisor is a tool that helps users pick the best
  practices to manage Optimizer Statistics. It analyzes the following areas 
  in the system:
  - the way the user is gathering statistics
  - automatic statistics collection
  - the quality of statistics already gathered
  and generate findings for any issues it finds. Based on these findings, the
  statistics advisor will provide recommendations, rationale for the 
  recommendations and the actions to be taken.

  The advisor has a set of rules, and generate the finding based on the results
  of each rule check. The rules are divided into three levels:
  - system level rules: 
      check for statistics issues on the system level, such as auto statistics
      job does not finish
  - operation level rules:
      check for issues related to satistics operations, such as the usage of 
      set_table_stats operations, the usage of non-default parameters, etc.
  - object level rules:
      check for statistics related issues for each object, such as object 
      statistics staleness


  Example Usage of the Statistics Advisor:

  declare
    tname   VARCHAR2(128) := 'my_task';
    ename   VARCHAR2(128) := NULL;
    report clob := null;
    script clob := null;
    implementation_result clob;
  begin

  -- create a task
  tname := dbms_stats.create_advisor_task(tname);

  -- execute the task
  ename := dbms_stats.execute_advisor_task(tname);

  -- view the task report
  report := dbms_stats.report_advisor_task(tname);
  dbms_output.put_line(report);

  -- implement the recommendation from the task
  implementation_result := dbms_stats.implement_advisor_task(tname);

  end;


  The statistics advisor provides the following procedures:

  create_advisor_task: create a statistics advisor task
  execute_advisor_task: executes a statistics advisor task
  report_advisor_task: reports the results of an advisor task
  script_advisor_task: get the script of an advisor task that 
                       implements its recommendations
  implement_advisor_task: implements the recommendations from an advisor task
  configure_advisor_filter: configures the filter for the advisor task,
                            which controls the scope of the advisor check
  get_advisor_opr_filter: get an operation filter for the advisor task
  set_advisor_task_param: set advisor task parameter
  drop_advisor_task: drop an advisor task
  interrupt_advisor_task: interrputs an executing advisor task
  cancel_advisor_task: cancels an advisor task
  reset_adsvisor_task: resets an advisor task
  resume_advisor_task: resume an interrupted advisor task
  
  See each individual API below for more detailed information.

  
  Privilege / Security model of the statistics advisor:

  _ All statistics advisor APIs require ADVISOR privilege.
    
  - Once the task is created, the APIs that operate on task are only allowed
    to be executed by the owner of the task. Also users are allowed to generate 
    report, script, and implement recommendations of the oracle predefined 
    advisor task created out of the box, 'AUTO_STATS_ADVISOR_TASK'.
    
  - The result of the operations, execute/report/script/implement, depends on 
    the privilege of the user, as described below.
    - system level
      Only users with both "analyze any" and "analyze any dictionary" will
      be able to perform the operation on system level rules
    - operation level
      - users with both "analyze any" and "analyze any dictionary" will be able
        to execute/report/script/implement for all statistics operations
      - users with only "analyze any" will be able to execute/report/script/
        implement on statistics operations related to any schemas except sys, 
        as well as their own schema
      - users with only "analyze any dictionary" will be able execute/report/
        script/implement on statistics operations related to the sys schema, 
        as well as their own schema
      - users with neither "analyze any" or "analyze any dictionary" will only
        be able to execute/report/script/implement on statistics operations 
        on their own schema
    - object level
      users will be able to execute/report/script/implement on any object on 
      which they have privilege to collect statistics

  - all procedures will executed be using the invoker's privilege for that
    operation instead of the task owner's privilege. For example, if someone 
    without "analyze_any_dictionary" privilege creates a task t1, then the dba
    comes and executes the task, then the execution will check for sys objects 
    too. A case to note is the following scenario: a task is executed by
    one user, interrupted, and later resumed by another user. In that case, 
    the checks of the resumed execution will be based on the privilege of the 
    second user who resumed the task, instead of the first user who executed
    the task.
  
*/

-- types for minimum/maximum values and histogram endpoints
type numarray is varray(2050) of number;
type datearray is varray(2050) of date;
type chararray is varray(2050) of varchar2(4000);
type rawarray is varray(2050) of raw(2000);
type fltarray is varray(2050) of binary_float;
type dblarray is varray(2050) of binary_double;

type StatRec is record (
  epc    number,
  minval raw(2000),
  maxval raw(2000),
  bkvals numarray,
  novals numarray,
  chvals chararray, 
  eavals rawarray,
  rpcnts numarray,
  eavs   number);

-- type for objects whose statistics may be gathered
-- make sure to maintain satisfy_obj_filter when ObjectElem type
-- is changed
type ObjectElem is record (
  ownname     dbms_quoted_id,   -- owner
  objtype     varchar2(6),      -- 'TABLE' or 'INDEX'
  objname     dbms_quoted_id,   -- table/index
  partname    dbms_quoted_id,   -- partition
  subpartname dbms_quoted_id    -- subpartition
);
type ObjectTab is table of ObjectElem;

-- type for Statistics Operation
TYPE StatsAdvOpr IS RECORD
(name       varchar2(64),    -- name of the operation
 param      varchar2(4000)); -- xml containing parameters and their values

TYPE StatsAdvOprTab IS TABLE OF StatsAdvOpr;

-- filter list type
TYPE StatsAdvFilter IS RECORD
(rulename   varchar2(64),   -- rule name
 objlist    ObjectTab,      -- object filter list
 oprlist    StatsAdvOprTab, -- operation filter list
 include    boolean);       -- include/exclude elements in the list

-- table type of the filter list
TYPE StatsAdvFilterTab IS TABLE OF StatsAdvFilter;

-- type for displaying stats difference report
type DiffRepElem is record (
  report     clob,              -- stats difference report
  maxdiffpct number);           -- max stats difference (percentage)
type DiffRepTab is table of DiffRepElem;

-- type for gather_table_stats context -- internal only
type CContext is varray(30) of varchar2(4000);
CCTX_SIZE CONSTANT NUMBER := 30;

-- oracle decides whether to collect stats for indexes or not
AUTO_CASCADE CONSTANT BOOLEAN := null;

-- oracle decides when to invalidate dependend cursors
AUTO_INVALIDATE CONSTANT BOOLEAN := null;

-- constant used to indicate auto sample size algorithms should
-- be used.
AUTO_SAMPLE_SIZE        CONSTANT NUMBER := 0;

-- constant to indicate use of the system default degree of
-- parallelism determined based on the initialization parameters.
DEFAULT_DEGREE          CONSTANT NUMBER := 32767;
-- force serial execution if the object is relatively small.
-- use the system default degree of parallelism otherwise.
AUTO_DEGREE             CONSTANT NUMBER := 32768;
-- DEFAULT_DEGREE_VALUE is defined as 32766;
-- NVL_TABPREF_AUTO_DEGREE (used in prvtstat.sql) is defined as 32765;
-- make sure any new degree values do not conflict with the existing
-- values

-- constant used to specify that we want the table cached block 
-- to be automatically computed
AUTO_TABLE_CACHED_BLOCKS CONSTANT INTEGER := 0;


--
-- Default values for key parameters passed to dbms_stats procedures
-- These values are specified in the DEFAULT clause when declaring the
-- corresponding parameter in any of the dbms_stats procedures.
--
DEFAULT_CASCADE          CONSTANT BOOLEAN  := null;
DEFAULT_DEGREE_VALUE     CONSTANT NUMBER   := 32766;
DEFAULT_ESTIMATE_PERCENT CONSTANT NUMBER   := 101;
DEFAULT_METHOD_OPT       CONSTANT VARCHAR2(1) := 'Z';
DEFAULT_NO_INVALIDATE    CONSTANT BOOLEAN     := null;
DEFAULT_GRANULARITY      CONSTANT VARCHAR2(1) := 'Z';
DEFAULT_PUBLISH          CONSTANT BOOLEAN     := true;
DEFAULT_INCREMENTAL      CONSTANT BOOLEAN     := false;
DEFAULT_STALE_PERCENT    CONSTANT NUMBER      := 10;
DEFAULT_AUTOSTATS_TARGET CONSTANT VARCHAR2(1) := 'Z';
DEFAULT_STAT_CATEGORY    CONSTANT VARCHAR2(100) := 'Z';
DEFAULT_DEL_STAT_CATEGORY CONSTANT VARCHAR2(100) := 'OBJECT_STATS, SYNOPSES';
                               -- delete both object stats and synopses
DEFAULT_OPTIONS          CONSTANT VARCHAR2(1) := 'Z';
DEFAULT_ROOT_TRIGGER_PDB     CONSTANT BOOLEAN     := false; 
DEFAULT_COORD_TRIGGER_SHARD CONSTANT BOOLEAN  := false;
-- options in transfer_stats
ADD_GLOBAL_PREFS         CONSTANT NUMBER := 1;  
                                   -- transfer global preferences etc

--
-- Defining the options for EXPORT_STATS_FOR_DP
--
DP_OPTIONS_FULL          CONSTANT NUMBER :=  ADD_GLOBAL_PREFS;  
                                   -- full data pump export or import

-- Constant which is used as an indicator that purge_stats should
-- purge everything (i.e., truncate) in stats history tables.
PURGE_ALL CONSTANT TIMESTAMP WITH TIME ZONE := 
 TO_TIMESTAMP_TZ('1001-01-0101:00:00-00:00','YYYY-MM-DDHH:MI:SSTZH:TZM');

-- Constant which is used for reclaiming synopsis table space
RECLAIM_SYNOPSIS CONSTANT TIMESTAMP WITH TIME ZONE := 
 TO_TIMESTAMP_TZ('1002-01-0101:00:00-00:00','YYYY-MM-DDHH:MI:SSTZH:TZM');

-- Flags used in copy_table_stats procedure
UPDATE_GLOBAL_STATS CONSTANT BINARY_INTEGER := 8;

--
-- This set of procedures enable the storage and retrieval of 
-- individual column-, index-, table- and system-  related statistics
--
-- The procedures are:
--
--  prepare_column_values*
--
--  set_column_stats
--  set_index_stats
--  set_table_stats
--  set_system_stats
--
--  convert_raw_value*
--
--  get_column_stats
--  get_index_stats
--  get_table_stats
--  get_system_stats
--
--  delete_column_stats
--  delete_index_stats
--  delete_table_stats
--  delete_schema_stats
--  delete_database_stats
--  delete_system_stats
--  delete_fixed_objects_stats
--  delete_dictionary_stats
--
 
  procedure prepare_column_values(
        srec in out NOCOPY StatRec, charvals chararray);
  pragma restrict_references(prepare_column_values, WNDS, RNDS, WNPS, RNPS);
  procedure prepare_column_values(
        srec in out NOCOPY StatRec, datevals datearray);
  pragma restrict_references(prepare_column_values, WNDS, RNDS, WNPS, RNPS);
  procedure prepare_column_values(
        srec in out NOCOPY StatRec, numvals numarray);
  pragma restrict_references(prepare_column_values, WNDS, RNDS, WNPS, RNPS);
  procedure prepare_column_values(
        srec in out NOCOPY StatRec, fltvals fltarray);
  pragma restrict_references(prepare_column_values, WNDS, RNDS, WNPS, RNPS);
  procedure prepare_column_values(
        srec in out NOCOPY StatRec, dblvals dblarray);
  pragma restrict_references(prepare_column_values, WNDS, RNDS, WNPS, RNPS);
  procedure prepare_column_values(
        srec in out NOCOPY StatRec, rawvals rawarray);
  pragma restrict_references(prepare_column_values, WNDS, RNDS, WNPS, RNPS);
  procedure prepare_column_values_nvarchar(
        srec in out NOCOPY StatRec, nvmin nvarchar2, nvmax nvarchar2);
  pragma restrict_references(prepare_column_values, WNDS, RNDS, WNPS, RNPS);
  procedure prepare_column_values_rowid(
        srec in out NOCOPY StatRec, rwmin rowid, rwmax rowid);
  pragma restrict_references(prepare_column_values, WNDS, RNDS, WNPS, RNPS);
--
-- Convert user-specified minimum, maximum, and histogram endpoint
-- datatype-specific values into Oracle's internal representation 
-- for future storage via set_column_stats.
--
-- Generic input arguments:
--   srec.epc - The number of values specified in charvals, datevals,
--      numvals, or rawvals.  This value must be between 2 and 2050 inclusive.
--      Should be set to 2 for procedures which don't allow histogram
--      information (nvarchar and rowid).
--      The first corresponding array entry should hold the minimum 
--      value for the column and the last entry should hold the maximum.
--      If there are more than two entries, then all the others hold the
--      remaining histogram endpoint values
--      (with in-between values ordered from next-smallest to next-largest).  
--      This value may be adjusted to account for compression, so the
--      returned value should be left as is for a call to set_column_stats.
--   srec.bkvals - If a frequency or hybrid histogram is desired, this array
--      contains the number of occurrences of each distinct value specified in
--      charvals, datevals, numvals, or rawvals.  Otherwise, it is merely an
--      output argument and must be set to null when this procedure is
--      called.
--   srec.rpcnts - If a hybrid histogram is desired, this array contains
--      the total frequency of values that are less than or equal to each 
--      distinct value specified in  charvals, datevals, numvals, or rawvals.  
--      Otherwise, it is merely an output argument and must be set to null 
--      when this procedure is called.
--         As an example, for a given array numvals with numvals(i)=4, 
--         rpcnts(i)=13 means that there are 13 rows in the column which
--         are less than or equal to 4.
--
--    ** Note that whenever srec.rpcnts is populated, srec.bkvals must be
--       populated as described above, too.
--
--    ** Also note that, whenever bkvals and/or rpcnts are populated, there 
--       should not be any duplicates in charvals, datevals, numvals, or 
--       rawvals.
--        
--
-- Datatype specific input arguments (one of these):
--   charvals - The array of values when the column type is character-based.
--      Up to the first 64 bytes of each string should be provided.
--      Arrays must have between 2 and 2050 entries, inclusive.
--      If the datatype is fixed char, the strings must be space padded
--      to 15 characters for correct normalization.
--   datevals - The array of values when the column type is date-based.
--   numvals - The array of values when the column type is numeric-based.
--   rawvals - The array of values when the column type is raw.
--      Up to the first 64 bytes of each strings should be provided.
--   nvmin,nvmax - The minimum and maximum values when the column type
--      is national character set based (NLS).  No histogram information
--      can be provided for a column of this type.
--      If the datatype is fixed char, the strings must be space padded
--      to 15 characters for correct normalization.
--   rwmin,rwmax - The minimum and maximum values when the column type
--      is rowid.  No histogram information can be provided for a column 
--      of this type.
--
-- Output arguments:
--   srec.minval - Internal representation of the minimum which is
--      suitable for use in a call to set_column_stats.
--   srec.maxval - Internal representation of the maximum which is
--      suitable for use in a call to set_column_stats.
--   srec.bkvals - array suitable for use in a call to set_column_stats.
--   srec.novals - array suitable for use in a call to set_column_stats.
--   srec.eavals - array suitable for use in a call to set_column_stats.
--   srec.rpcnts - array suitable for use in a call to set_column_stats.
--
-- Exceptions:
--   ORA-20001: Invalid or inconsistent input values
--

  procedure set_param(
    pname in varchar2,
    pval  in varchar2);
--
--  WARNING ** WARNING ---> obsoleted <--- WARNING  ** WARNING 
--     Please use SET_GLOBAL_PREFS() instead.
--  WARNING ** WARNING ---> obsoleted <--- WARNING  ** WARNING 
--
-- This procedure can be used to set default value for parameters 
-- of dbms_stats procedures.
--
-- The function get_param can be used to get the current
-- default value of a parameter. 
--
-- To run this procedure, you must have the SYSDBA OR 
-- both ANALYZE ANY DICTIONARY and ANALYZE ANY system privilege. 
--
-- Input arguments:
--   pname   - parameter name
--             The default value for following parameters can be set.
--                CASCADE - The default value for CASCADE set by set_param
--                          is not used by export/import procedures.
--                          It is used only by gather procedures.
--                DEGREE 
--                ESTIMATE_PERCENT
--                METHOD_OPT
--                NO_INVALIDATE
--                GRANULARITY
--                AUTOSTATS_TARGET
                        -- This parameter is applicable only for auto stats
--                         collection. The value of this parameter controls
--                         the objects considered for stats collection
--                         It takes the following values
--                         'ALL'    -- statistics collected 
--                                     for all objects in system
--                         'ORACLE' -- statistics collected 
--                                     for all oracle owned objects
--                         'AUTO'   -- oracle decide which objects 
--                                     to collect stats
--   pval    - parameter value. 
--             if null is specified, it will set the oracle default value
--
-- Notes:
--   Both arguments are of type varchar2 and values are enclosed in quotes,
--   even when they represent numbers
--
-- Examples:
--        dbms_stats.set_param('CASCADE','DBMS_STATS.AUTO_CASCADE');
--        dbms_stats.set_param('ESTIMATE_PERCENT','5');
--        dbms_stats.set_param('DEGREE','NULL');
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--   ORA-20001: Invalid or Illegal input values
--

  function get_param(
    pname   in varchar2) 
  return varchar2;
-- 
--  WARNING ** WARNING ---> obsoleted <--- WARNING  ** WARNING 
--     Please use GET_PREFS() instead.
--  WARNING ** WARNING ---> obsoleted <--- WARNING  ** WARNING 
--
-- Get default value of parameters of dbms_stats procedures 
--
-- Input arguments:
--   pname   - parameter name
--
-- Exceptions:
--   ORA-20001: Invalid input values
--

  procedure reset_param_defaults;
--
--  WARNING ** WARNING ---> obsoleted <--- WARNING  ** WARNING 
--     Please use RESET_GLOBAL_PREF_DEFAULTS() instead.
--  WARNING ** WARNING ---> obsoleted <--- WARNING  ** WARNING 
--
-- This procedure resets the default of parameters to ORACLE
-- recommended values.
--

  procedure reset_global_pref_defaults;
--
-- This procedure resets the global preference to the default values
--

  procedure set_global_prefs(
    pname   varchar2,
    pvalue  varchar2);
-- 
-- This procedure is used to set the global statistics preferences.
-- This setting is honored only of there is no preference specified
-- for the table to be analyzed.
-- 
-- To run this procedure, you need to have the SYSDBA OR 
-- both ANALYZE ANY DICTIONARY and ANALYZE ANY system privilege. 
--
-- Input arguments:
--   pname   - preference name
--             The default value for following preferences can be set.
--                CASCADE
--                DEGREE 
--                ESTIMATE_PERCENT
--                METHOD_OPT
--                NO_INVALIDATE
--                GRANULARITY
--                PUBLISH
--                INCREMENTAL
--                INCREMENTAL_LEVEL
--                INCREMENTAL_STALENESS
--                GLOBAL_TEMP_TABLE_STATS
--                STALE_PERCENT
--                AUTOSTATS_TARGET
--                CONCURRENT
--                TABLE_CACHED_BLOCKS
--                OPTIONS
--                STAT_CATEGORY
--                PREFERENCE_OVERRIDES_PARAMETER
--                APPROXIMATE_NDV_ALGORITHM
--                AUTO_STAT_EXTENSIONS
--                WAIT_TIME_TO_UPDATE_STATS
--                ROOT_TRIGGER_PDB
--                COORDINATOR_TRIGGER_SHARD
--
--   pvalue  - preference value. 
--             if null is specified, it will set the oracle default value.
--
--   
--  CASCADE: Please see CASCADE in gather_table_stats
--
--  DEGREE: Please see DEGREE in gather_table_stats
--
--  ESTIMATE_PERCENT: Please see ESTIMATE_PERCENT in gather_table_stats
--
--  METHOD_OPT: Please see METHOD_OPT in gather_table_stats
--
--  NO_INVALIDATE: Please see NO_INVALIDATE in gather_table_stats
--
--  GRANULARITY: Please see GRANULARITY in gather_table_stats
--
--  PUBLISH: The "PUBLISH" value determines whether or not newly gathered 
--    statistics will be published once the gather job has completed.  
--    Prior to 11g, once a statistic gathering job completed, the new 
--    statistics were automatically published into the dictionary tables. 
--    The user now has the ability to gather statistics but not publish 
--    them immediately. This allows the DBA to test the new statistics 
--    before publishing them.
--
--  INCREMENTAL: The "INCREMENTAL" value determines whether or not the global 
--    statistics of a partitioned table will be maintained without doing a 
--    full table scan. With partitioned tables it is very common to load new 
--    data into a new partition. As new partitions are added and data loaded, 
--    the global table statistics need to be kept up to date.  Oracle will 
--    update the global table statistics by scanning only the partitions that 
--    have been changed instead of the entire table if the following conditions
--    hold: (1) the INCREMENTAL value for the partitioned table is set to TRUE;
--    (2) the PUBLISH value for the partitioned table is set to TRUE; and
--    (3) the user specifies AUTO_SAMPLE_SIZE for estimate_percent and AUTO for
--    granularity when gathering statistics on the table.
--    If the INCREMENTAL value for the partitioned table was set to FALSE 
--    (default value), then a full table scan would be used to maintain the 
--    global statistics.
--
--  INCREMENTAL_LEVEL: INCREMENTAL_LEVEL controls what synopses to collect when
--    'INCREMENTAL' preference is set to 'TRUE'. It takes two values:
--      table -- table level synopses are gathered. This is used when user
--        wants to exchange this table with a partition. User can run
--        gather_table_stats on this table with 'INCREMENTAL' to 'TRUE'
--        and 'INCREMENTAL_LEVEL' to 'TABLE' before the exchange. Then table
--        level synopses are gathered on this table (for now we only support
--        table level synopses on non partitoned table). Then we do the
--        exchange. After the exchange, the partition will have synopses 
--        which come from the table level synopses of the table before 
--        exchange. This preference value can be only used in set_table_prefs. 
--        It is not allowed in set_global/database/schema_prefs.
--      partition -- partition level synopses are gathered. This is the 
--        default value. If 'partition' is set on a non partitioned table,
--        no synopses will be gathered.
--
--  INCREMENTAL_STALENESS: INCREMENTAL_STALENESS controls how we decide
--    a partition or subpartition as stale. It takes an enumeration of 
--    values, i.e., 'USE_STALE_PERCENT', 'USE_LOCKED_STATS' and 'ALLOW_
--    MIXED_FORMAT'. Multiple values are allowed, e.g., 'USE_STALE_PERCENT, 
--    USE_LOCKED_STATS, ALLOW_MIXED_FORMAT'
--    'USE_STALE_PERCENT': a partition/subpartition is NOT considered as 
--       stale if DML changes are less the stale_percent preference value
--    'USE_LOCKED_STATS': locked partitions/subpartitions stats are NOT
--       considered as stale, regardless of dml changes 
--    'ALLOW_MIXED_FORMAT': partitions with synopses in adaptive sampling
--    (AS) format are NOT considered as stale even when approximate_ndv_
--    algorithm preference is 'HYPERLOGLOG'
--    'NULL' - this means a partition/subpartition.
--    is considered as stale as long as it has any DML changes. When the 
--    default value is used, statistics gathered in incremental mode are 
--    guaranteed to be the same as the statistics gathered in non incremental
--    mode. When a non default value is used, the statistics gathered in
--    incremental mode might be less accurate than those gathered in non-
--    incremental mode.
--    The default value is 'ALLOW_MIXED_FORMAT'.
--    NOTE the following two are different.
--      command 1: dbms_stats.set_table_prefs('sh', 'sales', 
--                   'incremental_staleness', 'null');
--      command 2: dbms_stats.set_table_prefs('sh', 'sales',
--                   'incremental_staleness', null);
--    command 1 sets the preference value to 'null' while command 2 resets
--    the preference value to default which is 'ALLOW_MIXED_FORMAT'.
--    example of usage case:
--    case 1: stale_percent is 10; null is specified for incrmental_
--    staleness; a partition has 5% of DML changes. Statistics of the 
--    partition are regathered
--    case 2: stale_percent is 10; 'use_stale_percent' is specified; a 
--    partition has 5% of DML changes. Statistis of the partition are
--    NOT regathered
--    case 3: stale_percent is 10; 'use_stale_percent' is specified;
--    a partition has 20% of DML changes; the partition is also locked. 
--    The partition is considered as stale. Since it is locked, statistics 
--    are not regathered. We fall back to the non incremental mode for 
--    global statistics gathering
--    case 4: stale_percent is 10; 'use_stale_percent' is specified; a
--    partition has 5% of DML changes; the partition is also locked. 
--    The partition is not considered as stale and its statistics are
--    not gathered. Its existing statistics are used to derive global 
--    statistics
--    case 5: stale_percent is 10; 'use_locked_stats, use_stale_percent' is 
--    specified; a partition has 20% of DML changes; the partition is also 
--    locked. The partition is NOT considered as stale. Its existing statistics
--    are used to derive global statistics
--    case 6: approximate_ndv_algorithm is HLL. 'allow_mixed_format' is
--    specified. All partitions have synopses in old AS format. None 
--    partition is considered stale. Its existing synopses are used
--    to derive global NDV (auto job will regather stats on partitions 
--    with synospes of old AS format and replace them with synopses of
--    new HLL format).
--
--  GLOBAL_TEMP_TABLE_STATS: GLOBAL_TEMP_TABLE_STATS controls whether
--  the statistics gathered for a global temporary table should be stored
--  as shared statistics or session statistics. It takes two values:
--    'SHARED': all sessions can see the statistics
--    'SESSION': only the session in which the statistics are collected can
--               see the statistics
--
--  STALE_PERCENT: The "STALE_PERCENT" value determines the percentage of rows 
--    in a table that have to change before the statistics on that table are 
--    deemed stale and should be regathered. The default value is 10%. 
--
--  AUTOSTATS_TARGET
--    This preference is applicable only for auto stats collection. The value 
--    of this parameter controls the objects considered for stats collection.
--    It takes the following values
--    'ALL'    -- statistics collected  for all objects in system
--    'ORACLE' -- statistics collected  for all oracle owned objects
--    'AUTO'   -- oracle decide which objects   to collect stats
--
--  CONCURRENT
--    This preference determines whether the statistics of tables or
--    (sub)partitions of tables to be gathered concurrently when user issues
--    gather_*_stats procedures. DBMS_STATS has the ability to collect 
--    statistics for a single object (table, (sub)partition) in parallel
--    based on the value of degree parameter. However the parallelism is 
--    limited to one object. CONCURRENT preference extends the scope of 
--    "parallelization" to multiple database objects by enabling users to 
--    concurrently gather statistics for multiple tables in a schema/database 
--    and multiple (sub)partitions within a table. Note that this is primarily
--    intented for multi cpu systems and it may not be suitable for small 
--    databases on single cpu machines. 
--
--    To gather statistics concurrently, 
--       1. The user must have DBA role or have the following privileges in 
--          addition to privileges that are required for gathering statistics.
--              CREATE JOB, MANAGE SCHEDULER, MANAGE ANY QUEUE
--       2. Resource Manager should be enabled.
--       3. job_queue_processes parameter should be at least 4.
--
--    The preference takes the following values. 
--
--    MANUAL: Concurrency is enabled only for manual statistics gathering.
--    AUTOMATIC: Concurrency is enabled only for the auto statistics gathering.
--    ALL: Concurrency is enabled for all statistics gathering calls.
--    OFF: Concurrency is disabled (default).
--
--  TABLE_CACHED_BLOCKS
--    The average number of blocks cached in the buffer cache for any table
--    we can assume when gathering the index clustering factor.
--
--
--  OPTIONS
--    The preference determines the 'options' parameter used in 
--    gather_table_stats
--    The preference takes two values:
--      'GATHER' (default)  - Gather statistics for all objects in the table
--      'GATHER AUTO' - Gather statistics for objects having missing or empty
--                      statistics
--    We recommend setting 'GATHER AUTO' on tables that undergo bulk loads. 
--    Statistics gathering on load will automatically gather statistics during
--    bulk load. Gather_table_stats on these tables with 'gather auto' options
--    will skip regathering the already fresh statistics.
--
--  STAT_CATEGORY
--    The preferece determines category of statistics that will be exported or
--    imported using export_*_stats/import_*_stats/datapump. It accepts 
--    multiple values separated by comma. The values we support now are 
--    'OBJECT_STATS' (i.e., table statistics, column statistics and index 
--    statistics) and 'SYNOPSES'. However synopses can only be exported/
--    imported along with OBJECT_STATS. Therefore only valid combinations are 
--          OBJECT_STATS   (default value)
--          OBJECT_STATS, SYNOPSES
--    Note that the preference is not used in delete_*_stats procedures.
--
--  PREFERENCE_OVERRIDES_PARAMETER
--    This preference determines for a statistics operation, whether to 
--    override the input value of a parameter with the preference value 
--    of that parameter. 
--    Possible values are:
--    'FALSE'(default): input parameter values are obeyed
--    'TRUE': input parameter values are ignored, and the value of 
--            the corresponding preference is used.
--    Example:
--    If preference_overrides_parameter is set to 'TRUE', and the user issues 
--    the following statistics operation:
--
--      dbms_stats.gather_table_stats('SCOTT', 'EMP', estimate_percent=>100);
--
--    Suppose the user has specified a table preference for estimate_percent 
--    for table SCOTT.EMP 10, then that value will be used, and it will be 
--    equivalent to issuing the following operation:
--
--      dbms_stats.gather_table_stats('SCOTT', 'EMP', estimate_percent=>10);
--
--    If the user did not specify a table preference for estimate_percent, 
--    but has issued a global level preference value of 5, then it will be 
--    equivalent to issuing the following operation:
--
--      dbms_stats.gather_table_stats('SCOTT', 'EMP', estimate_percent=>5);
--
--    If the user did not specify any preference for estimate_percent,
--    then the default value for estimate_percent will be used. It will be 
--    equivalent to issuing the following opereation:
--
--      dbms_stats.gather_table_stats('SCOTT', 'EMP', 
--                   estimate_percent=>DBMS_STATS.AUTO_SAMPLE_SIZE);
--
--    The order of precedence is not changed if this preference is specified,
--    which is:
--    table preference > global preference > default
--
--  APPROXIMATE_NDV_ALGORITHM
--      Possible values for this preference are:
--        - HYPERLOGLOG: use Hyperloglog algorithm.
--
--        - ADAPTIVE SAMPLING: use adaptive sampling algorithm.
--
--        - REPEAT OR HYPERLOGLOG: 
--          If incremental stats maintenance is disabled on the partitioned 
--          table, then this preference is the same as 'HYPERLOGLOG'
--          If incremental stats maintenance is enabled on the partitioned
--          table:
--          - If the latest synopses gathered in this partitioned table uses
--            HYPERLOGLOG (ADAPTIVE SAMPLING respectively), then use 
--            HYPERLOGLOG (ADAPTIVE SAMPLING respectively) for statistics 
--            gathering.
--          - If no synopses exist yet for this partitioned table, then use
--            HYPERLOGLOG for statistics gathering.
--
--  AUTO_STAT_EXTENSIONS
--    This preference controls the automatic creation of extensions
--    while gathering (auto or manual) statistics. The values are
--
--     ON: extensions are created automatically as part of gathering 
--         statistics based on usage of columns in the predicates in 
--         the workload.
--
--     OFF: extensions are not created automatically. It will be created 
--         only when create_extended_stats API is executed or when 
--         extension is specified explicitly in method_opt clause of 
--         gather API. This is the default.
--
--  WAIT_TIME_TO_UPDATE_STATS
--    This preference specifies the wait time, in minutes, before
--    timing out for locks and pins required for updating statistics. 
--    It accepts values in the range, [0, 65535]. The default value is 
--    15 minutes. The special value  0 can be used to get the locks and 
--    pins in no-wait mode.
--
--  ROOT_TRIGGER_PDB
--    This preference is used by App PDB user to determine whether to allow App
--    Root to interfere in the statistics gathering in PDB.          
--    While gathering the statistics for a metadata linked table in App Root,
--    if the statistics in a PDB are stale, App Root will trigger the statistics
--    gathering in that PDB. User can execute or ignore that command from App
--    Root by using this preference.
--    Note: CDB Root, different from App Root, never triggers statistics
--          gathering on the PDBs and it is not controled by this preference.
--    Values are:
--    'TRUE':           allow the App Root trigger the statistics gathering on
--                      metadata linked table in App PDB if the statisitcs on
--                      PDB are stale.
--    'FALSE'(default): ignore the statistics gathering command triggered from
--                      App root.
--
--
--  COORDINATOR_TRIGGER_SHARD
--    This preference is used by user of each shard to determine whether to
--    allow shard coordinaotr to interfere in the statistics gathering in each
--    shards. While gathering the statistics in shard coordinator, if the
--    statistics in one of the shards are stale, shard coordinator will try to
--    trigger the statistics gathering in that shard. User can execute or ignore
--    that command from shard coordinator by using this preference.

--   Values are:
--   'TRUE':            allow the shard coordinator trigger the statistics
--                      gathering on sharded table in local shard if the 
--                      statistics on local shard arestale.
--   'FALSE'(default):  ignore the statistics gathering command triggered from
--                      shard coordinator.
--             
--
-- Notes:
--   Both arguments are of type varchar2 and values are enclosed in quotes,
--   even when they represent numbers
--
-- Examples:
--        dbms_stats.set_global_prefs('ESTIMATE_PERCENT','9');
--        dbms_stats.set_global_prefs('DEGREE','99');
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--   ORA-20001: Invalid or Illegal input values
--

  function get_prefs(
    pname   in varchar2,
    ownname in varchar2 default null,
    tabname in varchar2 default null) 
  return varchar2;
-- 
--
-- Get default value of the specified preference.
-- If the ownname and tabname are provided and a preference has been entered
-- for the table then it returns the preference as specified for the table.
-- In all other cases it returns the global preference, in case it has been 
-- specified, otherwise the default value is returned.
--
-- Input arguments:
--   pname   - preference name
--             The default value for following preferences can be retrieved.
--                CASCADE
--                DEGREE 
--                ESTIMATE_PERCENT
--                METHOD_OPT
--                NO_INVALIDATE
--                GRANULARITY
--                PUBLISH
--                INCREMENTAL
--                INCREMENTAL_LEVEL
--                INCREMENTAL_STALENESS
--                GLOBAL_TEMP_TABLE_STATS
--                STALE_PERCENT
--                AUTOSTATS_TARGET
--                CONCURRENT
--                TABLE_CACHED_BLOCKS
--                OPTIONS
--                STAT_CATEGORY
--                PREFERENCE_OVERRIDES_PARAMETER
--                APPROXIMATE_NDV_ALGORITHM
--                AUTO_STAT_EXTENSIONS
--                WAIT_TIME_TO_UPDATE_STATS
--                ROOT_TRIGGER_PDB
--                COORDINATOR_TRIGGER_SHARD
--               
--
--   ownname - owner name
--   tabname - table name
--  
--
-- Exceptions:
--   ORA-20001: Invalid input values
--

  procedure set_table_prefs(
    ownname varchar2,
    tabname varchar2,
    pname   varchar2,
    pvalue  varchar2);
-- 
-- This procedure is used to set the statistics preferences of the 
-- specified table in the specified schema.
-- 
-- To run this procedure, you need to connect as owner of the table
-- or be granted ANALYZE ANY system privilege.
--
-- Input arguments:
--   ownname - owner name
--   tabname - table name
--   pname   - preference name
--             The default value for following preferences can be set.
--                CASCADE
--                DEGREE 
--                ESTIMATE_PERCENT
--                METHOD_OPT
--                NO_INVALIDATE
--                GRANULARITY
--                PUBLISH
--                INCREMENTAL
--                INCREMENTAL_LEVEL
--                INCREMENTAL_STALENESS
--                GLOBAL_TEMP_TABLE_STATS
--                STALE_PERCENT
--                TABLE_CACHED_BLOCKS
--                OPTIONS
--                STAT_CATEGORY
--                PREFERENCE_OVERRIDES_PARAMETER
--                APPROXIMATE_NDV_ALGORITHM
--                AUTO_STAT_EXTENSIONS
--                ROOT_TRIGGER_PDB
--                COORDINATOR_TRIGGER_SHARD
--
--   pvalue  - preference value. 
--             if null is specified, it will set the oracle default value.
--
-- Notes:
--   All arguments are of type varchar2 and values are enclosed in quotes,
--   even when they represent numbers
--
-- Examples:
--        dbms_stats.set_table_prefs('SH', 'SALES', 'CASCADE',
--                                   'DBMS_STATS.AUTO_CASCADE');
--        dbms_stats.set_table_prefs('SH', 'SALES', 'ESTIMATE_PERCENT','9');
--        dbms_stats.set_table_prefs('SH', 'SALES', 'DEGREE','99');
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--   ORA-20001: Invalid or Illegal input values
--

  procedure delete_table_prefs(
    ownname varchar2,
    tabname varchar2,
    pname   varchar2);
-- 
-- This procedure is used to delete the statistics preferences of the 
-- specified table in the specified schema.
-- 
-- To run this procedure, you need to connect as owner of the table
-- or be granted ANALYZE ANY system privilege.
--
-- Input arguments:
--   ownname - owner name
--   tabname - table name
--   pname   - preference name
--             The default value for following preferences can be deleted.
--                CASCADE
--                DEGREE 
--                ESTIMATE_PERCENT
--                METHOD_OPT
--                NO_INVALIDATE
--                GRANULARITY
--                PUBLISH
--                INCREMENTAL
--                INCREMENTAL_LEVEL
--                INCREMENTAL_STALENESS
--                GLOBAL_TEMP_TABLE_STATS
--                STALE_PERCENT
--                TABLE_CACHED_BLOCKS
--                OPTIONS
--                STAT_CATEGORY
--                PREFERENCE_OVERRIDES_PARAMETER
--                APPROXIMATE_NDV_ALGORITHM
--                AUTO_STAT_EXTENSIONS
--                ROOT_TRIGGER_PDB
--                COORDINATOR_TRIGGER_SHARD
--
-- Notes:
--   All arguments are of type varchar2 and values are enclosed in quotes.
--
-- Examples:
--        dbms_stats.delete_table_prefs('SH', 'SALES', 'CASCADE');
--        dbms_stats.delete_table_prefs('SH', 'SALES', 'DEGREE');
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--   ORA-20001: Invalid or Illegal input values
--


  procedure export_table_prefs(
    ownname varchar2,
    tabname varchar2,
    stattab varchar2,
    statid  varchar2 default null,
    statown varchar2 default null);
-- 
-- This procedure is used to export the statistics preferences of the 
-- specified table in the specified schema into the specified statistics
-- table.
-- 
-- To run this procedure, you need to connect as owner of the table
-- or be granted ANALYZE ANY system privilege.
--
-- Input arguments:
--   ownname - owner name
--   tabname - table name
--   stattab - statistics table name where to export the statistics
--   statid  - (optional) identifier to associate with these statistics
--             within stattab.
--   statown - The schema containing stattab (if different then ownname)
--
-- Notes:
--   All arguments are of type varchar2 and values are enclosed in quotes.
--
-- Examples:
--        dbms_stats.export_table_prefs('SH', 'SALES', 'MY_STAT_TAB');
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges 
--


  procedure import_table_prefs(
    ownname varchar2,
    tabname varchar2,
    stattab varchar2,
    statid  varchar2 default null,
    statown varchar2 default null);
-- 
-- This procedure is used to set the statistics preferences of the 
-- specified table in the specified schema.
-- 
-- To run this procedure, you need to connect as owner of the table
-- or be granted ANALYZE ANY system privilege.
--
-- Input arguments:
--   ownname - owner name
--   tabname - table name
--   stattab - The user stat table identifier describing from where
--      to retrieve the statistics.
--   statid  - (optional) identifier to associate with these statistics
--             within stattab.
--   statown - The schema containing stattab (if different then ownname)
--
-- Notes:
--   All arguments are of type varchar2 and values are enclosed in quotes.
--
-- Examples:
--        dbms_stats.import_table_prefs('SH', 'SALES', 'MY_STAT_TAB');
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--   ORA-20000: Schema "<schema>" does not exist 
--


  procedure set_schema_prefs(
    ownname varchar2,
    pname   varchar2,
    pvalue  varchar2);
-- 
-- This procedure is used to set the statistics preferences of all
-- the tables owned by the specified owner name.
-- 
-- To run this procedure, you need to connect as owner, have the SYSDBA 
-- privilege, OR have the ANALYZE ANY system privilege 
--
-- Input arguments:
--   ownname - owner name
--   pname   - preference name
--             The default value for following preferences can be set.
--                CASCADE
--                DEGREE 
--                ESTIMATE_PERCENT
--                METHOD_OPT
--                NO_INVALIDATE
--                GRANULARITY
--                PUBLISH
--                INCREMENTAL
--                INCREMENTAL_LEVEL
--                INCREMENTAL_STALENESS
--                GLOBAL_TEMP_TABLE_STATS
--                STALE_PERCENT
--                TABLE_CACHED_BLOCKS
--                OPTIONS
--                STAT_CATEGORY
--                PREFERENCE_OVERRIDES_PARAMETER
--                APPROXIMATE_NDV_ALGORITHM
--                AUTO_STAT_EXTENSIONS
--                ROOT_TRIGGER_PDB
--                COORDINATOR_TRIGGER_SHARD
--
--   pvalue  - preference value. 
--             if null is specified, it will set the oracle default value.
-- Notes:
--   All arguments are of type varchar2 and values are enclosed in quotes,
--   even when they represent numbers
--
-- Examples:
--        dbms_stats.set_schema_prefs('SH', 'CASCADE',
--                                    'DBMS_STATS.AUTO_CASCADE');
--        dbms_stats.set_schema_prefs('SH' 'ESTIMATE_PERCENT','9');
--        dbms_stats.set_schema_prefs('SH', 'DEGREE','99');
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--   ORA-20000: Schema "<schema>" does not exist 
--   ORA-20001: Invalid or Illegal input values
--


  procedure delete_schema_prefs(
    ownname varchar2,
    pname   varchar2);
-- 
-- This procedure is used to delete the statistics preferences of all
-- the tables owned by the specified owner name.
-- 
-- To run this procedure, you need to connect as owner, have the SYSDBA 
-- privilege, OR have the ANALYZE ANY system privilege 
--
-- Input arguments:
--   ownname - owner name
--   pname   - preference name
--             The default value for following preferences can be deleted.
--                CASCADE
--                DEGREE 
--                ESTIMATE_PERCENT
--                METHOD_OPT
--                NO_INVALIDATE
--                GRANULARITY
--                PUBLISH
--                INCREMENTAL
--                INCREMENTAL_LEVEL
--                INCREMENTAL_STALENESS
--                GLOBAL_TEMP_TABLE_STATS
--                STALE_PERCENT
--                TABLE_CACHED_BLOCKS
--                OPTIONS
--                STAT_CATEGORY
--                PREFERENCE_OVERRIDES_PARAMETER
--                APPROXIMATE_NDV_ALGORITHM
--                AUTO_STAT_EXTENSIONS
--                ROOT_TRIGGER_PDB
--                COORDINATOR_TRIGGER_SHARD
--
-- Notes:
--   All arguments are of type varchar2 and values are enclosed in quotes.
--
-- Examples:
--        dbms_stats.delete_schema_prefs('SH', 'CASCADE');
--        dbms_stats.delete_schema_prefs('SH', 'ESTIMATE_PERCENT');
--        dbms_stats.delete_schema_prefs('SH', 'DEGREE');
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--   ORA-20000: Schema "<schema>" does not exist 
--   ORA-20001: Invalid or Illegal input values
--


  procedure export_schema_prefs(
    ownname varchar2,
    stattab varchar2,
    statid  varchar2 default null,
    statown varchar2 default null);
-- 
-- This procedure is used to export the statistics preferences of all
-- the tables owner by the specified owner name.
-- 
-- To run this procedure, you need to connect as owner, have the SYSDBA 
-- privilege, OR have the ANALYZE ANY system privilege 
--
-- Input arguments:
--   ownname - owner name
--   stattab - statistics table name where to export the statistics
--   statid  - (optional) identifier to associate with these statistics
--             within stattab.
--   statown - The schema containing stattab (if different then ownname)
--
-- Notes:
--   All arguments are of type varchar2 and values are enclosed in quotes.
--
-- Examples:
--        dbms_stats.export_schema_prefs('SH', 'MY_STAT_TAB');
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--   ORA-20000: Schema "<schema>" does not exist 
--


  procedure import_schema_prefs(
    ownname varchar2,
    stattab varchar2,
    statid  varchar2 default null,
    statown varchar2 default null);
-- 
-- This procedure is used to import the statistics preferences of all
-- the tables owner by the specified owner name.
-- 
-- To run this procedure, you need to connect as owner, have the SYSDBA 
-- privilege, OR have the ANALYZE ANY system privilege 
--
-- Input arguments:
--   ownname - owner name
--   stattab - The user stat table identifier describing from where
--      to retrieve the statistics.
--   statid  - (optional) identifier to associate with these statistics
--             within stattab.
--   statown - The schema containing stattab (if different from ownname)
--
-- Notes:
--   All arguments are of type varchar2 and values are enclosed in quotes.
--
-- Examples:
--        dbms_stats.import_schema_prefs('SH', 'MY_STAT_TAB');
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--   ORA-20000: Schema "<schema>" does not exist 
--


  procedure set_database_prefs(
    pname   varchar2,
    pvalue  varchar2,
    add_sys boolean default false);
-- 
-- This procedure is used to set the statistics preferences of all
-- the tables, excluding the tables owned by Oracle. These tables
-- can by included by passing TRUE for the add_sys parameter.
-- 
-- To run this procedure, you need to have the SYSDBA role OR both 
-- ANALYZE ANY DICTIONARY and ANALYZE ANY system privileges.
--
-- Input arguments:
--   pname   - preference name
--             The default value for following preferences can be set.
--                CASCADE 
--                DEGREE 
--                ESTIMATE_PERCENT
--                METHOD_OPT
--                NO_INVALIDATE
--                GRANULARITY
--                PUBLISH
--                INCREMENTAL
--                INCREMENTAL_LEVEL
--                INCREMENTAL_STALENESS
--                GLOBAL_TEMP_TABLE_STATS
--                STALE_PERCENT
--                TABLE_CACHED_BLOCKS
--                OPTIONS
--                STAT_CATEGORY
--                PREFERENCE_OVERRIDES_PARAMETER
--                APPROXIMATE_NDV_ALGORITHM
--                AUTO_STAT_EXTENSIONS
--                ROOT_TRIGGER_PDB
--                COORDINATOR_TRIGGER_SHARD
--
--   pvalue  - preference value. 
--             if null is specified, it will set the oracle default value.
--   add_sys - value TRUE will include the Oracle-owned tables
--
-- Notes:
--   All arguments are of type varchar2 and values are enclosed in quotes,
--   even when they represent numbers.
--
-- Examples:
--        dbms_stats.set_database_prefs('CASCADE', 'DBMS_STATS.AUTO_CASCADE');
--        dbms_stats.set_database_prefs('ESTIMATE_PERCENT','9');
--        dbms_stats.set_database_prefs('DEGREE','99');
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--   ORA-20001: Invalid or Illegal input values
--


  procedure delete_database_prefs(
    pname   varchar2,
    add_sys boolean default false);
-- 
-- This procedure is used to delete the statistics preferences of 
-- all the tables, excluding the tables owned by Oracle. These 
-- tables can by included by passing TRUE for the add_sys parameter.
-- 
-- To run this procedure, you need to have the SYSDBA role OR both 
-- ANALYZE ANY DICTIONARY and ANALYZE ANY system privileges.
--
-- Input arguments:
--   pname   - preference name
--             The default value for following preferences can be deleted.
--                CASCADE 
--                DEGREE 
--                ESTIMATE_PERCENT
--                METHOD_OPT
--                NO_INVALIDATE
--                GRANULARITY
--                PUBLISH
--                INCREMENTAL
--                INCREMENTAL_LEVEL
--                INCREMENTAL_STALENESS
--                GLOBAL_TEMP_TABLE_STATS
--                STALE_PERCENT
--                TABLE_CACHED_BLOCKS
--                OPTIONS
--                STAT_CATEGORY
--                PREFERENCE_OVERRIDES_PARAMETER
--                APPROXIMATE_NDV_ALGORITHM
--                AUTO_STAT_EXTENSIONS
--                ROOT_TRIGGER_PDB
--                COORDINATOR_TRIGGER_SHARD
--
--   add_sys - value TRUE will include the Oracle-owned tables
--
-- Notes:
--   All arguments are of type varchar2 and values are enclosed in quotes.
--
-- Examples:
--        dbms_stats.delete_database_prefs('CASCADE', false);
--        dbms_stats.delete_database_prefs('ESTIMATE_PERCENT',true);
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--   ORA-20001: Invalid or Illegal input values
--


  procedure export_database_prefs(
    stattab varchar2,
    statid  varchar2 default null,
    statown varchar2 default null,
    add_sys boolean  default false);
-- 
-- This procedure is used to export the statistics preferences of 
-- all the tables, excluding the tables owned by Oracle. These 
-- tables can by included by passing TRUE for the add_sys parameter.
-- 
-- To run this procedure, you need to have the SYSDBA role OR both 
-- ANALYZE ANY DICTIONARY and ANALYZE ANY system privileges.
--
-- Input arguments:
--   stattab - statistics table name where to export the statistics
--   statid  - (optional) identifier to associate with these statistics
--             within stattab.
--   statown - The schema containing stattab. If null, then it defaults
--             to the current user
--   add_sys - value TRUE will include the Oracle-owned tables
--
-- Examples:
--        dbms_stats.export_database_prefs('MY_STAT_TAB', statown=>'SH');
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--


  procedure import_database_prefs(
    stattab varchar2,
    statid  varchar2 default null,
    statown varchar2 default null,
    add_sys boolean  default false);
-- 
-- This procedure is used to import the statistics preferences of 
-- all the tables, excluding the tables owned by Oracle. These 
-- tables can by included by passing TRUE for the add_sys parameter.
-- 
-- To run this procedure, you need to have the SYSDBA role OR both 
-- ANALYZE ANY DICTIONARY and ANALYZE ANY system privileges.
--
-- Input arguments:
--   stattab - The user stat table identifier describing from where
--      to retrieve the statistics.
--   statid  - (optional) identifier to associate with these statistics
--             within stattab.
--   statown - The schema containing stattab
--   add_sys - value TRUE will include the Oracle-owned tables
-- Examples:
--        dbms_stats.import_database_prefs('MY_STAT_TAB', statown=>'SH');
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--

  function to_no_invalidate_type(no_invalidate varchar2) return boolean;
  procedure init_package;

  procedure publish_pending_stats(
    ownname varchar2 default null,
    tabname varchar2,
    no_invalidate boolean default 
      to_no_invalidate_type(get_param('NO_INVALIDATE')),
    force   boolean default FALSE);
-- 
-- This procedure is used to publish the statistics gathered and stored
-- as pending.
-- If the parameter TABNAME is null then publish applies to all tables 
-- of the specified schema. 
-- The default owner/schema is the user who runs the procedure.
-- 
-- To run this procedure, you need to have the privilge to collect stats
-- for the tables that will be touched by this procedure.
--
-- Input arguments:
--   ownname - owner name
--   tabname - table name
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--      The procedure invalidates the dependent cursors immediately
--      if set to FALSE.
--      Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--      invalidate dependend cursors. This is the default. The default 
--      can be changed using set_param procedure.
--   force   - to override the lock (TRUE will override the lock).
--
-- Notes:
--   All arguments are of type varchar2 and values are enclosed in quotes.
--
-- Examples:
--        dbms_stats.publish_pending_stats('SH', null);
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--

  procedure export_pending_stats(
    ownname varchar2 default null,
    tabname varchar2,
    stattab varchar2,
    statid  varchar2 default null,
    statown varchar2 default null);
-- 
-- This procedure is used to export the statistics gathered and stored
-- as pending.
-- 
-- If the parameter TABNAME is null then export applies to all tables 
-- of the specified schema. 
-- The default owner/schema is the user who runs the procedure.
-- 
-- To run this procedure, you need to have the SYSDBA role OR both 
-- ANALYZE ANY DICTIONARY and ANALYZE ANY system privileges.
--
-- Input arguments:
--   ownname - owner name
--   tabname - table name
--   stattab - statistics table name where to export the statistics
--   statid  - (optional) identifier to associate with these statistics
--             within stattab.
--   statown - The schema containing stattab (if different from ownname)
--
-- Notes:
--   All arguments are of type varchar2 and values are enclosed in quotes.
--
-- Examples:
--        dbms_stats.export_pending_stats(null, null, 'MY_STAT_TAB');
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--

  procedure delete_pending_stats(
    ownname varchar2 default null,
    tabname varchar2 default null);
-- 
-- This procedure is used to delete the pending statistics that have
-- been gathered but not published yet, i.e, stored as pending.
-- 
-- If the parameter TABNAME is null then delete applies to all tables 
-- of the specified schema. 
-- The default owner/schema is the user who runs the procedure.
--
-- To run this procedure, you need to have the SYSDBA role OR both 
-- ANALYZE ANY DICTIONARY and ANALYZE ANY system privileges.
--
-- Input arguments:
--   ownname - owner name
--   tabname - table name
--
-- Notes:
--   All arguments are of type varchar2 and values are enclosed in quotes.
--
-- Examples:
--        dbms_stats.delete_pending_stats('SH', 'SALES');
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--


  procedure publish_pending_system_stats;
--
-- This procedure is used to publish the system statistics which has been
-- gathered and stored as pending.
-- 
-- To run this procedure, you need to have the gather_system_statistics role.
--
-- Input argument:
--   None.
-- 
-- Examples:
--      dbms_stats.publish_pending_system_stats;
--
-- Exceptions:
-- ORA-20000: Insufficient privileges
--

  procedure export_pending_system_stats(
        stattab varchar2,
        statid  varchar2 default null,
        statown varchar2 default null);
-- Ths procedure is used to export the system statistics that has been
-- gathered and stored as pending to the specified table.
-- 
-- To run this procedure, you need to have the gather_system_statistics role.
--
-- Input arguments:
--   stattab - statistics table name where to export the statistics. Stattab
--             cannot be null.
--   statid  - (optional) identifier to associate with these statistics
--             within stattab.
--   statown - The schema containing stattab. If null, then it defaults to
--             the current user
--
-- Notes:
--   All arguments are of type varchar2 and values are enclosed in quotes.
-- 
-- Examples:
--   dbms_stats.export_pending_system_stats('MY_STAT_TAB', null, null);
-- 
-- Exceptions:
--   ORA-20000: Insufficient privileges
-- 

  procedure delete_pending_system_stats;
-- This procedure is used to delete the pendnig system statistics that
-- has been gathered but not published yet, i.e. stored as pending.
--
-- To run this procedure, you need to have the gather_system_statistics role.
--
-- Input Arguments:
--   None.
-- 
-- Examples: 
--      dbms_stats.delete_pending_system_stats;
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--


  procedure resume_gather_stats;
-- 
-- This procedure is used to resume statistics gathering at the point
-- where it was interrupted. Statistics gathering can be interrupted
-- as a result of a user action or a system event. 
-- 
-- To run this procedure, you need to have the SYSDBA role OR both 
-- ANALYZE ANY DICTIONARY and ANALYZE ANY system privileges.
--
-- Input arguments:
--   None.
--
-- Examples:
--        dbms_stats.resume_gather_stats();
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--

  procedure set_column_stats(
        ownname varchar2, tabname varchar2, colname varchar2, 
        partname varchar2 default null,
        stattab varchar2 default null, statid varchar2 default null,
        distcnt number default null, density number default null,
        nullcnt number default null, srec StatRec default null,
        avgclen number default null, flags number default null,
        statown varchar2 default null,
        no_invalidate boolean default 
          to_no_invalidate_type(get_param('NO_INVALIDATE')),
        force boolean default FALSE);

  procedure set_column_stats(
        ownname varchar2, tabname varchar2, colname varchar2, 
        partname varchar2 default null,
        stattab varchar2 default null, statid varchar2 default null,
        ext_stats raw,
        stattypown varchar2 default null,
        stattypname varchar2 default null,
        statown varchar2 default null,
        no_invalidate boolean default 
          to_no_invalidate_type(get_param('NO_INVALIDATE')),
        force boolean default FALSE);
--
-- Set column-related information 
--
-- Input arguments:
--   ownname - The name of the schema
--   tabname - The name of the table to which this column belongs
--   colname - The name of the column or extension
--   partname - The name of the table partition in which to store
--      the statistics.  If the table is partitioned and partname
--      is null, the statistics will be stored at the global table
--      level.
--   stattab - The user stat table identifier describing where
--      to store the statistics.  If stattab is null, the statistics
--      will be stored directly in the dictionary.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab (Only pertinent if stattab is not NULL).
--   distcnt - The number of distinct values
--   density - The column density.  If this value is null and distcnt is
--      not null, density will be derived from distcnt.
--   nullcnt - The number of nulls
--   srec - StatRec structure filled in by a call to prepare_column_values
--      or get_column_stats.
--   avgclen - The average length for the column (in bytes)
--   flags - For internal Oracle use (should be left as null)
--   statown - The schema containing stattab (if different then ownname)
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--      The procedure invalidates the dependent cursors immediately
--      if set to FALSE.
--      Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--      invalidate dependend cursors. This is the default. The default 
--      can be changed using set_param procedure.
--   force - set the values even if statistics of the object is locked
--
-- Input arguments for user-defined statistics:
--   ext_stats - external (user-defined) statistics
--   stattypown - owner of statistics type associated with column
--   stattypname - name of statistics type associated with column
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--   ORA-20001: Invalid or inconsistent input values
--   ORA-20002: Bad user statistics table, may need to upgrade it
--   ORA-20005: object statistics are locked
--


  procedure set_index_stats(
        ownname varchar2, indname varchar2,
        partname varchar2 default null,
        stattab varchar2 default null, statid varchar2 default null,
        numrows number default null, numlblks number default null,
        numdist number default null, avglblk number default null,
        avgdblk number default null, clstfct number default null,
        indlevel number default null, flags number default null,
        statown varchar2 default null,
        no_invalidate boolean default 
          to_no_invalidate_type(get_param('NO_INVALIDATE')),
        guessq number default null,
        cachedblk number default null,
        cachehit number default null,
        force boolean default FALSE);

  procedure set_index_stats(
        ownname varchar2, indname varchar2,
        partname varchar2 default null,
        stattab varchar2 default null, statid varchar2 default null,
        ext_stats raw,
        stattypown varchar2 default null,
        stattypname varchar2 default null,
        statown varchar2 default null,
        no_invalidate boolean default 
          to_no_invalidate_type(get_param('NO_INVALIDATE')),
        force boolean default FALSE);
--
-- Set index-related information
-- Input arguments:
--   ownname - The name of the schema
--   indname - The name of the index
--   partname - The name of the index partition in which to store
--      the statistics.  If the index is partitioned and partname
--      is null, the statistics will be stored at the global index
--      level.
--   stattab - The user stat table identifier describing where
--      to store the statistics.  If stattab is null, the statistics
--      will be stored directly in the dictionary.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab (Only pertinent if stattab is not NULL).
--   numrows - The number of rows in the index (partition)
--   numlblks - The number of leaf blocks in the index (partition)
--   numdist - The number of distinct keys in the index (partition)
--   avglblk - Average integral number of leaf blocks in which each
--      distinct key appears for this index (partition).  If not provided,
--      this value will be derived from numlblks and numdist.
--   avgdblk - Average integral number of data blocks in the table
--      pointed to by a distinct key for this index (partition).
--      If not provided, this value will be derived from clstfct
--      and numdist.
--   clstfct - See clustering_factor column of the all_indexes view
--      for a description.
--   indlevel - The height of the index (partition)
--   flags - For internal Oracle use (should be left as null)
--   statown - The schema containing stattab (if different then ownname)
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--      The procedure invalidates the dependent cursors immediately
--      if set to FALSE.
--      Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--      invalidate dependend cursors. This is the default. The default 
--      can be changed using set_param procedure.
--   guessq - IOT guess quality.  See pct_direct_access column of the
--      all_indexes view for a description.
--   force - set the values even if statistics of the object is locked
--
-- Input arguments for user-defined statistics:
--   ext_stats - external (user-defined) statistics
--   stattypown - owner of statistics type associated with index
--   stattypname - name of statistics type associated with index
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--   ORA-20001: Invalid input value
--   ORA-20002: Bad user statistics table, may need to upgrade it
--   ORA-20005: object statistics are locked
-- 

  procedure set_table_stats(
        ownname varchar2,
        tabname varchar2, 
        partname varchar2 default null,
        stattab varchar2 default null,
        statid varchar2 default null,
        numrows number default null,
        numblks number default null,
        avgrlen number default null, 
        flags number default null,
        statown varchar2 default null,
        no_invalidate boolean default 
          to_no_invalidate_type(get_param('NO_INVALIDATE')),
        cachedblk number default null,
        cachehit number default null,
        force boolean default FALSE,
        im_imcu_count number default null,
        im_block_count number default null,
        scanrate number default null);
--
-- Set table-related information
--
-- Input arguments:
--   ownname - The name of the schema
--   tabname - The name of the table
--   partname - The name of the table partition in which to store
--      the statistics.  If the table is partitioned and partname
--      is null, the statistics will be stored at the global table
--      level.
--   stattab - The user stat table identifier describing where
--      to store the statistics.  If stattab is null, the statistics
--      will be stored directly in the dictionary.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab (Only pertinent if stattab is not NULL).
--   numrows - Number of rows in the table (partition)
--   numblks - Number of blocks the table (partition) occupies
--   avgrlen - Average row length for the table (partition)
--   flags - For internal Oracle use (should be left as null)
--   statown - The schema containing stattab (if different then ownname)
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--      The procedure invalidates the dependent cursors immediately
--      if set to FALSE.
--      Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--      invalidate dependend cursors. This is the default. The default 
--      can be changed using set_param procedure.
--   im_imcu_count - Number of IMCUs for inmemory table
--   im_block_count - Number of inmemory blocks for inmemory table
--   scanrate - Scan rate for the table
--   force - set the values even if statistics of the object is locked
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--   ORA-20001: Invalid input value
--   ORA-20002: Bad user statistics table, may need to upgrade it
--   ORA-20005: object statistics are locked
--


  procedure convert_raw_value(
        rawval raw, resval out NOCOPY varchar2);
  pragma restrict_references(convert_raw_value, WNDS, RNDS, WNPS, RNPS);
  procedure convert_raw_value(
        rawval raw, resval out NOCOPY date);
  pragma restrict_references(convert_raw_value, WNDS, RNDS, WNPS, RNPS);
  procedure convert_raw_value(
        rawval raw, resval out NOCOPY number);
  pragma restrict_references(convert_raw_value, WNDS, RNDS, WNPS, RNPS);
  procedure convert_raw_value(
        rawval raw, resval out NOCOPY binary_float);
  pragma restrict_references(convert_raw_value, WNDS, RNDS, WNPS, RNPS);
  procedure convert_raw_value(
        rawval raw, resval out NOCOPY binary_double);
  pragma restrict_references(convert_raw_value, WNDS, RNDS, WNPS, RNPS);
  procedure convert_raw_value_nvarchar(
        rawval raw, resval out NOCOPY nvarchar2);
  pragma restrict_references(convert_raw_value_nvarchar,
                             WNDS, RNDS, WNPS, RNPS);
  procedure convert_raw_value_rowid(
        rawval raw, resval out NOCOPY rowid);
  pragma restrict_references(convert_raw_value_rowid, WNDS, RNDS, WNPS, RNPS);
--
-- Convert the internal representation of a minimum or maximum value
-- into a datatype-specific value.  The minval and maxval fields
-- of the StatRec structure as filled in by get_column_stats or
-- prepare_column_values are appropriate values for input.
--
-- Input argument
--   rawval - The raw representation of a column minimum or maximum
--
-- Datatype specific output arguments:
--   resval - The converted, type-specific value
--
-- Exceptions:
--   None
--

  function convert_raw_to_varchar2(rawval raw) return VARCHAR2;
  function convert_raw_to_date(rawval raw) return DATE;
  function convert_raw_to_number(rawval raw) return NUMBER;
  function convert_raw_to_bin_float(rawval raw) return BINARY_FLOAT;
  function convert_raw_to_bin_double(rawval raw) return BINARY_DOUBLE;
  function convert_raw_to_nvarchar(rawval raw) return NVARCHAR2;
  function convert_raw_to_rowid(rawval raw) return ROWID; 

-- #(25463265):
-- This is the function version of the convert_raw_value procedure.
-- Needed in Statistics-based Query Transformation since we need to
-- represent RAW value as some specific data type in a query.
-- Convert the internal representation of a minimum or maximum value
-- into a datatype-specific value and return it. 
--
-- Input argument
--   rawval - The raw representation of a column minimum or maximum
--
-- Return Value:
--   resval - The converted, type-specific value
--
-- Exceptions:
--   None
--

  procedure get_column_stats(
        ownname varchar2, tabname varchar2, colname varchar2, 
        partname varchar2 default null,
        stattab varchar2 default null, statid varchar2 default null,
        distcnt out NOCOPY number, density out NOCOPY number,
        nullcnt out NOCOPY number, srec out NOCOPY StatRec,
        avgclen out NOCOPY number,
        statown varchar2 default null);

  procedure get_column_stats(
        ownname varchar2, tabname varchar2, colname varchar2, 
        partname varchar2 default null,
        stattab varchar2 default null, statid varchar2 default null,
        ext_stats out NOCOPY raw, 
        stattypown out varchar2, stattypname out varchar2,
        statown varchar2 default null);
--
-- Gets all column-related information
--
-- Input arguments:
--   ownname - The name of the schema
--   tabname - The name of the table to which this column belongs
--   colname - The name of the column or extension
--   partname - The name of the table partition from which to get
--      the statistics.  If the table is partitioned and partname
--      is null, the statistics will be retrieved from the global table
--      level.
--   stattab - The user stat table identifier describing from where
--      to retrieve the statistics.  If stattab is null, the statistics
--      will be retrieved directly from the dictionary.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab (Only pertinent if stattab is not NULL).
--   statown - The schema containing stattab (if different then ownname)
--
-- Output arguments:
--   distcnt - The number of distinct values
--   density - The column density
--   nullcnt - The number of nulls
--   srec - structure holding internal representation of column minimum,
--      maximum, and histogram values
--   avgclen - The average length of the column (in bytes)
--
-- Output arguments for user-defined column statistics:
--   ext_stats - external (user-defined) statistics
--   stattypown - owner of statistics type associated with column
--   stattypname - name of statistics type associated with column
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges or
--              no statistics have been stored for requested object
--   ORA-20002: Bad user statistics table, may need to upgrade it
--


  procedure get_index_stats(
        ownname varchar2, indname varchar2,
        partname varchar2 default null,
        stattab varchar2 default null, statid varchar2 default null,
        numrows out NOCOPY number, numlblks out NOCOPY number,
        numdist out NOCOPY number, avglblk out NOCOPY number,
        avgdblk out NOCOPY number, clstfct out NOCOPY number,
        indlevel out NOCOPY number,
        statown varchar2 default null,
        guessq out NOCOPY number,
        cachedblk out NOCOPY number,
        cachehit out NOCOPY number);

  procedure get_index_stats(
        ownname varchar2, indname varchar2,
        partname varchar2 default null,
        stattab varchar2 default null, statid varchar2 default null,
        numrows out NOCOPY number, numlblks out NOCOPY number,
        numdist out NOCOPY number, avglblk out NOCOPY number,
        avgdblk out NOCOPY number, clstfct out NOCOPY number,
        indlevel out NOCOPY number,
        statown varchar2 default null,
        guessq out NOCOPY number);
  
  procedure get_index_stats(
        ownname varchar2, indname varchar2,
        partname varchar2 default null,
        stattab varchar2 default null, statid varchar2 default null,
        numrows out NOCOPY number, numlblks out NOCOPY number,
        numdist out NOCOPY number, avglblk out NOCOPY number,
        avgdblk out NOCOPY number, clstfct out NOCOPY number,
        indlevel out NOCOPY number,
        statown varchar2 default null);

  procedure get_index_stats(
        ownname varchar2, indname varchar2,
        partname varchar2 default null,
        stattab varchar2 default null, statid varchar2 default null,
        ext_stats out NOCOPY raw,
        stattypown out varchar2, stattypname out varchar2,
        statown varchar2 default null);
--
-- Gets all index-related information
--
-- Input arguments:
--   ownname - The name of the schema
--   indname - The name of the index
--   partname - The name of the index partition for which to get
--      the statistics.  If the index is partitioned and partname
--      is null, the statistics will be retrieved for the global index
--      level.
--   stattab - The user stat table identifier describing from where
--      to retrieve the statistics.  If stattab is null, the statistics
--      will be retrieved directly from the dictionary.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab (Only pertinent if stattab is not NULL).
--   statown - The schema containing stattab (if different then ownname)
--
-- Output arguments:
--   numrows - The number of rows in the index (partition)
--   numlblks - The number of leaf blocks in the index (partition)
--   numdist - The number of distinct keys in the index (partition)
--   avglblk - Average integral number of leaf blocks in which each
--      distinct key appears for this index (partition).
--   avgdblk - Average integral number of data blocks in the table
--      pointed to by a distinct key for this index (partition).
--   clstfct - The clustering factor for the index (partition).
--   indlevel - The height of the index (partition).
--   guessq - IOT guess quality of the index (partition).
--
-- Output arguments for user defined statistics:
--   ext_stats - external (user-defined) statistics
--   stattypown - owner of statistics type associated with index
--   stattypname - name of statistics type associated with index
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges or
--              no statistics have been stored for requested object
--   ORA-20002: Bad user statistics table, may need to upgrade it
--


  procedure get_table_stats(
        ownname varchar2, tabname varchar2, 
        partname varchar2 default null,
        stattab varchar2 default null, statid varchar2 default null,
        numrows out NOCOPY number, numblks out NOCOPY number,
        avgrlen out NOCOPY number,
        statown varchar2 default null);

  procedure get_table_stats(
        ownname varchar2, tabname varchar2, 
        partname varchar2 default null,
        stattab varchar2 default null, statid varchar2 default null,
        numrows out NOCOPY number, numblks out NOCOPY number,
        avgrlen out NOCOPY number,
        statown varchar2 default null,
        im_imcu_count out NOCOPY number,
        im_block_count out NOCOPY number,
        scanrate out NOCOPY number);

  procedure get_table_stats(
        ownname varchar2,
        tabname varchar2, 
        partname varchar2 default null,
        stattab varchar2 default null,
        statid varchar2 default null,
        numrows out NOCOPY number,
        numblks out NOCOPY number,
        avgrlen out NOCOPY number,
        statown varchar2 default null,
        cachedblk out NOCOPY number,
        cachehit out NOCOPY number);
--
-- Gets all table-related information
--
-- Input arguments:
--   ownname - The name of the schema
--   tabname - The name of the table to which this column belongs
--   partname - The name of the table partition from which to get
--      the statistics.  If the table is partitioned and partname
--      is null, the statistics will be retrieved from the global table
--      level.
--   stattab - The user stat table identifier describing from where
--      to retrieve the statistics.  If stattab is null, the statistics
--      will be retrieved directly from the dictionary.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab (Only pertinent if stattab is not NULL).
--   statown - The schema containing stattab (if different then ownname)
--
-- Output arguments:
--   numrows - Number of rows in the table (partition)
--   numblks - Number of blocks the table (partition) occupies
--   avgrlen - Average row length for the table (partition)
--   im_imcu_count - Number of IMCUs for inmemory table
--   im_block_count - Number of inmemory blocks for inmemory table
--   scanrate - Scan rate of the table
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges or
--              no statistics have been stored for requested object
--   ORA-20002: Bad user statistics table, may need to upgrade it
--



  procedure delete_column_stats(
        ownname varchar2, tabname varchar2, colname varchar2, 
        partname varchar2 default null,
        stattab varchar2 default null, statid varchar2 default null,
        cascade_parts boolean default true,
        statown varchar2 default null,
        no_invalidate boolean default 
          to_no_invalidate_type(get_param('NO_INVALIDATE')),
        force boolean default FALSE,
        col_stat_type varchar2 default 'ALL');
--
-- Deletes column-related statistics
--
-- Input arguments:
--   ownname - The name of the schema
--   tabname - The name of the table to which this column belongs
--   colname - The name of the column or extension
--   partname - The name of the table partition for which to delete
--      the statistics.  If the table is partitioned and partname
--      is null, global column statistics will be deleted.
--   stattab - The user stat table identifier describing from where
--      to delete the statistics.  If stattab is null, the statistics
--      will be deleted directly from the dictionary.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab (Only pertinent if stattab is not NULL).
--   cascade_parts - If the table is partitioned and partname is null,
--      setting this to true will cause the deletion of statistics for
--      this column for all underlying partitions as well.
--   statown - The schema containing stattab (if different then ownname)
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--      The procedure invalidates the dependent cursors immediately
--      if set to FALSE.
--      Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--      invalidate dependend cursors. This is the default. The default 
--      can be changed using set_param procedure.
--   force - delete statistics even if it is locked
--   col_stat_type - Type of column statitistics to be deleted.
--                   This argument takes the following values: 
--                   'HISTOGRAM' - delete column histogram only
--                   'ALL' - delete base column stats and histogram
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--   ORA-20002: Bad user statistics table, may need to upgrade it
--   ORA-20005: object statistics are locked
--


  procedure delete_index_stats(
        ownname varchar2, indname varchar2,
        partname varchar2 default null,
        stattab varchar2 default null, statid varchar2 default null,
        cascade_parts boolean default true,
        statown varchar2 default null,
        no_invalidate boolean default 
          to_no_invalidate_type(get_param('NO_INVALIDATE')),
        stattype varchar2 default 'ALL',
        force boolean default FALSE);
--
-- Deletes index-related statistics
--
-- Input arguments:
--   ownname - The name of the schema
--   indname - The name of the index
--   partname - The name of the index partition for which to delete
--      the statistics.  If the index is partitioned and partname
--      is null, index statistics will be deleted at the global level.
--   stattab - The user stat table identifier describing from where
--      to delete the statistics.  If stattab is null, the statistics
--      will be deleted directly from the dictionary.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab (Only pertinent if stattab is not NULL).
--   cascade_parts - If the index is partitioned and partname is null,
--      setting this to true will cause the deletion of statistics for
--      this index for all underlying partitions as well.
--   statown - The schema containing stattab (if different then ownname)
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--      The procedure invalidates the dependent cursors immediately
--      if set to FALSE.
--      Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--      invalidate dependend cursors. This is the default. The default 
--      can be changed using set_param procedure.
--   force - delete the statistics even if it is locked
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--   ORA-20002: Bad user statistics table, may need to upgrade it
--   ORA-20005: object statistics are locked
--


  procedure delete_table_stats(
        ownname varchar2, tabname varchar2, 
        partname varchar2 default null,
        stattab varchar2 default null, statid varchar2 default null,
        cascade_parts boolean default true, 
        cascade_columns boolean default true,
        cascade_indexes boolean default true,
        statown varchar2 default null,
        no_invalidate boolean default 
          to_no_invalidate_type(get_param('NO_INVALIDATE')),
        stattype varchar2 default 'ALL',
        force boolean default FALSE,
        stat_category varchar2 default DEFAULT_DEL_STAT_CATEGORY);
--
-- Deletes table-related statistics
--
-- Input arguments:
--   ownname - The name of the schema
--   tabname - The name of the table to which this column belongs
--   partname - The name of the table partition from which to get
--      the statistics.  If the table is partitioned and partname
--      is null, the statistics will be retrieved from the global table
--      level.
--   stattab - The user stat table identifier describing from where
--      to retrieve the statistics.  If stattab is null, the statistics
--      will be retrieved directly from the dictionary.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab (Only pertinent if stattab is not NULL).
--   cascade_parts - If the table is partitioned and partname is null,
--      setting this to true will cause the deletion of statistics for
--      this table for all underlying partitions as well.
--   cascade_columns - Indicates that delete_column_stats should be
--      called for all underlying columns (passing the cascade_parts
--      parameter).
--   cascade_indexes - Indicates that delete_index_stats should be
--      called for all underlying indexes (passing the cascade_parts
--      parameter).
--   statown - The schema containing stattab (if different then ownname)
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--      The procedure invalidates the dependent cursors immediately
--      if set to FALSE.
--      Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--      invalidate dependend cursors. This is the default. The default 
--      can be changed using set_param procedure.
--   force - delete the statistics even if it is locked
--   stat_category - what statistics to delete. It accepts multiple values
--   separated by comma. The values we support now are 'OBJECT_STATS' 
--   (i.e., table statistics, column statistics and index statistics) and 
--   'SYNOPSES'. The default is 'OBJECT_STATS, SYNOPSES'
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--   ORA-20002: Bad user statistics table, may need to upgrade it
--   ORA-20005: object statistics are locked
--


  procedure delete_schema_stats(
        ownname varchar2, 
        stattab varchar2 default null, statid varchar2 default null,
        statown varchar2 default null,
        no_invalidate boolean default 
          to_no_invalidate_type(get_param('NO_INVALIDATE')),
        stattype varchar2 default 'ALL',
        force boolean default FALSE,
        stat_category varchar2 default DEFAULT_DEL_STAT_CATEGORY);
--
-- Deletes statistics for a schema
--
-- Input arguments:
--   ownname - The name of the schema
--   stattab - The user stat table identifier describing from where
--      to delete the statistics.  If stattab is null, the statistics
--      will be deleted directly in the dictionary.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab (Only pertinent if stattab is not NULL).
--   statown - The schema containing stattab (if different then ownname)
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--      The procedure invalidates the dependent cursors immediately
--      if set to FALSE.
--      Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--      invalidate dependend cursors. This is the default. The default 
--      can be changed using set_param procedure.
--   stattype - The type of statistics to be deleted
--     ALL   - both data and cache statistics will be deleted
--     CACHE - only cache statistics will be deleted 
--   force - Ignores the statistics lock on objects and delete
--           the statistics if set to TRUE.
--   stat_category - what statistics to delete. It accepts multiple values
--   separated by comma. The values we support now are 'OBJECT_STATS' 
--   (i.e., table statistics, column statistics and index statistics) and 
--   'SYNOPSES'. The default is 'OBJECT_STATS, SYNOPSES'
--           
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--   ORA-20002: Bad user statistics table, may need to upgrade it
--


  procedure delete_database_stats(
        stattab varchar2 default null, statid varchar2 default null,
        statown varchar2 default null,
        no_invalidate boolean default 
          to_no_invalidate_type(get_param('NO_INVALIDATE')),
        stattype varchar2 default 'ALL',
        force boolean default FALSE,
        stat_category varchar2 default DEFAULT_DEL_STAT_CATEGORY);
--
-- Deletes statistics for an entire database
--
-- Input arguments:
--   stattab - The user stat table identifier describing from where
--      to delete the statistics.  If stattab is null, the statistics
--      will be deleted directly in the dictionary.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab (Only pertinent if stattab is not NULL).
--   statown - The schema containing stattab.
--      If stattab is not null and statown is null, it is assumed that
--      every schema in the database contains a user statistics table
--      with the name stattab.
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--      The procedure invalidates the dependent cursors immediately
--      if set to FALSE.
--      Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--      invalidate dependend cursors. This is the default. The default 
--      can be changed using set_param procedure.
--   stattype - The type of statistics to be deleted
--     ALL   - both data and cache statistics will be deleted
--     CACHE - only cache statistics will be deleted 
--   force - Ignores the statistics lock on objects and delete
--           the statistics if set to TRUE.
--   stat_category - what statistics to delete. It accepts multiple values
--   separated by comma. The values we support now are 'OBJECT_STATS' 
--   (i.e., table statistics, column statistics and index statistics) and 
--   'SYNOPSES'. The default is 'OBJECT_STATS, SYNOPSES'
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--   ORA-20002: Bad user statistics table, may need to upgrade it
--






--
-- This set of procedures enable the transferrance of statistics
-- from the dictionary to a user stat table (export_*) and from a user
-- stat table to the dictionary (import_*).
--
-- The procedures are:
--
--  create_stat_table
--  drop_stat_table
--  upgrade_stat_table
--
--  export_column_stats
--  export_index_stats
--  export_table_stats
--  export_schema_stats
--  export_database_stats
--  export_system_stats
--  export_fixed_objects_stats
--  export_dictionary_stats
--
--  import_column_stats
--  import_index_stats
--  import_table_stats
--  import_schema_stats
--  import_database_stats
--  import_system_stats
--  import_fixed_objects_stats
--  import_dictionary_stats
--  
--  Notes: 
--    We do not support export/import of stats across databases of 
--    different character sets.
--


  procedure create_stat_table(
        ownname varchar2, stattab varchar2,
        tblspace varchar2 default null,
        global_temporary boolean default false);
--
-- Creates a table with name 'stattab' in 'ownname's
-- schema which is capable of holding statistics.  The columns
-- and types that compose this table are not relevant as it
-- should be accessed solely through the procedures in this
-- package.
--
-- Input arguments:
--   ownname - The name of the schema
--   stattab - The name of the table to create.  This value should
--      be passed as the 'stattab' argument to other procedures
--      when the user does not wish to modify the dictionary statistics
--      directly.
--   tblspace - The tablespace in which to create the stat tables.
--      If none is specified, they will be created in the user's 
--      default tablespace.
--   table_options - Whether or not the table should be created as a global
--      temporary table.
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--   ORA-20001: Tablespace does not exist
--   ORA-20002: Table already exists
--


  procedure drop_stat_table(
        ownname varchar2, stattab varchar2);
--
-- Drops a user stat table
--
-- Input arguments:
--   ownname - The name of the schema
--   stattab - The user stat table identifier
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--   ORA-20001: Table is not a statistics table
--   ORA-20002: Table does not exist
--


  procedure upgrade_stat_table(
        ownname varchar2, stattab varchar2);
--
-- Upgrade a user stat table from an older version
--
-- Input arguments:
--   ownname - The name of the schema
--   stattab - The user stat table identifier
--
-- Exceptions:
--   ORA-20000: Unable to upgrade table
--

  procedure remap_stat_table(
        ownname varchar2, stattab varchar2,
        src_own varchar2, src_tab varchar2,
        tgt_own varchar2, tgt_tab varchar2);
--
-- The procedure remaps the names of objects in the user stat table. It allows
-- to import the statistics to objects with same definition but with different 
-- names.
--
-- Input arguments:
--   ownname - The owner of the user stat table (NULL means current schema).
--   stattab - The user stat table identifier.
--   src_own - Owner of the table to be renamed. This argument can not be null.
--   src_tab - Name of the table to be renamed.
--             If null, all tables owned by src_own.
--   tgt_own - New name of the owner of the table. The owner name is updated 
--             for the dependend objects like columns and indexes as well. Note
--             that a index of src_tab not owned by src_own is not renamed.
--             This argument can not be null.
--   tgt_tab - New name of the table. This argument is valid only if src_tab
--             is not null. 
-- Examples:
--   The following statement remap all objects of sh to shsave in user stat 
--   table sh.ustat 
--     dbms_stats.remap_stat_table('sh', 'ustat', 'sh', null, 'shsave', null);
--
--   The following statement can be used to import statistics into objects of
--   shsave once the above remap procedure is completed.
--     dbms_stats.import_schema_stats('shsave', 'ustat', statown => 'sh');
-- 
--   The following statement remaps sh.customers ->shsave.customers_sav. 
--     dbms_stats.remap_stat_table('sh', 'ustat', 'sh', 'customers', 
--                                 'shsave', 'customers_sav');
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--   ORA-20001: Invalid input
--
  procedure export_column_stats(
        ownname varchar2, tabname varchar2, colname varchar2, 
        partname varchar2 default null,
        stattab varchar2, statid varchar2 default null,
        statown varchar2 default null);
--
-- Retrieves statistics for a particular column and stores them in the user
-- stat table identified by stattab
--
-- Input arguments:
--   ownname - The name of the schema
--   tabname - The name of the table to which this column belongs
--   colname - The name of the column or extension
--   partname - The name of the table partition.  If the table is 
--      partitioned and partname is null, global and partition column 
--      statistics will be exported.
--   stattab - The user stat table identifier describing where
--      to store the statistics.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab.
--   statown - The schema containing stattab (if different then ownname)
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--   ORA-20002: Bad user statistics table, may need to upgrade it
--


  procedure export_index_stats(
        ownname varchar2, indname varchar2, 
        partname varchar2 default null,
        stattab varchar2, statid varchar2 default null,
        statown varchar2 default null);
--
-- Retrieves statistics for a particular index and stores them 
-- in the user stat table identified by stattab
--
-- Input arguments:
--   ownname - The name of the schema
--   indname - The name of the index
--   partname - The name of the index partition.  If the index is 
--      partitioned and partname is null, global and partition index 
--      statistics will be exported.
--   stattab - The user stat table identifier describing where
--      to store the statistics.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab.
--   statown - The schema containing stattab (if different then ownname)
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--   ORA-20002: Bad user statistics table, may need to upgrade it
--


  procedure export_table_stats(
        ownname varchar2, tabname varchar2, 
        partname varchar2 default null,
        stattab varchar2, statid varchar2 default null,
        cascade boolean default true,
        statown varchar2 default null,
        stat_category varchar2 default DEFAULT_STAT_CATEGORY
);
--
-- Retrieves statistics for a particular table and stores them 
-- in the user stat table.
-- Cascade will result in all index and column stats associated
-- with the specified table being exported as well.
--
-- Input arguments:
--   ownname - The name of the schema
--   tabname - The name of the table
--   partname - The name of the table partition.  If the table is 
--      partitioned and partname is null, global and partition table 
--      statistics will be exported.
--   stattab - The user stat table identifier describing where
--      to store the statistics.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab.
--   cascade - If true, column and index statistics for this table
--      will also be exported.
--   statown - The schema containing stattab (if different then ownname)
--   stat_category - what statistics to export. It accepts multiple values
--   separated by comma. The values we support now are 'OBJECT_STATS' 
--   (i.e., table statistics, column statistics and index statistics) and 
--   'SYNOPSES'. However SYNOPSES can only be exported along with 
--    OBJECT_STATS. Therefore only valid combinations are 
--          OBJECT_STATS 
--          OBJECT_STATS, SYNOPSES
--   The default value is OBJECT_STATS that can be changed usig statistics
--   preference.
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--   ORA-20002: Bad user statistics table, may need to upgrade it
--


  procedure export_schema_stats(
        ownname varchar2,
        stattab varchar2, statid varchar2 default null,
        statown varchar2 default null,
        stat_category varchar2 default DEFAULT_STAT_CATEGORY);
--
-- Retrieves statistics for all objects in the schema identified
-- by ownname and stores them in the user stat table identified
-- by stattab
--
-- Input arguments:
--   ownname - The name of the schema
--   stattab - The user stat table identifier describing where
--      to store the statistics.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab.
--   statown - The schema containing stattab (if different then ownname)
--   stat_category - what statistics to export. It accepts multiple values
--   separated by comma. The values we support now are 'OBJECT_STATS' 
--   (i.e., table statistics, column statistics and index statistics) and 
--   'SYNOPSES'. However SYNOPSES can only be exported along with 
--    OBJECT_STATS. Therefore only valid combinations are 
--          OBJECT_STATS 
--          OBJECT_STATS, SYNOPSES
--   The default value is OBJECT_STATS that can be changed usig statistics
--   preference.
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--   ORA-20002: Bad user statistics table, may need to upgrade it
--


  procedure export_database_stats(
        stattab varchar2, statid varchar2 default null,
        statown varchar2 default null,
        stat_category varchar2 default DEFAULT_STAT_CATEGORY);
--
-- Retrieves statistics for all objects in the database
-- and stores them in the user stat tables identified
-- by statown.stattab
--
-- Input arguments:
--   stattab - The user stat table identifier describing where
--      to store the statistics.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab.
--   statown - The schema containing stattab.
--      If statown is null, it is assumed that every schema in the database 
--      contains a user statistics table with the name stattab.
--   stat_category - what statistics to export. It accepts multiple values
--   separated by comma. The values we support now are 'OBJECT_STATS' 
--   (i.e., table statistics, column statistics and index statistics) and 
--   'SYNOPSES'. However SYNOPSES can only be exported along with 
--    OBJECT_STATS. Therefore only valid combinations are 
--          OBJECT_STATS 
--          OBJECT_STATS, SYNOPSES
--   The default value is OBJECT_STATS that can be changed usig statistics
--   preference.
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--   ORA-20002: Bad user statistics table, may need to upgrade it
--


  procedure import_column_stats(
        ownname varchar2, tabname varchar2, colname varchar2,
        partname varchar2 default null,
        stattab varchar2, statid varchar2 default null,
        statown varchar2 default null,
        no_invalidate boolean default 
          to_no_invalidate_type(get_param('NO_INVALIDATE')),
        force boolean default FALSE);
--
-- Retrieves statistics for a particular column from the user stat table
-- identified by stattab and stores them in the dictionary
--
-- Input arguments:
--   ownname - The name of the schema
--   tabname - The name of the table to which this column belongs
--   colname - The name of the column or extension
--   partname - The name of the table partition.  If the table is 
--      partitioned and partname is null, global and partition column 
--      statistics will be imported.
--   stattab - The user stat table identifier describing from where
--      to retrieve the statistics.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab.
--   statown - The schema containing stattab (if different then ownname)
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--      The procedure invalidates the dependent cursors immediately
--      if set to FALSE.
--      Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--      invalidate dependend cursors. This is the default. The default 
--      can be changed using set_param procedure.
--   force - import statistics even if it is locked
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--   ORA-20001: Invalid or inconsistent values in the user stat table
--   ORA-20002: Bad user statistics table, may need to upgrade it
--   ORA-20005: object statistics are locked
--


  procedure import_index_stats(
        ownname varchar2, indname varchar2,
        partname varchar2 default null,
        stattab varchar2, statid varchar2 default null,
        statown varchar2 default null,
        no_invalidate boolean default 
          to_no_invalidate_type(get_param('NO_INVALIDATE')),
        force boolean default FALSE);
--
-- Retrieves statistics for a particular index from the user
-- stat table identified by stattab and stores them in the 
-- dictionary
--
-- Input arguments:
--   ownname - The name of the schema
--   indname - The name of the index
--   partname - The name of the index partition.  If the index is 
--      partitioned and partname is null, global and partition index 
--      statistics will be imported.
--   stattab - The user stat table identifier describing from where
--      to retrieve the statistics.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab.
--   statown - The schema containing stattab (if different then ownname)
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--      The procedure invalidates the dependent cursors immediately
--      if set to FALSE.
--      Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--      invalidate dependend cursors. This is the default. The default 
--      can be changed using set_param procedure.
--   force - import the statistics even if it is locked
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--   ORA-20001: Invalid or inconsistent values in the user stat table
--   ORA-20002: Bad user statistics table, may need to upgrade it
--   ORA-20005: object statistics are locked
--


  procedure import_table_stats(
        ownname varchar2, tabname varchar2,
        partname varchar2 default null,
        stattab varchar2, statid varchar2 default null,
        cascade boolean default true,
        statown varchar2 default null,
        no_invalidate boolean default 
          to_no_invalidate_type(get_param('NO_INVALIDATE')),
        force boolean default FALSE,
        stat_category varchar2 default DEFAULT_STAT_CATEGORY);
--
-- Retrieves statistics for a particular table from the user
-- stat table identified by stattab and stores them in the dictionary.
-- Cascade will result in all index and column stats associated
-- with the specified table being imported as well.
-- The statistics will be imported as pending in case PUBLISH preference
-- is set to FALSE.
--
-- Input arguments:
--   ownname - The name of the schema
--   tabname - The name of the table
--   partname - The name of the table partition.  If the table is 
--      partitioned and partname is null, global and partition table 
--      statistics will be imported.
--   stattab - The user stat table identifier describing from where
--      to retrieve the statistics.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab.
--   cascade - If true, column and index statistics for this table
--      will also be imported.
--   statown - The schema containing stattab (if different then ownname)
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--      The procedure invalidates the dependent cursors immediately
--      if set to FALSE.
--      Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--      invalidate dependend cursors. This is the default. The default 
--      can be changed using set_param procedure.
--   force - import even if statistics of the object is locked
--   stat_category - what statistics to import. It accepts multiple values
--   separated by comma. The values we support now are 'OBJECT_STATS' 
--   (i.e., table statistics, column statistics and index statistics) and 
--   'SYNOPSES'. However SYNOPSES can only be imported along with 
--    OBJECT_STATS. Therefore only valid combinations are 
--          OBJECT_STATS 
--          OBJECT_STATS, SYNOPSES
--   The default value is OBJECT_STATS that can be changed usig statistics
--   preference.
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--   ORA-20001: Invalid or inconsistent values in the user stat table
--   ORA-20002: Bad user statistics table, may need to upgrade it
--   ORA-20005: object statistics are locked
--


  procedure import_schema_stats(
        ownname varchar2,
        stattab varchar2, statid varchar2 default null,
        statown varchar2 default null,
        no_invalidate boolean default 
          to_no_invalidate_type(get_param('NO_INVALIDATE')),
        force boolean default FALSE,
        stat_category varchar2 default DEFAULT_STAT_CATEGORY);
--
-- Retrieves statistics for all objects in the schema identified
-- by ownname from the user stat table and stores them in the
-- dictionary 
-- The statistics will be imported as pending in case PUBLISH preference
-- is set to FALSE.
--
-- Input arguments:
--   ownname - The name of the schema
--   stattab - The user stat table identifier describing from where
--      to retrieve the statistics.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab.
--   statown - The schema containing stattab (if different then ownname)
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--      The procedure invalidates the dependent cursors immediately
--      if set to FALSE.
--      Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--      invalidate dependend cursors. This is the default. The default 
--      can be changed using set_param procedure.
--   force - Override statistics lock.
--     TRUE- Ignores the statistics lock on objects and import
--           the statistics. 
--     FALSE-The statistics of an object will be imported only if it 
--           is not locked. 
--           ie if both DATA and CACHE statistics is locked, it will not
--           import anything. If CACHE statistics of an object is locked, 
--           only DATA statistics will be imported and vice versa.
--   stat_category - what statistics to import. It accepts multiple values
--   separated by comma. The values we support now are 'OBJECT_STATS' 
--   (i.e., table statistics, column statistics and index statistics) and 
--   'SYNOPSES'. However SYNOPSES can only be imported along with 
--    OBJECT_STATS. Therefore only valid combinations are 
--          OBJECT_STATS 
--          OBJECT_STATS, SYNOPSES
--   The default value is OBJECT_STATS that can be changed usig statistics
--   preference.
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges.
--              if ORA-20000 shows "no statistics are imported", several
--              possible reasons are: (1) no statistics exist for the specified
--              ownname or statid in the stattab; (2) statistics are locked;  
--              (3) objects in the stattab no longer exist in the current 
--              database  
--   ORA-20001: Invalid or inconsistent values in the user stat table
--   ORA-20002: Bad user statistics table, may need to upgrade it
--


  procedure import_database_stats(
        stattab varchar2, statid varchar2 default null,
        statown varchar2 default null,
        no_invalidate boolean default 
          to_no_invalidate_type(get_param('NO_INVALIDATE')),
        force boolean default FALSE,
        stat_category varchar2 default DEFAULT_STAT_CATEGORY
        );
--
-- Retrieves statistics for all objects in the database
-- from the user stat table(s) and stores them in the
-- dictionary 
-- The statistics will be imported as pending in case PUBLISH preference
-- is set to FALSE.
--
-- Input arguments:
--   stattab - The user stat table identifier describing from where
--      to retrieve the statistics.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab.
--   statown - The schema containing stattab.
--      If statown is null, it is assumed that every schema in the database 
--      contains a user statistics table with the name stattab.
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--      The procedure invalidates the dependent cursors immediately
--      if set to FALSE.
--      Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--      invalidate dependend cursors. This is the default. The default 
--      can be changed using set_param procedure.
--   force - Override statistics lock.
--     TRUE- Ignores the statistics lock on objects and import
--           the statistics. 
--     FALSE-The statistics of an object will be imported only if it 
--           is not locked. 
--           ie if both DATA and CACHE statistics is locked, it will not
--           import anything. If CACHE statistics of an object is locked, 
--           only DATA statistics will be imported and vice versa.
--   stat_category - what statistics to import. It accepts multiple values
--   separated by comma. The values we support now are 'OBJECT_STATS' 
--   (i.e., table statistics, column statistics and index statistics) and 
--   'SYNOPSES'. However SYNOPSES can only be imported along with 
--    OBJECT_STATS. Therefore only valid combinations are 
--          OBJECT_STATS 
--          OBJECT_STATS, SYNOPSES
--   The default value is OBJECT_STATS that can be changed usig statistics
--   preference.
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--              if ORA-20000 shows "no statistics are imported", several
--              possible reasons are: (1) user specified statid does not
--              exist; (2) statistics are locked; (3) objects in the 
--              stattab no longer exist in the current database  
--   ORA-20001: Invalid or inconsistent values in the user stat table
--   ORA-20002: Bad user statistics table, may need to upgrade it
--








--
-- This set of procedures enable the gathering of certain
-- classes of optimizer statistics with possible performance 
-- improvements over the analyze command.
--
-- The procedures are:
--
--  gather_index_stats
--  gather_table_stats
--  gather_schema_stats
--  gather_database_stats
--  gather_system_stats
--  gather_fixed_objects_stats
--  gather_dictionary_stats
--
-- We also provide the following procedure for generating some
-- statistics for derived objects when we have sufficient statistics 
-- on related objects
--
-- generate_stats
--

  procedure gather_index_stats
    (ownname varchar2, indname varchar2, partname varchar2 default null,
     estimate_percent number default DEFAULT_ESTIMATE_PERCENT,
     stattab varchar2 default null, statid varchar2 default null,
     statown varchar2 default null,
     degree number default DEFAULT_DEGREE_VALUE,
     granularity varchar2 default DEFAULT_GRANULARITY,
     no_invalidate boolean default 
       to_no_invalidate_type(get_param('NO_INVALIDATE')),
     stattype varchar2 default 'DATA',
     force boolean default FALSE);
--
-- This procedure gathers index statistics.
-- It attempts to parallelize as much of the work as possible.
-- are some restrictions as described in the individual parameters.
-- This operation will not parallelize with certain types of indexes,
-- including cluster indexes, domain indexes and bitmap join indexes.
-- The "granularity" and "no_invalidate" arguments are also not pertinent to
-- these types of indexes.
--
--   ownname - schema of index to analyze
--   indname - name of index
--   partname - name of partition
--   estimate_percent - Percentage of rows to estimate (NULL means compute).
--      The valid range is [0.000001,100].  Use the constant
--      DBMS_STATS.AUTO_SAMPLE_SIZE to have Oracle determine the
--      appropriate sample size for good statistics. This is the default.
--      The default value can be changed using set_param procedure.
--   degree - degree of parallelism (NULL means use of table default value
--      which was specified by DEGREE clause in CREATE/ALTER INDEX statement)
--      Use the constant DBMS_STATS.DEFAULT_DEGREE for the default value
--      based on the initialization parameters.
--      default for degree is NULL.
--      The default value can be changed using set_param procedure.
--   granularity - the granularity of statistics to collect (only pertinent
--      if the table is partitioned)
--     'AUTO' - the procedure determines what level of statistics to collect
--     'GLOBAL AND PARTITION' - gather global- and partition-level statistics
--     'SUBPARTITION' - gather subpartition-level statistics
--     'PARTITION' - gather partition-level statistics
--     'GLOBAL' - gather global statistics
--     'ALL' - gather all (subpartition, partition, and global) statistics
--     default for granularity is AUTO. 
--     The default value can be changed using set_param procedure.
--   stattab - The user stat table identifier describing where to save
--      the current statistics.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab.
--   statown - The schema containing stattab (if different then ownname)
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--      The procedure invalidates the dependent cursors immediately
--      if set to FALSE.
--      Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--      invalidate dependend cursors. This is the default. The default 
--      can be changed using set_param procedure.
--   force - gather statistics of index even if it is locked.
--   options - further specification of which objects to gather statistics for
--      'GATHER' - gather statistics on all objects in the schema
--      'GATHER AUTO' - gather all necessary statistics automatically. Oracle
--        implicitly determines which objects need new statistics.
--
-- Exceptions:
--   ORA-20000: Index does not exist or insufficient privileges
--   ORA-20001: Bad input value
--   ORA-20002: Bad user statistics table, may need to upgrade it
--   ORA-20005: object statistics are locked
--

  procedure gather_table_stats
    (ownname varchar2, tabname varchar2, partname varchar2 default null,
     estimate_percent number default DEFAULT_ESTIMATE_PERCENT,
     block_sample boolean default FALSE,
     method_opt varchar2 default DEFAULT_METHOD_OPT,
     degree number default DEFAULT_DEGREE_VALUE,
     granularity varchar2 default  DEFAULT_GRANULARITY,
     cascade boolean default DEFAULT_CASCADE,
     stattab varchar2 default null, statid varchar2 default null,
     statown varchar2 default null,
     no_invalidate boolean default 
       to_no_invalidate_type(get_param('NO_INVALIDATE')),
     stattype varchar2 default 'DATA',
     force boolean default FALSE,
     -- the context is intended for internal use only.
     context dbms_stats.CContext default null,
     options varchar2 default DEFAULT_OPTIONS
     );

-- For internal use only.
function gather_table_stats_func
    (
     ownname varchar2, tabname varchar2, partname varchar2 default null,
     estimate_percent number default DEFAULT_ESTIMATE_PERCENT,
     block_sample_str varchar2,
     method_opt varchar2 default DEFAULT_METHOD_OPT,
     degree number default DEFAULT_DEGREE_VALUE,
     granularity varchar2 default  DEFAULT_GRANULARITY,
     cascade_str varchar2,
     stattab varchar2 default null, statid varchar2 default null,
     statown varchar2 default null,
     no_invalidate_str varchar2,
     stattype varchar2 default 'DATA',
     force_str varchar2,
     options varchar2 default DEFAULT_OPTIONS
     ) return NUMBER;

--
-- This procedure gathers table and column (and index) statistics.
-- It attempts to parallelize as much of the work as possible, but there
-- are some restrictions as described in the individual parameters.
-- This operation will not parallelize if the user does not have select
-- privilege on the table being analyzed.
--
-- Input arguments:
--   ownname - schema of table to analyze
--   tabname - name of table
--   partname - name of partition
--   estimate_percent - Percentage of rows to estimate (NULL means compute).
--      The valid range is [0.000001,100].  Use the constant
--      DBMS_STATS.AUTO_SAMPLE_SIZE to have Oracle determine the
--      appropriate sample size for good statistics. This is the default.
--      The default value can be changed using set_param procedure.
--   block_sample - whether or not to use random block sampling instead of
--      random row sampling.  Random block sampling is more efficient, but
--      if the data is not randomly distributed on disk then the sample values
--      may be somewhat correlated.  Only pertinent when doing an estimate 
--      statistics.
--   method_opt - method options of the following format 
--
--         method_opt  := FOR ALL [INDEXED | HIDDEN] COLUMNS [size_clause]
--                        FOR COLUMNS [size_clause] 
--                        column|attribute [size_clause] 
--                        [,column|attribute [size_clause] ... ]
--
--         size_clause := SIZE [integer | auto | skewonly | repeat],
--                        where integer is between 1 and 2048
--
--         column      := column name | extension name | extension
--
--      default is FOR ALL COLUMNS SIZE AUTO.
--      The default value can be changed using set_param procedure.
--      Optimizer related table statistics are always gathered.
--
--      If an extension is provided, the procedure create the extension if it 
--      does not exist already. Please refer to create_extended_stats for
--      description of extension.
--     
--   degree - degree of parallelism (NULL means use of table default value
--      which was specified by DEGREE clause in CREATE/ALTER TABLE statement)
--      Use the constant DBMS_STATS.DEFAULT_DEGREE for the default value
--      based on the initialization parameters.
--      default for degree is NULL.
--      The default value can be changed using set_param procedure.
--   granularity - the granularity of statistics to collect (only pertinent
--      if the table is partitioned)
--     'AUTO' - the procedure determines what level of statistics to collect
--     'GLOBAL AND PARTITION' - gather global- and partition-level statistics
--     'APPROX_GLOBAL AND PARTITION' - This option is similar to
--        'GLOBAL AND PARTITION'. But the global statistics are aggregated
--         from partition level statistics. It will aggregate all statistics 
--         except number of distinct values for columns and number of distinct 
--         keys of indexes.  The existing histograms of the columns at the 
--         table level are also aggregated.  The global statistics are gathered
--         (i.e., going back to GLOBAL AND PARTITION behaviour) 
--         if partname argument is null. The aggregation will use only 
--         partitions with statistics, so to get accurate global statistics,
--         user has to make sure to have statistics for all partitions.
--
--
--         This option is useful when you collect statistics for a new 
--         partition added into a range partitioned table (for example, a table
--         partitioned by month).  The new data in the partition makes the 
--         global statistics stale (especially the min/max values of the 
--         partitioning column). This stale global statistics may cause 
--         suboptimal plans.  In this scenario, users can collect statistics
--         for the newly added partition with 'APPROX_GLOBAL AND PARTITION'
--         option so that the global statistics will reflect the newly added 
--         range.  This option will take less time than 'GLOBAL AND PARTITION'
--         option since the global statistics are aggregated from underlying 
--         partition level statistics.  Note that, if you are using 
--         APPROX_GLOBAL AND PARTITION, you still  need to collect global 
--         statistics (with granularity = 'GLOBAL' option) when there is
--         substantial amount of change at the table level.  For example you
--         added 10% more data to the table.  This is needed to get the correct
--         number of distinct values/keys statistic at table level. 
--     'SUBPARTITION' - gather subpartition-level statistics
--     'PARTITION' - gather partition-level statistics
--     'GLOBAL' - gather global statistics
--     'ALL' - gather all (subpartition, partition, and global) statistics
--     default for granularity is AUTO. 
--     The default value can be changed using set_param procedure.
--   cascade - gather statistics on the indexes for this table.
--      Use the constant DBMS_STATS.AUTO_CASCADE to have Oracle determine 
--      whether index stats to be collected or not. This is the default.
--      The default value can be changed using set_param procedure.
--      Using this option is equivalent to running the gather_index_stats 
--      procedure on each of the table's indexes.
--   stattab - The user stat table identifier describing where to save
--      the current statistics.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab.
--   statown - The schema containing stattab (if different then ownname)
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--     The procedure invalidates the dependent cursors immediately
--     if set to FALSE.
--     Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--     invalidate dependend cursors. This is the default. The default 
--     can be changed using set_param procedure.
--     When the 'cascade' argument is specified, not pertinent with certain
--     types of indexes described in the gather_index_stats section.
--   force - gather statistics of table even if it is locked.
--   context - internal use only.
--   
-- Exceptions:
--   ORA-20000: Table does not exist or insufficient privileges
--   ORA-20001: Bad input value
--   ORA-20002: Bad user statistics table, may need to upgrade it
--   ORA-20005: object statistics are locked
--

function report_gather_table_stats
    (ownname varchar2, tabname varchar2, partname varchar2 default null,
     estimate_percent number default DEFAULT_ESTIMATE_PERCENT,
     block_sample boolean default FALSE,
     method_opt varchar2 default DEFAULT_METHOD_OPT,
     degree number default DEFAULT_DEGREE_VALUE,
     granularity varchar2 default  DEFAULT_GRANULARITY,
     cascade boolean default DEFAULT_CASCADE,
     stattab varchar2 default null, statid varchar2 default null,
     statown varchar2 default null,
     no_invalidate boolean default 
       to_no_invalidate_type(get_param('NO_INVALIDATE')),
     stattype varchar2 default 'DATA',
     force boolean default FALSE,  
     options varchar2 default DEFAULT_OPTIONS,
     detail_level varchar2 default 'TYPICAL',
     format varchar2 default 'TEXT') 
 return clob;

--
-- This procedure runs gather_table_stats in reporting mode. That is,
-- stats are not actually collected, but all the objects that will be
-- affected when gather_table_stats is invoked are reported.
-- The detail level for the report is defined by the detail_level 
-- input parameter. Please see the comments for report_single_stats_operation 
-- on possible values for detail_level and format. 
-- For all other input parameters, please see the comments on 
-- gather_table_stats.     


 procedure gather_schema_stats
    (ownname varchar2,
     estimate_percent number default DEFAULT_ESTIMATE_PERCENT,
     block_sample boolean default FALSE,
     method_opt varchar2 default  DEFAULT_METHOD_OPT,
     degree number default DEFAULT_DEGREE_VALUE,
     granularity varchar2 default DEFAULT_GRANULARITY,
     cascade boolean default DEFAULT_CASCADE,
     stattab varchar2 default null, statid varchar2 default null,
     options varchar2 default 'GATHER', objlist out NOCOPY ObjectTab,
     statown varchar2 default null,
     no_invalidate boolean default
       to_no_invalidate_type(get_param('NO_INVALIDATE')),
     gather_temp boolean default FALSE,
     gather_fixed boolean default FALSE,
     stattype varchar2 default 'DATA',
     force boolean default FALSE,
     obj_filter_list ObjectTab default null);
  procedure gather_schema_stats
    (ownname varchar2,
     estimate_percent number default DEFAULT_ESTIMATE_PERCENT,
     block_sample boolean default FALSE,
     method_opt varchar2 default DEFAULT_METHOD_OPT,
     degree number default DEFAULT_DEGREE_VALUE,
     granularity varchar2 default DEFAULT_GRANULARITY,
     cascade boolean default DEFAULT_CASCADE,
     stattab varchar2 default null, statid varchar2 default null,
     options varchar2 default 'GATHER', statown varchar2 default null,
     no_invalidate boolean default 
       to_no_invalidate_type(get_param('NO_INVALIDATE')),
     gather_temp boolean default FALSE,
     gather_fixed boolean default FALSE,
     stattype varchar2 default 'DATA',
     force boolean default FALSE,
     obj_filter_list ObjectTab default null);
--
-- Input arguments:
--   ownname - schema to analyze (NULL means current schema)
--   estimate_percent - Percentage of rows to estimate (NULL means compute).
--      The valid range is [0.000001,100].  Use the constant
--      DBMS_STATS.AUTO_SAMPLE_SIZE to have Oracle determine the
--      appropriate sample size for good statistics. This is the default.
--      The default value can be changed using set_param procedure.
--   block_sample - whether or not to use random block sampling instead of
--      random row sampling.  Random block sampling is more efficient, but
--      if the data is not randomly distributed on disk then the sample values
--      may be somewhat correlated.  Only pertinent when doing an estimate 
--      statistics.
--   method_opt - method options of the following format 
--
--         method_opt  := FOR ALL [INDEXED | HIDDEN] COLUMNS [size_clause]
--
--         size_clause := SIZE [integer | auto | skewonly | repeat],
--                        where integer is between 1 and 2048
--
--      default is FOR ALL COLUMNS SIZE AUTO.
--      The default value can be changed using set_param procedure.
--      This value will be passed to all of the individual tables.
--   degree - degree of parallelism (NULL means use table default value which
--      is specified by DEGREE clause in CREATE/ALTER TABLE statement)
--      Use the constant DBMS_STATS.DEFAULT_DEGREE for the default value
--      based on the initialization parameters.
--      default for degree is NULL.
--      The default value can be changed using set_param procedure.
--   granularity - the granularity of statistics to collect (only pertinent
--      if the table is partitioned)
--     'AUTO' - the procedure determines what level of statistics to collect
--     'GLOBAL AND PARTITION' - gather global- and partition-level statistics
--     'SUBPARTITION' - gather subpartition-level statistics
--     'PARTITION' - gather partition-level statistics
--     'GLOBAL' - gather global statistics
--     'ALL' - gather all (subpartition, partition, and global) statistics
--     default for granularity is AUTO. 
--     The default value can be changed using set_param procedure.
--   cascade - gather statistics on the indexes as well.
--      Use the constant DBMS_STATS.AUTO_CASCADE to have Oracle determine 
--      whether index stats to be collected or not. This is the default.
--      The default value can be changed using set_param procedure.
--      Using this option is equivalent to running the gather_index_stats 
--      procedure on each of the indexes in the schema in addition to 
--      gathering table and column statistics.
--   stattab - The user stat table identifier describing where to save
--      the current statistics.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab.
--   options - further specification of which objects to gather statistics for
--      'GATHER' - gather statistics on all objects in the schema
--      'GATHER AUTO' - gather all necessary statistics automatically.  Oracle
--        implicitly determines which objects need new statistics, and
--        determines how to gather those statistics.  When 'GATHER AUTO' is
--        specified, the only additional valid parameters are no_invalidate,
--        ownname, stattab,
--        statid, objlist and statown; all other parameter settings will be
--        ignored.  Also, return a list of objects processed.
--      'GATHER STALE' - gather statistics on stale objects as determined
--        by looking at the *_tab_modifications views.  Also, return
--        a list of objects found to be stale.
--      'GATHER EMPTY' - gather statistics on objects which currently
--        have no statistics.  also, return a list of objects found
--        to have no statistics.
--      'LIST AUTO' - return list of objects to be processed with 'GATHER AUTO'
--      'LIST STALE' - return list of stale objects as determined
--        by looking at the *_tab_modifications views
--      'LIST EMPTY' - return list of objects which currently
--        have no statistics
--   objlist - list of objects found to be stale or empty
--   statown - The schema containing stattab (if different then ownname)
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--     The procedure invalidates the dependent cursors immediately
--     if set to FALSE.
--     Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--     invalidate dependend cursors. This is the default. The default 
--     can be changed using set_param procedure.
--     When 'cascade' option is specified, not pertinent with certain types
--     of indexes described in the gather_index_stats section.
--   gather_temp - gather stats on global temporary tables also.  The
--     temporary table must be created with "on commit preserve rows" clause,
--     and the statistics being collected are based on the data in the session
--     which this procedure is run but shared across all the sessions.
--   gather_fixed - Gather statistics on fixed tables also. 
--     Statistics for fixed tables can be collected only by user SYS.
--     Also the ownname should be SYS or NULL.
--     Specified values for the following arguments will be ignored while 
--     gathering statistics for fixed tables.
--       estimate_percent, block_sample, stattab, statid, statown  
--     It will not invalidate the dependent cursors on fixed table
--     on which stats is collected.
--     This option is meant for internal use only.
--   force - gather statistics of objects even if they are locked.
--   obj_filter_list - a list of object filters. When provided, 
--     gather_schema_stats will only gather statistics on the objects which 
--     satisfy at least one object filter in the list as needed. Please refer 
--     to obj_filter_list in gather_database_stats.
-- Exceptions:
--   ORA-20000: Schema does not exist or insufficient privileges
--   ORA-20001: Bad input value
--   ORA-20002: Bad user statistics table, may need to upgrade it
--

function report_gather_schema_stats
    (ownname varchar2,
     estimate_percent number default DEFAULT_ESTIMATE_PERCENT,
     block_sample boolean default FALSE,
     method_opt varchar2 default DEFAULT_METHOD_OPT,
     degree number default DEFAULT_DEGREE_VALUE,
     granularity varchar2 default DEFAULT_GRANULARITY,
     cascade boolean default DEFAULT_CASCADE,
     stattab varchar2 default null, statid varchar2 default null,
     options varchar2 default 'GATHER', statown varchar2 default null,
     no_invalidate boolean default 
       to_no_invalidate_type(get_param('NO_INVALIDATE')),
     gather_temp boolean default FALSE,
     gather_fixed boolean default FALSE,
     stattype varchar2 default 'DATA',
     force boolean default FALSE,
     obj_filter_list ObjectTab default null,     
     detail_level varchar2 default 'TYPICAL',
     format varchar2 default 'TEXT') 
 return clob;

--
-- This procedure runs gather_schema_stats in reporting mode. That is,
-- stats are not actually collected, but all the objects that will be
-- affected when gather_schema_stats is invoked are reported.
-- The detail level for the report is defined by the detail_level 
-- input parameter. Please see the comments for report_single_stats_operation 
-- on possible values for detail_level and format. 
-- For all other input parameters, please see the comments on 
-- gather_schema_stats.

  procedure gather_database_stats
    (estimate_percent number default DEFAULT_ESTIMATE_PERCENT,
     block_sample boolean default FALSE,
     method_opt varchar2 default DEFAULT_METHOD_OPT,
     degree number default DEFAULT_DEGREE_VALUE,
     granularity varchar2 default DEFAULT_GRANULARITY,
     cascade boolean default DEFAULT_CASCADE,
     stattab varchar2 default null, statid varchar2 default null,
     options varchar2 default 'GATHER', objlist out NOCOPY ObjectTab,
     statown varchar2 default null,
     gather_sys boolean default TRUE,
     no_invalidate boolean default 
       to_no_invalidate_type(get_param('NO_INVALIDATE')),
     gather_temp boolean default FALSE,
     gather_fixed boolean default FALSE,
     stattype varchar2 default 'DATA',
     obj_filter_list ObjectTab default null);

  procedure gather_database_stats
    (estimate_percent number default DEFAULT_ESTIMATE_PERCENT,
     block_sample boolean default FALSE,
     method_opt varchar2 default DEFAULT_METHOD_OPT,
     degree number default DEFAULT_DEGREE_VALUE,
     granularity varchar2 default DEFAULT_GRANULARITY,
     cascade boolean default DEFAULT_CASCADE,
     stattab varchar2 default null, statid varchar2 default null,
     options varchar2 default 'GATHER', statown varchar2 default null,
     gather_sys boolean default TRUE,
     no_invalidate boolean default 
       to_no_invalidate_type(get_param('NO_INVALIDATE')),
     gather_temp boolean default FALSE,
     gather_fixed boolean default FALSE,
     stattype varchar2 default 'DATA',
     obj_filter_list ObjectTab default null);
--
-- Input arguments:
--   estimate_percent - Percentage of rows to estimate (NULL means compute).
--      The valid range is [0.000001,100].  Use the constant
--      DBMS_STATS.AUTO_SAMPLE_SIZE to have Oracle determine the
--      appropriate sample size for good statistics. This is the default.
--      The default value can be changed using set_param procedure.
--   block_sample - whether or not to use random block sampling instead of
--      random row sampling.  Random block sampling is more efficient, but
--      if the data is not randomly distributed on disk then the sample values
--      may be somewhat correlated.  Only pertinent when doing an estimate 
--      statistics.
--   method_opt - method options of the following format 
--
--         method_opt  := FOR ALL [INDEXED | HIDDEN] COLUMNS [size_clause]
--
--         size_clause := SIZE [integer | auto | skewonly | repeat],
--                        where integer is between 1 and 2048
--
--      default is FOR ALL COLUMNS SIZE AUTO.
--      The default value can be changed using set_param procedure.
--      This value will be passed to all of the individual tables.
--   degree - degree of parallelism (NULL means use table default value which
--      is specified by DEGREE clause in CREATE/ALTER TABLE statement)
--      Use the constant DBMS_STATS.DEFAULT_DEGREE for the default value
--      based on the initialization parameters.
--      default for degree is NULL.
--      The default value can be changed using set_param procedure.
--   granularity - the granularity of statistics to collect (only pertinent
--      if the table is partitioned)
--     'AUTO' - the procedure determines what level of statistics to collect
--     'GLOBAL AND PARTITION' - gather global- and partition-level statistics
--     'SUBPARTITION' - gather subpartition-level statistics
--     'PARTITION' - gather partition-level statistics
--     'GLOBAL' - gather global statistics
--     'ALL' - gather all (subpartition, partition, and global) statistics
--     default for granularity is AUTO. 
--     The default value can be changed using set_param procedure.
--   cascade - gather statistics on the indexes as well.
--      Use the constant DBMS_STATS.AUTO_CASCADE to have Oracle determine 
--      whether index stats to be collected or not. This is the default.
--      The default value can be changed using set_param procedure.
--      Using this option is equivalent to running the gather_index_stats 
--      procedure on each of the indexes in the database in addition to
--      gathering table and column statistics.
--   stattab - The user stat table identifier describing where to save
--      the current statistics.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab.
--   options - further specification of which objects to gather statistics for
--      'GATHER' - gather statistics on all objects in the schema
--      'GATHER AUTO' - gather all necessary statistics automatically.  Oracle
--        implicitly determines which objects need new statistics, and
--        determines how to gather those statistics.  When 'GATHER AUTO' is
--        specified, the only additional valid parameters are no_invalidate, 
--        stattab, statid, objlist and statown; all other parameter settings 
--        will be ignored.  Also, return a list of objects processed.
--      'GATHER STALE' - gather statistics on stale objects as determined
--        by looking at the *_tab_modifications views.  Also, return
--        a list of objects found to be stale.
--      'GATHER EMPTY' - gather statistics on objects which currently
--        have no statistics.  also, return a list of objects found
--        to have no statistics.
--      'LIST AUTO' - return list of objects to be processed with 'GATHER AUTO'
--      'LIST STALE' - return list of stale objects as determined
--        by looking at the *_tab_modifications views
--      'LIST EMPTY' - return list of objects which currently
--        have no statistics
--   objlist - list of objects found to be stale or empty
--   statown - The schema containing stattab.  If null, it will assume
--      there is a table named stattab in each relevant schema in the 
--      database if stattab is specified for saving current statistics.
--   gather_sys - Gather statistics on the objects owned by the 'SYS' user
--      as well.
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--     The procedure invalidates the dependent cursors immediately
--     if set to FALSE.
--     Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--     invalidate dependend cursors. This is the default. The default 
--     can be changed using set_param procedure.
--     When 'cascade' option is specified, not pertinent with certain types
--     of indexes described in the gather_index_stats section.
--   gather_temp - gather stats on global temporary tables also.  The
--     temporary table must be created with "on commit preserve rows" clause,
--     and the statistics being collected are based on the data in the session
--     which this procedure is run but shared across all the sessions.
--   gather_fixed - Gather stats on fixed tables also.
--     Statistics for fixed tables can be collected only by user SYS.
--     Specified values for the following arguments will be ignored while 
--     gathering statistics for fixed tables.
--     gathering statistics for fixed tables.
--       estimate_percent, block_sample, stattab, statid, statown  
--     It will not invalidate the dependent cursors on fixed table
--     on which stats is collected.
--     This option is meant for internal use only.
--   obj_filter_list - a list of object filters. When provided, 
--     gather_database_stats will only gather statistics on the objects which 
--     satisfy at least one of the object filters as needed.
--
--     In one single object filter, we can specify the constraints on the 
--     object attributes. The attribute values specified in the object filter 
--     are case-insensitive unless double-quoted. Wildcard is allowed in the 
--     attribute values.  Suppose non-null values s1, s2, ... are specified for
--     attributes a1, a2, ... in one object filter. An object o is said to 
--     satisfy this object filter if (o.a1 like s1) and (o.a2 like s2) and ... 
--     is true.  The following example specifies that any table with a "SALES"
--     prefix in the SH schema and any table in the SYS schema, if stale, will 
--     be gathered.  Note that the statistics for the partitions of the tables 
--     also will be gathered if they are stale.
--   Example:
--     declare
--       filter_lst  dbms_stats.objecttab := dbms_stats.objecttab();
--     begin
--       filter_lst.extend(2);
--       filter_lst(1).ownname := 'sh';
--       filter_lst(1).objname := 'sales%';
--       filter_lst(2).ownname := 'sys';
--       dbms_stats.gather_schema_stats(null, obj_filter_list => filter_lst, 
--                                      options => 'gather_stale');
--     end;
-- Exceptions:
--   ORA-20000: Insufficient privileges
--   ORA-20001: Bad input value
--   ORA-20002: Bad user statistics table, may need to upgrade it
--

 function report_gather_database_stats
    (estimate_percent number default DEFAULT_ESTIMATE_PERCENT,
     block_sample boolean default FALSE,
     method_opt varchar2 default DEFAULT_METHOD_OPT,
     degree number default DEFAULT_DEGREE_VALUE,
     granularity varchar2 default DEFAULT_GRANULARITY,
     cascade boolean default DEFAULT_CASCADE,
     stattab varchar2 default null, statid varchar2 default null,
     options varchar2 default 'GATHER', statown varchar2 default null,
     gather_sys boolean default TRUE,
     no_invalidate boolean default 
       to_no_invalidate_type(get_param('NO_INVALIDATE')),
     gather_temp boolean default FALSE,
     gather_fixed boolean default FALSE,
     stattype varchar2 default 'DATA',
     obj_filter_list ObjectTab default null,
     detail_level varchar2 default 'TYPICAL',
     format varchar2 default 'TEXT')
 return clob;

--
-- This procedure runs gather_database_stats in reporting mode. That is,
-- stats are not actually collected, but all the objects that will be
-- affected when gather_database_stats is invoked are reported.
-- The detail level for the report is defined by the detail_level 
-- input parameter. Please see the comments for report_single_stats_operation 
-- on possible values for detail_level and format. 
-- For all other input parameters, please see the comments on 
-- gather_database_stats.   

  procedure generate_stats
    (ownname varchar2, objname varchar2,
     organized number default 7,
     force boolean default FALSE);
--
-- This procedure generates object statistics from previously collected
-- statistics of related objects.  For fully populated
-- schemas, the gather procedures should be used instead when more
-- accurate statistics are desired.
-- The currently supported objects are b-tree and bitmap indexes.
--
--   ownname - schema of object
--   objname - name of object
--   organized - the amount of ordering associated between the index and
--     its undelrying table.  A heavily organized index would have consecutive
--     index keys referring to consecutive rows on disk for the table
--     (the same block).  A heavily disorganized index would have consecutive
--     keys referencing different table blocks on disk.  This parameter is
--     only used for b-tree indexes.
--     The number can be in the range of 0-10, with 0 representing a completely
--     organized index and 10 a completely disorganized one.
--   force - generate statistics even if it is locked
-- Exceptions:
--   ORA-20000: Unsupported object type of object does not exist
--   ORA-20001: Invalid option or invalid statistics
--   ORA-20005: object statistics are locked
--




--
-- This procedure enables the flushing of in-memory monitoring
-- information to the dictionary.  Corresponding entries in the
-- *_tab_modifications views are updated immediately, without waiting
-- for Oracle to flush it periodically.  Useful for the users who need
-- up-to-date information in those views.
-- The gather_*_stats procedures internally flush the monitoring information
-- accordingly, and it is NOT necessary to run this procedure before
-- gathering the statistics.
-- 
--
-- The procedure is:
--
--  flush_database_monitoring_info
--
-- The modification monitoring mechanism is now controlled by the
-- STATISTICS_LEVEL initialization parameter, and the following
-- procedures no longer have any effect:
--
--  alter_schema_tab_monitoring
--  alter_database_tab_monitoring
--

procedure flush_database_monitoring_info;
--
-- Flush in-memory monitoring information for all the tables to the dictionary.
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--

procedure alter_schema_tab_monitoring
  (ownname varchar2 default NULL, monitoring boolean default TRUE);
procedure alter_database_tab_monitoring
  (monitoring boolean default TRUE, sysobjs boolean default FALSE);



procedure gather_system_stats (
  gathering_mode  varchar2 default 'NOWORKLOAD',
  interval  integer  default 60,
  stattab   varchar2 default null, 
  statid    varchar2 default null,
  statown   varchar2 default null);
--
-- This procedure gathers system statistics. 
--
-- Input arguments:
--   gathering_mode - Values: NOWORKLOAD, INTERVAL, START, STOP, EXADATA
--     NOWORKLOAD:
--       In this mode system statistics will be gathered based on system
--       characteristics only, without regard to the workload.
--     INTERVAL:
--       In this mode the user can specify a time interval parameter, in 
--       minutes. 
--       After <interval> minutes has passed the system statistics will be 
--       updated either in dictionary, or stattab if specified. The system
--       statistics are based on system activity during specified interval.
--     START | STOP:
--       The procedure is first called with START then followed by another
--       call using STOP. It is assumed that between these two calls some
--       SQL workload has been running allowing the procedure to capture
--       workload-specific statistics.
--       START will initiate gathering statistics. STOP will calculate 
--       statistics for elapsed period of time (since START) and refresh
--       dictionary or stattab. Interval in these modes is ignored.
--     EXADATA:
--       In this mode the gathered system statistics takes into account the
--       unique capabilities provided by using Exadata such as large IO size
--       and high IO throughput. The multi-block read count and IO throughput 
--       statistics are set along with the CPU speed.
--
--   interval - Specifies period of time in minutes for gathering statistics
--      in INTERVAL mode.
--   stattab - The user stat table identifier describing where to save
--      the current statistics.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab.
--   statown - The schema containing stattab (if different then ownname)
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--   ORA-20001: Bad input value
--   ORA-20002: Bad user statistics table, may need to upgrade it
--   ORA-20003: Unable to gather system statistics
--   ORA-20004: Error in "INTERVAL" mode :
--              system parameter job_queue_processes must be > 0
--

procedure get_system_stats (
   status     out   varchar2,
   dstart     out   date,
   dstop      out   date,
   pname            varchar2,
   pvalue     out   number,
   stattab          varchar2 default null, 
   statid           varchar2 default null,
   statown          varchar2 default null);

--
-- Input arguments:
--   stattab - The user stat table identifier describing from where to get
--      the current statistics info. If stattab is null, the statistics info
--      will be obtained directly from the dictionary.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab.
--   statown - The schema containing stattab (if different then ownname)
--   pname - parameter name to get
--
-- Output arguments:
--   status - returns one of the following: COMPLETED, AUTOGATHERING, 
--   MANUALGATHERING, BADSTATS
--   dstart - date when system stats gathering has been started
--   dstop - date when gathering was finished if status =  COMPLETE,
--   will be finished if status = AUTOGATHERING, 
--   had to be finished if status = BADSTATS,
--   dstarted if status = MANUALGATHERING,
--   the following parameters defined only if status = COMPLETE
--   pvalue   - parameter value to get
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--   ORA-20002: Bad user statistics table, may need to upgrade it
--   ORA-20003: Unable to get system statistics
--   ORA-20004: Parameter doesn't exist 
--

procedure set_system_stats (
   pname            varchar2,
   pvalue           number,
   stattab          varchar2 default null, 
   statid           varchar2 default null,
   statown          varchar2 default null);

--
-- Input arguments:
--   pname - parameter name to set
--   pvalue   - parameter value to set
--   stattab - The user stat table identifier describing from where to get
--      the current statistics info. If stattab is null, the statistics info
--      will be obtained directly from the dictionary.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab.
--   statown - The schema containing stattab (if different then ownname)
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--   ORA-20001: Invalid input value
--   ORA-20002: Bad user statistics table, may need to upgrade it
--   ORA-20003: Unable to set system statistics
--   ORA-20004: Parameter doesn't exist 
--


procedure delete_system_stats (
   stattab         varchar2  default nulL, 
   statid          varchar2  default nulL,
   statown         varchar2  default null);

--
-- Deletes system statistics
--
-- Input arguments:
--   stattab - The user stat table identifier describing from where
--      to delete the statistics.  If stattab is null, the statistics
--      will be deleted directly from the dictionary.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab (Only pertinent if stattab is not NULL).
--   statown - The schema containing stattab (if different then ownname)
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--   ORA-20002: Bad user statistics table, may need to upgrade it
--

procedure import_system_stats (
   stattab  varchar2, 
   statid   varchar2 default null,
   statown  varchar2 default null);

--
-- Retrieves system statistics from the user
-- stat table identified by stattab and stores it in the
-- dictionary
--
-- Input arguments:
--   stattab - The user stat table identifier describing from where
--      to retrieve the statistics.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab.
--   statown - The schema containing stattab (if different then ownname)
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--              if ORA-20000 shows "no statistics are imported", several
--              possible reasons are: (1) user specified statid does not
--              exist; (2) statistics are locked; (3) objects in the 
--              stattab no longer exist in the current database  
--   ORA-20001: Invalid or inconsistent values in the user stat table
--   ORA-20002: Bad user statistics table, may need to upgrade it
--   ORA-20003: Unable to import system statistics
--


procedure export_system_stats (
   stattab  varchar2, 
   statid   varchar2 default null,
   statown  varchar2 default null);

--
-- Retrieves system statistics and stores it
-- in the user stat table identified by stattab
--
-- Input arguments:
--   stattab - The user stat table identifier describing where
--      to store the statistics.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab.
--   statown - The schema containing stattab (if different then ownname)
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--   ORA-20002: Bad user statistics table, may need to upgrade it
--   ORA-20003: Unable to export system statistics
--


  procedure gather_fixed_objects_stats
    (stattab varchar2 default null, statid varchar2 default null,
     statown varchar2 default null,
     no_invalidate boolean default 
       to_no_invalidate_type(get_param('NO_INVALIDATE')));
--
-- Gather statistics for fixed tables. 
-- To run this procedure, you must have the SYSDBA or ANALYZE ANY DICTIONARY
-- system privilege. 
--
-- Input arguments:
--   stattab - The user stat table identifier describing where to save
--      the current statistics.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab.
--   statown - The schema containing stattab (if different then ownname)
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--      The procedure invalidates the dependent cursors immediately
--      if set to FALSE.
--      Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--      invalidate dependend cursors. This is the default. The default 
--      can be changed using set_param procedure.
-- Exceptions:
--   ORA-20000: insufficient privileges
--   ORA-20001: Bad input value
--   ORA-20002: Bad user statistics table, may need to upgrade it
--

  function report_gather_fixed_obj_stats
    (stattab varchar2 default null, statid varchar2 default null,
     statown varchar2 default null,
     no_invalidate boolean default
       to_no_invalidate_type(get_param('NO_INVALIDATE')),
     detail_level varchar2 default 'TYPICAL',
     format varchar2 default 'TEXT')
  return clob;

--
-- This procedure runs gather_fixed_objects_stats in reporting mode. That is,
-- stats are not actually collected, but all the objects that will be
-- affected when gather_fixed_objects_stats is invoked are reported.
-- The detail level for the report is defined by the detail_level 
-- input parameter. Please see the comments for report_single_stats_operation 
-- on possible values for detail_level and format. 
-- For all other input parameters, please see the comments on 
-- gather_fixed_objects_stats.

  procedure delete_fixed_objects_stats(
        stattab varchar2 default null, statid varchar2 default null,
        statown varchar2 default null,
        no_invalidate boolean default 
        to_no_invalidate_type(get_param('NO_INVALIDATE')),
        force boolean default FALSE);
--
-- Deletes statistics for fixed tables
-- To run this procedure, you must have the SYSDBA or ANALYZE ANY DICTIONARY
-- system privilege. 
--
-- Input arguments:
--   stattab - The user stat table identifier describing from where
--      to delete the statistics.  If stattab is null, the statistics
--      will be deleted directly in the dictionary.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab (Only pertinent if stattab is not NULL).
--   statown - The schema containing stattab (if different then ownname)
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--      The procedure invalidates the dependent cursors immediately
--      if set to FALSE.
--      Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--      invalidate dependend cursors. This is the default. The default 
--      can be changed using set_param procedure.
--   force - Ignores the statistics lock on objects and delete
--           the statistics if set to TRUE.
--
-- Exceptions:
--   ORA-20000: insufficient privileges
--   ORA-20002: Bad user statistics table, may need to upgrade it
--


  procedure export_fixed_objects_stats(
        stattab varchar2, statid varchar2 default null,
        statown varchar2 default null);
--
-- Retrieves statistics for fixed tables and stores them in the user 
-- stat table identified by stattab
-- To run this procedure, you must have the SYSDBA or ANALYZE ANY DICTIONARY
-- system privilege. 
--
-- Input arguments:
--   stattab - The user stat table identifier describing where
--      to store the statistics.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab.
--   statown - The schema containing stattab (if different then ownname)
--
-- Exceptions:
--   ORA-20000: insufficient privileges
--   ORA-20002: Bad user statistics table, may need to upgrade it
--


  procedure import_fixed_objects_stats(
        stattab varchar2, statid varchar2 default null,
        statown varchar2 default null, 
        no_invalidate boolean default 
           to_no_invalidate_type(get_param('NO_INVALIDATE')),
        force boolean default FALSE);
--
-- Retrieves statistics for fixed tables from the user stat table and 
-- stores them in the dictionary 
-- To run this procedure, you must have the SYSDBA or ANALYZE ANY DICTIONARY
-- system privilege. 
-- The statistics will be imported as pending in case PUBLISH preference
-- is set to FALSE.
--
-- Input arguments:
--   stattab - The user stat table identifier describing from where
--      to retrieve the statistics.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab.
--   statown - The schema containing stattab (if different then ownname)
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--      The procedure invalidates the dependent cursors immediately
--      if set to FALSE.
--      Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--      invalidate dependend cursors. This is the default. The default 
--      can be changed using set_param procedure.
--   force - Override statistics lock.
--     TRUE- Ignores the statistics lock on objects and import
--           the statistics. 
--     FALSE-The statistics of an object will be imported only if it 
--           is not locked. 
--
-- Exceptions:
--   ORA-20000: insufficient privileges
--              if ORA-20000 shows "no statistics are imported", several
--              possible reasons are: (1) user specified statid does not
--              exist; (2) statistics are locked; (3) objects in the 
--              stattab no longer exist in the current database  
--   ORA-20001: Invalid or inconsistent values in the user stat table
--   ORA-20002: Bad user statistics table, may need to upgrade it
--

  procedure gather_dictionary_stats
    (comp_id varchar2 default null,
     estimate_percent number default DEFAULT_ESTIMATE_PERCENT,
     block_sample boolean default FALSE,
     method_opt varchar2 default DEFAULT_METHOD_OPT,
     degree number default DEFAULT_DEGREE_VALUE,
     granularity varchar2 default DEFAULT_GRANULARITY,
     cascade boolean default DEFAULT_CASCADE,
     stattab varchar2 default null, statid varchar2 default null,
     options varchar2 default 'GATHER AUTO', objlist out ObjectTab,
     statown varchar2 default null,
     no_invalidate boolean default 
       to_no_invalidate_type(get_param('NO_INVALIDATE')),
     stattype varchar2 default 'DATA',
     obj_filter_list ObjectTab default null);
  procedure gather_dictionary_stats
    (comp_id varchar2 default null,
     estimate_percent number default DEFAULT_ESTIMATE_PERCENT,
     block_sample boolean default FALSE,
     method_opt varchar2 default DEFAULT_METHOD_OPT,
     degree number default DEFAULT_DEGREE_VALUE,
     granularity varchar2 default DEFAULT_GRANULARITY,
     cascade boolean default DEFAULT_CASCADE,
     stattab varchar2 default null, statid varchar2 default null,
     options varchar2 default 'GATHER AUTO', statown varchar2 default null,
     no_invalidate boolean default 
       to_no_invalidate_type(get_param('NO_INVALIDATE')),
     stattype varchar2 default 'DATA',
     obj_filter_list ObjectTab default null);

--
-- Gather statistics for dictionary schemas 'SYS', 'SYSTEM' and schemas of
-- RDBMS components.
-- To run this procedure, you must have the SYSDBA OR 
-- both ANALYZE ANY DICTIONARY and ANALYZE ANY system privilege. 
--
-- Input arguments:
--   comp_id - component id of the schema to analyze (NULL means schemas
--             of all RDBMS components). 
--             Please refer to comp_id column of dba_registry view.
--             The procedure always gather stats on 'SYS' and 'SYSTEM' schemas
--             regardless of this argument.
--   estimate_percent - Percentage of rows to estimate (NULL means compute).
--      The valid range is [0.000001,100].  Use the constant
--      DBMS_STATS.AUTO_SAMPLE_SIZE to have Oracle determine the
--      appropriate sample size for good statistics. This is the default.
--      The default value can be changed using set_param procedure.
--   block_sample - whether or not to use random block sampling instead of
--      random row sampling.  Random block sampling is more efficient, but
--      if the data is not randomly distributed on disk then the sample values
--      may be somewhat correlated.  Only pertinent when doing an estimate 
--      statistics.
--   method_opt - method options of the following format 
--
--         method_opt  := FOR ALL [INDEXED | HIDDEN] COLUMNS [size_clause]
--
--         size_clause := SIZE [integer | auto | skewonly | repeat],
--                        where integer is between 1 and 2048
--
--      default is FOR ALL COLUMNS SIZE AUTO.
--      The default value can be changed using set_param procedure.
--      This value will be passed to all of the individual tables.
--   degree - degree of parallelism (NULL means use table default value which
--      is specified by DEGREE clause in CREATE/ALTER TABLE statement)
--      Use the constant DBMS_STATS.DEFAULT_DEGREE for the default value
--      based on the initialization parameters.
--      default for degree is NULL.
--      The default value can be changed using set_param procedure.
--   granularity - the granularity of statistics to collect (only pertinent
--      if the table is partitioned)
--     'AUTO' - the procedure determines what level of statistics to collect
--     'GLOBAL AND PARTITION' - gather global- and partition-level statistics
--     'SUBPARTITION' - gather subpartition-level statistics
--     'PARTITION' - gather partition-level statistics
--     'GLOBAL' - gather global statistics
--     'ALL' - gather all (subpartition, partition, and global) statistics
--     default for granularity is AUTO. 
--     The default value can be changed using set_param procedure.
--   cascade - gather statistics on the indexes as well.
--      Use the constant DBMS_STATS.AUTO_CASCADE to have Oracle determine 
--      whether index stats to be collected or not. This is the default.
--      The default value can be changed using set_param procedure.
--      Using this option is equivalent to running the gather_index_stats 
--      procedure on each of the indexes in the schema in addition to 
--      gathering table and column statistics.
--   stattab - The user stat table identifier describing where to save
--      the current statistics.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab.
--   options - further specification of which objects to gather statistics for
--      'GATHER' - gather statistics on all objects in the schema
--      'GATHER AUTO' - gather all necessary statistics automatically.  Oracle
--        implicitly determines which objects need new statistics, and
--        determines how to gather those statistics.  When 'GATHER AUTO' is
--        specified, the only additional valid parameters are no_invalidate, 
--        comp_id, stattab,
--        statid and statown; all other parameter settings will be
--        ignored. Also, return a list of objects processed.
--      'GATHER STALE' - gather statistics on stale objects as determined
--        by looking at the *_tab_modifications views.  Also, return
--        a list of objects found to be stale.
--      'GATHER EMPTY' - gather statistics on objects which currently
--        have no statistics.  also, return a list of objects found
--        to have no statistics.
--      'LIST AUTO' - return list of objects to be processed with 'GATHER AUTO'
--      'LIST STALE' - return list of stale objects as determined
--        by looking at the *_tab_modifications views
--      'LIST EMPTY' - return list of objects which currently
--        have no statistics
--   objlist - list of objects found to be stale or empty
--   statown - The schema containing stattab (if different from current schema)
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--     The procedure invalidates the dependent cursors immediately
--     if set to FALSE.
--     Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--     invalidate dependend cursors. This is the default. The default 
--     can be changed using set_param procedure.
--     When 'cascade' option is specified, not pertinent with certain types
--     of indexes described in the gather_index_stats section.
--   obj_filter_list - a list of object filters. When provided, 
--     gather_dictionary_stats will only gather statistics on the objects which
--     satisfy at least one of the object filters as needed. Please refer to 
--     obj_filter_list in gather_database_stats
-- Exceptions:
--   ORA-20000: Schema does not exist or insufficient privileges
--   ORA-20001: Bad input value
--   ORA-20002: Bad user statistics table, may need to upgrade it
--

 function report_gather_dictionary_stats
    (comp_id varchar2 default null,
     estimate_percent number default DEFAULT_ESTIMATE_PERCENT,
     block_sample boolean default FALSE,
     method_opt varchar2 default DEFAULT_METHOD_OPT,
     degree number default DEFAULT_DEGREE_VALUE,
     granularity varchar2 default DEFAULT_GRANULARITY,
     cascade boolean default DEFAULT_CASCADE,
     stattab varchar2 default null, statid varchar2 default null,
     options varchar2 default 'GATHER AUTO', statown varchar2 default null,
     no_invalidate boolean default 
       to_no_invalidate_type(get_param('NO_INVALIDATE')),
     stattype varchar2 default 'DATA',
     obj_filter_list ObjectTab default null,
     detail_level varchar2 default 'TYPICAL',
     format varchar2 default 'TEXT') 
  return clob;

--
-- This procedure runs gather_dictionary_stats in reporting mode. That is,
-- stats are not actually collected, but all the objects that will be
-- affected when gather_dictionary_stats is invoked are reported.
-- The detail level for the report is defined by the detail_level 
-- input parameter. Please see the comments for report_single_stats_operation 
-- on possible values for detail_level and format. 
-- For all other input parameters, please see the comments on 
-- gather_dictionary_stats.

  procedure delete_dictionary_stats(
        stattab varchar2 default null, statid varchar2 default null,
        statown varchar2 default null,
        no_invalidate boolean default 
          to_no_invalidate_type(get_param('NO_INVALIDATE')),
        stattype varchar2 default 'ALL',
        force boolean default FALSE,
        stat_category varchar2 default DEFAULT_DEL_STAT_CATEGORY);
--
-- Deletes statistics for all dictionary schemas ('SYS', 'SYSTEM' and
-- RDBMS component schemas) 
--
-- To run this procedure, you must have the SYSDBA OR 
-- both ANALYZE ANY DICTIONARY and ANALYZE ANY system privilege. 
--
-- Input arguments:
--   stattab - The user stat table identifier describing from where
--      to delete the statistics.  If stattab is null, the statistics
--      will be deleted directly in the dictionary.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab (Only pertinent if stattab is not NULL).
--   statown - The schema containing stattab (if different from current schema)
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--      The procedure invalidates the dependent cursors immediately
--      if set to FALSE.
--      Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--      invalidate dependend cursors. This is the default. The default 
--      can be changed using set_param procedure.
--   stattype - The type of statistics to be deleted
--     ALL   - both data and cache statistics will be deleted
--     CACHE - only cache statistics will be deleted 
--   force - Ignores the statistics lock on objects and delete
--           the statistics if set to TRUE.
--   stat_category - what statistics to delete. It accepts multiple values
--   separated by comma. The values we support now are 'OBJECT_STATS' 
--   (i.e., table statistics, column statistics and index statistics) and 
--   'SYNOPSES'. The default is 'OBJECT_STATS, SYNOPSES'
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--   ORA-20002: Bad user statistics table, may need to upgrade it
--

  procedure export_dictionary_stats(
        stattab varchar2, statid varchar2 default null,
        statown varchar2 default null,
        stat_category varchar2 default DEFAULT_STAT_CATEGORY);
--
-- Retrieves statistics for all dictionary schemas ('SYS', 'SYSTEM' and
-- RDBMS component schemas) and stores them in the user stat table 
-- identified by stattab
--
-- To run this procedure, you must have the SYSDBA OR 
-- both ANALYZE ANY DICTIONARY and ANALYZE ANY system privilege. 
--
-- Input arguments:
--   stattab - The user stat table identifier describing where
--      to store the statistics.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab.
--   statown - The schema containing stattab (if different from current schema)
--   stat_category - what statistics to export. It accepts multiple values
--   separated by comma. The values we support now are 'OBJECT_STATS' 
--   (i.e., table statistics, column statistics and index statistics) and 
--   'SYNOPSES'. However SYNOPSES can only be exported along with 
--    OBJECT_STATS. Therefore only valid combinations are 
--          OBJECT_STATS 
--          OBJECT_STATS, SYNOPSES
--   The default value is OBJECT_STATS that can be changed usig statistics
--   preference.
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--   ORA-20002: Bad user statistics table, may need to upgrade it
--
  procedure import_dictionary_stats(
        stattab varchar2, statid varchar2 default null,
        statown varchar2 default null,
        no_invalidate boolean default 
          to_no_invalidate_type(get_param('NO_INVALIDATE')),
        force boolean default FALSE,
        stat_category varchar2 default DEFAULT_STAT_CATEGORY);
--
-- Retrieves statistics for all dictionary schemas ('SYS', 'SYSTEM' and
-- RDBMS component schemas) from the user stat table and stores them in 
-- the dictionary 
-- The statistics will be imported as pending in case PUBLISH preference
-- is set to FALSE.
--
-- To run this procedure, you must have the SYSDBA OR 
-- both ANALYZE ANY DICTIONARY and ANALYZE ANY system privilege. 
--
-- Input arguments:
--   stattab - The user stat table identifier describing from where
--      to retrieve the statistics.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab.
--   statown - The schema containing stattab (if different from current schema)
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--      The procedure invalidates the dependent cursors immediately
--      if set to FALSE.
--      Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--      invalidate dependend cursors. This is the default. The default 
--      can be changed using set_param procedure.
--   force - Override statistics lock.
--     TRUE- Ignores the statistics lock on objects and import
--           the statistics. 
--     FALSE-The statistics of an object will be imported only if it 
--           is not locked. 
--           ie if both DATA and CACHE statistics is locked, it will not
--           import anything. If CACHE statistics of an object is locked, 
--           only DATA statistics will be imported and vice versa.
--   stat_category - what statistics to import. It accepts multiple values
--   separated by comma. The values we support now are 'OBJECT_STATS' 
--   (i.e., table statistics, column statistics and index statistics) and 
--   'SYNOPSES'. However SYNOPSES can only be imported along with 
--    OBJECT_STATS. Therefore only valid combinations are 
--          OBJECT_STATS 
--          OBJECT_STATS, SYNOPSES
--   The default value is OBJECT_STATS that can be changed usig statistics
--   preference.
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--              if ORA-20000 shows "no statistics are imported", several
--              possible reasons are: (1) user specified statid does not
--              exist; (2) statistics are locked; (3) objects in the 
--              stattab no longer exist in the current database  
--   ORA-20001: Invalid or inconsistent values in the user stat table
--   ORA-20002: Bad user statistics table, may need to upgrade it
--

  procedure lock_table_stats(
    ownname varchar2, 
    tabname varchar2, 
    stattype varchar2 default 'ALL');
-- 
-- This procedure enables the user to lock the statistics on the table
--
-- Input arguments:
--   ownname  - schema of table to lock
--   tabname  - name of the table
--   stattype - type of statistics to be locked
--     'CACHE'  - lock only caching statistics  
--     'DATA'   - lock only data statistics  
--     'ALL'    - lock both data and caching statistics. This is the default  


  procedure lock_partition_stats(
    ownname varchar2,
    tabname varchar2,
    partname varchar2);

--
-- This procedure enables the user to lock statistics for a partition
-- 
-- Input arguments:
--   ownname   - schema of the table to lock
--   tabname   - name of the table
--   partname  - name of the partition
--   


  procedure lock_schema_stats(
    ownname varchar2, 
    stattype varchar2 default 'ALL');

-- 
-- This procedure enables the user to lock the statistics of all
-- tables of a schema
--
-- Input arguments:
--   ownname  - schema of tables to lock
--   stattype - type of statistics to be locked
--     'CACHE'  - lock only caching statistics  
--     'DATA'   - lock only data statistics  
--     'ALL'    - lock both data and caching statistics. This is the default  


  procedure unlock_table_stats(
    ownname varchar2, 
    tabname varchar2, 
    stattype varchar2 default 'ALL');
-- 
-- This procedure enables the user to unlock the statistics on the table
--
-- Input arguments:
--   ownname  - schema of table to unlock
--   tabname  - name of the table
--   stattype - type of statistics to be unlocked
--     'CACHE'  - unlock only caching statistics  
--     'DATA'   - unlock only data statistics  
--     'ALL'    - unlock both data and caching statistics. This is the default


  procedure unlock_partition_stats(
    ownname varchar2,
    tabname varchar2,
    partname varchar2);

--
-- This procedure enables the user to unlock statistics for a partition
-- 
-- Input arguments:
--   ownname   - schema of table to unlock
--   tabname   - name of the table
--   partname  - name of the partition
--   


  procedure unlock_schema_stats(
    ownname varchar2, 
    stattype varchar2 default 'ALL');
-- 
-- This procedure enables the user to unlock the statistics of all
-- tables of a schema
--
-- Input arguments:
--   ownname  - schema of tables to unlock
--   stattype - type of statistics to be unlocked
--     'CACHE'  - unlock only caching statistics  
--     'DATA'   - unlock only data statistics  
--     'ALL'    - unlock both data and caching statistics. This is the default

  procedure restore_table_stats(
    ownname varchar2, 
    tabname varchar2, 
    as_of_timestamp timestamp with time zone,
    restore_cluster_index boolean default FALSE,
    force boolean default FALSE,
    no_invalidate boolean default 
      to_no_invalidate_type(get_param('NO_INVALIDATE')));
-- 
-- This procedure enables the user to restore statistics of a table as of
-- a specified timestamp (as_of_timestamp). The procedure will restore 
-- statistics of associated indexes and columns as well. If the table 
-- statistics were locked at the specified timestamp the procedure will 
-- lock the statistics.
-- Note:
--   The procedure may not restore statistics correctly if analyze interface 
--   is used for computing/deleting statistics.
--   Old statistics versions are not saved when SYSAUX tablespace is
--   offline, this affects restore functionality. 
--   The procedure may not restore statistics if the table defn is
--   changed (eg: column added/deleted, partition exchanged etc).
--   Also it will not restore stats if the object is created after
--   the specified timestamp.
--   The procedure will not restore user defined statistics.
-- Input arguments:
--   ownname  - schema of table for which statistics to be restored
--   tabname  - table name 
--   as_of_timestamp - statistics as of this timestamp will be restored.
--   restore_cluster_index - If the table is part of a cluster,
--     restore statistics of the cluster index if set to TRUE.
--   force - restore statistics even if the table statistics are locked.
--           if the table statistics were not locked at the specified 
--           timestamp, it will unlock the statistics 
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--      The procedure invalidates the dependent cursors immediately
--      if set to FALSE.
--      The procedure invalidates the dependent cursors immediately
--      if set to FALSE.
--      Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--      invalidate dependend cursors. This is the default. The default 
--      can be changed using set_param procedure.
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--   ORA-20001: Invalid or inconsistent values 
--   ORA-20006: Unable to restore statistics , statistics history not available

  procedure restore_schema_stats(
    ownname varchar2, 
    as_of_timestamp timestamp with time zone,
    force boolean default FALSE,
    no_invalidate boolean default 
      to_no_invalidate_type(get_param('NO_INVALIDATE')));
-- 
-- This procedure enables the user to restore statistics of all tables of
-- a schema as of a specified timestamp (as_of_timestamp). 

-- Input arguments:
--   ownname  - schema of tables for which statistics to be restored
--   as_of_timestamp - statistics as of this timestamp will be restored.
--   force - restore statistics of tables even if their statistics are locked.
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--      The procedure invalidates the dependent cursors immediately
--      if set to FALSE.
--      Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--      invalidate dependend cursors. This is the default. The default 
--      can be changed using set_param procedure.
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--   ORA-20001: Invalid or inconsistent values 
--   ORA-20006: Unable to restore statistics , statistics history not available

  procedure restore_database_stats(
    as_of_timestamp timestamp with time zone,
    force boolean default FALSE,
    no_invalidate boolean default 
      to_no_invalidate_type(get_param('NO_INVALIDATE')));
-- 
-- This procedure enables the user to restore statistics of all tables of
-- the database as of a specified timestamp (as_of_timestamp). 

-- Input arguments:
--   as_of_timestamp - statistics as of this timestamp will be restored.
--   force - restore statistics of tables even if their statistics are locked.
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--      The procedure invalidates the dependent cursors immediately
--      if set to FALSE.
--      Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--      invalidate dependend cursors. This is the default. The default 
--      can be changed using set_param procedure.
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--   ORA-20001: Invalid or inconsistent values 
--   ORA-20006: Unable to restore statistics , statistics history not available

  procedure restore_fixed_objects_stats(
    as_of_timestamp timestamp with time zone,
    force boolean default FALSE,
    no_invalidate boolean default 
      to_no_invalidate_type(get_param('NO_INVALIDATE')));
-- 
-- This procedure enables the user to restore statistics of all fixed tables
-- as of a specified timestamp (as_of_timestamp). 
-- To run this procedure, you must have the SYSDBA or ANALYZE ANY DICTIONARY
-- system privilege.
--
-- Input arguments:
--   as_of_timestamp - statistics as of this timestamp will be restored.
--   force - restore statistics of tables even if their statistics are locked.
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--      The procedure invalidates the dependent cursors immediately
--      if set to FALSE.
--      Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--      invalidate dependend cursors. This is the default. The default 
--      can be changed using set_param procedure.
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--   ORA-20001: Invalid or inconsistent values 
--   ORA-20006: Unable to restore statistics , statistics history not available

  procedure restore_dictionary_stats(
    as_of_timestamp timestamp with time zone,
    force boolean default FALSE,
    no_invalidate boolean default 
      to_no_invalidate_type(get_param('NO_INVALIDATE')));
-- 
-- This procedure enables the user to restore statistics of all dictionary 
-- tables (tables of 'SYS', 'SYSTEM' and RDBMS component schemas)
-- as of a specified timestamp (as_of_timestamp). 
--
-- To run this procedure, you must have the SYSDBA OR
-- both ANALYZE ANY DICTIONARY and ANALYZE ANY system privilege.
--
-- Input arguments:
--   as_of_timestamp - statistics as of this timestamp will be restored.
--   force - restore statistics of tables even if their statistics are locked.
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--      The procedure invalidates the dependent cursors immediately
--      if set to FALSE.
--      Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--      invalidate dependend cursors. This is the default. The default 
--      can be changed using set_param procedure.
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--   ORA-20001: Invalid or inconsistent values 
--   ORA-20006: Unable to restore statistics , statistics history not available

  procedure restore_system_stats(
    as_of_timestamp timestamp with time zone);
-- 
-- This procedure enables the user to restore system statistics 
-- as of a specified timestamp (as_of_timestamp). 
--
-- Input arguments:
--   as_of_timestamp - statistics as of this timestamp will be restored.
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--   ORA-20001: Invalid or inconsistent values 
--   ORA-20006: Unable to restore statistics , statistics history not available

  procedure purge_stats(
    before_timestamp timestamp with time zone);
-- 
-- This procedure enables the user to purge old versions of statistics 
-- saved in dictionary
--
-- To run this procedure, you must have the SYSDBA OR 
-- both ANALYZE ANY DICTIONARY and ANALYZE ANY system privilege. 
--
-- Input arguments:
--   before_timestamp - versions of statistics saved before this timestamp
--             will be purged. if null, it uses the purging policy 
--             used by automatic purge. The automatic purge deletes all
--             history older than 
--               min(current time - stats history retention, 
--                   time of recent analyze in the system - 1). 
--             stats history retention value can be changed using 
--             alter_stats_history_retention procedure. 
--             The default is 31 days. 
--
--   When before_timestamp is specified as DBMS_STATS.PURGE_ALL, all stats 
--   history tables are truncated. Please note that interrupting
--   (e.g., hitting Ctrl-C) purge_stats while it is running with PURGE_ALL 
--   option may lead to inconsistencies. Hence, please avoid interrupting 
--   purge_stats manually.
--             
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--   ORA-20001: Invalid or inconsistent values 

  procedure alter_stats_history_retention(
    retention in number);
--
-- This procedure enables the user to change stats history retention
-- value.  Stats history retention is used by both the automatic 
-- purge and purge_stats procedure. 
--  
--
-- To run this procedure, you must have the SYSDBA OR 
-- both ANALYZE ANY DICTIONARY and ANALYZE ANY system privilege. 
--
-- Input arguments:
--   retention - The retention time in days. The stats history will be
--               ratained for at least these many number of days.
--               The valid range is [1,365000].  Also the following
--               values can be used for special purposes.
--                 0 - old stats are never saved. The automatic purge will
--                     delete all stats history
--                -1 - stats history is never purged by automatic purge.
--                null -  change stats history retention to default value
 
--               

  function get_stats_history_retention return number;

-- This function returns the current retention value.

  function get_stats_history_availability
             return timestamp with time zone;

--  This function returns oldest timestamp where stats history 
--  is available.
--  Users can not restore stats to timestamp older than  this one.


  procedure copy_table_stats(
        ownname varchar2,
        tabname varchar2,
        srcpartname varchar2,
        dstpartname varchar2,
        scale_factor number DEFAULT 1,
        flags number DEFAULT null,
        force boolean DEFAULT FALSE);

--
-- This procedure copies the statistics of the source [sub] partition to the 
-- destination [sub] partition. It also copies statistics of all dependent 
-- objects such as columns and local indexes. If the statistics for source 
-- are not available, then nothing is copied. It can optionally scale the 
-- statistics (such as the number of blks, or number of rows) based on the 
-- given scale_factor.
-- 
-- Usage notes:
--
-- a) To invoke this procedure you must be owner of the table, or you need 
--   the ANALYZE ANY privilege. For objects owned by SYS, you need to be 
--   either the owner of the table, or you need the ANALYZE ANY DICTIONARY 
--   privilege or the SYSDBA privilege.
--
-- b) This procedure updates the minimum and maximum values of destination 
--   partition for the first partitioning column as follows:
--
--  - If the partitioning type is HASH the minimum and maximum values of the 
--    destination partition are same as that of the source partition.
--
--  - If the partitioning type is LIST then
--     if the destination partition is a NOT DEFAULT partition then
--
--        The minimum value of the destination partition is set to the 
--        minimum value of the value list that describes the destination 
--        partition.
--        The maximum value of the destination partition is set to the 
--        maximum value of the value list that describes the destination 
--        partition.
--
--     Alternatively, if the destination partition is a DEFAULT partition, then
--       The minimum value of the destination partition is set to the minimum 
--       value of the source partition
--       The maximum value of the destination partition is set to the maximum 
--       value of the source partition
--
--  - If the partitioning type is RANGE then

--     The minimum value of the destination partition is set to the high bound 
--     of previous partition unless the destination partition is the first 
--     partition. For the first partition, the minimum value is set to the
--     high bound of the destination partition.
--     The maximum value of the destination partition is set to the high bound 
--     of the destination partition unless the high bound of the destination 
--     partition is MAXVALUE, in which case the maximum value of the 
--     destination partition is set to the high bound of the previous 
--     partition.
--
-- c) Additional modification to minimum and maximum values if the 
--   partitioning type is RANGE:
--
--   - If the source partition column's minimum value is equal to its maximum 
--     value, and both are equal to the source partition's lower bound, and 
--     it has a single distinct value, then the destination partition column's
--     minimum and maximum values are both set to the destination partition's 
--     lower bound. This is done for all partitioning columns.
-- 
--   - If the above condition does not apply, second and subsequent 
--     partitioning columns are updated as follows:
--     The destination partition column's maximum value is set to the greater 
--     of the destination partition upper bound and the source partition 
--     column's maximum value, with the following exception: if the 
--     destination partition is D and its preceding partition is D-1 and the 
--     key column to be adjusted is Cn, the maximum value for Cn is set to 
--     the upper bound of D (ignoring the maximum value of the source 
--     partition column) provided that the upper bounds of the previous key 
--     column Cn-1 are the same in partitions D and D-1.
-- 
-- d) If the minimum and maximum values are different for a column after 
--   modifications, and if the number of distinct values is less than 1,
--   the number of disctinct values is updated as 2.
--
-- e) This procedure does not copy statistics of the underlying subpartitions 
--   if the source/destination is a partition of a composite partitioned table.
--
-- f) If the source and destination points to a subpartition, the minimum
--    and maximum of partitioning column(s) are adjusted based on bounds of
--    corresponding partition using same rules outlined above.
--
-- Parameters:
--   ownname      - Schema of the table of source and destination 
--                  [sub] partitions
--   tabname      - Table name of source and destination [sub] partitions
--   srcpartname  - Source [sub] partition
--   dtspartname  - Destination [sub] partition
--   scale_factor - Scale factor to scale nblks, nrows etc. in dstpartname
--   flags        - Specify DBMS_STATS.UPDATE_GLOBAL_STATS to update the 
--                  global column statistics at partition or table level based 
--                  on the new bounds of the destination [sub] partition.
--   force        - When value of this argument is TRUE copy statistics even 
--                  if the destination [sub]partition is locked

-- Exceptions:
--   ORA-20000: Invalid partition name
--   ORA-20001: Bad input value
--


  function diff_table_stats_in_stattab(
      ownname      varchar2,
      tabname      varchar2,
      stattab1     varchar2,
      stattab2     varchar2 default null,
      pctthreshold number   default 10,
      statid1      varchar2 default null,
      statid2      varchar2 default null,
      stattab1own  varchar2 default null,
      stattab2own  varchar2 default null)
   return DiffRepTab pipelined;

-- Input arguments:
--   ownname  - owner of the table. Specify null for current schema.
--   tabname  - table for which statistics are to be compared. 
--   stattab1 - user stats table 1.
--   stattab2 - user stats table 2. If null, statistics in stattab1
--              is compared with current statistics in dictionary.
--              This is the default.
--              Specify same table as stattab1 to compare two sets
--              within the stats table (Please see statid below).
--   pctthreshold - The function report difference in statistics
--                  only if it exceeds this limit. The default value is 10.
--   statid1  - (optional) identifies statistics set within stattab1.
--   statid2  - (optional) identifies statistics set within stattab2.
--   stattab1own - The schema containing stattab1 (if different than ownname)
--   stattab2own - The schema containing stattab2 (if different than ownname)
--

  function diff_table_stats_in_history(
      ownname      varchar2,
      tabname      varchar2,
      time1        timestamp with time zone,
      time2        timestamp with time zone default null,
      pctthreshold number   default 10)
    return DiffRepTab pipelined;

-- Input arguments:
--   ownname  - owner of the table. Specify null for current schema.
--   tabname  - table for which statistics are to be compared. 
--   time1    - first time stamp
--   time2    - second time stamp
-- 
--   pctthreshold - The function report difference in statistics
--                  only if it exceeds this limit. The default value is 10.
--   
--   NOTE:
--   If the second timestamp is null, the function compares the current
--   statistics in dictionary with the statistics as of the other timestamp.

  function diff_table_stats_in_pending(
      ownname      varchar2,
      tabname      varchar2,
      time_stamp   timestamp with time zone default null,
      pctthreshold number   default 10)
    return DiffRepTab pipelined;

-- Input arguments:
--   ownname  - owner of the table. Specify null for the current schema.
--   tabname  - table for which statistics are to be compared. 
--   time_stamp - time stamp to get statistics from the history
-- 
--   pctthreshold - The function report difference in statistics
--                  only if it exceeds this limit. The default value is 10.
--   
--   NOTE:
--   If the time_stamp parameter is null, the function compares the current
--   statistics in the dictionary with the pending statistics.  This is the 
--   default



  function create_extended_stats(
      ownname    varchar2,
      tabname    varchar2,
      extension  varchar2) 
    return varchar2;

-- This function creates a column stats entry in the system for a user
-- specified column group or an expression in a table. Statistics for this
-- extension will be gathered when user or auto statistics gathering job
-- gathers statistics for the table. We call statistics for such an extension,
-- "extended statistics".  This function returns the name of this newly created
-- entry for the extension.  If the extension already exists then this function
-- throws an error.

-- 
--  Parameters:
--      ownname       -- owner name of a table
--      tabname       -- table name
--      extension     -- can be either a column group or an expression. Suppose
--                       the specified table has two column c1, c2. An example 
--                       column group can be '(c1, c2)', an example expression 
--                       can be '(c1 + c2)'.
-- 
--  Notes:
-- 
--      1. An extension cannot contain a virtual column.
-- 
--      2. You can not create extensions on tables owned by SYS. 
--
--      3. You can not create extensions on cluster tables, index organized 
--         tables, temporary tables, external tables.
--
--      4. Total number of extensions in a table cannot be greater than
--         maximum of (20, 10 % of number of non-virtual columns in the table).
-- 
--      5. Number of columns in a column group must be in the range [2, 32].
-- 
--      6. A column can not appear more than once in a column group.
-- 
--      7. Column group can not contain expressions.
--
--      8. An expression must contain at least one column.
--
--      9. An expression can not contain subquery.
--
--     10. COMPATIBLE parameter needs to be 11.0.0.0.0 or greater.
-- 
-- Exceptions:
--
--   ORA-20000: Insufficient privileges / creating extension is not supported
--
--   ORA-20001: Error when processing extension
--
--   ORA-20007: Extension already exist
--
--   ORA-20008: Reached the upper limit on number of extensions 
--  

  function create_extended_stats(
      ownname    varchar2,
      tabname    varchar2)
    return clob;

-- This function is very similar to the function above but creates statistics
-- extension based on the column group usage recorded by seed_col_usage 
-- procedure. This function returns a report of extensions created.
-- 
-- 
--  Parameters:
--      ownname       -- owner name of a table. If null, all schemas in the
--                       database.
--      tabname       -- table name. If null, creates statistics extensions
--                       for all tables of ownname.

  function show_extended_stats_name(
      ownname    varchar2,
      tabname    varchar2,
      extension  varchar2) 
    return varchar2;

--  This function returns the name of the statistics entry that is created for 
--  the user specified extension. It raises error if no extension is created
--  yet
-- 
-- 
--  Parameters:
--      ownname      -- owner name of a table
--      tabname      -- table name
--      extension    -- can be either a column group or an expression
--                      (see description in create_extended_stats)
-- Exceptions:
--   ORA-20000: Insufficient privileges or extension does not exist.
--   ORA-20001: Error when processing extension

  procedure drop_extended_stats(
      ownname    varchar2,
      tabname    varchar2,
      extension  varchar2);

-- This function drops the statistics entry that is created for the user 
-- specified extension. This cancels the effects of created_extended_stats.
-- If no extension is created for the extension, this function
-- throws an error.
-- 
--
--  Parameters:
--      ownname      -- owner name of a table
--      tabname      -- table name
--      extension    -- can be either a column group or an expression
--                      (see description in create_extended_stats)
-- Exceptions:
--   ORA-20000: Insufficient privileges or extension does not exist.
--   ORA-20001: Error when processing extension
--
-- The following procedure is for internal use only.
--
--  gather_database_stats_job_proc
--  cleanup_stats_job_proc
--


  procedure merge_col_usage(
      dblink varchar2);

--
-- This procedure merges column usage information from a source database,
-- specified via a dblink, into the local database.
-- If the column usage information already exists for a given table and 
-- column then it will combine both the local and the remote information
-- otherwise it will insert the remote information as new.
-- This procedure is allowed to execute as SYS only, otherwise you will
-- get an error message 'Insufficient privileges'.
-- In addition the user specified during the creation of the dblink is
-- expected to have privileges to select from tables in the SYS schema.
-- 
-- Parameters:
--     dblink     - dblink name
--
-- Exceptions:
--   ORA-20000: Insufficient privileges 
--   ORA-20001: Parameter dblink cannot be null
--   ORA-20002: Unable to create a temp table
--

  procedure transfer_stats(
      ownname IN VARCHAR2,
      tabname IN VARCHAR2,
      dblink  IN VARCHAR2,
      options IN NUMBER DEFAULT null);
--
-- This procedure transfers statistics for specified table(s) from a remote 
-- database specified by dblink to the local database. It also transfers other 
-- statistics related structures like synopses, DML monitoring information etc.
-- This procedure is allowed to execute as SYS only, otherwise you will
-- get an error message 'Insufficient privileges'.
-- In addition the user specified during the creation of the dblink is
-- expected to have privileges to select from tables in the SYS schema.
--
--
-- Parameters:
--     dblink          - dblink name
--     ownname         - owner name. If null transfers stats for all objects
--                       in all schemas in the database.
--     tabname         - table name. If null, transfers stats for all objects
--                       of ownname.
--     options         - different options. Specify ADD_GLOBAL_PREFS to 
--                       transfer global preferences as well.
-- 
--
-- Exceptions:
--   ORA-20000: Insufficient privileges 
--   ORA-20001: Invalid input
--

  procedure seed_col_usage(
      sqlset_name IN         VARCHAR2,
      owner_name  IN         VARCHAR2,
      time_limit  IN         POSITIVE DEFAULT NULL);

--
-- This procedure seeds column usage information from a statements in 
-- the specified sql tuning set.
-- The procedure will iterate over the SQL statements in the SQL tuning
-- set and compile them in order to seed column usage information for
-- the columns that appear in these statements. This procedure records
-- group of columns as well. Extensions for the recorded group of columns 
-- can be created using create_extended_stats procedure.
-- 
-- Parameters:
--     sqlset_name     - sqlset name
--     owner_name      - owner name
--     time_limit      - time limit (in seconds). Default value is 1800s.
--
-- If sqlset_name and owner_name is null, it records the column (group) usage 
-- information for the statements executed in the system in next time_limit 
-- seconds.
--
-- Exceptions:
--   ORA-20000: Insufficient privileges 
--

  procedure reset_col_usage(
      ownname      varchar2,
      tabname      varchar2);

-- This procedure deletes the recorded column (group) usage information from
-- dictionary. Column (group) usage information is used by gather procedures to
-- automatically determine the columns that require histograms.  Also this
-- information is used by create_extended_stats to create extensions for the
-- group of columns seen in the workload. So resetting column usage will affect
-- these functionalities. This procedure should be used only in very rare cases
-- where you need to start from scratch and need to seed column usage all over
-- again.
--
-- Parameters:
--     ownname         - owner name. If null it resets column usage information
--                       for tables in all schemas in the database.
--     tabname         - table name. If null, resets column usage information
--                       for all tables of ownname.
-- If ownname and tabname is null, it will stop seeding column usage, if 
-- currently seeding column usage using seed_col_usage.

  function report_col_usage(
      ownname      varchar2,
      tabname      varchar2)  return clob;

-- This procedure reports the recorded column (group) usage information.
--
-- Parameters:
--     ownname         - owner name. If null it reports column usage 
--                       information for tables in all schemas in the database.
--     tabname         - table name. If null, it reports column usage 
--                       information for all tables of ownname.
-- Examples:
--     The following example shows column usage information for customers table
--     in SH schema.
--
--SQL> set long 100000
--SQL> set lines 120
--SQL> set pages 0
--SQL> 
--SQL> -- Display column usage
--SQL> select dbms_stats.report_col_usage('sh', 'customers') from dual;
--LEGEND:
--.......
--
--EQ         : Used in single table EQuality predicate
--RANGE      : Used in single table RANGE predicate
--LIKE       : Used in single table LIKE predicate
--NULL       : Used in single table is (not) NULL predicate
--EQ_JOIN    : Used in EQuality JOIN predicate
--NONEQ_JOIN : Used in NON EQuality JOIN predicate
--FILTER     : Used in single table FILTER predicate
--JOIN       : Used in JOIN predicate
--GROUP_BY   : Used in GROUP BY expression
--.............................................................................
--
--#############################################################################
--
--COLUMN USAGE REPORT FOR SH.CUSTOMERS
--....................................
--
--1. COUNTRY_ID                          : EQ
--2. CUST_CITY                           : EQ
--3. CUST_STATE_PROVINCE                 : EQ
--4. (CUST_CITY, CUST_STATE_PROVINCE,
--    COUNTRY_ID)                        : FILTER
--5. (CUST_STATE_PROVINCE, COUNTRY_ID)   : GROUP_BY
--#############################################################################

-------------------------------------------------------------------------
-- procedure set_processing_rate
-------------------------------------------------------------------------
--
-- Sets the value of rate of processing for a given operation.
--
-- Input arguments:
--   opName   - Name of the operation
--              Valid values: ALL, CPU, CPU_ACCESS, CPU_AGGR, 
--              CPU_BYTES_PER_SEC, CPU_FILTER, CPU_GBY, CPU_HASH_JOIN,
--              CPU_JOIN, CPU_NL_JOIN, CPU_RANDOM_ACCESS,
--              CPU_SEQUENTIAL_ACCESS, CPU_SM_JOIN, CPU_SORT, IO,
--              IO_ACCESS, IO_BYTES_PER_SEC, IO_RANDOM_ACCESS,
--              IO_SEQUENTIAL_ACCESS, HASH, AGGR, MEMCMP, MEMCPY
--   procRate - Processing Rate
--
-- Output arguments: None
--
-- Privileges: The user issuing should have the role optimizer_processing_rate
--             or dba
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--   ORA-20001: Invalid or inconsistent input values
--
procedure set_processing_rate (
   opName      IN     varchar2,
   procRate    IN     number);

-------------------------------------------------------------------------
-- procedure delete_processing_rate
-------------------------------------------------------------------------
--
-- deletes the processing rate of a given stat source. If the source is not
-- specified, then it deletes the statistics of all the sources
-- 
-- Input arguments:
--   stat_source - the source of processing rates can be 'MANUAL' or
--                 'CALIBRATION'
--
-- Output arguments: None
--
-- Privileges: The user issuing should have the role optimizer_processing_rate
--             or dba
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--   ORA-20001: Invalid or inconsistent input values
--
procedure delete_processing_rate (
stat_source IN varchar2 DEFAULT NULL);

--------------------------- gather_processing_rate --------------------------
-- NAME:
--   gather_processing_rate - Gather Processing Rates
--
-- DESCRIPTION: This procedure starts the job of gathering the processing 
--              rates which end after 'timeLimit' seconds
--
-- PARAMETERS:
--   gathering_mode   - Mode can be 'START' and 'END'
--   duration         - time duration (number of minutes) for which the 
--                      processing must be gathered. Default value is 60
--                      minutes.
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--   ORA-20001: Invalid or inconsistent input values
--
procedure gather_processing_rate(gathering_mode IN VARCHAR2 DEFAULT 'START',
                                 duration       IN NUMBER DEFAULT NULL);

NULL_NUMTAB constant dbms_utility.number_array 
                       := dbms_utility.init_number_array;

------------------------------ create_advisor_task ----------------------------
-- NAME:
--     create_advisor_task
--
-- DESCRIPTION: Creates an advisor task for the Statistics Advisor.
--
-- PARAMETERS:
--   task_name          (IN) - name of the advisor task(optional). If not
--                             specified, will automatically generate a unique
--                             name for the new task.
-- RETURNS:
--   Unique name of the statistics advisor task.
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--   ORA-20001: User Input errors
--   ORA-20012: Statistics Advisor errors
-- 
-------------------------------------------------------------------------------
FUNCTION create_advisor_task(
  task_name     IN VARCHAR2     := NULL)
RETURN VARCHAR2;

---------------------------- execute_advisor_task -----------------------------
-- NAME:
--     execute_advisor_task
--
-- DESCRIPTION: executes a previously created statistics advisor task.
--
-- PARAMETERS:
--   task_name:         (IN) - name of the statistics advisor task
--   execution_name:    (IN) - A name to qualify and identify an execution.
--                             If not specified, it is automatically generated
--                             by the advisor and returned by the function.
--   
-- RETURNS:
--   Name of the new execution.
-- 
-- NOTES:
--   This function will give an error if the specified execution conflicts
--   with the name of an existing execution (when the given execution name
--   already exists).
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--   ORA-20001: User Input errors
--   ORA-20012: Statistics Advisor errors
--
-------------------------------------------------------------------------------
FUNCTION execute_advisor_task(
  task_name             IN VARCHAR2,
  execution_name        IN VARCHAR2 := NULL)
RETURN VARCHAR2;

---------------------------- report_advisor_task ------------------------------
-- NAME:
--   report_advisor_task
--
-- DESCRIPTION:
--   reports the results of a statistics advisor task.
--
-- PARAMETERS:
--  task_name           (IN) - name of the advisor task
--  execution_name      (IN) - A name to qualify and identify an execution.
--                             If not specified, the latest execution of the
--                             given task is used.
--  type                (IN) - Type of the report.  Possible values are:
--                               TEXT, HTML, XML
--  section             (IN) - Particular section in the report.  
--                             Possible values are: 
--                               SUMMARY, FINDINGS, ERRORS, ALL
--                             Combinations of different values can be
--                             specified using +/-, for example:
--                               'SUMMARY +FINDINGS +ERRORS',
--                               'ALL -ERRORS'
--  level               (IN) - Format of the report.  Possible values are:
--                               BASIC, TYPICAL, ALL, SHOW_HIDDEN
--                             The SHOW_HIDDEN option can be specified together
--                             with the other three input values, for example:
--                               'BASIC +SHOW_HIDDEN', 'TYPICAL +SHOW_HIDDEN'
--
-- RETURNS:
--   A CLOB that contains the report.
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--   ORA-20001: User Input errors
--   ORA-20012: Statistics Advisor errors
--
-- Notes:
-- Usage Example:
/*
declare
  report clob := null;
  tname VARCHAR2(32767) := 'my_task';
begin
  -- generate a report and get it in text format
  report := dbms_stats.report_stats_advisor_task(tname, type => 'TEXT', 
                                                 section=>'SUMMARY +FINDINGS');
end;
/ */
-------------------------------------------------------------------------------
FUNCTION report_advisor_task(
  task_name          IN VARCHAR2,
  execution_name     IN VARCHAR2             := NULL,
  type               IN VARCHAR2             := 'TEXT',
  section            IN VARCHAR2             := 'ALL',
  level              IN VARCHAR2             := 'TYPICAL')
RETURN CLOB;

---------------------------- script_advisor_task ------------------------------
-- NAME:
--   script_advisor_task
--
-- DESCRIPTION: 
--   Gets the script that implements the recommended actions for the
--   problems found by the statistics advisor.
--
-- PARAMETERS:
--  task_name:          (IN) - name of the advisor task
--  execution_name:     (IN) - A name to qualify and identify an execution.
--                             If not specified, the latest execution of the
--                             given task is used.
--  dir_name            (IN) - Directory path to write the generated script to.
--                             If not specified (NULL), the script will only
--                             be put in the CLOB returned with this function.
--                             If dir_name is specified, the script will be 
--                             both returned as a clob as well as a new file 
--                             in the given directory.
--  level               (IN) - The level of the script to generate. Possible
--                             values are:
--                             'ALL' -> ignore the filter and generate script
--                              for all findings
--                             'TYPICAL' -> generate script according to the
--                              filters in place
--                             
-- RETURNS:
--   A CLOB that contains the script.
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--   ORA-20001: User Input errors
--   ORA-20012: Statistics Advisor errors
--
-------------------------------------------------------------------------------
FUNCTION script_advisor_task(
  task_name             IN VARCHAR2,
  execution_name        IN VARCHAR2     := NULL,
  dir_name              IN VARCHAR2     := NULL,
  level                 IN VARCHAR2     := 'TYPICAL')
RETURN CLOB;

-------------------------- implement_advisor_task -----------------------------
-- NAME:
--   implement_advisor_task
--
-- DESCRIPTION: 
--   Implements the actions recommended by the statistics advisor
--
-- PARAMETERS:
--  task_name:          (IN) - name of the advisor task
--  execution_name:     (IN) - A name to qualify and identify an execution.
--                             If not specified, the latest execution of the
--                             given task is used.
--  level               (IN) - The level of the implementation of the 
--                             recommendations. Possible values are:
--                             'ALL' -> ignore the filters and implement all
--                             the recommendations
--                             'TYPICAL' -> implement the recommendations 
--                             according to the filters in place
-- 
-- RETURNS:
--   A CLOB XML indicating which recommendations have been successfully 
--   implemented.
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--   ORA-20001: User Input errors
--   ORA-20012: Statistics Advisor errors
--
-------------------------------------------------------------------------------
FUNCTION implement_advisor_task(
  task_name             IN VARCHAR2,
  execution_name        IN VARCHAR2     := NULL,
  level                 IN VARCHAR2     := 'TYPICAL')
RETURN CLOB;

------------------------- configure_advisor_filter ----------------------------
-- NAME:
--   configure_advisor_filter
--
-- DESCRIPTION: 
--   configure the filter list for a statistics advisor task
--
-- PARAMETERS:
--  task_name:          (IN) - name of the statistics advisor task
--  stats_adv_opr_type  (IN) - Type of operation to configure. Possible values:
--                               'EXECUTE', 'REPORT', 'SCRIPT', 'IMPLEMENT'
--                             combination of configure operation types are 
--                             allowed. For example, 'EXECUTE + REPORT'.
--                             If this parameter is null, then the filter will
--                             apply to all types of advisor operations. 
--  configuration_type  (IN) - Type of configuration. Possible values:
--                               'SET', 'CLEAR', 'SHOW'. 
--                             'SET' - setting the specified filter list
--                                     values.
--                             'CLEAR' - for the passed in filter, clear 
--                                       the existing values for that filter
--                             'SHOW' - showing the current configuration of
--                                      the given item.
--  filter              (IN) - Item filter list for the script. See examples
--                             below for more details.
--
-- RETURN:
--   A CLOB containing the configuration of the provided filter in XML format.
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--   ORA-20001: User Input errors
--   ORA-20012: Statistics Advisor errors
-- 
-- NOTES:
--   The argument stats_adv_opr_type can take in any combination of values, 
--   appended using '+', for example, 'EXECUTE +REPORT'.
--
/*
How to create a filter:
There are three types of filters: rule, operation and object filters.
Each filter is associated with a boolean value of include and exclude.
 - The rule filter takes a rule name as input. Rule names can be found 
   from the view v$stats_advisor_rules
 - The operation filter is an exact match filter, which takes in the name of
   the operation as well as an xml string representation of all the parameter
   values in the particular call. This xml can be found in the notes section
   of dba_optstat_operations.
   Also, users can use dbms_stats.get_advisor_opr_filter to get the filter
   of the operation they need
 - The object filter takes in an owner name and an object name. Wildcards 
   (%) are supported in the owner name and object name. When an object name
   is null or simply '%', it means a filter for all the objects in the given
   schema. If owner name is also null or '%', it means a default filter for
   all objects in the system.
 - If none of the filters are specified, the filter is recognized as setting
   the global default value of filtering (include or exclude). During the 
   check, when no filter has been specified for an rule/operation/object/, 
   the default value is used to determine whether to include or exclude it.
 - In 'SET' mode, the passed in filter will override the existing filter
   values. In clear mode, the procedure will only clear the values in the
   specified filter. In 'show' mode, the procedure will only show the values
   of the specified filter.

Below are some example scenarios and how to create a filter and pass it 
into the configure procedure in each case. They correspond to:
1) disabling/enabling a rule
2) disabling/enabling an operation
3) disabling/enabling a schema/object

I. The DBA wants to turn off checks for all other rules except for one 
specific rule. For example, the DBA only wants to check whether SQL plan 
directive has been disabled. Then the user can create a rule filter:

declare
  task_name     varchar2(128) := 'my_task';
  filter dbms_stats.StatsAdvFilter := null;
  filterTab dbms_stats.StatsAdvFilterTab := null;
  counter number := 0;
  filterReport CLOB;
begin
  -- init filter table
  filterTab := dbms_stats.StatsAdvFilterTab();
  
  -- 1st filter: set filters to be FALSE by default
  filter.include := FALSE;

  -- add it to the filter table
  counter := counter + 1;
  filterTab.extend;
  filterTab(counter) := filter;

  -- 2nd filter: turn on filter for one rule
  filter.include := TRUE;
  filter.rulename := 'TurnOnSQLPlanDirective';
  
  -- add it to the filter table
  counter := counter + 1;
  filterTab.extend;
  filterTab(counter) := filter;

  filterReport := dbms_stats.configure_advisor_filter(task_name, NULL, 
                                                      'SET', filterTab);
end;

II. The DBA has some customized scripts to gather statistics for a table. 
    If the DBA does not want to see a specific statistics operation 
    in the report, he or she can specify an operation filter:

declare
  task_name     varchar2(128) := 'my_task';
  filter dbms_stats.StatsAdvFilter := null;
  filterTab dbms_stats.StatsAdvFilterTab := null;
  opr           dbms_stats.StatsAdvOpr;
  oprTab        dbms_stats.StatsAdvOprTab;
  oprCnt        number := 0;
  type numTab is table of number;
  opr_tab       numTab;
  filterReport  CLOB;
begin
  -- init filter table
  filterTab := dbms_stats.StatsAdvFilterTab();

  -- init opr filter    
  oprTab := dbms_stats.StatsAdvOprTab();

  select id bulk collect into opr_tab from DBA_OPTSTAT_OPERATIONS
  where operation = 'set_table_stats' and target = 'SCOTT.EMP';

  -- populate the opr table
  for i in 1..opr_tab.count loop

    -- use the procedure get_advisor_opr_filter to construct
    -- an operation filter
    dbms_stats.get_advisor_opr_filter(opr_tab(i), NULL, opr);

    oprCnt := oprCnt + 1;
    oprTab.extend;
    oprTab(oprCnt) := opr;
  end loop;
  
  filter.include := FALSE;
  filter.oprlist := oprTab;

  -- add to filter table
  filterTab.extend;
  filterTab(1) := filter;

  filterReport := dbms_stats.configure_advisor_filter(task_name, NULL, 
                                                      'SET', filterTab);
end;

III. The DBA cares about a particular schema and would like to see a report
     only on that schema, and would also like to skip an object in the 
     schema. The DBA can then create the following object filter:

declare
  filter        dbms_stats.StatsAdvFilter := null;
  filterTab     dbms_stats.StatsAdvFilterTab := null;
  filterReport  CLOB;
  counter       number := 0;
  obj           dbms_stats.ObjectElem;
  objTab        dbms_stats.ObjectTab;
  objCnt        number := 0;
begin

  -- init filter table
  filterTab := dbms_stats.StatsAdvFilterTab();

  -- Set object filter to be off by default
  filter.include := FALSE;
  
  objTab := dbms_stats.ObjectTab();
  
  obj.ownname := NULL;
  obj.objname := NULL;

  -- add to the object table
  objCnt := objCnt + 1;
  objTab.extend;
  objTab(objCnt) := obj;

  filter.objlist := objTab;

  -- add the object filter to the filter table
  counter := counter + 1;
  filterTab.extend;
  filterTab(counter) := filter;

  -- filter I
  -- turn on the check only for schema SH

  filter.include := TRUE;

  objTab := dbms_stats.ObjectTab();
  objCnt := 0;
  
  obj.ownname := 'SH';
  obj.objname := NULL;

  -- add to the object table
  objCnt := objCnt + 1;
  objTab.extend;
  objTab(objCnt) := obj;

  filter.objlist := objTab;

  -- add the object filter to the filter table
  counter := counter + 1;
  filterTab.extend;
  filterTab(counter) := filter;
  
  -- filter II
  -- exclude the check for object SH.PRODUCTS

  filter.include := FALSE;

  objTab := dbms_stats.ObjectTab();
  objCnt := 0;

  -- specify another object filter for sh/products
  obj.ownname := 'SH';
  obj.objname := 'PRODUCTS';

  -- add to the object table
  objCnt := objCnt + 1;
  objTab.extend;
  objTab(objCnt) := obj;

  filter.objlist := objTab;

  -- add the object filter to the filter table
  counter := counter + 1;
  filterTab.extend;
  filterTab(counter) := filter;

  filterReport := 
  dbms_stats.configure_advisor_filter(task_name, NULL, 
                                      'SET', filterTab);
end;

The filters can be used in combination with each other, and can be different
for different operations (execute / report / script / implement).

*/
-------------------------------------------------------------------------------
FUNCTION configure_advisor_filter(
  task_name             IN VARCHAR2,
  stats_adv_opr_type    IN VARCHAR2,
  configuration_type    IN VARCHAR2,
  filter                IN StatsAdvFilterTab    := NULL)
RETURN CLOB;

------------------------- get_advisor_opr_filter ------------------------------
-- NAME:
--   get_advisor_opr_filter
--
-- DESCRIPTION: 
--   Create an operation filter for a statistics operation
--
-- PARAMETERS:
--  opr_id:          (IN) - ID of the statistics operation. This is the ID for
--                          the operation stored in dba_optstat_operations
--  opr_filter       (IN) - Statistics Advisor Filter generated based on 
--                          the given statistics operation
-- 
-- NOTE;
--   The filter can only be specified from either the operation ID or the 
--   filter ID, but not both at the same time.
-- 
-- Exceptions:
--   ORA-20000: Insufficient privileges
--   ORA-20001: User Input errors
--   ORA-20012: Statistics Advisor errors
-- 
-------------------------------------------------------------------------------
PROCEDURE get_advisor_opr_filter(
  opr_id     IN NUMBER,
  opr_filter IN OUT NOCOPY StatsAdvOpr);

----------------------- set_advisor_task_parameter ----------------------------
-- NAME:
--   set_advisor_task_parameter
--
-- DESCRIPTION: 
--   update the value of of a statistics advisor task parameter.
--   Possible parameters are:
--      TIME_LIMIT      - Time Limit that the task can run (in minutes)
--      OP_START_TIME   - Number of days the advisor task looks back
--
-- PARAMETERS:
--  task_name:          (IN) - name of the statistics advisor task
--  parameter           (IN) - Name of the parameter to set
--  value               (IN) - New value of the parameter
-- 
-- NOTES:
--  The function will give an error if the specified parameter does not exist.
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--   ORA-20001: User Input errors
--   ORA-20012: Statistics Advisor errors
-- 
-------------------------------------------------------------------------------
PROCEDURE set_advisor_task_parameter(
  task_name     in varchar2,
  parameter     in varchar2,
  value         in varchar2);

----------------------- configure_advisor_rule_filter -------------------------
-- NAME:
--   configure_advisor_rule_filter
--
-- DESCRIPTION: 
--   Configure rule filter for a statistics advisor task
--
-- PARAMETERS:
--  task_name:          (IN) - name of the statistics advisor task
--  stats_adv_opr_type  (IN) - type of operation to configure. Possible values:
--                               'EXECUTE', 'REPORT', 'SCRIPT', 'IMPLEMENT'
--                             combination of configure operation types are 
--                             allowed. For example, 'EXECUTE + REPORT'.
--                             If this parameter is null, then the filter will
--                             apply to all types of advisor operations. 
--  rule_name           (IN) - name of the rule to configure. If null, apply
--                             the filter to all rules
--  action              (IN) - configuration action to take for the given
--                             rule. Possible values:
--                             'ENABLE': enable the filter
--                             'DISABLE: disable the filter
--                             'DELETE': delete the filter
--                             'SHOW': show the current filter value
-- RETURNS:
--   A clob of xml format containing the (updated) values of the filter.
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--   ORA-20001: User Input errors
--   ORA-20012: Statistics Advisor errors
-- 
-------------------------------------------------------------------------------
FUNCTION configure_advisor_rule_filter(
  task_name             IN VARCHAR2,
  stats_adv_opr_type    IN VARCHAR2,
  rule_name             IN VARCHAR2,
  action                IN VARCHAR2)
RETURN CLOB;

----------------------- configure_advisor_opr_filter --------------------------
-- NAME:
--   configure_advisor_opr_filter
--
-- DESCRIPTION: 
--   Configure operation filter for a statistics advisor task.
--
-- PARAMETERS:
--  task_name:          (IN) - name of the statistics advisor task
--  stats_adv_opr_type  (IN) - type of statistics advisor operation to 
--                             configure. See configure_advisor_rule_filter.
--  rule_name           (IN) - name of the rule to configure. If null, apply
--                             the filter to all operation level rules
--  operation_name      (IN) - operation name (e.g. 'gather_table_stats')
--  action              (IN) - configuration action to take. 
--                             See configure_advisor_rule_filter.
-- RETURNS:
--   A clob of xml format containing the (updated) values of the filter.
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--   ORA-20001: User Input errors
--   ORA-20012: Statistics Advisor errors
-- 
-------------------------------------------------------------------------------
FUNCTION configure_advisor_opr_filter(
  task_name             IN VARCHAR2,
  stats_adv_opr_type    IN VARCHAR2,
  rule_name             IN VARCHAR2,
  operation_name        IN VARCHAR2,
  action                IN VARCHAR2)
RETURN CLOB;

----------------------- configure_advisor_opr_filter --------------------------
-- NAME:
--   configure_advisor_opr_filter
--
-- DESCRIPTION: 
--   Configure operation filter for a statistics advisor task.
--
-- PARAMETERS:
--  task_name:          (IN) - name of the statistics advisor task
--  stats_adv_opr_type  (IN) - type of statistics advisor operation to 
--                             configure. See configure_advisor_rule_filter.
--  rule_name           (IN) - name of the rule to configure. If null, apply
--                             the filter to all operation level rules
--  operation_name      (IN) - operation name (e.g. 'gather_table_stats')
--  ownname             (IN) - owner name of the operation target. 
--                             Cannot be null.
--  tabname             (IN) - table name of the operation target
--  action              (IN) - configuration action to take. 
--                             See configure_advisor_rule_filter.
-- RETURNS:
--   A clob of xml format containing the (updated) values of the filter.
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--   ORA-20001: User Input errors
--   ORA-20012: Statistics Advisor errors
-- 
-------------------------------------------------------------------------------
FUNCTION configure_advisor_opr_filter(
  task_name             IN VARCHAR2,
  stats_adv_opr_type    IN VARCHAR2,
  rule_name             IN VARCHAR2,
  operation_name        IN VARCHAR2,
  ownname               IN VARCHAR2,
  tabname               IN VARCHAR2,
  action                IN VARCHAR2)
RETURN CLOB;

----------------------- configure_advisor_opr_filter --------------------------
-- NAME:
--   configure_advisor_opr_filter
--
-- DESCRIPTION: 
--   Configure operation filter for a statistics advisor task.
--
-- PARAMETERS:
--  task_name:          (IN) - name of the statistics advisor task
--  stats_adv_opr_type  (IN) - type of statistics advisor operation to 
--                             configure. See configure_advisor_rule_filter.
--  rule_name           (IN) - name of the rule to configure. If null, apply
--                             the filter to all operation level rules
--  operation_id        (IN) - operation id to configure. The filter will apply
--                             to any operation with the same signature as the
--                             given operation ID. If two operations have the
--                             same signature, then they have the same value
--                             for every parameter. The operation ID comes from
--                             the ID column in dba_optstat_operations.
--  action              (IN) - configuration action to take. 
--                             See configure_advisor_rule_filter.
--
-- RETURNS:
--   A clob of xml format containing the (updated) values of the filter.
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--   ORA-20001: User Input errors
--   ORA-20012: Statistics Advisor errors
-- 
-------------------------------------------------------------------------------
FUNCTION configure_advisor_opr_filter(
  task_name             IN VARCHAR2,
  stats_adv_opr_type    IN VARCHAR2,
  rule_name             IN VARCHAR2,
  operation_id          IN NUMBER,
  action                IN VARCHAR2)
RETURN CLOB;

--------------------- configure_advisor_obj_filter ----------------------------
-- NAME:
--   configure_advisor_obj_filter
--
-- DESCRIPTION: 
--   Configure object filter for a statistics advisor task.
--
-- PARAMETERS:
--  task_name:          (IN) - name of the statistics advisor task
--  stats_adv_opr_type  (IN) - type of statistics advisor operation to 
--                             configure. See configure_advisor_rule_filter.
--  rule_name           (IN) - name of the rule to configure. If null, apply
--                             the filter to all object rules
--  ownname             (IN) - owner name of object to filter
--  tabname             (IN) - table name of object to filter
--  action              (IN) - configuration action to take. 
--                             See configure_advisor_rule_filter.
--
-- RETURNS:
--   A clob of xml format containing the (updated) values of the filter.
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--   ORA-20001: User Input errors
--   ORA-20012: Statistics Advisor errors
-- 
-------------------------------------------------------------------------------
FUNCTION configure_advisor_obj_filter(
  task_name             IN VARCHAR2,
  stats_adv_opr_type    IN VARCHAR2,
  rule_name             IN VARCHAR2,
  ownname               IN VARCHAR2,
  tabname               IN VARCHAR2,
  action                IN VARCHAR2)
RETURN CLOB;

--------------------------- drop_advisor_task ---------------------------------
-- NAME:
--   drop_advisor_task
--
-- DESCRIPTION: 
--   drops the statistics advisor task.
--
-- PARAMETERS:
--  task_name:          (IN) - name of the statistics advisor task
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--   ORA-20001: User Input errors
--   ORA-20012: Statistics Advisor errors
--
-------------------------------------------------------------------------------
procedure drop_advisor_task(
  task_name IN VARCHAR2);

--------------------------- interrupt_advisor_task ----------------------------
-- NAME:
--   interrupt_advisor_task
--
-- DESCRIPTION: 
--  interrupts a currently executing statistics advisor task. The task will
--  end its operations as it would at a normal exit and the user will be able
--  to access intermediate results. The task may also later be resumed.
--
-- PARAMETERS:
--  task_name:          (IN) - name of the statistics advisor task
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--   ORA-20001: User Input errors
--   ORA-20012: Statistics Advisor errors
--
-------------------------------------------------------------------------------
procedure interrupt_advisor_task(
  task_name IN VARCHAR2);

--------------------------- cancel_advisor_task -------------------------------
-- NAME:
--   cancel_advisor_task
--
-- DESCRIPTION: 
--   Cancels a statistics advisor task execution. All intermediate results
--   of the current execution will be removed from the task.
--
-- PARAMETERS:
--  task_name:          (IN) - name of the statistics advisor task
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--   ORA-20001: User Input errors
--   ORA-20012: Statistics Advisor errors
--
-------------------------------------------------------------------------------
procedure cancel_advisor_task(
  task_name IN VARCHAR2);

--------------------------- reset_advisor_task --------------------------------
-- NAME:
--   reset_advisor_task
--
-- DESCRIPTION: 
--  Reset a statistics advisor task execution to its initial state.
--  The procedure should be called on an execution that is not currently 
--  executing.
--
-- PARAMETERS:
--  task_name:          (IN) - name of the statistics advisor task
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--   ORA-20001: User Input errors
--   ORA-20012: Statistics Advisor errors
--
-------------------------------------------------------------------------------
procedure reset_advisor_task(
  task_name IN VARCHAR2);

--------------------------- resume_advisor_task -------------------------------
-- NAME:
--   resume_advisor_task
--
-- DESCRIPTION: 
--  Resume a previously interrupted task. It will only resume the execution
--  that was most recently interrupted.
--
-- PARAMETERS:
--  task_name:          (IN) - name of the statistics advisor task
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--   ORA-20001: User Input errors
--   ORA-20012: Statistics Advisor errors
--
-------------------------------------------------------------------------------
procedure resume_advisor_task(
  task_name IN VARCHAR2);

------------------------------ get_advisor_recs -------------------------------
-- NAME:
--   get_advisor_recs
--
-- DESCRIPTION:
--   Generates a recommendation report on the given item.
--  
-- PARAMETERS:
--  ownname             (IN) - owner name of the table.
--  tabname             (IN) - table name
--  rec                 (IN) - Recommendation. Possible values are:
--                             'CONCURRENT', 'INCREMENTAL'
--  type                (IN) - Type of the report. Possible values are: 
--                             'TEXT', 'HTML', 'XML'
--
-- RETURN:
--  A report of the given recommendation.
--
-- NOTES:
--  INCREMENTAL:
--  Incremental option improves the performance of statistics gathering 
--  dramatically when only a small number of range partitions are modified. 
--  However, it requires additional space to store auxiliary structures 
--  (synopses) for maintaining the statistics incrementally. This tradeoff 
--  will be analyzed in the report.
--
--  CONCURRENT:
--  The report will make one of two recommendations:
--   1) setting the CONCURRENT preference 
--   2) using AUTO_DEGREE for individual tables
--  If the system resources and usage satisfies the conditions, Oracle always 
--  recommend setting CONCURRENT first. Oracle will only recommend AUTO_DEGREE
--  ifstatistics gathering on an individual tables take a long time and the 
--  CONCURRENT preference has already been set.
--  
--  Because Oracle is not aware of the user's intents and purposes, Oracle 
--  will not make any recommendations for manual statistics gathering 
--  operations. Oracle will only make recommendations on auto statistics 
--  gathering job, with the main goal of getting the job to finish within 
--  the maintenance window. As long as the auto job finishes, Oracle does 
--  not make further recommendations.
--
--  This procedure requires ADVISOR privilege. Also user must have privilege
--  to gather stats for the objects for which recommendations are generated
--  for.
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--   ORA-20001: User Input errors
--   ORA-20012: Statistics Advisor errors
--
-------------------------------------------------------------------------------
FUNCTION get_advisor_recs(
  ownname       IN VARCHAR2,
  tabname       IN VARCHAR2,
  rec           IN VARCHAR2,
  type          IN VARCHAR2     := 'TEXT')
RETURN CLOB;

--------------------------- report_stats_operations ---------------------------
-- NAME:
--     report_stats_operations
--
-- DESCRIPTION: This procedure reports statistics operations at different 
--              levels of detail with optional filters on the start time of 
--              operations.
--
-- PARAMETERS:
--    detail_level  (IN) detail level for the content of the report
--          BASIC : The report includes:
--                                 * operation id
--                                 * operation name
--                                 * operation target object
--                                 * start time
--                                 * end time
--                                 * completion status (i.e., succeeded, 
--                                   failed, etc.)
-- 
--          TYPICAL (default): In addition to the information provided at level
--               BASIC, at this level of detail, the report includes the 
--               following fields:
--                                 * total number of target objects
--                                 * total number of successfully completed 
--                                         objects
--                                 * total number of failed objects
--                                 * total number of timedout objects 
--                                         (applies to only auto stats 
--                                         gathering) 
--          ALL: In addition to the information provided at level TYPICAL, 
--               at this level of detail, the report includes the following 
--               details.
--                                 * job name (if the operation was run in a 
--                                   job)
--                                 * session id
--                                 * parameter values
--                                 * additional error details if the operation 
--                                   has failed.
--
--    format        (IN) Report format. Suported formats are TEXT (default), 
--                       HTML, XML.
--
--    latestN       (IN) Include in the report only latest N operations 
--                       (if null (default), no limit on the number of 
--                       operations included in the report).
--    since         (IN) only include only stat operations that started since 
--                       this date.  when null (default), no lower limit on 
--                       start time is applied.
--    until         (IN) only include stat operations that started before this
--                       date when null (default), no upper limit on start time
--                       is applied.
--    auto_only     (IN)  TRUE: report only auto stats gathering operations 
--                       FALSE: report all operations (default) 
--
--    container_ids (IN) When provided, the report will include operations only
--                       from the input set of pluggable databases in a 
--                       consolidated database environment.  By default it is 
--                       null. In a pluggable-database, only operations from
--                       the local database are reported, and in the root 
--                       database, operations from all pluggable databases are 
--                       reported.
--                   
--  
--  NOTES:
--     Note that the type for container_ids input parameter is 
--     dbms_utility.number_array which is an associative PL/SQL array 
--     collection.  Although associative array type allows for more flexible 
--     hash table-like organization of entries, this function treats 
--     container_ids as a regular table collection with the first id located at
--     index 1 and the last id located at index "container_ids.count" without 
--     any empty array slot left between any two ids. An example for 3 
--     container ids is provided below.
--        
--          declare
--            conid_tab dbms_utility.number_array;
--            report clob;
--          begin
--            conid_tab(1) := 124;
--            conid_tab(2) := 63;
--            conid_tab(3) := 98;
--
--            report := dbms_stats.report_stats_operations(container_ids => 
--                                                         conid_tab);
--          end;
-------------------------------------------------------------------------------
function report_stats_operations(detail_level varchar2 default 'TYPICAL',
                                 format varchar2 default 'TEXT',
                                 latestN number default null,
                                 since timestamp with time zone default null,
                                 until timestamp with time zone default null,
                                 auto_only boolean default false,
                                 container_ids dbms_utility.number_array 
                                                default dbms_stats.NULL_NUMTAB)
return clob;

--------------------------- report_single_stats_operation ---------------------
-- NAME:
--     report_single_stats_operation
--
-- DESCRIPTION: This procedure generates a report for the provided operation. 
--
-- PARAMETERS:
--    opid          (IN) internal id of the operation that will be reported. 
--                       This information may be obtained from the output of 
--                       report_stats_operations or through querying 
--                       DBA_OPTSTAT_OPERATIONS view.
--
--    detail_level  (IN) detail level for the content of the report
--          BASIC : The report includes:
--                                 * operation id
--                                 * operation name
--                                 * operation target object
--                                 * start time
--                                 * end time
--                                 * completion status (i.e., succeeded, 
--                                   failed, etc.)         
-- 
--          TYPICAL (default): In addition to the information provided at level
--               BASIC, at this level of detail, the report includes individual
--               target objects for which statistics are gathered in this 
--               operation. More specifically: 
--                           -- operation related details --
--                                 * total number of target objects 
--                                 * total number of successfully completed 
--                                         objects
--                                 * total number of failed objects
--                                 * total number of timedout objects 
--                                         (applies to only auto stats 
--                                         gathering)   
--
--                           -- target object related details --
--                                 * owner and name of each target object
--                                 * target object type (e.g., table, index, 
--                                   etc.)
--                                 * start time
--                                 * end time
--                                 * completion status
--                           
--          ALL: In addition to the information provided at level TYPICAL, 
--               at this level of detail, the report includes further 
--               information on each target object as follows: 
--                            -- operation related details --
--                                 * job name (if the operation was run in a 
--                                   job)
--                                 * session id
--                                 * parameter values
--                                 * additional error details if the operation 
--                                   has failed. 
--
--                            -- target object related details --
--                                 * job name
--                                 * batching details
--                                 * estimated cost
--                                 * rank in the target list
--                                 * columns for which histograms were 
--                                   collected
--                                 * list of collected extended stats (if any)
--                                 * reason for including the object in the 
--                                   target list (applies to only auto stats 
--                                   gathering) 
--                                 * additional error details if the task has 
--                                   failed.
--
--    format        (IN) Report format. Suported formats are TEXT (default), 
--                       HTML, XML.
--    container_id  (IN) container (pluggable database) id in a consolidated
--                       database environment. By default it is null. In a 
--                       pluggable-database, only operations from the local 
--                       database are reported, and in the root database,
--                       operations from all pluggable databases are reported.
--
--  NOTES:
--     Note that some of the fields like estimated cost, batching details, 
--     job_name, etc. for individual tasks are only populated when the 
--     corresponding operation was run with concurrency enabled.
--                                      
-------------------------------------------------------------------------------
function report_single_stats_operation(opid number,
                                       detail_level varchar2 default 'TYPICAL',
                                       format varchar2 default 'TEXT',
                                       container_id number default null) 
 return clob;


function report_gather_auto_stats (
     detail_level varchar2 default 'TYPICAL',
     format varchar2 default 'TEXT')
 return clob;
--
-- This procedure runs auto stats gathering job in reporting mode. That is,
-- stats are not actually collected, but all the objects that will be
-- affected when auto stats gathering is invoked are reported.
-- The detail level for the report is defined by the detail_level 
-- input parameter. Please see the comments for report_single_stats_operation 
-- on possible values for detail_level and format. 

procedure gather_database_stats_job_proc;

procedure cleanup_stats_job_proc(
      ctx number, job_owner varchar2, job_name varchar2,
      sesid number, sesser number);

-- internal use only
procedure gen_selmap( 
    owner        varchar2,
    tabname      varchar2,
    pname        varchar2,
    spname       varchar2,
    flag         IN OUT NOCOPY binary_integer,
    colinfo      ColDictTab,
    selmap       IN OUT NOCOPY SelTab,
    clist        IN OUT NOCOPY CTab);

-- internal use only
procedure postprocess_stats(
    owner         varchar2,
    tabname       varchar2,
    pname         varchar2,
    spname        varchar2,
    tobjn         number,
    fobjn         number,
    flag          number,
    rawstats      RawCTab,
    selmap        SelTab,
    clist         CTab,
    cht           ColHistTab,
    restoretime   timestamp with time zone
  );

-- internal use only
function conv_raw (
   rawval raw,
   type   number) 
return varchar2;

-- For internal use of datapump only
procedure export_stats_for_dp (
  objlist_tab_own varchar2, 
  objlist_tab varchar2,
  dblink in varchar2 default null,
  options in number default null,
  export_stats_since timestamp with time zone default null
);

-- For internal use of datapump only
procedure import_stats_for_dp (
  objlist_tab_own varchar2, 
  objlist_tab varchar2,
  options in number default null
);

-- For internal use
function get_compatible return number;

-- For internal use
function get_stat_tab_version return number;

-- For internal use
function varray_to_clob(va DS_VARRAY_4_CLOB) return clob;

-- For internal use
function clob_to_varray(cl clob) return DS_VARRAY_4_CLOB;

-- For internal use
function column_need_hist(ownname varchar2, tabname varchar2,
                          colname varchar2, method_opt varchar2)
return number;


  -- For internal use
  --
  -- Quickly estimate number of rows in the table for auto sampling
  --
  function get_row_count_estimate(
        ownname varchar2,                 -- table owner to select from
        tabname varchar2,                 -- table name to select from
        partname varchar2,                -- table partition name
        nblks integer,
        degree integer
        ) return number;

-- for internal use
procedure save_inmemory_stats(objn IN NUMBER);

end;
/

show errors;

create or replace public synonym dbms_stats for sys.dbms_stats
/
grant execute on dbms_stats to public
/
create role gather_system_statistics
/
grant update, insert, select, delete on aux_stats$ to gather_system_statistics 
/
grant update, insert, select, delete on sys.wri$_optstat_aux_history to 
gather_system_statistics
/
grant gather_system_statistics to dba
/
create role optimizer_processing_rate
/
grant update, insert, select, delete on opt_calibration_stats$ to 
optimizer_processing_rate 
/
grant optimizer_processing_rate to dba
/

-- create the trusted pl/sql callout library
CREATE OR REPLACE LIBRARY DBMS_STATS_LIB TRUSTED AS STATIC;
/

@?/rdbms/admin/sqlsessend.sql
