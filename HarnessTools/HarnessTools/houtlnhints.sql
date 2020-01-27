set echo off
rem $Header$
rem $Name$		houtlnhints.sql

rem Copyright (c); 2005-2011 by Hotsos Enterprises, Ltd.
rem 
rem  Notes: Produces a list of hints for a named stored outline.

set termout on verify off feedback off long 50000
column hint format a50 word_wrapped
column node format 999999
column stage format 999999
column join_pos format 999999

accept p_name prompt 'Enter the outline name: '

select hint 
--     ,node, stage, join_pos
  from user_outline_hints
 where name = UPPER('&p_name')
/

undefine p_name

clear columns

@henv

