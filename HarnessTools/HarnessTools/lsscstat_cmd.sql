set echo off

rem $Header$
rem $Name$          lsscstat_cmd.sql

rem Copyright (c); 2005-2011 by Hotsos Enterprises, Ltd.
rem


select stat_type,
       stat_name,
       stat_diff
  from hscenario_snap_diff
 where hscenario_id = &htst_id1
   and (case when substr(upper('&htst_stats'), 1, 1) = 'A' and
                  stat_diff > 0
             then 'A'
             when substr(upper('&htst_stats'), 1, 1) = 'S' and
                  stat_type IN ('Stats','Time')            and
                  stat_diff > 0
             then 'S'
             when substr(upper('&htst_stats'), 1, 1) = 'L' and
                  stat_type IN ('Latch','Time')            and
                  stat_diff > 0
             then 'L'
             when substr(upper('&htst_stats'), 1, 1) = 'C' and
                  always_print = 1
             then 'C'
             else null
        end) = substr(upper('&htst_stats'), 1, 1)
 order by stat_type, lower(stat_name), stat_diff
/

