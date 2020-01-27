set echo off

rem $Header$
rem $Name$			snap.sql

rem Copyright (c); 2004-2011 by Hotsos Enterprises, Ltd.
rem 

define hsnap_id=&1

insert into hscenario_snap_stat (hscenario_id, snap_id, hstat_id, value)
	select &htst_scenario_id, &hsnap_id, statistic# hstat_id, value
	from v$mystat
	union all
	select &htst_scenario_id, &hsnap_id, latch#+10000 hstat_id, gets+immediate_gets value
	from v$latch
	union all
	select &htst_scenario_id, &hsnap_id, -1 hstat_id, hsecs value
	from v$timer
/

undefine hsnap_id
undefine 1
