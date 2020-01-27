set echo off

rem $Header$
rem $Name$

rem Copyright (c); 2004-2011 by Hotsos Enterprises, Ltd.
rem 
rem Determine and display the highwater mark information for a table
rem 

set verify off feed off termout on
accept htst_owner prompt 'Enter the owner: '
accept htst_table prompt 'Enter the table: '

variable fblks number

declare
  tblks  number;
  tbytes number;
  ublks  number;
  ubytes number;
  luefid number;
  luebid number;
  lublk  number;
begin
  sys.dbms_space.unused_space(
    upper('&htst_owner'), upper('&htst_table'), 'TABLE',
    tblks, tbytes, ublks, ubytes, luefid, luebid, lublk, null );
  :fblks := tblks - ublks;
end;
/

col blks   form   9,999,999,999 heading 'Table blocks below hwm' just c
col nrows  form 999,999,999,999 heading 'Table rows'             just c new_value v_nrows

select :fblks blks, num_rows nrows
  from all_tables
 where owner = upper('&htst_owner')
   and table_name = upper('&htst_table');

undefine fblks
clear columns
@henv
