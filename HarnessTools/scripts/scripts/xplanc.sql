select * from table(dbms_Xplan.display_cursor('&sql_id9.',format=>'ADVANCED'))
/
