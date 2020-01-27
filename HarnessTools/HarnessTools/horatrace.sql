set echo off 

rem $Header$
rem $Name$			horatrace.sql

rem Copyright (c); 2005-2011 by Hotsos Enterprises, Ltd.
rem 
rem SQL Trace data (10046) display

set termout on feed off verify off heading off

accept htst_workspace  prompt 'Enter the workspace name   : '
accept htst_scenario   prompt 'Enter the scenario name    : '
accept htst_tkprof     prompt 'Review tkprof output? (Y/N): '

set termout off 

column id new_val sc_id
column filename new_val f

select h.id, t.filename
  from hscenario h, user_avail_trace_files t
 where UPPER(h.workspace) = UPPER('&htst_workspace')
   and UPPER(h.name) = UPPER('&htst_scenario') 
   and h.id = t.hscenario_id 
   and t.trc_type = 10046 ;

set embedded on linesize 4000 trimspool on  

spool &f

select text 
  from hscenario_10046_line
 where hscenario_id = &sc_id
 order by line#;

spool off

set termout on
prompt Your trace file (&f) has been spooled to your default directory.
prompt
prompt Tkprof output will be displayed first (if requested).
prompt 
prompt &f will be displayed in your editor after any tkprof output.
prompt
pause Press Enter to continue. . .

set termout off
column sort_ord noprint

select 1 as sort_ord, '&_hst tkprof &f tk.prf' tkprof_cmd
  from dual
 where substr(upper('&htst_tkprof'), 1, 1) = 'Y'
UNION
select 2 as sort_ord, 'edit tk.prf' tkprof_edt
  from dual
 where substr(upper('&htst_tkprof'), 1, 1) = 'Y'
 order by sort_ord
 
set termout off verify off echo off heading off
spool tkprof.lst
/
spool off
set termout on  
prompt
@tkprof.lst

ed &f

@hrmtempfile tkprof.lst

undefine htst_tkprof
undefine f
undefine htst_workspace
undefine htst_scenario
undefine sc_id

clear columns
@henv
