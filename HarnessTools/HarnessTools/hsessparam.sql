
drop table hsessparam;
create table HSESSPARAM (
	id			number			not null,
	name		varchar2(100)	not null,
	constraint HSESSPARAM_PK primary key (id),
	constraint HSESSPARAM_U1 unique (name)
);

rem If want to see hidden parameters, must change v$parameter 
rem to sys.hotsos_parameters below
insert into hsessparam 
select num id, name from v$parameter ;

commit ;
