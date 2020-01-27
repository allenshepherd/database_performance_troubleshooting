set echo off 

rem $Header$
rem $Name$

rem Copyright (c); 2005-2011 by Hotsos Enterprises, Ltd.
rem 
rem  Notes: Hotsos data selectivity using ALL_TABLES.NUM_ROWS to get the row count.
rem 		Information for non-partitioned tables.
rem
rem 

set autotrace off
set term off
@horaver
set term on

define v_substr7 = 'substr(rowid,15,4)||substr(rowid,1,8)'
define v_substr8 = 'substr(rowid,7,9)'
define v_over    = 'substr(''&db_ver'',1,1)'

col dummy new_value v_substr

set termout off heading on pause off

select decode(&v_over, '7', '&v_substr7', '&v_substr8') dummy
  from dual;

define hds_def_pgs=30

set termout on verify off feedback off pages 30

accept p_town  prompt 'Table Owner    : '
accept p_tname prompt 'Table Name     : '
accept p_clst  prompt 'Column List    : '
accept p_where prompt 'Where Clause   : '
accept p_pgs   prompt 'Page Size [30] : '


set termout off
col hds_pgs new_value p_pgs
col hds_town new_value p_town
select decode('&p_pgs', '', '&hds_def_pgs', '&p_pgs') hds_pgs from dual;
select decode('&p_town', '', '&hds_def_usr', '&p_town') hds_town from dual;
set termout on


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
    upper('&p_town'), upper('&p_tname'), 'TABLE',
    tblks, tbytes, ublks, ubytes, luefid, luebid, lublk, null
  );
  :fblks := tblks - ublks;
end;
/

col blks  form   9,999,999,999 heading 'Table blocks below hwm|(B)' just c new_value v_nblks
col nrows form 999,999,999,999 heading 'Table rows|(R)'             just c new_value v_nrows

select :fblks blks, num_rows nrows
  from all_tables
 where owner = upper('&p_town')
   and table_name = upper('&p_tname');

col bs    form             a17 heading 'Block selectivity|(pb = b/B)' just c
col nblks form   9,999,999,999 heading 'Block count|(b)' just c
col rs    form             a17 heading 'Row selectivity|(pr = r/R)' just c
col nrows form 999,999,999,999 heading 'Row count|(r)' just c

set pause on pause 'More: ' pages &p_pgs

select &p_clst,
       lpad(to_char(count(distinct &v_substr)/:fblks*100,'990.00')||'%',17) as bs,
       count(distinct &v_substr) nblks, 
       lpad(to_char(count(*)/&v_nrows*100,'990.00')||'%',17) rs,
       count(*) nrows
  from &p_town..&p_tname &p_where
group by &p_clst
order by bs desc;

set pause off
clear columns
@henv
