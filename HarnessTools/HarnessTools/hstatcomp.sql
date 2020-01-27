set echo off

rem $Header$
rem $Name$      hstatcomp.sql

rem Copyright (c); 2005-2011 by Hotsos Enterprises, Ltd.
rem

set feedback off heading on termout on

accept htst_workspace prompt 'Enter the workspace name           : '
accept htst_stat_name prompt 'Enter the statistic name or pattern: '
accept htst_level     prompt 'All (0) or Top-N (#) scenarios     : '

define htst_pattern = "&htst_stat_name"

col scenario format a30
col statistic format a40
col rn format 9999
col value format 999999999

break on statistic skip 1

select name as scenario, stat_name as statistic, stat_diff as value
  from
(
select h.name, s.stat_name, s.stat_diff,
       row_number() over (partition by s.stat_name order by s.stat_diff) rn
  from hscenario_snap_diff s, hscenario h
 where s.stat_name like '&htst_pattern%'
   and h.id = s.hscenario_id
   and upper(h.workspace) = upper('&htst_workspace')
)
 where &htst_level = 0
    or rn <= &htst_level
 order by stat_name, value, name
/

clear columns
undefine htst_workspace
undefine htst_stat_name
undefine htst_pattern

@henv
