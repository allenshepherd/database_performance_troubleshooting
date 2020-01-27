REMARK ********* (c) 2017 - THE AUTOMATION DBA : All rights reserved*********
PROMPT _________________________________________________________________________________________________________________________________________
PROMPT   CREATE BASELINE : DESCRIPTION AND USAGE
PROMPT  This sql will take a SQL_ID as input, and walk you through the process of creating a baseline from AWR or cursor. Additionally,
PROMPT   If there is a baseline already created for the sql_id, this will allow you to add/remove hash_plans.
PROMPT 
PROMPT     DATE FORMAT EXAMPLES
PROMPT           01-JAN-2017
PROMPT           01-JAN-2017 13:48
PROMPT _________________________________________________________________________________________________________________________________________
PROMPT
set feedback off timing off
variable tmp NUMBER;
ACCEPT sql_id PROMPT '*ENTER SQL-ID: ';
PROMPT .
PROMPT .      Searching for applicable plans in AWR FROM &&start_time to &&end_time.
DECLARE
  v_tmp number :=0;
BEGIN
  select count(*) into v_tmp from dba_sqlset where name='sql_sts_&&sql_id';
  if v_tmp <> 0 then
    dbms_sqltune.drop_sqlset(sqlset_name =>'sql_sts_&&sql_id');
   end if;
   dbms_sqltune.create_sqlset(sqlset_name =>'sql_sts_&&sql_id', description => 'Sql tuning set for &&sql_id');
END;
/

select w.PLAN_TABLE_OUTPUT from
(select distinct(p.PLAN_HASH_VALUE) list_of_available_hash_plans from dba_hist_sql_plan p, dba_hist_sqlstat q, dba_hist_snapshot s
where q.sql_id='&&sql_id' and s.snap_id = q.snap_id and s.dbid = q.dbid and p.PLAN_HASH_VALUE= q.PLAN_HASH_VALUE and s.instance_number = q.instance_number
 and s.end_interval_time >= to_date(trim('&&start_time.'),'dd-mon-yyyy hh24:mi')
 and s.begin_interval_time <= to_date(trim('&&end_time.'),'dd-mon-yyyy hh24:mi')
) r, table(dbms_Xplan.display_awr('&&sql_id',plan_hash_value=> r.list_of_available_hash_plans, format=>'BASIC')) w
/

select distinct(p.PLAN_HASH_VALUE) list_of_available_hash_plans from dba_hist_sql_plan p,  dba_hist_sqlstat q, dba_hist_snapshot s
where q.sql_id='&&sql_id' and s.snap_id = q.snap_id and s.dbid = q.dbid and p.PLAN_HASH_VALUE= q.PLAN_HASH_VALUE and s.instance_number = q.instance_number
 and s.end_interval_time >= to_date(trim('&&start_time.'),'dd-mon-yyyy hh24:mi')
 and s.begin_interval_time <= to_date(trim('&&end_time.'),'dd-mon-yyyy hh24:mi')
/

PROMPT
PROMPT
PROMPT ------------------------------------------------------------------------------------------------------------------------------------------------------;


set pages 0
select distinct('. ***************** SQL_ID-> &&sql_id already has existing Baselines****************') baseline from  dba_hist_sqlstat  s, DBA_SQL_PLAN_BASELINES b WHERE s.FORCE_MATCHING_SIGNATURE=b.SIGNATURE AND s.sql_id='&&sql_id';

set lines 220 pages 1000
col created for a30 trunc
select * from (
  select
  NVL(case when g.sql_id is not null then g.sql_id else s.sql_id end, 'AGED OUT OF AWR') sql_id, b.sql_handle,
  NVL(to_char(g.PLAN_HASH_VALUE),'NOT IN CURSOR CACHE') HASH_PLAN_VALUE, PLAN_NAME, ENABLED, ACCEPTED, FIXED, CREATED, ORIGIN
  FROM DBA_SQL_PLAN_BASELINES b
    left join DBA_HIST_SQLSTAT s on s.FORCE_MATCHING_SIGNATURE=b.SIGNATURE
    left join gv$sql g on g.EXACT_MATCHING_SIGNATURE=b.SIGNATURE AND b.PLAN_NAME=g.SQL_PLAN_BASELINE
  group by case when g.sql_id is not null then g.sql_id else s.sql_id end, sql_handle, g.PLAN_HASH_VALUE, PLAN_NAME, ENABLED, ACCEPTED, FIXED,CREATED,ORIGIN
  order by 3,1
  )
  where sql_id='&&sql_id'
