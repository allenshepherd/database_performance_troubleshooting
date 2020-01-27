set echo off

rem $Header$
rem $Name$		htracefiles.sql

rem Copyright (c); 2005-2011 by Hotsos Enterprises, Ltd.
rem 
rem Displays trace file names for all scenarios
rem 

set lines 140 pages 60 termout on heading on feed off 
set pause on
set pause 'More:'

column filename format a60 heading 'File Name'
column date_str format a20 heading 'Date/Time'
column tname format a30 heading 'Scenario'
column trc_type format 99999999 heading 'Trace Type'

select to_char(t.dt,'mm/dd/yyyy hh24:mi:ss') date_str,  
       UPPER(h.workspace || '.' || h.name || ' (' || to_char(h.id) || ')' ) as tname, 
       t.trc_type, t.filename
  from user_avail_trace_files t , hscenario h
 where t.hscenario_id = h.id
 order by dt;

set pause off

clear columns
@henv
