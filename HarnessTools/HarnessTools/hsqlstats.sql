set echo off

rem $Header$
rem $Name$		hsqlstats.sql

rem Copyright (c); 2011 by Hotsos Enterprises, Ltd.
rem
rem   Usage: For a given plan hash value, this script will display stats
rem          for the SQL statement from the v$sql_plan_statistics_all view.  
rem
rem

column ID format 9999
column PID format 9999
column cost format 9999
column cardinality format 99,999,999
column last_output_rows heading ROWS format 99,999,999
column rso format a45
column object format a25
column LIOS format 999,999,999
column total format 999,999,999

accept phv prompt 'SQL Statement Plan Hash Value: ' 

select 
id, 
parent_id PID,
cost,
cardinality,
last_output_rows,
LPAD (' ', DEPTH)||operation||' '||options RSO, 
object_name OBJECT,
last_cr_buffer_gets LIOS, 
last_elapsed_time TOTAL_TIME
from v$sql_plan_statistics_all
where plan_hash_value = &phv
order by id
/

clear columns 
undefine phv
@henv