/


PROMPT
PROMPT ------------------------------------------------------------------------------------------------------------------------------------------------------;
PROMPT . **************************************************************************************
PROMPT  *ENTER YOUR PLAN*  - If a plan is not listed that you want, (say from cursor),
PROMPT .           you can still enter that plan and we will attempt to load from cursor cache.
PROMPT . **************************************************************************************
PROMPT .
PROMPT *ENTER DESIRED PLAN HASH VALUE FROM AWR or CURSOR CACHE: 
PROMPT .

DECLARE
  cursor1 sys_refcursor;
  bsnap number;
  esnap number;
  load_plan number :=0;
  tmp number :=0;
  temp_hash_value number;
  v_handle varchar(32);
  v_plan_name varchar(32);
  v_tmp_plan_name varchar(32);
  v_id varchar(32);
  tmp_sql_id varchar(32);
  v_cursor_query varchar(256);
  v_cursor_query2 varchar(256);
  v_sql_handle varchar(30);
BEGIN
  select min(snap_id)-1 into bsnap from dba_hist_snapshot s where /*instance_number=1 and*/ s.end_interval_time >= to_date(trim('&&start_time'),'dd-mon-yyyy hh24:mi:ss');
  select max(snap_id) into esnap from dba_hist_snapshot s where /*instance_number=1 and*/ s.begin_interval_time <= to_date(trim('&&end_time'),'dd-mon-yyyy hh24:mi:ss');
  open cursor1 for select value(p) from table(dbms_sqltune.select_workload_repository(begin_snap=>bsnap ,end_snap=>esnap, basic_filter=>'sql_id =''&&sql_id''',attribute_list =>'ALL')) p;
  DBMS_SQLTUNE.load_sqlset(sqlset_name=>'sql_sts_&&sql_id', populate_cursor =>cursor1);
  CLOSE cursor1;
  select count( distinct(p.PLAN_HASH_VALUE)) into tmp from dba_hist_sql_plan p,  dba_hist_sqlstat q, dba_hist_snapshot s
 	where q.sql_id='&&sql_id' and s.snap_id = q.snap_id and s.dbid = q.dbid and p.PLAN_HASH_VALUE= q.PLAN_HASH_VALUE and s.instance_number = q.instance_number
	 and s.end_interval_time >= to_date(trim('&&start_time.'),'dd-mon-yyyy hh24:mi')
	 and s.begin_interval_time <= to_date(trim('&&end_time.'),'dd-mon-yyyy hh24:mi') and p.PLAN_HASH_VALUE=&&desired_plan_hash_value;
  v_cursor_query := '';
  dbms_output.put_line('.');
  if tmp > 0 then
   	dbms_output.put_line('.             ****ATTEMPTING TO LOAD FROM AWR*** ');
	load_plan :=DBMS_SPM.LOAD_PLANS_FROM_SQLSET(sqlset_name =>'sql_sts_&&sql_id', basic_filter =>'sql_id =''&&sql_id''');
	DBMS_LOCK.sleep(5);
  else
     dbms_output.put_line('.             ****ATTEMPTING TO LOAD FROM CURSOR CACHE*** ');
     select count(*) into tmp from v$sql where plan_hash_value=&&desired_plan_hash_value and upper(sql_text) not like '%EXPLAIN PLAN %';
     if tmp = 0 then
        dbms_output.put_line('.');
	dbms_output.put_line('. **** ERROR: Please try priming cache on this instance, as no sql_id was found with hash value of &&desired_plan_hash_value');
        dbms_output.put_line('.');
     else
--_____________________________________________________________________________________________________________________
  	tmp :=DBMS_SPM.LOAD_PLANS_FROM_SQLSET(sqlset_name =>'sql_sts_&&sql_id', basic_filter =>'sql_id =''&&sql_id''');
	DBMS_LOCK.sleep(5);
