set echo off

rem $Header$
rem $Name$      do.sql

rem Copyright (c); 2005-2011 by Hotsos Enterprises, Ltd.
rem
rem
rem Executes a test within the Hotsos Test Harness
rem This script prompts for the parameters
rem
rem Usage:  @dosql <.sql file> <Scenario>

set termout on pause off autotrace off heading on

accept htst_dofile                      prompt 'Enter .sql file name (without extension)            : '
accept htst_workspace default 'TESTS'   prompt 'Enter the workspace name                            : '
accept htst_scenario                    prompt 'Enter the scenario name                             : '
accept htst_test_type default 'S'       prompt 'Is this a (S)QL or (P)L/SQL test execution[S]?      : '
accept htst_doterm    default 'N'       prompt 'Display results of SQL (Y/N) [N]?                   : '
accept htst_yn        default 'Y'       prompt 'Load trace files (Y/N) [Y]?                         : '
accept htst_exec_init default 'N'       prompt 'Execute once prior to test (Y/N) [N]?               : '
accept htst_stats     default 'C'       prompt 'Display? (S)tats/(L)atches/(A)ll/(C)ustom/(N)one [C]: '

define do_file = '&htst_dofile'
define htst_stmt_id = '&htst_workspace:&htst_scenario'
define debug = 'OFF'

@do_main
