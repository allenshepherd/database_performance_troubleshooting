set echo off

rem $Header$
rem $Name$		hdts.sql

rem Copyright (c); 2005-2011 by Hotsos Enterprises, Ltd.
rem 
rem Deletes (drops) stats for a given table


set termout on verify off
accept htst_owner prompt 'Enter the owner name: '
accept htst_table prompt 'Enter the table name: '

DECLARE
     v_owner	all_tables.owner%type := '&htst_owner' ;
     v_tab		all_tables.table_name%type := '&htst_table' ;
BEGIN
     DBMS_STATS.DELETE_TABLE_STATS (v_owner, v_tab);
END;
/

clear columns
@henv