--_____________________________________________________________________________________________________________________
	BEGIN
       	  select sql_id into tmp_sql_id from
		(select sql_id from v$sql where plan_hash_value=&&desired_plan_hash_value and upper(sql_text) not like '%EXPLAIN PLAN%' order by LAST_ACTIVE_TIME desc) where rownum=1;
	  select distinct(sql_handle) into v_handle from DBA_SQL_PLAN_BASELINES b where 
		signature in (select s.FORCE_MATCHING_SIGNATURE from DBA_HIST_SQLSTAT s where s.sql_id='&&sql_id')
	        or signature in (select g.EXACT_MATCHING_SIGNATURE from gv$sql g where g.sql_id='&&sql_id') 
		or signature in (select g.FORCE_MATCHING_SIGNATURE from gv$sql g where g.sql_id='&&sql_id');
          v_cursor_query := 'declare t number; begin t :=DBMS_SPM.LOAD_PLANS_FROM_CURSOR_CACHE(sql_id=>'''||tmp_sql_id||''', plan_hash_value=>''&&desired_plan_hash_value'', sql_handle=>'''||v_handle||''', fixed=>''YES''); end;';
	  execute immediate v_cursor_query;
	  select count(*) into load_plan from 
		( with source as (select rownum rowcount, plan_table_output from (select * from table(dbms_xplan.display_sql_plan_baseline(sql_handle =>v_handle))))
			select trim(substr(A.PLAN_TABLE_OUTPUT,12,32)) plan_name, trim(substr(B.PLAN_TABLE_OUTPUT,18)) plan_hash_value from source a, source b
			where A.PLAN_TABLE_OUTPUT like 'Plan name: %' and B.PLAN_TABLE_OUTPUT like 'Plan hash value: %' and b.rowcount=a.rowcount+4
		) where plan_hash_value='&&desired_plan_hash_value';
	  --___________________________________________________________________________________________________________
       END;
    end if; -- if to check if cache has a sql_id
  end if;  --if to check if to load from AWR or cursor cache
  dbms_output.put_line('.');
  if load_plan >= 1 then
    dbms_output.put_line('_*_*_*_*_*_*_*_*_*_*_*_*_PLAN LOADED SUCCESSFUL_*_*_*_*_*_*_*_*_*_*_*_*');
    DBMS_LOCK.sleep(5);
    begin
      for row in 
        (
	  with source as (select rownum rowcount, plan_table_output from (select plan_table_output from
                ( select distinct(sql_handle) from DBA_SQL_PLAN_BASELINES b where
                signature in (select s.FORCE_MATCHING_SIGNATURE from DBA_HIST_SQLSTAT s where s.sql_id='&&sql_id')
                or signature in (select g.EXACT_MATCHING_SIGNATURE from gv$sql g where g.sql_id='&&sql_id')
                or signature in (select g.FORCE_MATCHING_SIGNATURE from gv$sql g where g.sql_id='&&sql_id')) B, table(dbms_xplan.display_sql_plan_baseline(sql_handle =>b.sql_handle)) A ) )
          select trim(substr(A.PLAN_TABLE_OUTPUT,12,32)) plan_name, trim(substr(B.PLAN_TABLE_OUTPUT,18)) plan_hash_value from source a, source b
          where A.PLAN_TABLE_OUTPUT like 'Plan name: %' and B.PLAN_TABLE_OUTPUT like 'Plan hash value: %' and b.rowcount=a.rowcount+4
	)
      loop
         if row.plan_hash_value <> &&desired_plan_hash_value then
           begin 
             v_cursor_query := 'declare t number; begin t :=DBMS_SPM.ALTER_SQL_PLAN_BASELINE( sql_handle=>'''||v_handle||''', plan_name=>'''||row.plan_name||''',attribute_name=>''ENABLED'',attribute_value=>''NO''); end;';
             execute immediate v_cursor_query;
           end;
	 else
           begin
             v_cursor_query := 'declare t number; begin t :=DBMS_SPM.ALTER_SQL_PLAN_BASELINE( sql_handle=>'''||v_handle||''', plan_name=>'''||row.plan_name||''',attribute_name=>''FIXED'',attribute_value=>''YES''); end;';
             execute immediate v_cursor_query;
           end;
         end if;
	if row.plan_name not like 'PERF_TEAM_FOR_PLAN_%' then
           begin
             v_cursor_query :='declare t number; begin t :=DBMS_SPM.ALTER_SQL_PLAN_BASELINE(sql_handle=>'''||v_handle||''',plan_name=>'''||row.plan_name||''', attribute_name=>''PLAN_NAME'', attribute_value=>''PERF_TEAM_FOR_PLAN_'||row.plan_hash_value||''');end;';
  	     execute immediate v_cursor_query;
           end;
 	end if;
      end loop row;
    end;
  else
    dbms_output.put_line('.');
    dbms_output.put_line('_*_*_*_*_*_*_*_*_*_*_*_*_FAILED TO LOAD PLAN_*_*_*_*_*_*_*_*_*_*_*_*');
  end if;
  dbms_sqltune.drop_sqlset(sqlset_name =>'sql_sts_&&sql_id');
