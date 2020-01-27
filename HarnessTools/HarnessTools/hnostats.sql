set echo off

rem $Header$
rem $Name$			hnostats.sql

rem Copyright (c); 2005-2011 by Hotsos Enterprises, Ltd.
rem 

set termout on verify off serveroutput on

accept htst_owner prompt 'Enter the owner name: '

DECLARE
    v_owner	 all_tables.owner%type := UPPER('&htst_owner') ;
	obj_tab  dbms_stats.objecttab;

begin
	dbms_stats.gather_database_stats
	   (OPTIONS=>'LIST EMPTY',OBJLIST=>obj_tab);
	for i in 1 .. obj_tab.count loop
	if obj_tab(i).ownname = v_owner THEN
	   dbms_output.put_line( obj_tab(i).ownname || '.' ||
	     obj_tab(i).objName || ' >> ' || obj_tab(i).objType ||
	     '   ' || obj_tab(i).PartName || ' ' ||
	     obj_tab(i).subPartName );
	end if;
	end loop;
end;
/

undefine htst_owner

@henv
