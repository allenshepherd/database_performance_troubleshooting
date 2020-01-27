REM HOTSOS_ILO
REM Copyright (C) 2006, 2007 Hotsos Enterprises Ltd
REM
REM This library is free software; you can redistribute it and/or
REM modify it under the terms of the GNU Lesser General Public
REM License as published by the Free Software Foundation; either
REM version 2.1 of the License, or (at your option) any later version.
REM
REM This library is distributed in the hope that it will be useful,
REM but WITHOUT ANY WARRANTY; without even the implied warranty of
REM MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
REM Lesser General Public License for more details.
REM
REM You should have received a copy of the GNU Lesser General Public
REM License along with this library; if not, write to the Free Software
REM Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
REM
PROMPT =========================================================================
PROMPT
PROMPT This script will UNINSTALL the HOTSOS Oracle Instrumentation Library
PROMPT and its associated utilities, including SLA extensions if present.
PROMPT
PROMPT Objects Uninstalled:
PROMPT
PROMPT * Package HOTSOS_SYSUTIL 
PROMPT * Package HOTSOS_ILO_TASK
PROMPT * Package HOTSOS_ILO_TIMER
PROMPT * Package SYS.HOTSOS_SYSUTIL (if no other ILO schemas detected)
PROMPT
PROMPT * Public Synonym HOTSOS_SYSUTIL 
PROMPT * Public Synonym HOTSOS_ILO_TASK
PROMPT * Public Synonym HOTSOS_ILO_TIMER
PROMPT
PROMPT * Table ILO_RUN
PROMPT * Table ILO_SCHEDULE_CACHE
PROMPT
PROMPT * Sequence ILO_RUN_SEQ
PROMPT
PROMPT * Trigger ILO_LOGOFF_TRG
PROMPT * Trigger SYS.ILO_LOGOFF_TRG (if no other ILO schemas detected)
PROMPT
PROMPT =========================================================================
PROMPT 
PROMPT Preparing to start. Hit enter to continue...
PAUSE
PROMPT

set define '&' 
set echo off heading off termout off feedback off verify off
set serveroutput on size 1000000

select 'start ' || decode(user, 'SYS', 'hotsos_ilo_sysok.sql', 'hotsos_ilo_sysnotok.sql')
from  dual

spool hotsos_ilo_uninstall.tmp
/
spool off
start hotsos_ilo_uninstall.tmp

ACCEPT h_user char default HOTSOS prompt '*** Please enter the owner of the HOTSOS_ILO packages : [hotsos] '

set echo off heading off termout off feedback off
select 'start ' || 'hotsos_ilo_hotsosok.sql &&h_user'
from all_users where upper(username) = upper('&&h_user')
UNION
select 'start ' || 'hotsos_ilo_hotsosnotok.sql &&h_user'
from dual 
where not exists (select null from all_users where upper(username) = upper('&&h_user'))

spool hotsos_ilo_uninstall.tmp
/
spool off
start hotsos_ilo_uninstall.tmp

set termout on feedback on
spool hotsos_ilo_uninstall.log
PROMPT
-- only drop the system trigger if no other hotsos schema exists
declare
  procedure drop_trigger (p_obj varchar2) is
    not_exists exception;
    PRAGMA EXCEPTION_INIT (not_exists, -4080);
  begin
    for rec in 
      (select null from dual where not exists
        (select null from dba_source
           where name = 'HOTSOS_ILO_TASK' 
             and owner not in ('&&h_user',upper('&&h_user'))
        )
       ) 
    loop
      dbms_output.put_line('... Dropping trigger '||p_obj);
      execute immediate 'drop trigger '||p_obj;
    end loop;
  exception
    when not_exists then null;
    when others then dbms_output.put_line(sqlerrm);
  end drop_trigger;
begin
  drop_trigger('sys.ilo_logoff_trg');
end;
/
PROMPT
declare
  procedure drop_trigger (p_obj varchar2) is
    not_exists exception;
    PRAGMA EXCEPTION_INIT (not_exists, -4080);
  begin
    dbms_output.put_line('... Dropping trigger '||p_obj);
    execute immediate 'drop trigger '||p_obj;
  exception
    when not_exists then null;
    when others then dbms_output.put_line(sqlerrm);
  end drop_trigger;
begin
  drop_trigger('&&h_user..ilo_logoff_trg');
