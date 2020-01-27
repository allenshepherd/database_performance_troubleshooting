set echo off

rem $Header$
rem $Name$		hmsess.sql

rem Copyright (c); 2004-2011 by Hotsos Enterprises, Ltd.
rem 
rem  Notes:    Display session information for this session.

col hmsess_sid  fold_after
col hmsess_pid  fold_after
col hmsess_usr  fold_after
col hmsess_mach fold_after
col hmsess_spid noprint new_value hmsess_spid

set heading off verify off feedback off lines 50

select 'Auditsid sid serial#: '  ||  s.audsid    ||' '||  s.sid  ||' '||  s.serial# sid,
       ' Serverpid Clientpid: '  ||  p.spid      ||' '||  s.process pid,
       '    Terminal Machine: '  ||  s.terminal  ||' '||  s.machine mach,
       '       DBuser OSuser: '  ||  s.username  ||' '||  s.osuser usr,
       p.spid hmsess_spid
  from sys.v_$process p, sys.v_$session s
 where s.paddr = p.addr
   and s.sid = (select sid from sys.v_$mystat where rownum = 1)
/

set heading on feedback on lines 132

undefine hmsess_spid
clear columns
@henv
