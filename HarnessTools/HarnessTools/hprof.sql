set echo off

rem $Header$
rem $Name$			hprof.sql

rem Copyright (c); 2005-2011 by Hotsos Enterprises, Ltd.
rem 

set termout on pause off autotrace off heading off feed off

accept htst_workspace prompt 'Enter the workspace name: '
accept htst_scenario  prompt 'Enter the scenario name : '

set termout off

column id new_val hsc_id

rem Get scenario ID
select id
  from HSCENARIO
 where UPPER(workspace) = UPPER('&htst_workspace') 
   and UPPER(name) = UPPER('&htst_scenario');

column filename new_val f

select filename
  from user_avail_trace_files 
 where hscenario_id = &hsc_id
   and trc_type = '10046';

spool &f

select text 
  from hscenario_10046_line
 where hscenario_id = &hsc_id
 order by line#;

spool off

set term off verify off head off feed off

select '&_hst prof.pl &f' from dual

spool prof_exec.lst
/
spool off

@prof_exec.lst

@hrmtempfile prof_exec.lst

clear columns
undefine f
undefine htst_workspace
undefine htst_scenario
undefine hsc_id

@henv
