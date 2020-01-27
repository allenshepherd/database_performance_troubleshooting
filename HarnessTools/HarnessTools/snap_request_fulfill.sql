
drop procedure snap_request_fulfill;
CREATE OR REPLACE PROCEDURE SNAP_REQUEST_FULFILL (p_harness_nm varchar2)
as
   v_rtn        number;
   v_halt       varchar2(1);
   v_sc_id      number;
   v_snap_id    number;
   v_sid        number;

   l_harness_nm   varchar2(30) := 'harness_pipe_'||p_harness_nm ;

begin

   dbms_application_info.set_module('Hotsos Test Harness', l_harness_nm||' (capture)');

   LOOP
      v_rtn := dbms_pipe.receive_message(l_harness_nm) ;
      dbms_pipe.unpack_message (v_sc_id) ;
      dbms_pipe.unpack_message (v_snap_id) ;
      dbms_pipe.unpack_message (v_sid) ;
      dbms_pipe.unpack_message (v_halt) ;

      IF v_halt = 'Y' THEN
         v_rtn := dbms_pipe.remove_pipe(l_harness_nm) ;
         dbms_application_info.set_module('Hotsos Test Harness', l_harness_nm||' (Pipe released)');
         EXIT;
      END IF ;

      begin
         get_snap_remote(v_sc_id, v_snap_id, v_sid, p_harness_nm);
         dbms_pipe.pack_message('done');
      exception
         when others then
              dbms_pipe.pack_message('SnapError');
      end;

      v_rtn := dbms_pipe.send_message(v_sid);

   END LOOP;

end;
/
show errors
