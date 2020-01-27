set echo off

rem $Header$
rem $Name$			htopsql.sql

rem Copyright (c); 2004-2011 by Hotsos Enterprises, Ltd.
rem 
rem   Usage: This script shows inefficient SQL by computing the ratio
rem          of logical_reads to rows_processed.  The user will have
rem          to press return to see the first page.  The user should
rem          be able to see the really bad stuff on the first page and
rem          therefore should press ^C and then press [Return] when the
rem          first page is completely displayed.
rem          SQL hash values are really statement identifiers. These
rem          identifiers are used as input to a hashing function to
rem          determine if a statement is in the shared pool.
rem          This script shows only statement identifiers. Use hsqltxt.sql
rem          to display the text of interesting statements.
rem
rem   Notes: This will return data for select,insert,update, and delete
rem          statements. We don't return rows for PL/SQL blocks because
rem          their reads are counted in their underlying SQL statements.
rem          There is value in knowing the PL/SQL routine that executes
rem          an inefficient statement but it's only important once you
rem          know what's wrong with the statment.

col stmtid      heading 'Stmt Id'               format    9999999999
col dr          heading 'PIO blks'              format   999,999,999
col bg          heading 'LIOs'                  format   999,999,999
col sr          heading 'Sorts'                 format       999,999
col exe         heading 'Runs'                  format   999,999,999
col rp          heading 'Rows'                  format 9,999,999,999
col rpr         heading 'LIOs|per Row'          format   999,999,999
col rpe         heading 'LIOs|per Run'          format   999,999,999

set termout   on
set pause     on
set pagesize  30
set pause     'More: '
set linesize  95

select  hash_value stmtid
       ,sum(disk_reads) dr
       ,sum(buffer_gets) bg
       ,sum(rows_processed) rp
       ,sum(buffer_gets)/greatest(sum(rows_processed),1) rpr
       ,sum(executions) exe
       ,sum(buffer_gets)/greatest(sum(executions),1) rpe
 from v$sql
where command_type in ( 2,3,6,7 )
group by hash_value
order by rpr desc
/

set pause off

clear columns
@henv
