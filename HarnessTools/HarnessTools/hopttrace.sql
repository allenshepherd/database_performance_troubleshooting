set echo off

rem $Header$
rem $Name$      hopttrace.sql

rem Copyright (c); 2005-2011 by Hotsos Enterprises, Ltd.
rem
rem Optimizer trace (10053) display
rem

set termout on feed off verify off

accept htst_workspace  prompt 'Enter the workspace name: '
accept htst_scenario   prompt 'Enter the scenario name : '

set termout off heading off

column id new_val sc_id
column filename new_val f

select h.id, t.filename
  from hscenario h, user_avail_trace_files t
 where UPPER(h.workspace) = UPPER('&htst_workspace')
   and UPPER(h.name) = UPPER('&htst_scenario')
   and h.id = t.hscenario_id
   and t.trc_type = 10053 ;

set embedded on linesize 4000 trimspool on

spool &f

select text
  from hscenario_10053_line
 where hscenario_id = &sc_id
 order by line#;

spool off

set termout on

prompt Your trace file (&f) has been spooled to
prompt your default directory and opened in your default editor.
prompt

ed &f


undefine sc_id
undefine f
undefine htst_workspace
undefine htst_scenario

clear columns
@henv
