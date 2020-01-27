set echo off

rem $Header$
rem $Name$		houtlnswitch.sql

rem Copyright (c); 2005-2011 by Hotsos Enterprises, Ltd.
rem 
rem  Notes: Copy execution plan from one outline to another.
rem

set serveroutput on verify off feed on

accept p_src prompt 'Enter the source outline     : '
accept p_dst prompt 'Enter the destination outline: '

update outln.ol$hints 
   set ol_name = decode(ol_name, UPPER('&p_dst'), UPPER('&p_src'),
   								 UPPER('&p_src'), UPPER('&p_dst') )
 where ol_name in (UPPER('&p_src'), UPPER('&p_dst'));

update outln.ol$ ol1 set hintcount = 
	   (select hintcount from outln.ol$ ol2 
	     where ol2.ol_name in (UPPER('&p_src'), UPPER('&p_dst'))
	       and ol2.ol_name != ol1.ol_name )
 where ol1.ol_name in (UPPER('&p_src'), UPPER('&p_dst')) ;


undefine p_src
undefine p_dst

@henv
