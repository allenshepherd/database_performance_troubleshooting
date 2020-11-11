Rem
Rem $Header: rdbms/admin/dbmshpro.sql /main/8 2017/01/31 14:57:58 sylin Exp $
Rem
Rem dbmshpro.sql
Rem
Rem Copyright (c) 2003, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmshpro.sql - dbms hierarchical profiler
Rem
Rem    DESCRIPTION
Rem
Rem    NOTES
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmshpro.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmshpro.sql
Rem SQL_PHASE: DBMSHPRO
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    sylin       11/02/16 - In-memory trace support
Rem    sylin       03/17/15 - SQL ID support
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    dbronnik    11/19/08 - Add memory profile support
Rem    lvbcheng    10/11/06 - Remove grants to public
Rem    sylin       08/28/06 - Disable trace with multiple symbols
Rem    sylin       04/20/06 - analyze output in database tables
Rem    lvbcheng    04/08/05 - Add exceptions 
Rem    sylin       03/30/05 - Add run_comment to analyze 
Rem    lvbcheng    03/22/05 - Add exception 
Rem    sylin       05/25/04 - Add options to analyze
Rem    kmuthukk    02/24/03 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

CREATE OR REPLACE PACKAGE dbms_hprof AUTHID CURRENT_USER IS

   PROCEDURE start_profiling(location    VARCHAR2    DEFAULT NULL,
                             filename    VARCHAR2    DEFAULT NULL,
                             max_depth   PLS_INTEGER DEFAULT NULL,
                             profile_uga BOOLEAN     DEFAULT NULL,
                             profile_pga BOOLEAN     DEFAULT NULL,
                             sqlmonitor  BOOLEAN     DEFAULT TRUE
                            );
    pragma deprecate(start_profiling,
                     'start_profiling file overload is deprecated.');

   FUNCTION start_profiling(max_depth   PLS_INTEGER DEFAULT NULL,
                            profile_uga BOOLEAN     DEFAULT NULL,
                            profile_pga BOOLEAN     DEFAULT NULL,
                            sqlmonitor  BOOLEAN     DEFAULT TRUE,
                            run_comment VARCHAR2    DEFAULT NULL
                           ) RETURN NUMBER;

   /* DESCRIPTION:
        Start profiling at this point and collect profile information in the
        specified location.

      ARGUMENTS
        location -
          The name of a directory object. The filesystem directory mapped to
          this directory object is where the raw profiler output is generated.

        filename -
          The output filename for the raw profiler data.

        max_depth -
          By default (when max_depth value is NULL) profile information is
          gathered for all functions irrespective of their call depth.  When a
          non-NULL value is specified for max_depth, the profiler collects
          data only for functions up to a call depth level of max_depth.
          [Note: Even though the profiler does not individually track functions
          at depth greater than max_depth, the time spent in such functions is
          charged to the ancestor function at depth max_depth.] This can be
          used for collecting coarse grain profile information. For example, if
          all that is needed is a high level overview of the subtree times
          spent under the top level functions and not much detailed drill down
          analysis is required, then the max_depth could be set at 1. 

        profile_uga -
          Profile session memory usage (undocumented, for internal use only)

        profile_pga -
          Profile process memory usage (undocumented, for internal use only)

        sqlmonitor  -
          By default (when sqlmonitor value is TRUE) a Real-Time monitoring
          report will be generated for the profiler run when profiler run ends.

        run_comment -
          User provided comment for this profiler data collection run.

      RETURN
        Unique profiler run identifier for this profiler run.

      EXCEPTION
        invalid filename
        invalid directory object 
        incorrect directory permission
        invalid maxdepth
   */

   PROCEDURE stop_profiling;
   
   FUNCTION stop_profiling RETURN CLOB;


   /* DESCRIPTION
        Stop profiler data collection in the user's session. All data collected
        so far is flushed.

      ARGUMENTS
        see analyze for detail information.

      RETURN
        Real-Time Monitoring report for the profiler run.

      EXCEPTION
        None.
   */

   FUNCTION  analyze(location          VARCHAR2,
                     filename          VARCHAR2,
                     summary_mode      BOOLEAN     DEFAULT FALSE,
                     trace             VARCHAR2    DEFAULT NULL,
                     skip              PLS_INTEGER DEFAULT 0,
                     collect           PLS_INTEGER DEFAULT NULL,
                     run_comment       VARCHAR2    DEFAULT NULL,
                     profile_uga       BOOLEAN     DEFAULT NULL,
                     profile_pga       BOOLEAN     DEFAULT NULL
                    ) RETURN NUMBER;
    pragma deprecate(analyze,
                     'analyze file overload is deprecated.');

   PROCEDURE analyze(location          VARCHAR2,
                     filename          VARCHAR2,
                     summary_mode      BOOLEAN     DEFAULT FALSE,
                     trace             VARCHAR2    DEFAULT NULL,
                     skip              PLS_INTEGER DEFAULT 0,
                     collect           PLS_INTEGER DEFAULT NULL,
                     profile_uga       BOOLEAN     DEFAULT NULL,
                     profile_pga       BOOLEAN     DEFAULT NULL);
    pragma deprecate(analyze,
                     'analyze file overload is deprecated.');

   PROCEDURE analyze(location          VARCHAR2,
                     filename          VARCHAR2,
                     report_clob   OUT CLOB,
                     trace             VARCHAR2    DEFAULT NULL,
                     skip              PLS_INTEGER DEFAULT 0,
                     collect           PLS_INTEGER DEFAULT NULL,
                     profile_uga       BOOLEAN     DEFAULT NULL,
                     profile_pga       BOOLEAN     DEFAULT NULL);
    pragma deprecate(analyze,
                     'analyze file overload is deprecated.');

   FUNCTION  analyze(trace_id          NUMBER,
                     summary_mode      BOOLEAN     DEFAULT FALSE,
                     trace             VARCHAR2    DEFAULT NULL,
                     skip              PLS_INTEGER DEFAULT 0,
                     collect           PLS_INTEGER DEFAULT NULL,
                     run_comment       VARCHAR2    DEFAULT NULL,
                     profile_uga       BOOLEAN     DEFAULT NULL,
                     profile_pga       BOOLEAN     DEFAULT NULL
                    ) RETURN NUMBER;

   PROCEDURE analyze(trace_id          NUMBER,
                     report_clob   OUT CLOB,
                     trace             VARCHAR2    DEFAULT NULL,
                     skip              PLS_INTEGER DEFAULT 0,
                     collect           PLS_INTEGER DEFAULT NULL,
                     profile_uga       BOOLEAN     DEFAULT NULL,
                     profile_pga       BOOLEAN     DEFAULT NULL);

   /* DESCRIPTION:
      Analyzes profiler run output from input trace file, or profiler data
      in profiler data table and produces one of the following:

      2) analyzed HTML report in location/filename.html
      [Note: Does not upload the analyzed result into database tables.]

      3) analyzed HTML report in report_clob.
      [Note: Does not upload the analyzed result into database tables.]

      ARGUMENTS:
      location -
        The name of a directory object. The raw profiler data file is
        read from the filesystem directory mapped to this directory
        object. Output files are written to this directory as well.

      filename -
        Name of the raw profiler data file to be analyzed.

      trace_id -
        profiler trace id entry in profiler data table (dbmshp_data)

      report_clob -
        analyzed HTML report

      summary_mode -
        By default (when "summary_mode" is FALSE), the full analysis is done.
        When "summary_mode" is TRUE, only top level summary information is
        generated into the database tables.

      trace -
        Analyze only the subtrees rooted at the specified "trace" entry.
        By default (when "trace" is NULL), the analysis/reporting is generated
        for the entire run.  The "trace" entry must be specified in the
        qualified format as in for example, "HR"."PKG"."FOO".  [If multiple
        overloads exist for the specified name, all of them will be analyzed.]

      skip -
        Used only when "trace" is specified.  Analyze only the subtrees rooted
        at the specified "trace", but ignore the first "skip" invocations to
        "trace".
        The default value for "skip" is 0.

      collect -
        Used only when "trace" is specified.  Analyze "collect" number of
        invocations of "trace" (starting from "skip"+1'th invocation).
        By default only 1 invocation is collected.

      run_comment -
        User provided comment for this analyze run.

      profile_uga -
        Report UGA usage

      profile_pga - 
        Report PGA usage

      RETURN
        Unique run identifier from dbmshp_runnumber sequence for this run of
        the analyzer.

      EXCEPTION
        invalid filename
        invalid directory object 
        incorrect directory permission
   */

   PROCEDURE create_tables(force_it boolean default FALSE);
   /* DESCRIPTION:
   
      Create the following table and sequence required to collect data by
      dbms_hprof.start_profiling function call:

          dbmshp_trace_data
            raw trace information on each hierarchical profiler trace runs

          The dbmshp_tracenumber sequence - used for generating unique
            trace id numbers.

      Create the following tables and sequence required to collect data by
      dbms_hprof.analyze function call:

          dbmshp_runs -
            information on hierarchical profiler runs
   
          dbmshp_function_info -
            information on each function profiled
   
          dbmshp_parent_child_info -
            parent-child level profiler information
   
          The dbmshp_runnumber sequence - used for generating unique
            run numbers.

      ARGUMENTS:

      force_it -
        If force_it is false and dbms_hprof tables are 
        present then a hprof error is raised. If 
        force_it is true then it silently creates tables.
        If tables already exist then they are dropped and
        new tables are created.

      [Note:
       No need to use the dbmshptab.sql script located in the rdbms/admin
       directory to create the hierarchical profiler database tables and data
       structures anymore. dbmshptab.sql is deprecated.]
   */

END dbms_hprof;
/

CREATE OR REPLACE PUBLIC SYNONYM dbms_hprof FOR sys.dbms_hprof
/

@?/rdbms/admin/sqlsessend.sql
