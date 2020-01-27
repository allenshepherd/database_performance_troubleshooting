drop table hscenario_plans;
create table hscenario_plans (
	hscenario_id   number,
	line#          number,
	plan_output    varchar2(500),
	constraint hscenario_plans_pk primary key (hscenario_id, line#)
);

