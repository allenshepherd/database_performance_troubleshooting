set echo off

rem $Header$
rem $Name$

rem Copyright (c); 2005-2011 by Hotsos Enterprises, Ltd.
rem 
rem Displays column constraints for a table 
rem 

set termout on
accept htst_owner prompt 'Enter the owner name: '
accept htst_table prompt 'Enter the table name: '

set lines 250
set pages 100
set feedback off

column cname format a35 word_wrapped heading 'Constraint'
column ctype format a11 heading 'Type'
column crule format a40 word_wrapped heading 'Constraint Rule'
column colname format a20 word_wrapped heading 'Column'
column cpos format 9 heading '#'
column crefer format a30 word_wrapped heading 'Refers To'
column csort noprint

break on ctype skip 2

select	a.constraint_type || a.constraint_name as csort,
		decode(a.constraint_type,'P','Primary Key','R','Foreign Key','C','Check','Other') as ctype,
		a.table_name || '.' || a.constraint_name as cname,
		b.position as cpos,
		b.column_name as colname,
		case when a.r_constraint_name is not null
			 then (select table_name
			   		 from all_indexes
				    where owner = a.owner
			    	  and index_name = a.r_constraint_name) || '.' ||
						  a.r_constraint_name
		else a.r_constraint_name
		end as crefer,
		a.search_condition as crule
  from all_constraints a, all_cons_columns b
 where a.constraint_name = b.constraint_name
   and a.table_name = b.table_name
   and a.owner = b.owner
   and a.table_name = UPPER('&htst_table')
   and a.owner = UPPER('&htst_owner')
 order by csort, b.position
/

clear columns
undefine htst_owner
undefine htst_table

@henv
