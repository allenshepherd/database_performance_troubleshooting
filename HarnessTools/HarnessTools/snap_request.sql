drop procedure snap_request;
CREATE OR REPLACE  PROCEDURE SNAP_REQUEST (p_sc_id number,
        p_snap_id number , p_sid number, p_halt varchar2 default 'N', p_harness_nm varchar2 )
as
   v_rtn    number;
   v_stat_msg varchar2(200);
   v_timeout_pipe number := 2;  /* seconds */

   l_harness_nm   varchar2(30) := 'harness_pipe_'||p_harness_nm ;

begin

   dbms_pipe.pack_message (p_sc_id) ;
   dbms_pipe.pack_message (p_snap_id) ;
   dbms_pipe.pack_message (p_sid) ;
   dbms_pipe.pack_message (p_halt) ;

   v_rtn := dbms_pipe.send_message(l_harness_nm);

   v_rtn := dbms_pipe.receive_message(p_sid, v_timeout_pipe) ;
   if v_rtn = 0 then
      dbms_pipe.unpack_message (v_stat_msg) ;
      if v_stat_msg = 'SnapError' then
         dbms_output.put_line('Error during snapshot collection.  Check harness job.');
      else
         dbms_output.put_line('Snapshot ' || to_char(p_snap_id) || ' collection OK.');
      end if;
   else
      if v_rtn = 1 then
         v_stat_msg := 'Pipe name: ' || l_harness_nm || ' Error: Timeout (> 2 seconds) on pipe';
      elsif v_rtn = 2 then
         v_stat_msg := 'Pipe name: ' || l_harness_nm || ' Error: Record in pipe is too large for buffer';
      elsif v_rtn = 3 then
         v_stat_msg := 'Pipe name: ' || l_harness_nm || ' Error: An interrupt occurred';
      else
         v_stat_msg := 'Pipe name: ' || l_harness_nm || ' Error: ' || v_rtn ;
      end if;

      raise_application_error(-20001,v_stat_msg);
   end if;

exception
   when others then
        raise ;
end;
/
show errors
