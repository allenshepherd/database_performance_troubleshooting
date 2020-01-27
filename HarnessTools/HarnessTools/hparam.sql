set echo off

rem $Header$
rem $Name$			hparam.sql

rem Copyright (c); 2004-2011 by Hotsos Enterprises, Ltd.
rem 
rem Usage: This script shows instance parameters, even hidden ones. 
rem Unless you create corresponding v$ views, you'll have to log in 
rem as SYS to run this.

col name        heading 'Parameter Name'        format   a50
col value       heading 'Parameter Value'       format   a50

set termout   on
set wrap      off
set pause     'More: '
set pause     on
set pagesize  30
set linesize  300

select name, value, description
  from sys.hotsos_parameters
 where name like '%&1%'
 order by name ;

set pause off wrap on

clear columns
@henv
