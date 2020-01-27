rem $Header$
rem $Name$      _rmsc.sql

rem Copyright (c); 2004-2011 by Hotsos Enterprises, Ltd.
rem

whenever sqlerror continue;

set heading off

delete hscenario_sessparam
where hscenario_id=&1;

delete hscenario_statdetail
where hscenario_id=&1;

delete hscenario_snap_stat
where hscenario_id=&1;

delete hscenario_snap_diff
where hscenario_id=&1;

delete hscenario_10046_line
where hscenario_id=&1;

delete hscenario_10053_line
where hscenario_id=&1;

delete hscenario_plans
where hscenario_id=&1;

delete hscenario_plan_table
where hscenario_id=&1;

delete hscenario_v$sql_all
where hscenario_id=&1;

delete hscenario
where id=&1;

commit;


