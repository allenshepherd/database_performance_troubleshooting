set echo off
rem $Header$
rem $Name$

rem Copyright (c); 2005-2011 by Hotsos Enterprises, Ltd.
rem
rem Exports schema stats into named STATTAB
rem

set verify off termout on
accept htst_owner   prompt 'Enter the owner name  : '
accept htst_stattab prompt 'Enter the stattab name: '

set serveroutput on termout on

declare

    v_owner     all_tables.owner%type := '&htst_owner' ;
    v_stattab   varchar2(30) := '&htst_stattab' ;

begin

    dbms_stats.export_schema_stats (v_owner, stattab => v_stattab ) ;

exception
   when others then
    dbms_output.put_line (sqlerrm) ;
    dbms_output.put_line ('*** Statistics export error ***') ;

end ;
/

clear columns
undefine htst_owner
undefine htst_stattab

@henv
