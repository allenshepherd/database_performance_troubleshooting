set echo off

rem $Header$
rem $Name$      lssc.sql

rem Copyright (c); 2005-2011 by Hotsos Enterprises, Ltd.
rem

set termout on

accept htst_workspace  prompt 'Enter the workspace name: '

col llsc_workspace       format   a20 heading 'Workspace'
col llsc_scenario_id     format 99999 heading 'Scenario|Id'
col llsc_scenario_name   format   a20 heading 'Scenario|Name'
col llsc_num_params      format 9,990 heading 'Number of|Parameters'
col llsc_num_snaps       format 9,990 heading 'Number of|Snapshots'
col llsc_type            format a6    heading ' Test | Type '

break on llsc_workspace nodup
set linesize 132 termout on heading on feedback on

select   s1.workspace llsc_workspace
        ,s1.id llsc_scenario_id
        ,decode(upper(s1.test_type),'S',' SQL','P',' PLSQL','') llsc_type
        ,s1.name  llsc_scenario_name
        ,(select count(*)
            from hscenario_sessparam sp where sp.hscenario_id = s1.id) llsc_num_params
        ,(select count(distinct snap_id)
            from hscenario_snap_stat ss where ss.hscenario_id = s1.id) llsc_num_snaps
  from hscenario s1
 where UPPER(workspace)=UPPER('&htst_workspace');

clear breaks
clear columns
undefine htst_workspace
@henv
