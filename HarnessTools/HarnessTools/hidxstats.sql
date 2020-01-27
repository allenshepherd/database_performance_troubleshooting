set echo off

rem $Header$
rem $Name$		hidxstats.sql

rem Copyright (c); 2005-2011 by Hotsos Enterprises, Ltd.
rem 
rem Retrieve index stats information for an index
rem 

set feed off term on

accept htst_index prompt 'Enter the index name  : '

analyze index &htst_index validate structure;

declare
  v_query varchar2(4000)  ;
begin
  dbms_output.put_line('==========================================================================================');
  dbms_output.put_line('  Index Statistics');
  dbms_output.put_line('==========================================================================================');
  
  v_query := 'select * from index_stats';
  print_table (v_query);
end ;
/

undefine htst_index

@henv
