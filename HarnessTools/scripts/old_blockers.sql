select
	 -- Time
	 blocker.sample_time||' :-> Session '||blocker.session_id|| ' from program '''||replace(blocker.program,'.target.com','')||''' running sql_id '||blocker.sql_id||' blocked session ' || blocked.session_id||
	  ' from program '''||blocked.program||''' using server '||replace(blocked.machine,'.target.com','') ||' running sql_id '|| blocked.sql_id ||' for '||
	  round(blocked.TIME_WAITED/1000/60,1)||' minutes' as the_blocker1
--	 blocker.session_serial#   as blocker_serial#,
--	 blocker.user_id	   as blocker_username,
--	 blocker.machine	   as blocker_machine,
--	 blocker.program	   as blocker_program,
--	 blocker.sql_id 	   as blocker_sql_id,
--	 blocker.sql_child_number  as blocker_sql_child_number,
--	 ' -> ' 		   as is_blocking,
--	 blocked.session_id	   as blocked_sid,
--	 blocked.session_serial#   as blocked_serial#,
--	 blocked.user_id	    as blocked_username,
--	 blocked.machine	   as blocked_machine,
--	 blocked.program	   as blocked_program,
--	 blocked.blocking_session  as blocked_blocking_session,
--	 blocked.sql_id 	   as blocked_sql_id,
--	 blocked.TIME_WAITED/1000  as blocked_time
--	 blocked.sql_child_number  as blocked_sql_child_number,
--	 sys_obj.name		   as blocked_table_name,
--	 dbms_rowid.rowid_create(
--	     rowid_type    => 1,
--	     object_number => blocked.current_obj#,
--	     relative_fno  => blocked.current_file#,
--	     block_number  => blocked.current_block#,
--	     row_number    => blocked.current_row#
--	 )			   as blocked_rowid,
--	 blocker_sql.sql_text	   as blocker_sql_text,
--	 blocked_sql.sql_text	   as blocked_sql_text
from
	 dba_hist_active_sess_history blocker
	 inner join
	 dba_hist_active_sess_history blocked
	     on blocker.session_id = blocked.blocking_session
	 inner join
	 sys.obj$ sys_obj
	     on sys_obj.obj# = blocked.current_obj#
	 left outer join
	 v$sql blocked_sql
	     on blocked_sql.sql_id = blocked.sql_id
	     and blocked_sql.child_number = blocked.sql_child_number
	 left outer join
	 v$sql blocker_sql
	     on blocker_sql.sql_id = blocker.sql_id
	     and blocker_sql.child_number = blocker.sql_child_number
where
	 blocked.time_waited>100000
	 and blocker.program not like '%LMON%'
	 and blocker.sample_time between
	     to_timestamp(trim('&&start_time'),'dd-mon-yyyy hh24:mi:ss') and
 	     to_timestamp(trim('&&end_time'),'dd-mon-yyyy hh24:mi:ss')
order by
	 blocker.sample_time
/
