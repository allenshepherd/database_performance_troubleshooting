rem $Header$
rem $Name$

rem Copyright (c); 2005-2011 by Hotsos Enterprises, Ltd.
rem

rem Drop all objects related to the Hotsos SQL Test Harness for a user

drop table hscenario_v$sql_all;
drop table plan_table ;
drop table hscenario_plan_table;
drop table hscripts ;
drop table hscenario;
drop table hsessparam;
drop table hscenario_sessparam;
drop table hstat ;
drop table hscenario_snap_stat;
drop table hscenario_snap_diff;
drop table hscenario_10046_line;
drop table hscenario_10053_line ;
drop table hscenario_plans;
drop table hscenario_statdetail;
drop table hconfig ;

drop procedure get_snap_remote;
drop procedure snap_request;
drop procedure snap_request_fulfill;
drop procedure load_trace ;
drop procedure print_table ;

drop function boil_raw;

drop sequence hseq;
