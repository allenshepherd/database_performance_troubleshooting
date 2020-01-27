rem $Header$
rem $Name$

rem Copyright (c); 2005-2011 by Hotsos Enterprises, Ltd.
rem 

set term off
column id        new_val hsc_id
column max_line  new_val maxln
column cursor_id new_val cur_id

rem Get scenario ID
select id
  from HSCENARIO
 where UPPER(workspace) = UPPER('&1') 
   and UPPER(name) = UPPER('&2');

rem Get last STAT line for the scenario
select max(line#) max_line
  from hscenario_10046_line 
 where hscenario_id = &hsc_id 
   and text like 'STAT%';

rem Get cursor id from STAT line
select substr(text,7,(instr(text,'id')-1)-7) cursor_id
  from hscenario_10046_line
 where line# = &maxln
   and hscenario_id = &hsc_id;

set term on

set linesize 132 pages 600 heading on verify off feed off 
rem set head off

prompt
column hscenario_id noprint
column text heading 'Actual PARSE and STAT line(s) from extended SQL trace'

rem PARSE line
select text
  from (select text
		  from hscenario_10046_line 
	     where hscenario_id = &hsc_id
           and text like 'PARSE #' || '&cur_id' || '%'
           and line# < &maxln
         order by line# desc )
 where rownum = 1;

set head off

rem STAT lines
select text
  from hscenario_10046_line
 where hscenario_id = &hsc_id
   and text like 'STAT #' || '&cur_id' || '%'
 order by line#;

prompt