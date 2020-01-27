set echo off
set verify off

rem $Header$
rem $Name$

rem Copyright (c); 2005-2011 by Hotsos Enterprises, Ltd.
rem 


set termout on serveroutput on
accept htst_owner   prompt 'Enter the owner name: '
accept htst_stattab prompt 'Enter the stattab name to create: '

declare

	v_owner		all_tables.owner%type := '&htst_owner' ;
	v_stattab	varchar2(30) := '&htst_stattab' ;
	e_no_tab    exception;
    PRAGMA EXCEPTION_INIT (e_no_tab, -20002);
begin
  begin  /*drop the table first */
	DBMS_STATS.DROP_STAT_TABLE(v_owner, v_stattab) ;
  exception 
    when e_no_tab then dbms_output.put_line ('No table to drop. Creating new table.');
  end;
  DBMS_STATS.CREATE_STAT_TABLE (v_owner, v_stattab);
  dbms_output.put_line ('*** stattab creation successful ***') ;

exception
   when others then
   	dbms_output.put_line (sqlerrm) ;
	dbms_output.put_line ('*** stattab creation error ***') ;
   
end ;
/

clear columns
undefine htst_owner
undefine htst_stattab

@henv
