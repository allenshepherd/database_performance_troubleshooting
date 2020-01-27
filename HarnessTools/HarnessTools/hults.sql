set echo off

rem $Header$
rem $Name$			hults.sql

rem Copyright (c); 2005-2011 by Hotsos Enterprises, Ltd.
rem 

set termout on verify off
accept htst_owner prompt 'Enter the owner name: '
accept htst_table prompt 'Enter the table name: '

DECLARE
     v_owner	all_tables.owner%type := '&htst_owner' ;
     v_tab		all_tables.table_name%type := '&htst_table' ;
BEGIN
     DBMS_STATS.UNLOCK_TABLE_STATS (v_owner, v_tab);
END;
/

undefine htst_owner
undefine htst_table
@henv
