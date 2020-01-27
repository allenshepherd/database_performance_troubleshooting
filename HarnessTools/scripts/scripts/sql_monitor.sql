set trimspool on
set trim on
set pages 0
set linesize 1000
set long 1000000
set longchunksize 1000000
spool sqlmon_active.html
select dbms_sqltune.report_sql_monitor(type=>'active', sql_id=>'&sql_id') from dual;
spool off
