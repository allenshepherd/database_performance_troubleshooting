set echo off

rem $Header$
rem $Name$      hlio.sql

rem Copyright (c); 2005-2011 by Hotsos Enterprises, Ltd.
rem

set feedback off heading on termout on

accept htst_workspace prompt 'Enter the workspace name: '

col name         format a20 heading 'Scenario'
col cr           format 999,999,999,999 heading 'Consistent Gets'
col cu           format 999,999,999,999 heading 'DB Block Gets'
col bipc         format 999,999,999,999 heading 'Buffer Pinned Ct'
col lio          format 999,999,999,999 heading 'Logical IO' noprint
col total_lio    format 999,999,999,999 heading 'Total LIO'
col pr           format 999,999,999,999 heading 'Physical Reads'

select name, total_lio, cr, bipc, cu, pr
  from
(
select h.name,
       max (decode (d.stat_name, 'physical reads', d.stat_diff) ) pr,
       max (decode (d.stat_name, 'consistent gets', d.stat_diff) ) cr,
       max (decode (d.stat_name, 'buffer is pinned count', d.stat_diff) ) bipc,
       max (decode (d.stat_name, 'db block gets', d.stat_diff) ) cu,
       max (decode (d.stat_name, 'consistent gets', d.stat_diff) ) +
       max (decode (d.stat_name, 'db block gets', d.stat_diff) ) +
       max (decode (d.stat_name, 'buffer is pinned count', d.stat_diff) ) total_LIO
  from hscenario_snap_diff d, hscenario h
 where d.hscenario_id = h.id
   and UPPER(h.workspace) = UPPER('&htst_workspace')
   and d.stat_name IN ('buffer is pinned count','consistent gets','db block gets','physical reads')
 group by h.name
)
  order by total_LIO
/

clear columns
undefine htst_workspace

@henv
