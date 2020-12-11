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
      --break down inline clauses
      v_i:=instr(sql_text,')',1);
      v_k:=instr(substr(sql_text,1,v_i)  ,'(',-1);
      while v_i > 0 loop
        if instr(substr(sql_text,v_k, v_i-v_k),'SELECT ') >0 then
          parse_tester(user_name, object_name,object_path, event_name, last_start_time,query_name, datasource, DB_USER, substr(sql_text, v_k+1,v_i-v_k-1), executions, v_depth+1);
          sql_text := substr(sql_text,1,v_k-1) || ' {#QB_SEL$_' ||v_depth||'_'||v_occurence||'#} ' || substr(sql_text,v_i+1,length(sql_text)-v_i);
          v_occurence:=v_occurence+1;
        else
          --dbms_output.put_line(sql_text);
          sql_text := substr(sql_text,1,v_k-1) || '{FILLER_FUNCTION}' || substr(sql_text,v_i+1,length(sql_text)-v_i);
          --dbms_output.put_line(sql_text);
        end if;
        v_i:=instr(sql_text,')',1);
        v_k:=instr(substr(sql_text,1,v_i)  ,'(',-1);
      end loop;


      sql_text:=REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(sql_text, 'RIGHT JOIN', 'JCOND'),'RIGHT OUTER JOIN', 'JCOND'), 'LEFT JOIN', 'JCOND'), 'LEFT OUTER JOIN', 'JCOND'), 'FULL OUTER JOIN', 'JCOND'), 'INNER JOIN', 'JCOND'),'JOIN','JCOND');
      sql_text:=REPLACE(REPLACE(REPLACE( sql_text, CHR(10) ), CHR(13) ,' '),CHR(9),' ');
      sql_text:=REPLACE(REPLACE(replace(sql_text,'	',' '),',',','), '  ', ' ');
      sql_text:=replace(replace(sql_text,')',' ) '),'(',' ( ');
      sql_text:=REPLACE(REPLACE(replace(sql_text,'	',' '),',',','), '  ', ' '); --ran twice to ensure braces have spaces and being sensitive to 4k limit
      sql_text:=replace(sql_text,'''''','**');
      
      
      --This is mainly for SFS report --> Static Pool Defaults ACCT v2BC
      --remove space between double quotes
	  while instr(SQL_TEXT,'"',1,1)>0 loop
	    v_i:=instr(SQL_TEXT,'"',1,1);
	    v_k:=instr(SQL_TEXT,'"',1,2);
	    SQL_TEXT:=substr(SQL_TEXT,1,v_i-1)||replace(substr(SQL_TEXT,v_i+1,v_k-v_i-1),' ','_')||substr(SQL_TEXT,v_k+1, length(SQL_TEXT));
	  end loop;
      
      
      --remove comments
      v_i:=instr(sql_text,'''',1,1);
      v_k:=instr(sql_text,'''',1,2);
      while v_i > 0 loop
        --dbms_output.put_line('------->'||substr(sql_text,1,v_i-1));
        sql_text:=substr(sql_text,1,v_i-1)||'"comment_removed"'||substr(sql_text,v_k+1,length(sql_text)-v_i);
        v_i:=instr(sql_text,'''',1,1);
        v_k:=instr(sql_text,'''',1,2);
      end loop;

      --remove comment blocks
      v_i:=instr(sql_text,'/*',1);
      v_k:=instr(sql_text,'*/',1);
      while v_i > 0 loop
        sql_text:=substr(sql_text,1,v_i-1)||substr(sql_text,v_k+2,length(sql_text)-v_i);
        v_i:=instr(sql_text,'/*',1);
        v_k:=instr(sql_text,'*/',1);
      end loop;
      sql_text:=REPLACE(REPLACE(replace(sql_text,'	',' '),',',','), '  ', ' ');
      --remove inline queries
/*
      v_i:=instr(sql_text,')',1);
      v_k:=instr(substr(sql_text,1,v_i)  ,'(',-1);
      while v_i > 0 loop
        if instr(substr(sql_text,v_k, v_i-v_k),'SELECT ') >0 then
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
*/


	  dbms_output.put_line(sql_text);
	  select substr(sql_text, 1, instr(sql_text,' ')) command_type into var_command from dual;
	  select substr(sql_text, instr(sql_text,' ')+1 , instr(sql_text,' FROM ', -1,1)-instr(sql_text,' ')-1) INTO var_columns from dual;
	  if instr(sql_text,' WHERE ', 1,1)>0 then
  	    select substr(sql_text, instr(sql_text,' FROM ' , 1,1)+6 , instr(sql_text,' WHERE ', 1,1) - instr(sql_text,' FROM ', 1,1)-6 ) INTO var_temp_placeholder from dual;
	    select substr(sql_text, instr(sql_text,' WHERE ', 1,1)+7)  INTO var_filters from dual;
	  else -- ... check for group by, having, order by, union, union all, intersect, minus, and finally with.....
	    case when instr(sql_text,' GROUP BY ', 1,1)>0 then 
	         v_i:=instr(sql_text,' GROUP BY ', 1,1);
	         when instr(sql_text,' ORDER BY ', 1,1)>0 then 
	         v_i:=instr(sql_text,' ORDER BY ', 1,1);
	         else 
	         v_i:=length(sql_text);
	    end case;
	    

  	    select substr(sql_text, instr(sql_text,' FROM ' , 1,1)+6 , v_i - instr(sql_text,' FROM ', 1,1)-6) INTO var_temp_placeholder from dual;
  	    --dbms_output.put_line('this is placeholder ---->'|| var_temp_placeholder);
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
      
        if instr(var_tables,' ',2,1)=0 then 
          dbms_output.put_line('insert into test_table1 (table_name) values ('''/*||db_user||'@'||datasource||' '*/||var_tables ||''');     ------->'|| object_name);
        else
          var_temp_placeholder:=var_tables; 
          v_i:=instr(var_temp_placeholder,',',1);
          --dbms_output.put_line('this is tables      ---->'|| var_tables);
          while v_i>0 loop
            dbms_output.put_line('insert into test_table2 (table_name) values ('''/*||db_user||'@'||datasource||' '*/||substr(var_temp_placeholder,1,instr(var_temp_placeholder,' ',1,1)-1) ||''');     ------->'|| object_name);
            var_temp_placeholder:=substr(var_temp_placeholder,v_i+2, length(var_temp_placeholder)-v_i);
            v_i:=instr(var_temp_placeholder,',',1);
          end loop;
          if instr(var_temp_placeholder,' ',1,1)=0 then 
            dbms_output.put_line('insert into test_table3 (table_name) values ('''/*||db_user||'@'||datasource||' '*/|| var_temp_placeholder ||''');     ------->'|| object_name);
          else
            if instr(var_temp_placeholder,'"',1,1)=0 then
			dbms_output.put_line('insert into test_table4 (table_name) values ('''/*||db_user||'@'||datasource||' '*/||substr(var_temp_placeholder,1,instr(var_temp_placeholder,' ',1,1)-1) ||''');     ------->'|| object_name);
			else
			 while instr(var_temp_placeholder,'"',1,1)>0 loop
			   v_i:=instr(var_temp_placeholder,'"',1,1);
			   v_k:=instr(var_temp_placeholder,'"',1,2);
			   var_temp_placeholder:=substr(var_temp_placeholder,1,v_i-1)||replace(substr(var_temp_placeholder,v_i+1,v_k-v_i-1),' ','_')||substr(var_temp_placeholder,v_k+1, length(var_temp_placeholder));
			 end loop;
			 dbms_output.put_line('insert into test_table5 (table_name) values ('''/*||db_user||'@'||datasource||' '*/||substr(var_temp_placeholder,1,instr(var_temp_placeholder,' ',1,1)-1) ||''');     ------->'|| object_name);
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
  v1_sql_text:='USE DRINCCC SELECT  E.DEPARTMENT_DESCRIPTION, A.TEAM_DESC, C.ALIAS, D.ATLAS_USERNAME, CASE D.ACTIVE  WHEN 1 THEN "c"Y"c"  ELSE "c"N"c" END AS ACTIVE, B.DATE_END AS END_DATE FROM  LEADS.TEAM A JCOND  LEADS.DEPARTMENT_AGENT B ON A.TEAM_ID = B.TEAM_ID JCOND  LEADS.AGENTS C ON C.NOBLE_AGENT_ID = B.NOBLE_AGENT_ID JCOND VDW_AGENT D ON C.NOBLE_AGENT_ID = D.TSR JCOND LEADS.DEPARTMENT E ON
A.DEPARTMENT_CODE = E.DEPARTMENT_CODE WHERE  C.ACTIVE = 1 AND B.DATE_END IS NULL AND {FILLER_FUNCTION} ORDER BY E.DEPARTMENT_DESCRIPTION, A.TEAM_DESC, C.ALIAS';
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
				--and upper(query_string) not like '%PREMIER.%' and upper(query_string) not like '%DBO.%' and upper(query_string) not like'%"PREMIER".%' and upper(query_string) not like '%"DBO".%' 
				and c.object_name in ('I3 Agent List')
				--and c.object_name in ('StatusReporting_TermModification','Confirmations','DTA','Hourly Stats','I3 Agent List','QA TM Audit','I3 Call Data','TPS V3 Main CAL','VUDOO Current', 'OTA Availability','CLUB Discount_Brad2-copy')
				group by a.user_name, c.object_name, c.object_path, b.event_name, d.query_name, d.datasource, d.query_string, D.DB_USER
				order by c.object_path, c.object_name 
				) --where rownum=1
  			)
  loop
    --dbms_output.put_line(row.object_name);
    --dbms_output.put_line(row.query_string);
    if upper(row.query_string) not like '%WITH % AS%' and upper(row.query_string) not like '%OPENQUERY%' and length(row.query_string)<4000 then
      --dbms_output.put_line('___________________________________________________________________________________');
      --dbms_output.put_line(row.query_string);
      --dbms_output.put_line(row.db_user||'@'||row.datasource);
      --dbms_output.put_line(row.object_name);
      --dbms_output.put_line('___________________________________________________________________________________');
      --dbms_output.put_line(v1_sql_text);
      parse_tester(row.user_name, row.object_name, row.object_path,row.event_name, row.last_start_time,row.query_name, row.datasource,row.DB_USER,upper(trim(row.query_string)), row.executions, 0);
      --parse_tester(row.user_name, row.object_name, row.object_path,row.event_name, row.last_start_time,row.query_name, row.datasource,row.DB_USER,upper(trim(v1_sql_text)), row.executions, 0);
      --dbms_output.put_line('commit;');
    end if;
  end loop;
END;
/

/* users with prefix
$ cat output.txt | grep insert | awk -F '----' '{print $1 }' | grep -v "QB_SEL"| grep "\." |awk -F';' '{print $1}'| awk -F"'" '{print $2}' | awk -F'.' '{print $1}' | sort -u
ATLAS
CCI
CONVERT
DATAWH
DBO
EPMRAF
HSI
KMARCOS
LBACSYS
LEADS
MDSYS
NOETIX_NEW_SYS
NORTRIDGE
OTA_INTERFACE
PAUDIT
PREMIER
SFS_DBO
SQLPDBAV10
WEBRES
WEBUI
WMSYS

*/

/* tables without a prefix entirely
$ cat output.txt | grep -v '\.' | awk -F"'" '{print $2}' | awk -F'.' '{print $1}' | sort -u

(SELECT
{#QB_SEL$_0_1#}
{#QB_SEL$_0_2#}
{#QB_SEL$_0_3#}
{#QB_SEL$_0_4#}
{#QB_SEL$_0_5#}
{#QB_SEL$_0_6#}
{#QB_SEL$_0_7#}
{#QB_SEL$_0_7#}DAYQRY
{#QB_SEL$_0_8#}
1
AR_CLUB_GROUP
CASE
CONCAT{FILLER_FUNCTION}
DUAL
FDI_CHOICE
LN_NLS_PAYMENT_EXCEPTIONS
LN_NLS_PAYMENT_FILES
LN_NLS_TASK_TERM_MOD_ELIGIBILILTY
MAIN_QUERY
NLS_LOAN_PAYMENT_METHOD
NVL{FILLER_FUNCTION}
P_BOX_PROGRAM,
P_CLOSING_COST
P_CLOSING_COST_TYPE
P_CONTRACT
P_CONTRACT_APPLY_TO
P_CONTRACT_HISTORY
P_CONTRACT_LEAD
P_CONTRACT_LOAN
P_CONTRACT_PAY_SCHEDULE
P_CONTRACT_PURCHASE
P_CONTRACT_TRADEOUT
P_ITEM_MASTER
P_MEMBER_CONTRACT
P_TOUR_TYPE,
PV_TOUR_STATUS,
R_SERVICER
S_MEMBERSHIP
S_TRANSACTION
V_NLS_LOANACCT
V_NLS_LOANACCT_BATCH
V_NLS_LOANACCT_COMMENTS
V_NLS_LOANACCT_PAYMENT_HISTORY_DETAIL
V_NLS_LOANACCT_PAYMENT_HISTORY_HEADER
V_NLS_LOANACCT_STATUSES
V_NLS_TASK
V_NLS_TASK_WORKFLOW_DETAIL
VDW_AGENT

*/