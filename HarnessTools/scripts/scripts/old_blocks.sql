set timing on
set feedback on
PROMPT - The Below query will look across a particular time frame for sessions that were blocked by another session.
PROMPT -    NOTE - the key to this query is that that session need not still be connected to the database (hence - old blocks from old sessions) 
PROMPT -    Use a small time frame to hone in on a particular blocking period.
PROMPT ____________________________________________________________________________________________________________________________________________
select
'   * SID:SERIAL '||max_time_blocker.SESSION_ID ||':'||max_time_blocker.SESSION_SERIAL# ||' on inst #'||max_time_blocker.instance_number ||' running sql '||max_time_blocker.sql_id||
 ' using program '''||max_time_blocker.program||''' accessing '|| max_time_blocker.object_type||' "'|| max_time_blocker.owner||'.'|| max_time_blocker.object_name||
 '" was blocked for a duration of '||replace(max_time_blocker.sample_time-min_time_blocker.sample_time,'000000000 ','')|| ' by session '|| max_time_blocker.BLOCKING_SESSION ||':'||
 max_time_blocker.BLOCKING_SESSION_SERIAL# ||' on inst '|| max_time_blocker.instance_number ||' causing this wait event ->' ||max_time_blocker.event as "Blocked Session information" from 
(select max(sample_time) sample_time, SESSION_ID,SESSION_SERIAL#,BLOCKING_SESSION,WAIT_CLASS,instance_number,BLOCKING_SESSION_SERIAL#,obj.OWNER,obj.OBJECT_NAME,obj.OBJECT_TYPE,
     blocked.SEQ#,CURRENT_OBJ#,CURRENT_BLOCK#,blocked.program, blocked.sql_id, blocked.EVENT,blocked.wait_time,SQL_CHILD_NUMBER,SQL_OPCODE,SESSION_STATE
    from
         dba_hist_active_sess_history blocked
         inner join
         dba_objects obj
             on obj.OBJECT_ID = blocked.current_obj#
    where event is not null
         and blocked.sample_time between
             to_timestamp(trim('&&start_time'),'dd-mon-yyyy hh24:mi:ss') and
             to_timestamp(trim('&&end_time'),'dd-mon-yyyy hh24:mi:ss')
group by SESSION_ID,SESSION_SERIAL#,BLOCKING_SESSION_SERIAL#,BLOCKING_SESSION,WAIT_CLASS,instance_number,BLOCKING_SESSION_SERIAL#,obj.OWNER,obj.OBJECT_NAME,obj.OBJECT_TYPE,
     blocked.SEQ#,CURRENT_OBJ#,CURRENT_BLOCK#,blocked.program, blocked.sql_id, blocked.EVENT,blocked.wait_time,SQL_CHILD_NUMBER,SQL_OPCODE,SESSION_STATE
) max_time_blocker
 join  
 (select min(sample_time) sample_time, SESSION_ID,SESSION_SERIAL#,BLOCKING_SESSION,WAIT_CLASS,instance_number,BLOCKING_SESSION_SERIAL#,
     blocked.SEQ#,CURRENT_OBJ#,CURRENT_BLOCK#,blocked.program, blocked.sql_id, blocked.EVENT,blocked.wait_time,SQL_CHILD_NUMBER,SQL_OPCODE,SESSION_STATE
    from
         dba_hist_active_sess_history blocked
    where event is not null
          and blocked.sample_time between
             to_timestamp(trim('&&start_time'),'dd-mon-yyyy hh24:mi:ss') and
             to_timestamp(trim('&&end_time'),'dd-mon-yyyy hh24:mi:ss')
group by SESSION_ID,SESSION_SERIAL#,BLOCKING_SESSION_SERIAL#,BLOCKING_SESSION,WAIT_CLASS,instance_number,BLOCKING_SESSION_SERIAL#,
     blocked.SEQ#,CURRENT_OBJ#,CURRENT_BLOCK#,blocked.program, blocked.sql_id, blocked.EVENT,blocked.wait_time,SQL_CHILD_NUMBER,SQL_OPCODE,SESSION_STATE
) min_time_blocker on max_time_blocker.SESSION_ID=min_time_blocker.SESSION_ID and max_time_blocker.SESSION_SERIAL#=min_time_blocker.SESSION_SERIAL# and min_time_blocker.seq#=max_time_blocker.seq#
where max_time_blocker.sample_time> min_time_blocker.sample_time
/ 

