set echo off
rem $Header$
rem $Name$			hscstatdtl.sql

rem Copyright (c); 2005-2011 by Hotsos Enterprises, Ltd.
rem 
rem Parameters
rem 1 - Workspace name
rem 2 - Scenario name
rem 
rem Usage
rem 		@hscstatdtl myworkspace test1
rem


set term off
col id1 new_val htst_sc_id

select id id1
  from hscenario 
 where UPPER(workspace)=UPPER('&1') 
   and UPPER(name)=UPPER('&2');

   
set linesize 250 pages 600 heading on term on feed off
prompt


col id format 9999
col pid format 9999
col cnt format 99999999999
col cr format 999999999999
col pr format 999999999999
col pw format 999999999999
col tim format 99999999999999999999
col op format a50

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
),
stat_lines as
(   select *
	  from whole_cursor_info 
	 where line_type = 'STAT'
	 order by rn
),
stat_pos as
(   select text, 
		   instr(text, 'id=') + 3 id_start,
		   instr(text, 'cnt=') -1 id_end,
		   instr(text, 'cnt=') + 4 cnt_start,
		   instr(text, 'pid=') - 1 cnt_end,
		   instr(text, 'pid=') + 4 pid_start,
		   instr(text, 'pos=') - 1 pid_end,
		   instr(text, 'op=') + 4 op_start,
		   instr(text, '(cr=') - 1 op_end,
		   substr(text, instr(text,'(cr=')) rowsource_stats,
		   instr(text, '(cr=') + 4 cr_start,
		   instr(text, 'pr=') - 1 cr_end,
		   instr(text, 'pr=') + 3 pr_start,
		   instr(text, 'pw=') - 1 pr_end,
		   instr(text, 'pw=') + 3 pw_start,
		   instr(text, 'time=') - 1 pw_end,
		   instr(text, 'time=') + 5 time_start,
		   instr(text, 'us)') - 1 time_end,
		   instr(text, 'p=') + 2 p_start,
		   instr(text, 'w=') - 1 p_end,
	   	   instr(text, 'w=') + 2 w_start,
	   	   instr(text, 'time=') - 1 w_end
	  from stat_lines
),
stat_detail as 
(   select &htst_sc_id hscenario_id, text,
		   to_number(substr(text,id_start,id_end - id_start)) id,
		   to_number(substr(text,pid_start,pid_end - pid_start)) pid,
		   to_number(substr(text,cnt_start,cnt_end - cnt_start)) cnt,
		   to_number(substr(text,cr_start,cr_end - cr_start)) cr,
		   to_number(substr(text,pr_start,pr_end - pr_start)) pr,
		   to_number(substr(text,pw_start,pw_end - pw_start)) pw,
		   to_number(substr(text,time_start,time_end - time_start)) tim,
	   	   substr(text,op_start,op_end - op_start) op
	  from stat_pos
	 order by id
)
select id, pid, cnt, cr, pr, pw, tim, (lpad(' ', pid) || op) op
  from stat_detail
/

prompt
clear break
clear columns
undefine 1
undefine 2
undefine htst_sc_id

@henv
