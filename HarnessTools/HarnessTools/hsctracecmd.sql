set echo off
rem $Header$
rem $Name$          hsctracecmd.sql

rem Copyright (c); 2005-2011 by Hotsos Enterprises, Ltd.
rem
rem Parameters
rem 1 - Workspace name
rem 2 - Scenario name
rem 3 - Lines to view
rem 4 - Termout setting (ON or OFF)
rem     A - All lines in trace file for your SQL statement's cursor
rem     Q - The SQL statement itself
rem     P - The PARSE line
rem     B - The BINDS line(s)
rem     E - The EXEC line
rem     F - The FETCH line(s)
rem     W - The WAIT line(s)
rem     S - The STAT line(s)
rem
rem Usage
rem         @hsctracecmd myworkspace test1 A termout_setting
rem


set term off
col id1 new_val htst_sc_id
col id2 new_val htst_where
col parm4 new_val htst_termout

select id id1, decode(nvl('&4','ON'),'OFF','OFF','ON') parm4
  from hscenario
 where UPPER(workspace)=UPPER('&1')
   and UPPER(name)=UPPER('&2');

select decode (upper('&3'),
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

set linesize 132 pages 600 heading off term &htst_termout feed off
--prompt
--column text heading 'Actual lines from extended SQL trace for &1:&2'


with
maxln_info as
(   select max(line#) max_line
      from hscenario_10046_line
     where hscenario_id = &htst_sc_id
       and text like 'STAT%'
),
cursor_info as
(   select substr(text,7,(instr(text,'id')-1)-7) cursor_id
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
(   select line# parse_line_for_cursor
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
                                  when text like 'PARSE%'             then 'PARSE'
                                  when text like 'EXEC%'              then 'EXEC'
                                  when text like 'BIND%'              then 'BIND'
                                  when text like 'FETCH%'             then 'FETCH'
                                  when text like 'WAIT%'              then 'WAIT'
                                  when text like 'STAT%'              then 'STAT'
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


-- prompt
clear break
clear columns
undefine 1
undefine 2
undefine htst_sc_id
undefine 3
undefine htst_where
undefine 4

@henv
