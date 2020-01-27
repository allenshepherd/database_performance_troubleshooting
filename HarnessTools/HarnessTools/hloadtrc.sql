set echo off

rem $Header$
rem $Name$      hloadtrc.sql

rem Copyright (c); 2005-2011 by Hotsos Enterprises, Ltd.
rem


set termout on
accept htst_trcfile   prompt 'Enter the trace file name: '
accept htst_trctype   prompt 'Enter the trace file type [10046 or 10053]: '
accept htst_workspace prompt 'Enter the workspace name: '
accept htst_scenario  prompt 'Enter the scenario name: '

set termout off heading off feedback off

column id new_val sc_id

select id
  from hscenario
 where UPPER(workspace) = UPPER('&htst_workspace')
   and UPPER(name) = UPPER('&htst_scenario') ;

set termout on serveroutput on heading off feed off

exec hotsos_pkg.trace_file_upload ('&htst_trcfile', &sc_id, &htst_trctype)
exec load_trace (&sc_id, &htst_trctype)

select case when &htst_trctype = 10046
            then count(*)  || ' total 10046 trace file lines loaded.'
            else null
       end tot_msg
  from hscenario_10046_line
 where hscenario_id = &sc_id
   and 10046 = &htst_trctype;

select case when &htst_trctype = 10053
            then count(*)  || ' total 10053 trace file lines loaded.'
            else null
       end tot_msg
  from hscenario_10053_line
 where hscenario_id = &sc_id
   and 10053 = &htst_trctype;


undefine sc_id
undefine htst_trcfile
undefine htst_trctype
undefine htst_workspace
undefine htst_scenario

clear columns

@henv
