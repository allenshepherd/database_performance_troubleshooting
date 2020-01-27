drop procedure get_snap_remote;
create or replace procedure get_snap_remote
 (p_sc_id number, p_snap_id number , p_sid number, p_harness_nm varchar2 )
as
   pragma autonomous_transaction ;
   
   l_harness_nm   varchar2(30) := 'harness_pipe_'||p_harness_nm ;
begin
    /* Take snapshot */
	begin
	    insert into hscenario_snap_stat (hscenario_id, snap_id, hstat_id, value)
		select p_sc_id, p_snap_id, statistic# hstat_id, value
		from  v$sesstat 
		where sid = p_sid 
		union all
		select p_sc_id, p_snap_id, latch#+10000 hstat_id, gets+immediate_gets value
		from v$latch
		union all
		select p_sc_id, p_snap_id, -1 hstat_id, hsecs value
		from v$timer;
		commit ;
		
	exception
	    when others then 
	    /* For any error, purge the pipe and retry the INSERT once */
	        
	        dbms_pipe.purge(l_harness_nm);
			begin
			    insert into hscenario_snap_stat (hscenario_id, snap_id, hstat_id, value)
				select p_sc_id, p_snap_id, statistic# hstat_id, value
				from  v$sesstat 
				where sid = p_sid 
				union all
				select p_sc_id, p_snap_id, latch#+10000 hstat_id, gets+immediate_gets value
				from v$latch
				union all
				select p_sc_id, p_snap_id, -1 hstat_id, hsecs value
				from v$timer;
				commit ;
			exception
				when others then raise ;
			end ;		         
	end ;

	
end;	
/
show errors
