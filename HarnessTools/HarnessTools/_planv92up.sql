set echo off
rem $Header$
rem $Name$

rem Copyright (c); 2005-2011 by Hotsos Enterprises, Ltd.
rem 

set term on linesize 132 pages 600 heading on verify off feed off 
prompt
column text heading 'Actual PARSE and STAT line(s) from extended SQL trace'

with 
sc_info as
(	select id
	  from HSCENARIO
	 where UPPER(workspace) = UPPER('&1') 
	   and UPPER(name) = UPPER('&2')
),
maxln_info as
(	select max(line#) max_line
	  from hscenario_10046_line 
	 where hscenario_id = (select id from sc_info)
	   and text like 'STAT%'
),
cursor_info as
(	select substr(text,7,(instr(text,'id')-1)-7) cursor_id
	  from hscenario_10046_line
	 where line# = (select max_line from maxln_info)
	   and hscenario_id = (select id from sc_info)
),
parse_info as 
(	select text
	  from (
			select text
			  from hscenario_10046_line 
			 where hscenario_id = (select id from sc_info)
			   and text like 
			   		(select 'PARSE #' || cursor_id || '%' from cursor_info)
			   and line# < (select max_line from maxln_info)
			 order by line# desc 
			) pl
	 where rownum = 1
),
parse_type_info as
(	select case when instr(text,'mis=0') > 0 then 'Query was SOFT parsed'
				when instr(text,'mis=1') > 0 then 'Query was HARD parsed' 
				else '***'
			end text
	  from parse_info
),
stat_lines as
(	select text
	  from hscenario_10046_line
	 where hscenario_id = (select id from sc_info)
	   and text like (select 'STAT #' || cursor_id || '%' from cursor_info)
	 order by line#
)
select * from parse_type_info
UNION ALL
select text from parse_info 
UNION ALL
select ' ' text from dual
UNION ALL
select text from stat_lines ;

prompt
