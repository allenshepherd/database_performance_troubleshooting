set echo off

rem $Header$
rem $Name$

rem Copyright (c); 2005-2011 by Hotsos Enterprises, Ltd.
rem
rem Determine and display the highwater mark information for a table
rem along with block content detail
rem

set verify off feed off termout on head on feed off
accept htst_owner     prompt 'Enter the owner name  : '
accept htst_table     prompt 'Enter the table name  : '

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
    tblks, tbytes, ublks, ubytes, luefid, luebid, lublk, null
  );
  :fblks := tblks - ublks;
end;
/

set termout off

col blks           new_value nblks
col blks_with_data new_value bwd
col avg_rpb        new_value arpd
col min_nrows      new_value minr
col max_nrows      new_value maxr
col tot_rows       new_value totr

select round(avg(nrows),0) as avg_rpb , count(block#) blks_with_data,
       sum(nrows) tot_rows,
       :fblks blks,
       min(nrows) min_nrows, max(nrows) max_nrows
from
(
select block#, count(*) as nrows
  from (select dbms_rowid.rowid_block_number(rowid) block#
             from &htst_owner..&htst_table
        )
 group by block#
);


set termout on
set serveroutput on
begin
  dbms_output.put_line ('========================================') ;
  dbms_output.put_line ('Blocks below HWM       : ' || &nblks) ;
  dbms_output.put_line ('Total rows in table    : ' || &totr) ;
  dbms_output.put_line ('Blocks containing data : ' || &bwd) ;
  dbms_output.put_line ('Average rows per block : ' || &arpd) ;
  dbms_output.put_line ('Min rows in one block  : ' || &minr) ;
  dbms_output.put_line ('Max rows in one block  : ' || &maxr) ;
  dbms_output.put_line ('========================================') ;
end;
/

clear columns
@henv
