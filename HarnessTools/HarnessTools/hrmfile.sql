set echo off

rem $Header$
rem $Name$			hrmfile.sql

rem Copyright (c); 2006-2011 by Hotsos Enterprises, Ltd.
rem 
rem Works in 9i and above
rem Deletes trace files from USER_DUMP_DEST 
rem First displays a list of all trace files associated with scenarios
rem 

undefine htst_trcfile

set lines 140 pages 60 termout on heading on feed off 

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

set termout on serveroutput on echo off head off
prompt 
accept htst_trcfile prompt 'Enter the trace file name to delete: '

exec hotsos_pkg.remove_host_file('UDUMP_DIR','&htst_trcfile') ;

undefine htst_trcfile
clear columns
@henv
