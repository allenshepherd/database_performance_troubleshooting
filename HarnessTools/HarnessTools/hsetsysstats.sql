set echo off

rem $Header$
rem $Name$			hsetsysstats.sql

rem Copyright (c); 2005-2011 by Hotsos Enterprises, Ltd.
rem 
rem Must have DBA privilege to execute this script
rem

set termout on verify off serveroutput on

prompt
prompt Statistic names: 
prompt  iotfrspeed
prompt  ioseektim
prompt  sreadtim
prompt  mreadtim
prompt  cpuspeed
prompt  cpuspeednw
prompt  mbrc
prompt  maxthr
prompt  slavethr
prompt

accept htst_sysparm           prompt 'Enter the system statistic to change: '
accept htst_sysparmval number prompt 'Enter the system statistic value    : '

declare

	v_stattab	varchar2(30) := null ;
	v_parm		varchar2(30) := UPPER('&htst_sysparm') ;
	v_pvalue	number := &htst_sysparmval ;

	v_status	varchar2(30) ;
	v_dstart	date;
	v_dstop		date;
	v_pvaluex	number;
	
begin
	
	if v_parm is null or v_parm = '' then
		dbms_output.put_line ('---------------------------------' );
		dbms_output.put_line ('  NO PARAMETER CHOSEN TO CHANGE! ' );
		dbms_output.put_line ('  ENTER PARAMETER AND TRY AGAIN. ' );
	else
	
		dbms_output.put_line ('--- Original Settings ---');
	
		dbms_stats.get_system_stats (stattab => v_stattab, status => v_status, dstart => v_dstart,
				dstop => v_dstop, pvalue => v_pvaluex, pname => v_parm) ;
	
		dbms_output.put_line ('Parameter : '||v_parm) ;
		dbms_output.put_line ('Status    : '||v_dstop) ;
		dbms_output.put_line ('Start Date: '||to_char(v_dstart,'mm/dd/yyyy')) ;
		dbms_output.put_line ('Stop Date : '||to_char(v_dstop,'mm/dd/yyyy')) ;
		dbms_output.put_line ('Value     : '||v_pvaluex) ;
		dbms_output.put_line ('-------------------------');	
	
		dbms_stats.set_system_stats (stattab => v_stattab, pname => v_parm, pvalue => v_pvalue) ;
		
		dbms_output.put_line ('--- Updated Settings ---');	
	
		dbms_stats.get_system_stats (stattab => v_stattab, status => v_status, dstart => v_dstart,
				dstop => v_dstop, pvalue => v_pvaluex, pname => v_parm) ;
	
		dbms_output.put_line ('Parameter : '||v_parm) ;
		dbms_output.put_line ('Status    : '||v_dstop) ;
		dbms_output.put_line ('Start Date: '||to_char(v_dstart,'mm/dd/yyyy')) ;
		dbms_output.put_line ('Stop Date : '||to_char(v_dstop,'mm/dd/yyyy')) ;
		dbms_output.put_line ('Value     : '||v_pvaluex) ;
		dbms_output.put_line ('-------------------------');	
	end if ;
		
exception
   when others then
   	dbms_output.put_line (sqlerrm) ;
	dbms_output.put_line ('*** Statistics error ***') ;
   
end ;
/

clear columns
undefine htst_sysparm
undefine htst_sysparmval

@henv
