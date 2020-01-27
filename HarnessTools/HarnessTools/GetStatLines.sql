rem $Header$
rem $Name$      GetStatLines.sql

rem Copyright (c); 2011 by Hotsos Enterprises, Ltd.
rem
rem change log
rem inital writing RVD SEPT 2011
rem
COLUMN ID   FORMAT 9999
COLUMN PRED HEADING P FORMAT A1
COLUMN ACT_ROWS HEADING 'ACTUAL|ROWS'   FORMAT 999,999,999
COLUMN EST_ROWS HEADING 'ESTIMATE|ROWS' FORMAT 999,999,999
COLUMN PID FORMAT 9999
COLUMN RSO HEADING 'ROW SOURCE OPERATION' FORMAT A51
COLUMN OBJECT FORMAT A15
COLUMN STARTS FORMAT 9,999
COLUMN TLIOS  HEADING 'LIOS|W/CHLRD' FORMAT 9,999,999
COLUMN SLIOS  HEADING 'SELF|LIOS'    FORMAT 9,999,999
COLUMN TOTAL_TIME HEADING 'TIME|W/CHLRD' FORMAT 9,999,999
COLUMN SELF_TIME  HEADING 'SELF|TIME'    FORMAT 9,999,999
COLUMN P_TYPE     HEADING 'TYPE'
COLUMN PREDICATE  FORMAT A80
SET HEADING ON
SET FEEDBACK OFF
SET ECHO OFF
SET TERMOUT ON
SET TAB OFF
-- SEVEROUTPUT must be off to get the correct SQL_ID
SET SERVEROUTPUT OFF

alter session set statistics_level = all
/
accept sqlfile   prompt 'Enter .sql file name (without extension): '

-- get and run SQL statement
-- no output will be displayed of the query
set termout off
get &sqlfile
run
-- show the statment just run
set termout on
list
set termout off
-- retreiving the SQL_ID of the above statement
COLUMN PREV_SQL_ID NEW_VALUE PSQLID
select PREV_SQL_ID from v$session WHERE audsid = userenv('sessionid');

set termout on
-- show the sql_id of the statement
select '&psqlid' SQL_ID from dual;
-- Retreiving information from V$SQL_PLAN_STATISTICS_ALL
-- The WITH clause gets the total time and LIOs for all the children
-- of a given parent. This information is used in the main quiery
-- to get the time and LIOs that a step did by it self.
with child_work as
(select
  parent_id cid,
  sum(last_elapsed_time) ctime,
  sum(last_cr_buffer_gets)+sum(last_cu_buffer_gets) clios
  from v$sql_plan_statistics_all
  where sql_id = '&psqlid'
  and child_number = (select max(child_number)
                      from v$sql_plan_statistics_all where sql_id = '&psqlid')
  group by parent_id)
select
  id,
  case
   when access_predicates is not null then '*'
   when filter_predicates is not null then '*'
   else ' '
  end pred,
  parent_id pid,
  lpad (' ', depth)||operation||' '||options rso,
  object_name object,
  starts,
  last_output_rows act_rows,
  cardinality est_rows,
  last_cr_buffer_gets+last_cu_buffer_gets tlios,
  (last_cr_buffer_gets+last_cu_buffer_gets)-nvl(clios,0) slios,
  last_elapsed_time total_time,
  last_elapsed_time - nvl(ctime,0) self_time
from v$sql_plan_statistics_all sqlplnstats, child_work chldwrk
where sql_id = '&psqlid'
  and child_number = (select max(child_number)
                    from v$sql_plan_statistics_all where sql_id = '&psqlid')
  and chldwrk.cid(+) = sqlplnstats.id
order by id
/
-- this select gets predicate informaiton for any step in the plan
select * from
(select /* access predicates */
id , 'ACCESS:' p_type, access_predicates predicate
from v$sql_plan_statistics_all
where sql_id = '&psqlid'
and child_number = (select max(child_number)
                    from v$sql_plan_statistics_all where sql_id = '&psqlid')
and access_predicates is not null
union all
select /* filter predicates */
id , 'FILTER:', filter_predicates
from v$sql_plan_statistics_all
where sql_id = '&psqlid'
and child_number = (select max(child_number)
                    from v$sql_plan_statistics_all where sql_id = '&psqlid')
and filter_predicates is not null)
order by id
/

