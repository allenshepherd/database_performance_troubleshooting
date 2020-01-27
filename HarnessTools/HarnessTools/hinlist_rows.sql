set echo off
rem $Header: $
rem
rem  Copyright (c) 2000-2013 by Hotsos Enterprises, Ltd. All rights reserved.
rem
rem  Notes: script to calculate rows returned by IN-List
rem
rem parameters:  1) density of column
rem              2) # of values in IN-List
rem              3) # rows in table

set termout on verify off feedback off
prompt ***********************************************************
prompt This will calculate the number of rows returned by IN-List.
prompt Based on the desity of a column and the number of values 
prompt in the list.  
prompt ************************************************************
accept v_density number prompt 'Enter the density of the column compared to the IN-List: '
accept v_vals    number prompt 'Enter the number of values in the IN-List: '
accept v_rows    number prompt 'Enter the number of rows in the table: '

select (((&v_density*&v_vals) + power(&v_density,&v_vals)) * &v_rows) as "Est. Rows Returned",
       (((((&v_density*&v_vals) + power(&v_density,&v_vals)) * &v_rows)/&v_rows) * 100) as "% Rows Returned"
from dual
/

undefine v_density
undefine v_vals
undefine v_rows

@henv
