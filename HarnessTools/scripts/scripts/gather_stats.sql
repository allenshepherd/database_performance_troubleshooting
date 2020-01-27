exec dbms_stats.gather_table_stats(OWNNAME=>'&SCHEMA_NAME',TABNAME=>'&TABLE_NAME', method_opt=>'FOR ALL COLUMNS SIZE AUTO',CASCADE=>TRUE,DEGREE=>48);

