set echo off
set verify off

rem $Header$
rem $Name$

rem Copyright (c); 2005-2011 by Hotsos Enterprises, Ltd.
rem
rem Exports system stats into the named STATTAB
rem


set termout on serveroutput on

accept htst_stattab prompt 'Enter the stattab name: '

declare

    v_stattab   varchar2(30) := '&htst_stattab' ;

begin

    dbms_stats.export_system_stats (stattab => v_stattab) ;

exception
   when others then
    dbms_output.put_line (sqlerrm) ;
    dbms_output.put_line ('*** System statistics export error ***') ;

end ;
/

undefine htst_stattab
@henv
