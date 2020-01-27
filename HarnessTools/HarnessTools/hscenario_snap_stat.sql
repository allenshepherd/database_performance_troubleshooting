drop table hscenario_snap_stat;
create table HSCENARIO_SNAP_STAT (
	hscenario_id		number		not null,
	snap_id				number		not null,
	hstat_id			number		not null,
	value				number		not null,
	constraint HSCENARIO_SNAP_STAT_CK check (snap_id in (1,2)),
	constraint HSCENARIO_SNAP_STAT_PK primary key (hscenario_id, snap_id, hstat_id)
);

