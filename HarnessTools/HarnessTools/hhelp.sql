set echo off

rem $Header$
rem $Name$

rem Copyright (c); 2004-2011 by Hotsos Enterprises, Ltd.
rem
rem Usage: This script provides a list of all scripts available
rem        and shows a brief description.
rem
rem Parameters: 1) script_name
rem


set termout   on
set wrap      on
set pause     'More: '
set pause     on
set pagesize  30
set linesize  3000

col script_type       heading 'Script Type'  format   a11 word_wrapped
col script_name       heading 'Script Name'  format   a25 word_wrapped
col script_desc       heading 'Description'  format   a50 word_wrapped
col cmd_syntax        heading 'Syntax'       format   a60 word_wrapped

select script_type, script_name, script_desc, (command_syntax || ' ' ||
       (case when parm1 is not null then trim(parm1) else '' end) ||
       (case when parm2 is not null then ' / ' || trim(parm2) else '' end) ||
       (case when parm3 is not null then ' / ' || trim(parm3) else '' end) ) cmd_syntax
from hscripts
where 'ALL' = UPPER('&&1')
or upper(script_name) = UPPER('&1')
order by script_type, script_name ;

set pause off
set wrap on
undefine 1

