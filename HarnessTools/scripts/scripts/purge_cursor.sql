select 'exec DBMS_SHARED_POOL.PURGE('''||ADDRESS||', '||HASH_VALUE||''',''C'');' from V$SQLAREA where SQL_ID ='&sql_id';

