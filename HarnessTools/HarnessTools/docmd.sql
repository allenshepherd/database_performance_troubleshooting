set echo off

rem $Header$
rem $Name$      docmd.sql

rem Copyright (c); 2005-2011 by Hotsos Enterprises, Ltd.
rem
rem A command line parameter version of do.sql
rem This script needs the .sql file, test type, workspace, and scenario parameters
rem
rem Usage:  @docmd <.sql file> <SQL or PL/SQL> <Workspace> <Scenario>

set termout on pause off autotrace off heading on

rem accept htst_dofile                prompt 'Enter .sql file name (without extension)         : '
rem accept htst_test_type default 'S' prompt 'Is this a (S)QL or (P)L/SQL test execution?      : '
rem accept htst_workspace             prompt 'Enter the workspace name                         : '
rem accept htst_scenario              prompt 'Enter the scenario name                          : '
rem accept htst_doterm    default 'N' prompt 'Display results of SQL (Y/N)?                    : '
rem accept htst_yn        default 'Y' prompt 'Load trace files (Y/N)?                          : '
rem accept htst_exec_init default 'N' prompt 'Execute once prior to test (Y/N)?                : '
rem accept htst_stats     default 'C' prompt 'Display? (S)tats/(L)atches/(A)ll/(C)ustom/(N)one : '

define htst_dofile = &1
define htst_test_type = &2
define htst_workspace = &3
define htst_scenario = &4

define htst_exec_init = 'N'
define htst_doterm = 'N'
define htst_yn = 'Y'
define htst_stats = 'C'

define do_file = '&htst_dofile'
define htst_stmt_id = '&htst_workspace:&htst_scenario'
define debug = 'OFF'

@do_main

