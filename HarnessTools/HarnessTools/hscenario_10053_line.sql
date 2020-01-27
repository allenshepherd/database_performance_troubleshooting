drop table hscenario_10053_line ;
create table HSCENARIO_10053_LINE (
	hscenario_id			number		not null,
	line#				number		not null,
	text				varchar2(2000)	not null,
	constraint HSCENARIO_10053_LINE_PK primary key (hscenario_id, line#)
);