end;
/
PROMPT
-- only drop public synonyms if they point to this schema
declare
  procedure drop_public_synonym (p_obj varchar2) is
    not_exists exception;
    PRAGMA EXCEPTION_INIT (not_exists, -1432);
  begin
    for rec in 
      (select synonym_name from dba_synonyms
         where table_owner in ('&&h_user',upper('&&h_user'))
           and owner = 'PUBLIC' and synonym_name = upper(p_obj)
       ) 
    loop
      dbms_output.put_line('... Dropping public synonym '||p_obj);
      execute immediate 'drop public synonym '||p_obj;
    end loop;
  exception
    when not_exists then null;
    when others then dbms_output.put_line(sqlerrm);
  end drop_public_synonym;
begin
  drop_public_synonym('hotsos_ilo_task');
  drop_public_synonym('hotsos_ilo_timer');
  drop_public_synonym('hotsos_sysutil');
end;
/
PROMPT
PROMPT ... Revoking Execute Privileges on &&h_user packages ...
begin
  execute immediate 'revoke execute on &&h_user..HOTSOS_ILO_TASK from PUBLIC';
exception when others then null;
end;
/
begin
  execute immediate 'revoke execute on &&h_user..HOTSOS_ILO_TIMER from PUBLIC';
exception when others then null;
end;
/
begin
  execute immediate 'revoke execute on &&h_user..HOTSOS_SYSUTIL from PUBLIC';
exception when others then null;
end;
/
PROMPT
declare
  procedure drop_package (p_obj varchar2) is
    not_exists exception;
    PRAGMA EXCEPTION_INIT (not_exists, -4043);
  begin
    dbms_output.put_line('... Dropping package '||p_obj);
    execute immediate 'drop package '||p_obj;
  exception
    when not_exists then null;
    when others then dbms_output.put_line(sqlerrm);
  end drop_package;
begin
  -- If uninstalling version < 1.6 and no other schemas exist
  begin
    for rec in 
      (select null from dual where not exists
        (select null from dba_source
           where name = 'HOTSOS_ILO_TASK' 
             and owner not in ('&&h_user',upper('&&h_user'))
        )
       ) 
    loop
      drop_package('sys.HOTSOS_SYSUTIL');
    end loop;
  exception when others then null; -- don't break other schema
  end;
  drop_package('&&h_user..HOTSOS_ILO_TIMER');
  drop_package('&&h_user..HOTSOS_ILO_TASK');
  drop_package('&&h_user..HOTSOS_SYSUTIL');
end;
/
PROMPT
PROMPT ... Revoking Execute Privileges on DBMS_MONITOR or DBMS_SUPPORT from &&h_user   
begin
  execute immediate 'revoke EXECUTE ON  SYS.DBMS_MONITOR from &&h_user';
exception when others then null;
end;
/
begin
  execute immediate 'revoke EXECUTE ON  SYS.DBMS_SUPPORT from &&h_user';
exception when others then null;
end;
/
PROMPT
declare
  procedure drop_table (p_obj varchar2) is
    not_exists exception;
    PRAGMA EXCEPTION_INIT (not_exists, -942);
  begin
    dbms_output.put_line('... Dropping table '||p_obj);
    execute immediate 'drop table '||p_obj;
  exception
    when not_exists then null;
    when others then dbms_output.put_line(sqlerrm);
  end drop_table;
begin
  drop_table('&&h_user..ILO_RUN');
  drop_table('&&h_user..ILO_SCHEDULE_CACHE');
end;
/
PROMPT
declare
  procedure drop_sequence (p_obj varchar2) is
    not_exists exception;
    PRAGMA EXCEPTION_INIT (not_exists, -2289);
  begin
    dbms_output.put_line('... Dropping sequence '||p_obj);
    execute immediate 'drop sequence '||p_obj;
  exception
    when not_exists then null;
    when others then dbms_output.put_line(sqlerrm);
  end drop_sequence;
begin
  drop_sequence('&&h_user..ILO_RUN_SEQ');
end;
/
PROMPT
PROMPT =================================================================================
PROMPT UNINSTALL of HOTSOS_ILO Complete
PROMPT
PROMPT Note: The &&h_user schema was NOT dropped as part of the uninstall. 
PROMPT If you wish to do so, copy/paste this:
PROMPT DROP USER &&h_user CASCADE
PROMPT =================================================================================
