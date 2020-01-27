rem Turn on tracing
alter session set tracefile_identifier = 'harness' ;
alter session set events '10046 trace name context forever, level 12';

rem Execute your query
@<your sql file>

rem Turn off tracing
alter session set events '10046 trace name context off';

rem Determine your session information
rem The first entry on the 2nd line shows you your SPID
@hmsess

rem Go look in USER_DUMP_DEST and find a trace file named to make sure
rem it is there:
-- <your_instance_name>_ora_<your_spid>_harness.trc

rem Create a scenario
delete from hscenario where id = 1 ;
delete from hscenario_10046_line where hscenario_id = 1 ;
insert into hscenario values (1,'DEBUG','DEBUG','S') ;
commit ;

rem Get the trace file name
set serveroutput on feed on
exec hotsos_pkg.capture_trace_files(1, 10046)

rem Verify the trace file name was found and captured
select dt, filename from user_avail_trace_files
where hscenario_id = 1 and trc_type = 10046 ;

rem Load the trace file into the hscenario_10046_line table
exec hotsos_pkg.trace_file_upload ('<enter the filename from the previous query>',1, 10046)
exec load_trace(1, 10046)

rem Verify the trace file was loaded
select text from hscenario_10046_line where hscenario_id = 1 order by line#;

@hsctrace
--Enter the workspace name: DEBUG
--Enter the scenario name : DEBUG

--Which lines from the trace file for this scenario do you wish to view?
--A - All lines in trace file for your SQL statement's cursor
--Q - The SQL statement itself
--P - The PARSE line
--B - The BINDS line(s)
--E - The EXEC line
--F - The FETCH line(s)
--W - The WAIT line(s)
--S - The STAT line(s)

--Selection? : A
