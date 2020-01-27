set echo off
rem $Header$
rem $Name$			hsctrace.sql

rem Copyright (c); 2005-2011 by Hotsos Enterprises, Ltd.
rem 


set termout on verify off heading off feed off

accept htst_workspace prompt 'Enter the workspace name: '
accept htst_scenario  prompt 'Enter the scenario name : '
prompt
prompt Which lines from the trace file for this scenario do you wish to view?
prompt A - All lines in trace file for your SQL statement's cursor
prompt Q - The SQL statement itself
prompt P - The PARSE line
prompt B - The BINDS line(s)
prompt E - The EXEC line
prompt F - The FETCH line(s)
prompt W - The WAIT line(s)
prompt S - The STAT line(s)
accept htst_what      prompt 'Selection? : '
prompt

set term off
col id1 new_val htst_sc_id
col id2 new_val htst_where

select id id1
  from hscenario 
 where UPPER(workspace)=UPPER('&htst_workspace') 
   and UPPER(name)=UPPER('&htst_scenario');

select decode (upper('&htst_what'), 
		'A', '%',
		'Q', 'CURSQL',  
		'P', 'PARSE',
		'B', 'BIND',
		'E', 'EXEC',
		'F', 'FETCH',  
		'W', 'WAIT',
		'S', 'STAT',
		'%') id2
  from dual;
   
set linesize 132 pages 600 heading on term on
prompt
column text heading 'Actual lines from extended SQL trace for &htst_workspace:&htst_scenario'


with 
maxln_info as
(	select max(line#) max_line
	  from hscenario_10046_line 
	 where hscenario_id = &htst_sc_id
	   and text like 'STAT%'
),
cursor_info as
(	select substr(text,7,(instr(text,'id')-1)-7) cursor_id
	  from hscenario_10046_line
	 where line# = (select max_line from maxln_info)
	   and hscenario_id = &htst_sc_id
),
firstln_info as
(   select max(line#) min_line
      from hscenario_10046_line
     where hscenario_id = &htst_sc_id
       and line# < (select max_line from maxln_info)
       and text like (select 'PARSING IN CURSOR #' || cursor_id || '%' from cursor_info)
),
parse_info as 
(	select line# parse_line_for_cursor
	  from (
			select text, line#
			  from hscenario_10046_line 
			 where hscenario_id = &htst_sc_id
			   and text like 
			   		(select 'PARSE #' || cursor_id || '%' from cursor_info)
			   and line# < (select max_line from maxln_info)
			 order by line# desc 
			) pl
	 where rownum = 1
),
whole_cursor_info as
(   select rownum rn, text, (case when text like 'PARSING IN CURSOR%' then 'CURDEF' 
								  when text like 'END OF STMT%'       then 'CURDEF' 
								  when text like 'PARSE%'			  then 'PARSE'  
								  when text like 'EXEC%'			  then 'EXEC'   
								  when text like 'BIND%'			  then 'BIND'   
								  when text like 'FETCH%'			  then 'FETCH'  
								  when text like 'WAIT%'			  then 'WAIT'   
								  when text like 'STAT%'			  then 'STAT'
								  else 'CURSQL'
							  end ) as line_type
	  from (              
			select line#, text
			  from hscenario_10046_line
			 where hscenario_id = &htst_sc_id
			   and line# >= (select parse_line_for_cursor from parse_info)
			   and line# <= (select max_line from maxln_info)
			   and text like '%#' || (select cursor_id from cursor_info) || '%'
			UNION ALL
			select line#, text
			  from hscenario_10046_line
			 where hscenario_id = &htst_sc_id
			   and line# >= (select min_line from firstln_info) 
			   and line# <  (select parse_line_for_cursor from parse_info)   
			 order by line#					   	 	        
	       ) 
)
select text 
  from whole_cursor_info 
 where line_type like '&htst_where%' 
 order by rn; 

 
prompt
clear break
clear columns
undefine htst_workspace
undefine htst_scenario
undefine htst_sc_id
undefine htst_what
undefine htst_where

@henv
