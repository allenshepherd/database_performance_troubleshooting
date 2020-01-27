set echo off
set verify off

rem $Header$
rem $Name$

rem Copyright (c); 2005-2011 by Hotsos Enterprises, Ltd.
rem 


set termout on serveroutput on
accept htst_owner   prompt 'Enter the owner name  : '
accept htst_stattab prompt 'Enter the stattab name: '

declare
	v_owner		all_tables.owner%type := '&htst_owner' ;
	v_stattab	varchar2(30) := '&htst_stattab' ;
begin
	dbms_stats.import_schema_stats (v_owner, stattab => v_stattab, cascade => TRUE, no_invalidate => FALSE ) ;
exception
   when others then
   	dbms_output.put_line (sqlerrm) ;
	dbms_output.put_line ('*** Statistics import error ***') ;  
end ;
/

undefine htst_owner
undefine htst_stattab

@henv
