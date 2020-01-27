set echo off

rem $Header$
rem $Name$		hprofany.sql

rem Copyright (c); 2005-2011 by Hotsos Enterprises, Ltd.
rem 
rem Creates simple resource profile for any trace file.
rem You must pass the full path and trace file name.
rem Command line parameter:  <trace file name>
rem
rem This uses a the pearl script: prof.pl 
rem Active Pearl must be installed for this to work
rem

set termout on pause off autotrace off heading off feed off
accept htst_tracefile prompt 'Enter the trace file name: '

set term off verify off head off feed off

select '&_hst prof.pl &htst_tracefile' from dual

spool prof_exec.lst
/
spool off

@prof_exec.lst

@hrmtempfile prof_exec.lst

clear columns
undefine htst_tracefile

@henv
