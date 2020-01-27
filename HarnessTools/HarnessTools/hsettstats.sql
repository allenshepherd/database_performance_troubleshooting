set echo off

rem $Header$
rem $Name$		hsettstats.sql

rem Copyright (c); 2005-2011 by Hotsos Enterprises, Ltd.
rem 

set termout on verify off serveroutput on

prompt
prompt For the following prompts, no entry will leave values unchanged.
prompt To set a value to 0 (zero), enter -1.
prompt

accept htst_owner       prompt 'Owner name      : '
accept htst_table       prompt 'Table name      : '
accept htst_rows number prompt 'Number of rows  : '
accept htst_blks number prompt 'Number of blocks: '

declare

	v_numrows	number := &htst_rows;
	v_numblks	number := &htst_blks;
	v_avgrlen	number ;
	v_table		all_tables.table_name%type := UPPER('&htst_table') ;
	v_owner		all_tables.owner%type := UPPER('&htst_owner') ;
	v_stattab	varchar2(30) := null ;

begin

	if v_numrows = -1 then 
		v_numrows := 0 ;
	elsif v_numrows = 0 then
		v_numrows := -1 ;
	elsif v_numrows is null then
		v_numrows := -1 ;
	end if ;

	if v_numblks = -1 then 
		v_numblks := 0 ;
	elsif v_numblks = 0 then
		v_numblks := -1 ;
	elsif v_numblks is null then
		v_numblks := -1 ;
	end if ;
	
	if v_numrows >= 0 then
		dbms_stats.set_table_stats(v_owner, v_table, numrows=>v_numrows,
			stattab=>v_stattab, no_invalidate=>FALSE) ;
	end if;
			
	if v_numblks >= 0 then
		dbms_stats.set_table_stats(v_owner, v_table, numblks=>v_numblks, 
			stattab=>v_stattab, no_invalidate=>FALSE) ;
	end if ;

	dbms_output.put_line ('Request Complete.') ;	
	
	dbms_stats.get_table_stats (v_owner, v_table, stattab => v_stattab,
		numrows => v_numrows,  numblks => v_numblks, avgrlen => v_avgrlen ) ;
	dbms_output.put_line ('-----------------------------------------');
	dbms_output.put_line ('Table: ' || UPPER(v_table));
	dbms_output.put_line ('-----------------------------------------');
	dbms_output.put_line ('Rows: ' || v_numrows || '  Blocks: ' || v_numblks ||'  Avg Row Len: ' || v_avgrlen) ;

exception 
	when others then
	   	dbms_output.put_line (sqlerrm) ;
		dbms_output.put_line ('Cannot modify statistics.  Check request and try again.') ;
	
end ;
/

undefine htst_owner
undefine htst_table
undefine htst_rows 
undefine htst_blks 

@henv
