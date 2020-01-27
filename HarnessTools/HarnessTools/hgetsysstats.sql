set echo off
set verify off

rem $Header$
rem $Name$

rem Copyright (c); 2005-2011 by Hotsos Enterprises, Ltd.
rem 

set serveroutput on termout on

declare

	v_stattab	varchar2(30) := null ;
	v_status	varchar2(30) ;
	v_dstart	date;
	v_dstop		date;
	v_pvalue	number;
	
begin

	dbms_output.put_line ('----------------------------------------------------------------------');
	dbms_stats.get_system_stats (stattab => v_stattab, status => v_status, dstart => v_dstart,
			dstop => v_dstop, pvalue => v_pvalue, pname => 'CPUSPEEDNW') ;
	dbms_output.put_line ('cpuspeednw - average number of CPU cycles for each second in millions');
	dbms_output.put_line ('This is a NOWORKLOAD statistic');
	dbms_output.put_line ('Default is a gathered value, varies based on system');
	dbms_output.put_line ('-------------');
	dbms_output.put_line ('Value       : '||NVL(TO_CHAR(v_pvalue),'NULL')) ;
	dbms_output.put_line ('Start Time  : '||TO_CHAR(v_dstart,'dd-MON-yyyy hh24:mi:ss')) ;
	dbms_output.put_line ('Stop Time   : '||TO_CHAR(v_dstop,'dd-MON-yyyy hh24:mi:ss')) ;
	dbms_output.put_line ('----------------------------------------------------------------------');

	dbms_stats.get_system_stats (stattab => v_stattab, status => v_status, dstart => v_dstart,
			dstop => v_dstop, pvalue => v_pvalue, pname => 'IOTFRSPEED') ;
	dbms_output.put_line ('iotfrspeed - average I/O transfer speed in bytes/millisecond  ');
	dbms_output.put_line ('This is a NOWORKLOAD statistic');
	dbms_output.put_line ('Default is 4096 bytes/ms ');
	dbms_output.put_line ('-------------');
	dbms_output.put_line ('Value       : '||NVL(TO_CHAR(v_pvalue),'NULL')) ;
	dbms_output.put_line ('Start Time  : '||TO_CHAR(v_dstart,'dd-MON-yyyy hh24:mi:ss')) ;
	dbms_output.put_line ('Stop Time   : '||TO_CHAR(v_dstop,'dd-MON-yyyy hh24:mi:ss')) ;
	dbms_output.put_line ('----------------------------------------------------------------------');
		
	dbms_stats.get_system_stats (stattab => v_stattab, status => v_status, dstart => v_dstart,
			dstop => v_dstop, pvalue => v_pvalue, pname => 'IOSEEKTIM') ;
	dbms_output.put_line ('ioseektim - seek + latency + operating system overhead in milliseconds');
	dbms_output.put_line ('This is a NOWORKLOAD statistic');
	dbms_output.put_line ('Default is 10ms ');
	dbms_output.put_line ('-------------');
	dbms_output.put_line ('Value       : '||NVL(TO_CHAR(v_pvalue),'NULL')) ;
	dbms_output.put_line ('Start Time  : '||TO_CHAR(v_dstart,'dd-MON-yyyy hh24:mi:ss')) ;
	dbms_output.put_line ('Stop Time   : '||TO_CHAR(v_dstop,'dd-MON-yyyy hh24:mi:ss')) ;
	dbms_output.put_line ('----------------------------------------------------------------------');
	
	dbms_stats.get_system_stats (stattab => v_stattab, status => v_status, dstart => v_dstart,
			dstop => v_dstop, pvalue => v_pvalue, pname => 'SREADTIM') ;
	dbms_output.put_line ('sreadtim - average time to read single block read (sequential) in milliseconds');
	dbms_output.put_line ('This is a WORKLOAD statistic');
	dbms_output.put_line ('-------------');
	dbms_output.put_line ('Value       : '||NVL(TO_CHAR(v_pvalue),'NULL')) ;
	dbms_output.put_line ('Start Time  : '||TO_CHAR(v_dstart,'dd-MON-yyyy hh24:mi:ss')) ;
	dbms_output.put_line ('Stop Time   : '||TO_CHAR(v_dstop,'dd-MON-yyyy hh24:mi:ss')) ;
	dbms_output.put_line ('----------------------------------------------------------------------');
	
	dbms_stats.get_system_stats (stattab => v_stattab, status => v_status, dstart => v_dstart,
			dstop => v_dstop, pvalue => v_pvalue, pname => 'MREADTIM') ;
	dbms_output.put_line ('mreadtim - average time to read a multi block read (scattered) in milliseconds');
	dbms_output.put_line ('This is a WORKLOAD statistic');
	dbms_output.put_line ('-------------');
	dbms_output.put_line ('Value       : '||NVL(TO_CHAR(v_pvalue),'NULL')) ;
	dbms_output.put_line ('Start Time  : '||TO_CHAR(v_dstart,'dd-MON-yyyy hh24:mi:ss')) ;
	dbms_output.put_line ('Stop Time   : '||TO_CHAR(v_dstop,'dd-MON-yyyy hh24:mi:ss')) ;
	dbms_output.put_line ('----------------------------------------------------------------------');
	
	dbms_stats.get_system_stats (stattab => v_stattab, status => v_status, dstart => v_dstart,
			dstop => v_dstop, pvalue => v_pvalue, pname => 'CPUSPEED') ;
	dbms_output.put_line ('cpuspeed - average number of CPU cycles for each second, in millions');
	dbms_output.put_line ('This is a WORKLOAD statistic');
	dbms_output.put_line ('-------------');
	dbms_output.put_line ('Value       : '||NVL(TO_CHAR(v_pvalue),'NULL')) ;
	dbms_output.put_line ('Start Time  : '||TO_CHAR(v_dstart,'dd-MON-yyyy hh24:mi:ss')) ;
	dbms_output.put_line ('Stop Time   : '||TO_CHAR(v_dstop,'dd-MON-yyyy hh24:mi:ss')) ;
	dbms_output.put_line ('----------------------------------------------------------------------');
	
	
	dbms_stats.get_system_stats (stattab => v_stattab, status => v_status, dstart => v_dstart,
			dstop => v_dstop, pvalue => v_pvalue, pname => 'MBRC') ;
	dbms_output.put_line ('mbrc - average multiblock read count for scattered read in blocks  ');
	dbms_output.put_line ('This is a WORKLOAD statistic');
	dbms_output.put_line ('-------------');
	dbms_output.put_line ('Value       : '||NVL(TO_CHAR(v_pvalue),'NULL')) ;
	dbms_output.put_line ('Start Time  : '||TO_CHAR(v_dstart,'dd-MON-yyyy hh24:mi:ss')) ;
	dbms_output.put_line ('Stop Time   : '||TO_CHAR(v_dstop,'dd-MON-yyyy hh24:mi:ss')) ;
	dbms_output.put_line ('----------------------------------------------------------------------');
	
	dbms_stats.get_system_stats (stattab => v_stattab, status => v_status, dstart => v_dstart,
			dstop => v_dstop, pvalue => v_pvalue, pname => 'MAXTHR') ;
	dbms_output.put_line ('maxthr - maximum I/O system throughput, in bytes/second  ');
	dbms_output.put_line ('This is a WORKLOAD statistic');
	dbms_output.put_line ('-------------');
	dbms_output.put_line ('Value       : '||NVL(TO_CHAR(v_pvalue),'NULL'));
	dbms_output.put_line ('Start Time  : '||TO_CHAR(v_dstart,'dd-MON-yyyy hh24:mi:ss')) ;
	dbms_output.put_line ('Stop Time   : '||TO_CHAR(v_dstop,'dd-MON-yyyy hh24:mi:ss')) ;
	dbms_output.put_line ('----------------------------------------------------------------------');
	
	dbms_stats.get_system_stats (stattab => v_stattab, status => v_status, dstart => v_dstart,
			dstop => v_dstop, pvalue => v_pvalue, pname => 'SLAVETHR') ;
	dbms_output.put_line ('slavethr - average slave I/O throughput in bytes/second  ');
	dbms_output.put_line ('This is a WORKLOAD statistic');
	dbms_output.put_line ('-------------');
	dbms_output.put_line ('Value       : '||NVL(TO_CHAR(v_pvalue),'NULL')) ;
	dbms_output.put_line ('Start Time  : '||TO_CHAR(v_dstart,'dd-MON-yyyy hh24:mi:ss')) ;
	dbms_output.put_line ('Stop Time   : '||TO_CHAR(v_dstop,'dd-MON-yyyy hh24:mi:ss')) ;
	dbms_output.put_line ('----------------------------------------------------------------------');
	
exception
   when others then
   	dbms_output.put_line (sqlerrm) ;
	dbms_output.put_line ('*** Statistics error ***') ;
   
end ;
/

clear columns
@henv
