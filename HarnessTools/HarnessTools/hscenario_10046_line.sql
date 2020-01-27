drop table hscenario_10046_line;
create table HSCENARIO_10046_LINE (
	hscenario_id			number		not null,
	line#				number		not null,
	tim#				number		not null,
	text				varchar2(2000)	not null,
	constraint HSCENARIO_10046_LINE_PK primary key (hscenario_id, line#)
);

