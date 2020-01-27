set echo off

rem $Header$
rem $Name$		hnewplan.sql

rem Copyright (c); 2005-2011 by Hotsos Enterprises, Ltd.
rem 
rem  Notes: Copy execution plan from one outline to another.
rem

whenever sqlerror exit rollback;

set serveroutput on verify off

define src=&1
define dest=&2

declare
	cursor oldesc is select column_name from all_tab_columns
         where owner='OUTLN' and table_name='OL$HINTS' order by column_id;
	stmt varchar(1024);
	v_fnd  number;
	ic   number;
	nr   number;
	sep  char := '';
begin
select count(distinct ol_name) into v_fnd from ol$ where ol_name in ('&dest','&src');
if v_fnd != 2 then
	dbms_output.put_line('Cannot find both src and dest outlines');
	return;
end if;
delete ol$hints where ol_name='&dest';
stmt := 'insert into ol$hints select ';
for dr in oldesc loop
	if dr.column_name = 'OL_NAME' then
		stmt := stmt || sep || '''&dest''';
	else
		stmt := stmt || sep || dr.column_name;
	end if;
	sep := ',';
end loop;
stmt := stmt || ' from ol$hints where ol_name=''&src''';
ic := dbms_sql.open_cursor;
dbms_sql.parse(ic, stmt, dbms_sql.v7);
nr := dbms_sql.execute(ic);
dbms_sql.close_cursor(ic);
commit;
end;
/

undefine 1
undefine 2
undefine src
undefine dest

@henv
