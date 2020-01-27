set echo off

rem $Header$
rem $Name$      hvxplan.sql

rem Copyright (c); 2006-2011 by Hotsos Enterprises, Ltd.
rem
rem Usage: @hvxplan &htst_hv
rem
rem Parameters:
rem &htst_hv = SQL hash_value
rem
rem Retrieve V$SQL_PLAN plan data and statistics for a specified hash value
rem

set verify off echo off feed off lines 700 pages 3000 heading on termout on

accept htst_hv prompt 'Enter the SQL hash value: '


col hv head 'hv' noprint
col cn for 90 print
col est_rows head 'est. rows' for 999,999,990
col actual_rows head 'act. rows' for 999,999,990
col operation for a50
col elapsed for 99,990.999
col cpu for 99,990.999
col cr_gets for 99,999,990
col cu_gets for 99,999,990
col reads  for 9,999,990
col writes  for 99,990
col where_clause for a300
col access_predicates for a240
col filter_predicates for a240
col id for a4
col pid for a4

break on hv skip 0 on cn skip 0

select p.hash_value hv
     , p.child_number cn
     , to_char(p.id,'990') id
     , to_char(p.parent_id,'990') pid
     , p.cardinality est_rows
     , ( select s.last_output_rows
           from v$sql_plan_statistics s
          where s.address=p.address
            and s.hash_value=p.hash_value
            and s.child_number=p.child_number
            and s.operation_id=p.id) actual_rows
     , lpad(' ',depth)||p.operation||' '|| p.options||' '|| p.object_name||
       decode(p.partition_start,null,' ',':')|| translate(p.partition_start,'(nrumbe','(nr')||
       decode(p.partition_stop,null,' ','-')||translate(p.partition_stop,'(nrumbe','(nr') operation
     , ( select round(s.last_elapsed_time/1000000,2)
           from v$sql_plan_statistics s
          where s.address=p.address
            and s.hash_value=p.hash_value
            and s.child_number=p.child_number
            and s.operation_id=p.id) elapsed
     , (select s.last_cr_buffer_gets
          from v$sql_plan_statistics s
         where s.address=p.address
           and s.hash_value=p.hash_value
           and s.child_number=p.child_number
           and s.operation_id=p.id) cr_gets
     , (select s.last_cu_buffer_gets
          from v$sql_plan_statistics s
         where s.address=p.address
           and s.hash_value=p.hash_value
           and s.child_number=p.child_number
           and s.operation_id=p.id) cu_gets
     , (select s.last_disk_reads
          from v$sql_plan_statistics s
         where s.address=p.address
           and s.hash_value=p.hash_value
           and s.child_number=p.child_number
           and s.operation_id=p.id) reads
     , (select s.last_disk_writes
          from v$sql_plan_statistics s
         where s.address=p.address
           and s.hash_value=p.hash_value
           and s.child_number=p.child_number
           and s.operation_id=p.id) writes
     , (case when p.id = 0 then null else p.cost end) cost
     , (case when p.id = 0 then null else p.io_cost end) io_cost
     , (case when p.id = 0 then null else p.cpu_cost end) cpu_cost
--     , (case when p.id = 0 then null else p.temp_space end) temp_space
     , decode(access_predicates,null,null,access_predicates||' [access] ') ||
       decode(filter_predicates,null,null,filter_predicates||' [filter]') where_clause
  from v$sql_plan p
 where p.hash_value = &htst_hv
 order by p.child_number, p.id
/

undefine htst_hv
clear columns
@henv
