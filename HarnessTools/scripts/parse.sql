col COMMAND_TYPE for a13 wrap
col FILTER_INFO for a50 wrap
col COLUMN_INFO for a80 wrap
col TABLE_INFO for a30 wrap
col FILTER_INFO for a50 wrap

with sql_info as ( select UPPER(translate(substr(sql_text,1,4000), chr(10)||chr(11)||chr(13), ' ')) sql_text from DBA_HIST_SQLTEXT where sql_id = '&sql_id' )
select 
  substr(sql_text, 1, instr(sql_text,' '))||case when instr(sql_text,'FOR UPDATE', -1,1)>0 then chr(10)||'FOR UPDATE' END  command_type,
  substr(sql_text, instr(sql_text,' ')+1 , instr(sql_text,'FROM', -1,1)-instr(sql_text,' ')-1) column_info,
  substr(sql_text, instr(sql_text,'FROM', -1,1)+5 , instr(sql_text,' WHERE ', -1,1) - instr(sql_text,'FROM', -1,1)-5 ) table_info,
  substr(sql_text, instr(sql_text,'WHERE', -1,1)+6 , 
	  	least ( 
			  		 case when instr(sql_text,'FOR UPDATE', -1,1)=0 then 100000 else  (instr(sql_text,'FOR UPDATE', -1,1)-instr(sql_text,'WHERE', -1,1)-6) END
						  		 , (instr(sql_text,substr(sql_text,-1), -1)-instr(sql_text,'WHERE', -1,1)-5) )  
							   ) filter_info
							from sql_info;

							select UPPER(translate(substr(sql_text,1,4000), chr(10)||chr(11)||chr(13), ' ')) sql_text from DBA_HIST_SQLTEXT where sql_id = '&sql_id';

