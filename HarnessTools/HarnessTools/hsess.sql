rem $Header$
rem $Name$

rem Copyright (c); 2004-2011 by Hotsos Enterprises, Ltd.
rem 
rem  Notes:    Display session information for one or more sessions.
rem            Accepts various amount of information to identify one
rem            or more sessions.

accept p_sid   prompt '       Session id: '
accept p_spid  prompt 'Server process id: '
accept p_clpid prompt 'Client process id: '
accept p_dbusr prompt 'Database username: '
accept p_osusr prompt '      OS username: '

col hsess_sid fold_after
col hsess_pid fold_after
col hsess_usr fold_after

set heading  off
set verify   off
set feedback off
set lines 120

select 'Auditsid sid serial#: '  ||  s.audsid    ||' '||  s.sid  ||' '||  s.serial# sid ,
       ' Serverpid Clientpid: '  ||  p.spid      ||' '||  s.process pid ,
       '       DBuser OSuser: '  ||  s.username  ||' '||  s.osuser usr
  from sys.v_$process p , sys.v_$session s
 where ( s.sid      = '&p_sid'
      or p.spid     = '&p_spid'
      or s.process  = '&p_clpid'
      or s.username = upper('&p_dbusr')
      or upper(s.osuser)   = upper('&p_osusr') )
   and not (   '&p_sid' is null
           and '&p_spid' is null
           and '&p_clpid' is null
           and '&p_dbusr' is null
           and '&p_osusr' is null )
   and s.paddr = p.addr
/

set heading on  feedback on   


undefine p_sid   
undefine p_spid  
undefine p_clpid 
undefine p_dbusr 
undefine p_osusr 

clear columns
@henv
