set define off
DECLARE
  v1_sql_text varchar2(4000);
  --procedure parse_tester(v_sql_text varchar2 , v_depth number default 0, object_name varchar2 ) is
    procedure parse_tester(user_name varchar2, object_name varchar2, object_path varchar2,event_name  varchar2, last_start_time varchar2, query_name varchar2, datasource varchar2, DB_USER varchar2, v_sql_text varchar2, executions number, v_depth number default 0) is
    var_command varchar2(4000);
    var_columns varchar2(4000);
    var_tables  varchar2(4000);
    var_filters varchar2(4000);
    var_temp_placeholder varchar2(4000);
    sql_text varchar2(4000):= v_sql_text;
    v_i number;
    v_j number;
    v_k number;
	length_from_i_to_j number :=0;
    v_occurence number :=1;
    begin

      if instr(sql_text,' IN (',1)>0 then
	      v_occurence:=0;
	      v_i:=greatest( instr(sql_text,')',instr(sql_text,' IN (',1) ) ,length(sql_text));
	      v_k:=instr(substr(sql_text,1,v_i)  ,'(',-1);
	      while v_i > 0 loop
	          sql_text := substr(sql_text,1,v_k-1) || '{ FILLER_IN_CONDITION }' || substr(sql_text,v_i+1,length(sql_text)-v_i);
	        v_i:=instr(sql_text,')',instr(sql_text,' IN (',1) );
	        v_k:=instr(substr(sql_text,1,v_i)  ,'(',-1);
	        v_occurence:=v_occurence+1;
	        exit when v_occurence =6;
	      end loop;
	      --dbms_output.put_line(sql_text);
	  end if;
	  while instr(SQL_TEXT,'"',1,1)>0 loop
	    v_i:=instr(SQL_TEXT,'"',1,1);
	    v_k:=instr(SQL_TEXT,'"',1,2);
	    SQL_TEXT:=substr(SQL_TEXT,1,v_i-1)||replace(substr(SQL_TEXT,v_i+1,v_k-v_i-1),' ','_')||substr(SQL_TEXT,v_k+1, length(SQL_TEXT));
	  end loop;
	  --dbms_output.put_line(sql_text);

      sql_text:=REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(sql_text, 'RIGHT JOIN', 'JCOND'),'RIGHT OUTER JOIN', 'JCOND'), 'LEFT JOIN', 'JCOND'), 'LEFT OUTER JOIN', 'JCOND'), 'FULL OUTER JOIN', 'JCOND'), 'INNER JOIN', 'JCOND');
      sql_text:=REPLACE(REPLACE( sql_text, CHR(10) ), CHR(13) ,' ');
      sql_text:=REPLACE(REPLACE(replace(sql_text,'	',' '),',',' , '), '  ', ' ');
      

      v_i:=instr(sql_text,')',1);
      v_k:=instr(substr(sql_text,1,v_i)  ,'(',-1);
      while v_i > 0 loop
        if instr(substr(sql_text,v_k, v_i-v_k),'SELECT ') >0 then
          --dbms_output.put_line(substr(sql_text, v_k+1,v_i-v_k-1));
          --parse_tester(substr(sql_text, v_k+1,v_i-v_k-1),v_depth+1, object_name);
          parse_tester(user_name, object_name,object_path, event_name, last_start_time,query_name, datasource, DB_USER, substr(sql_text, v_k+1,v_i-v_k-1), executions, v_depth+1);
          sql_text := substr(sql_text,1,v_k-1) || '{#QB_SEL$_' ||v_depth||'_'||v_occurence||'#}' || substr(sql_text,v_i+1,length(sql_text)-v_i);
          v_occurence:=v_occurence+1;
        else
          --dbms_output.put_line(sql_text);
          sql_text := substr(sql_text,1,v_k-1) || '{FILLER_FUNCTION}' || substr(sql_text,v_i+1,length(sql_text)-v_i);
          --dbms_output.put_line(sql_text);
        end if;
        v_i:=instr(sql_text,')',1);
        v_k:=instr(substr(sql_text,1,v_i)  ,'(',-1);
      end loop;
      --dbms_output.put_line(sql_text);



	  select substr(sql_text, 1, instr(sql_text,' ')) command_type into var_command from dual;
	  select substr(sql_text, instr(sql_text,' ')+1 , instr(sql_text,' FROM ', -1,1)-instr(sql_text,' ')-1) INTO var_columns from dual;
	  if instr(sql_text,' WHERE ', 1,1)>0 then
  	    select substr(sql_text, instr(sql_text,' FROM ' , 1,1)+6 , instr(sql_text,' WHERE ', 1,1) - instr(sql_text,' FROM ', 1,1)-6 ) INTO var_temp_placeholder from dual;
	    select substr(sql_text, instr(sql_text,' WHERE ', 1,1)+7)  INTO var_filters from dual;
	  else -- ... check for group by, having, order by, union, union all, intersect, minus, and finally with.....
	    v_i:=greatest(least(instr(sql_text,' JCOND ', 1,1),instr(sql_text,' WHERE ', 1,1),instr(sql_text,' GROUP BY ', 1,1), instr(sql_text,' ORDER BY ', 1,1)),length(sql_text));
  	    select substr(sql_text, instr(sql_text,' FROM ' , 1,1)+6 , v_i - instr(sql_text,' FROM ', 1,1)-6 ) INTO var_temp_placeholder from dual;
  	    --select substr(sql_text, instr(sql_text,' WHERE ', 1,1)+7)  INTO var_filters from dual;
	  end if;
	  --dbms_output.put_line('THIS IS MY LIST OF TABLES ---------------------->'||var_temp_placeholder);
	  if instr(var_temp_placeholder,'JCOND ',1,1) =0 then
        var_tables:=trim(var_temp_placeholder);
	  else
	    var_tables:=substr(var_temp_placeholder,1, instr(var_temp_placeholder,'JCOND ',1,1)-1);
	  end if;
	  --dbms_output.put_line('this is placeholder ---->'|| var_temp_placeholder);
      --dbms_output.put_line('this is tables      ---->'|| var_tables);
          
	  v_i:=instr(var_temp_placeholder,' ON ',1);
      v_k:=instr(substr(var_temp_placeholder,1,v_i)  ,'JCOND ',-1);
      while v_i > 0 loop
        var_tables:=var_tables|| ', '|| substr(var_temp_placeholder,v_k+6,v_i-v_k-6);
        var_temp_placeholder:=substr(var_temp_placeholder,v_i+4,length(var_temp_placeholder));
        --dbms_output.put_line('this is placeholder ---->'|| var_temp_placeholder);
        --dbms_output.put_line('this is tables      ---->'|| var_tables);
        v_i:=instr(var_temp_placeholder,' ON ',1);
        v_k:=instr(substr(var_temp_placeholder,1,v_i)  ,'JCOND ',-1);
        v_occurence:=v_occurence+1;
        exit when v_occurence >19;
      end loop;
      
 --     if instr(var_tables,',',1)=0 then
        if instr(var_tables,' ',2,1)=0 then 
          dbms_output.put_line('insert into test_table (table_name) values ('''||var_tables ||''');');
        else
          var_temp_placeholder:=var_tables;
          v_i:=instr(var_temp_placeholder,',',1);
          while v_i>0 loop
            dbms_output.put_line('insert into test_table (table_name) values ('''||substr(var_temp_placeholder,1,instr(var_temp_placeholder,' ',1,1)-1) ||''');');
            var_temp_placeholder:=substr(var_temp_placeholder,v_i+2, length(var_temp_placeholder)-v_i);
            v_i:=instr(var_temp_placeholder,',',1);
          end loop;
          if instr(var_temp_placeholder,' ',1,1)=0 then 
            dbms_output.put_line('insert into test_table (table_name) values ('''||var_temp_placeholder ||'''); 		--'||object_name);
          else
            if instr(var_temp_placeholder,'"',1,1)=0 then
			dbms_output.put_line('insert into test_table (table_name) values ('''||substr(var_temp_placeholder,1,instr(var_temp_placeholder,' ',1,1)-1) ||''');');
			else
			 while instr(var_temp_placeholder,'"',1,1)>0 loop
			   v_i:=instr(var_temp_placeholder,'"',1,1);
			   v_k:=instr(var_temp_placeholder,'"',1,2);
			   var_temp_placeholder:=substr(var_temp_placeholder,1,v_i-1)||replace(substr(var_temp_placeholder,v_i+1,v_k-v_i-1),' ','_')||substr(var_temp_placeholder,v_k+1, length(var_temp_placeholder));
			 end loop;
			 dbms_output.put_line('insert into test_table (table_name) values ('''||substr(var_temp_placeholder,1,instr(var_temp_placeholder,' ',1,1)-1) ||''');');
			end if;
          end if;

        end if;
    
      --dbms_output.put_line('=========================================================');
       --dbms_output.put_line('This is depth   info - ' || v_depth);
        --dbms_output.put_line('This is command info - ' || var_command);
        --dbms_output.put_line('This is column info  - ' || var_columns);
      --dbms_output.put_line('This is table info   - ' || var_tables);
      --dbms_output.put_line('This is filter info  - ' || var_filters);     
      
	end;
BEGIN
  
  for row in (
				select  *
				from
				(select a.user_name, 
					    c.object_name, 
					    c.object_path, 
					    b.event_name, 
					    min(b.start_time) as last_start_time, 
					    d.query_name, 
					    trim(d.datasource) datasource, 
					    D.DB_USER, 
					    substr(d.query_string,1,4000) query_string, 
					    count(1) executions
				from EPMRAF.V8_USER_VW a
				,epmraf.V8_EVENT_VW b
				,epmraf.V8_OBJECT_VW c
				,epmraf.V8_QUERY_VW d
				where a.user_id = b.user_id
				and b.event_id = c.event_id
				and d.event_id = b.event_id
				and c.object_name  not in ('Authorized_Rep')
				--and upper(query_string) not like '%PREMIER.%' and upper(query_string) not like '%DBO.%' and upper(query_string) not like'%"PREMIER".%' and upper(query_string) not like '%"DBO".%' 
				and c.object_name not in ('CVV Tours','Agent Tour Grid','StatusReporting_TermModification','Confirmations','DTA','Hourly Stats','I3 Agent List','QA TM Audit','I3 Call Data','TPS V3 Main CAL','VUDOO Current',
					'OTA Availability','CLUB Discount_Brad2-copy')
				group by a.user_name, c.object_name, c.object_path, b.event_name, d.query_name, d.datasource, d.query_string, D.DB_USER
				order by c.object_path, c.object_name 
				) --where rownum<1000
  			)
  loop
    --dbms_output.put_line(row.object_name);
    --dbms_output.put_line(row.query_string);
    if /*upper(row.query_string) not like '%WITH % AS%' and*/ length(row.query_string)<3900 then
      dbms_output.put_line('___________________________________________________________________________________');
      --dbms_output.put_line(row.query_string);
      --dbms_output.put_line(row.object_name);
      --parse_tester(upper(replace(trim(row.query_string),'"','"')),0, row.object_name);
      parse_tester(row.user_name, row.object_name, row.object_path,row.event_name, row.last_start_time,row.query_name, row.datasource,row.DB_USER,upper(trim(row.query_string)), row.executions, 0);
      --dbms_output.put_line('commit;');
    end if;
  end loop;
END;
/