END;
/

col SUCCESSFUL_BASELINE_INFOMATION for a150 wrap
select PLAN_TABLE_OUTPUT SUCCESSFUL_BASELINE_INFOMATION from 
  (select distinct(sql_handle) from  V$SQL s, DBA_SQL_PLAN_BASELINES b
   WHERE s.EXACT_MATCHING_SIGNATURE=b.SIGNATURE AND s.sql_id='&&sql_id' ) r, 
table(dbms_xplan.display_sql_plan_baseline(sql_handle =>r.sql_handle, format=>'typical')) t
/

--PROMPT - BELOW PLANS AVAILABLE FOR SQL_ID 
set lines 220 
col created for a30 trunc
select * from (
  select
  NVL(case when g.sql_id is not null then g.sql_id else s.sql_id end, 'AGED OUT OF AWR') sql_id, b.sql_handle,
  NVL(to_char(g.PLAN_HASH_VALUE),'NOT IN CURSOR CACHE') HASH_PLAN_VALUE, PLAN_NAME, ENABLED, ACCEPTED, FIXED, CREATED, ORIGIN
  FROM DBA_SQL_PLAN_BASELINES b
    left join DBA_HIST_SQLSTAT s on s.FORCE_MATCHING_SIGNATURE=b.SIGNATURE
    left join gv$sql g on g.EXACT_MATCHING_SIGNATURE=b.SIGNATURE AND b.PLAN_NAME=g.SQL_PLAN_BASELINE
  group by case when g.sql_id is not null then g.sql_id else s.sql_id end, sql_handle, g.PLAN_HASH_VALUE, PLAN_NAME, ENABLED, ACCEPTED, FIXED,CREATED,ORIGIN
  order by 3,1
  )
  where sql_id='&&sql_id'
/
PROMPT ------------------------------------------------------------------------------------------------------------------------------------------------------

PROMPT
PROMPT _______________________________________________________________________________________________________________________________________________________________________________________
PROMPT .  NOTE - To *ADD* additional plans, re-run the script. To alter any of the above plans to enabled/fixed/accepted, use below command. For a plan to be potentially choosen, 
PROMPT .  it needs to be enabled, and accepted. Do so by using the below command.
PROMPT .      EXEC :tmp :=DBMS_SPM.ALTER_SQL_PLAN_BASELINE(sql_handle=>'sql handle',plan_name=>'plan from above', attribute_name=>'ENABLED/FIXED/ACCEPTED/AUTOPURGE', attribute_value=>'YES/NO');
PROMPT . 
PROMPT .  To *REMOVE* a Plan (if auto captured then it ma come back)
PROMPT .      EXEC :tmp :=DBMS_SPM.DROP_SQL_PLAN_BASELINE(sql_handle=>'sql handle',plan_name=>'plan name from above');
PROMPT _______________________________________________________________________________________________________________________________________________________________________________________
set feedback on timing on
undefine desired_plan_hash_value
