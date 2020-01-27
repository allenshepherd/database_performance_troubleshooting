drop table hscenario_snap_diff ;

create table hscenario_snap_diff (
 hscenario_id       number
,stat_type          varchar2(5)
,stat_name          varchar2(64)
,stat_diff          number
,always_print       number
,constraint snap_diff_pk primary key (hscenario_id, stat_name)
);
