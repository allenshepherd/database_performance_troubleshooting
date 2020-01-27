set echo OFF
set arraysize 15
set autoprint OFF
set feedback OFF
set heading ON
set linesize 300
set long 80
set longchunksize 80
set newpage 1
set numwidth 15
set pagesize 200
set pause OFF
set serveroutput ON format WORD_WRAPPED
set termout ON
set time off
set verify OFF
set wrap ON
set define ON


clear columns

-- Used for the SHOW ERRORS command
COLUMN LINE/COL FORMAT A8
COLUMN ERROR    FORMAT A65  WORD_WRAPPED

-- Used for the SHOW SGA command
COLUMN name_col_plus_show_sga FORMAT a24

-- Defaults for SHOW PARAMETERS
COLUMN name_col_plus_show_param FORMAT a36 HEADING NAME
COLUMN value_col_plus_show_param FORMAT a30 HEADING VALUE

-- Defaults for SET AUTOTRACE EXPLAIN report
COLUMN id_plus_exp FORMAT 990 HEADING i
COLUMN parent_id_plus_exp FORMAT 990 HEADING p
COLUMN plan_plus_exp FORMAT a120
COLUMN object_node_plus_exp FORMAT a12
COLUMN other_tag_plus_exp FORMAT a30
COLUMN other_plus_exp FORMAT a44
