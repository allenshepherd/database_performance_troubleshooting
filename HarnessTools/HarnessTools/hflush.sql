set echo off

rem $Header$
rem $Name$

rem Copyright (c); 2004-2011 by Hotsos Enterprises, Ltd.
rem 
rem Parameters:
rem				&1 		BP = buffer pool
rem						SP = shared pool
rem


set serveroutput on
set feedback on
set define on

declare
   v_flush		varchar2(3) := '&1';
   err_mesg     varchar2(250);

begin
   if substr(upper(v_flush),1,2) = 'BP' then
      sys.hotsos_pkg.flush_bp;
      dbms_output.put_line ('*** Buffer Pool Flushed ***') ;
   end if;
   if substr(upper(v_flush),1,2) = 'SP' then
      sys.hotsos_pkg.flush_sp;
      dbms_output.put_line ('*** Shared pool flushed ***') ;      
   end if; 
exception
   when others then 
      err_mesg := SQLERRM;
      dbms_output.put_line ('****** Error! '||err_mesg) ;
end ;
/

undefine 1
@hlogin
