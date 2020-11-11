declare
 v_command_type VARCHAR2(4000);
 v_column_info  VARCHAR2(4000);
 v_table_info   VARCHAR2(4000);
 v_filter_info  VARCHAR2(4000);
 v_sql_text     VARCHAR2(4000);
 tmp            VARCHAR2(4000);
 v_count        NUMBER :=1;
--type test2 is record(col_name2 varchar2(30),col_name4 varchar2(30));
type column_record is record(col_name varchar2(4000),table_name varchar2(256),table_owner varchar2(64));
type columntype is table of column_record index by pls_integer;
v_columns columntype;
begin
	select UPPER(translate(sql_text, chr(10)||chr(11)||chr(13), ' ')) into v_sql_text from DBA_HIST_SQLTEXT where sql_id = '&&sql_id';
		select substr(v_sql_text, 1, instr(v_sql_text,' ')) into v_command_type from dual;
		select substr(v_sql_text, instr(v_sql_text,' ')+1 , instr(v_sql_text,'FROM', -1,1)-instr(v_sql_text,' ')-1) into v_column_info from dual;
		select substr(v_sql_text, instr(v_sql_text,'FROM', -1,1)+5 , instr(v_sql_text,' WHERE ', -1,1) - instr(v_sql_text,'FROM', -1,1)-5 ) into v_table_info from dual;
		select substr(v_sql_text, instr(v_sql_text,'WHERE', -1,1)+6 ,
		  	least ( 
		  		 case when instr(v_sql_text,'FOR UPDATE', -1,1)=0 then 100000 else  (instr(v_sql_text,'FOR UPDATE', -1,1)-instr(v_sql_text,'WHERE', -1,1)-6) END
		  		 , (instr(v_sql_text,substr(v_sql_text,-1), -1)-instr(v_sql_text,'WHERE', -1,1)-5))
		   ) into v_filter_info from dual;

	for col in ( select trim(regexp_substr(v_column_info,'[^,]+', 1, level)) col1 from dual connect by regexp_substr(v_column_info, '[^,]+', 1, level) is not null) LOOP
		v_columns(v_count).col_name:=col.col1;
		v_columns(v_count).table_name:=v_table_info;
		select max(t1.parsing_schema_name) into v_columns(v_count).table_owner from  dba_hist_sqlstat t1 where sql_id = '&&sql_id' and parsing_schema_name<>'SYS';
		--select * from all_tab_columns where owner=v_columns(v_count).table_owner and table_name=v_columns(v_count).table_name;		
		dbms_output.put_line( 'Column name -> '|| v_columns(v_count).table_owner||'._.'||col.col1);
	end loop;
	--select translate(v_column_info,chr(32), '_') into tmp from dual;
	dbms_output.put_line('COMMAND TYPE   : '||v_command_type);
        dbms_output.put_line('COLUMN  INFO   : '||v_column_info);
        dbms_output.put_line('TABLE   INFO   : '||v_table_info);
        dbms_output.put_line('FILTER  INFO   : '||v_filter_info);
--   FOR rec IN (  SELECT * FROM TABLE (l_array) ORDER BY nm)
--   LOOP
--      DBMS_OUTPUT.put_line (rec.nm);
--   END LOOP;
end;
/

