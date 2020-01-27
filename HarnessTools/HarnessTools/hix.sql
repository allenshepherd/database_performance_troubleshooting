set echo off
rem $Header$
rem $Name$      hix.sql

rem Copyright (c); 2005-2011 by Hotsos Enterprises, Ltd.
rem
rem  Notes: List indexes for a table.
rem  Nov 2012 changed order by to columns names RVD

set termout on verify off feedback off

accept p_town  prompt 'Enter the owner name: '
accept p_tname prompt 'Enter the table name: '

col index_name  form  a30 heading 'Index Name'
col cons        form  a8 heading 'Unique?'
col vis         form  a9  heading 'Visible?'
col height      form  999 heading 'Height'
col column_name form  a30 heading 'Column Name'
col pos         noprint

break on report
break on index_name nodup on cons nodup on height nodup on vis nodup

variable msg varchar2(30)

declare
  fnd number;
begin
  :msg := 'No user by this name';
  select 1 into fnd
    from all_users
   where username = upper('&p_town');
  :msg := 'No table by this name';
  select 1 into fnd
    from all_tables
   where owner = upper('&p_town')
     and table_name = upper('&p_tname');
  :msg := 'No indexes for this table';
  select 1 into fnd
    from all_indexes
   where table_owner = upper('&p_town')
     and table_name = upper('&p_tname')
     and rownum = 1;
  :msg := null;
  exception when no_data_found then null;
end;
/

select i.index_name,
       decode(i.uniqueness,'UNIQUE','Y','N') cons,
       decode(i.visibility,'VISIBLE','Y','N') vis,
       i.blevel+1 height,
       ic.column_name,
       ic.column_position pos
  from all_indexes i, all_ind_columns ic
 where :msg is null
   and i.table_owner = upper('&p_town')
   and i.table_name = upper('&p_tname')
   and i.index_name = ic.index_name
   and i.owner = ic.index_owner
union all
select :msg index_name,
       null cons,
       null vis,
       to_number(null) height,
       null column_name,
       to_number(null) pos
  from dual
 where :msg is not null
order by index_name, cons, height, pos
/

undefine p_town
undefine p_tname

clear columns

@henv
