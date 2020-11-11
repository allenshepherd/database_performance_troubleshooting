select * from table(dbms_Xplan.display_cursor('&sql_id9.',null))
/

--hint to be placed inside the sql /*+ GATHER_PLAN_STATISTICS */
--SELECT plan_table_output FROM table(DBMS_XPLAN.DISPLAY_CURSOR ('&sql_id9',FORMAT=>'ALLSTATS LAST'))
