set echo off

rem $Header$
rem $Name$

rem Copyright (c); 2004-2011 by Hotsos Enterprises, Ltd.
rem 
rem  Notes: Display view definition for a view (i.e., v$ view)

accept p_hfv prompt 'Enter the view name: '

set termout on verify off lines 80
desc &p_hfv

column view_definition format a80 word_wrapped

select view_definition 
  from v$fixed_view_definition
 where view_name like upper('&p_hfv');

undefine p_hfv
clear columns

@henv
