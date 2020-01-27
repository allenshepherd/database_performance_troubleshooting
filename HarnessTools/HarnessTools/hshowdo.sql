set echo off

rem $Header$
rem $Name$          hshowdo.sql

rem Copyright (c); 2005-2011 by Hotsos Enterprises, Ltd.
rem


set termout on verify off heading off feed off

define htst_stats = 'C'

accept htst_workspace  prompt 'Enter the workspace name                  : '
accept htst_scenario   prompt 'Enter the scenario name                   : '
accept htst_stats      prompt 'Display? (S)tats/(L)atches/(A)ll/(C)ustom : '

set termout off

col id1 new_val htst_scenario_id
col test_type new_val htst_test_type
col termout_setting new_value htst_dotermout

select id id1, test_type, decode(UPPER(test_type),'S','ON','OFF') as termout_setting
  from hscenario
 where UPPER(workspace)=UPPER('&htst_workspace')
   and UPPER(name)=UPPER('&htst_scenario');


set term on serveroutput on

prompt

begin
  if '&htst_test_type' != 'S' then
     dbms_output.put_line ('************************************************');
     dbms_output.put_line ('To see output for a PL/SQL test, use @lsscstat');
     dbms_output.put_line ('************************************************');
  end if;
end;
/

set termout &htst_dotermout heading on linesize 132 pages 1000


prompt
prompt Test Output for &htst_workspace:&htst_scenario

@hsctracecmd &htst_workspace &htst_scenario Q &htst_dotermout
@hsctracecmd &htst_workspace &htst_scenario P &htst_dotermout
@hsctracecmd &htst_workspace &htst_scenario S &htst_dotermout

/*
set termout &htst_dotermout head on linesize 500

col id format 99999 heading 'ID'
col pid format 99999 heading 'PID'
col cnt format 9999999999999 heading 'Rows'
col cr format 99999999999999 heading 'LIO'
col pr format 99999999999999 heading 'PIO'
col pw format 99999999999999 heading 'Writes'
col tim format 9999999999999999999999 heading 'Time'
col op format a50 heading 'Operation'

select id, pid, op, cnt, cr, tim, pr, pw
  from hscenario_statdetail
 where hscenario_id = &htst_scenario_id
/

prompt
prompt

col tots format a100 heading 'Statement Totals (portion of total statistics attributable to this test SQL statement)'

select decode(r,1, 'Total LIO   : '||to_char(tot_cr),
                2, 'Total PIO   : '||to_char(tot_pr),
                3, 'Total Writes: '||to_char(tot_pw),
                4, 'Total Time  : '||to_char(tot_tim)||' secs') tots
  from (select sum(cr) tot_cr, sum(pr) tot_pr, sum(pw) tot_pw, sum(tim) * .000001 tot_tim
          from hscenario_statdetail
         where pid = 0
           and hscenario_id = &htst_scenario_id) qry,
       (select rownum r from all_objects where rownum <= 4 )
/

*/

set termout &htst_dotermout heading off
prompt
prompt
prompt Explain Plan for &htst_workspace:&htst_scenario

rem column plan_output heading 'Explain Plan for Scenario &htst_workspace:&htst_scenario'
select plan_output
  from hscenario_plans
 where hscenario_id = &htst_scenario_id ;

prompt
prompt
prompt Statistics Snapshot for &htst_workspace:&htst_scenario
prompt


set termout off verify off heading off
set feed off linesize 130 pagesize 0 echo off

define htst_id1 = &htst_scenario_id

-----------------------------------------
-- Display captured stats
-----------------------------------------

col stat_name     format  a40           heading 'Statistic Name' word_wrapped
col stat_diff     format  9,999,999,990 heading 'Value'
col stat_type     format  a5            heading 'Type '

set termout &htst_dotermout heading on linesize 132 pages 1000
break on stat_type skip 1

@lsscstat_cmd

set term on
clear break
clear columns
