set echo off

rem $Header$
rem $Name$		hsqltxt.sql

rem Copyright (c); 2004-2011 by Hotsos Enterprises, Ltd.
rem 
rem  Usage: @hsqltxt 
rem
rem Retrieve the SQL text for a specific hash_value
rem Hash values can come from htopsql.sql
rem

set pause off verify off term on

accept stmt_ident prompt 'SQL Statement Hash Value: ' 

col sql_text format a64 word_wrapped
ttitle off

select sql_text
  from v$sqltext
 where hash_value = decode ( substr('&&_O_RELEASE',1,1) ,
                             '1' , &stmt_ident ,
                             '9' , &stmt_ident ,
                             '8' , &stmt_ident ,
                             '7' ,
                             decode ( greatest ( power(2,31) , &stmt_ident ) ,
                                      &stmt_ident , &stmt_ident - 4294967296 ,
                                      &stmt_ident ) )
order by piece

spool &stmt_ident..sql
/
spool off

undefine stmt_ident
clear columns
@henv
