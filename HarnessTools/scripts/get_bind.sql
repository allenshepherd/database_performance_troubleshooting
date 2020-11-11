col VARIABLES for a170
select 'variable '||replace(name,':','')||' '||datatype_string||';'  VARIABLES from v$sql_bind_capture where sql_id='&&sql_id'
union
select 'exec '||name||' := '''||
nvl(value_string,'NULL')
||''';' "BIND INFO" from v$sql_bind_capture where sql_id='&&sql_id'
order by 1 desc
/
undefine sql_id
--look into decode function or date/timpestamps
