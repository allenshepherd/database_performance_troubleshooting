set feedback off
col sql_text for a200 wrap
PROMPT _____________________________________________________________________________

PROMPT _____________________________________________________________________________

col VARIABLES for a170
select 'variable '||replace(name,':','')||' '||datatype_string||';'  VARIABLES 
  from DBA_HIST_SQLBIND where sql_id='&&sql_id' and LAST_CAPTURED between to_date(trim('&&start_time'),'dd-mon-yyyy hh24:mi:ss') and to_date(trim('&&end_time'),'dd-mon-yyyy hh24:mi:ss')
union
select 'exec '||name||' := '''|| nvl(value_string,'NULL')||''';' "BIND INFO" 
  from DBA_HIST_SQLBIND where sql_id='&&sql_id' and LAST_CAPTURED between to_date(trim('&&start_time'),'dd-mon-yyyy hh24:mi:ss') and to_date(trim('&&end_time'),'dd-mon-yyyy hh24:mi:ss')
order by 1 desc
/

PROMPT _____________________________________________________________________________

select sql_text from DBA_HIST_SQLTEXT where sql_id='&&sql_id';
PROMPT _____________________________________________________________________________

PROMPT view binds in memory using v$sql_bind_capture instead of DBA_HIST_SQLBIND.
PROMPT _____________________________________________________________________________
PROMPT

set feedback on
undefine sql_id
--look into decode function or date/timpestamps
