set echo off
rem $Header$
rem $Name$		houtlnlst.sql

rem Copyright (c); 2005-2011 by Hotsos Enterprises, Ltd.
rem 
rem  Notes: Produces a list of stored outlines.

set termout on verify off feedback off long 50000
column sql_text format a50 word_wrapped

select name, sql_text
  from user_outlines
/


clear columns

@henv

