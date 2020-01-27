drop table hscenario_sessparam;
create table HSCENARIO_SESSPARAM (
	hscenario_id			number			not null,
	hsessparam_id			number			not null,
	value					varchar2(2000),
	constraint HSCENARIO_SESSPARAM_PK primary key (hscenario_id, hsessparam_id)
);

