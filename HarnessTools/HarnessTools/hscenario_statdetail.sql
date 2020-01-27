drop table hscenario_statdetail;
create table HSCENARIO_STATDETAIL 
(	hscenario_id		number			not null,
	text				varchar2(2000)			,
	id					number					,
	pid					number					,
	cnt					number					,
	cr					number					,
	pr					number					,
	pw					number					,	
	tim					number					,	
	op					varchar2(4000)			,
	constraint HSCENARIO_STATDETAIL_PK primary key (hscenario_id, id)
);
