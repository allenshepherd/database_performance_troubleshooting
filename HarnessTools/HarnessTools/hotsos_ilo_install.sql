REM HOTSOS_ILO
REM Copyright (c) 2006, 2007 by Hotsos Enterprises Ltd. All rights reserved.
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
PROMPT ========================================================================
PROMPT
PROMPT This script will install the HOTSOS Oracle Instrumentation Library
PROMPT and its associated utilities.
PROMPT
PROMPT Objects Installed:
PROMPT
PROMPT * Package HOTSOS_SYSUTIL
PROMPT * Package HOTSOS_ILO_TASK
PROMPT * Package HOTSOS_ILO_TIMER
PROMPT
PROMPT * Public Synonym HOTSOS_SYSUTIL
PROMPT * Public Synonym HOTSOS_ILO_TASK
PROMPT * Public Synonym HOTSOS_ILO_TIMER
PROMPT
PROMPT * Execute privileges are granted to PUBLIC for these packages
PROMPT
PROMPT For more information, consult the readme.txt file.
PROMPT
PROMPT ========================================================================
PROMPT
PROMPT Preparing to start. Hit enter to continue...
PAUSE
PROMPT

set define '&'
set echo off heading off termout off feedback off verify off

select 'start ' || decode(user, 'SYS', 'hotsos_ilo_sysok.sql', 'hotsos_ilo_sysnotok.sql')
from  dual

spool hotsos_ilo_install.tmp
/
spool off
start hotsos_ilo_install.tmp

ACCEPT h_user char default HOTSOS prompt '*** Enter the user you wish to own HOTSOS_ILO [hotsos]: '
ACCEPT h_pw   char default HOTSOS prompt '*** Enter the password for this user [hotsos]:          ' HIDE
ACCEPT alias  char                prompt '*** Enter the TNS alias for this user:                  '

VARIABLE tnsalias varchar2(2000);
begin
  if '&&alias' is null then
    :tnsalias := '"'; -- split the double quotes here and at the connect to avoid a null tnsalias which will prompt user
  elsif '&&alias' like '@%' then
    :tnsalias := '"&&alias';
  else
    :tnsalias := '"@&&alias';
  end if;
end;
/

set echo off heading off termout off feedback off
rem create the tnsalias subst variable for usage in connect later on
column tempalias new_value tnsalias
select :tnsalias tempalias from dual;

select 'start ' || 'hotsos_ilo_hotsosok.sql &&h_user'
from all_users where upper(username) = upper('&&h_user')
UNION
select 'start ' || 'hotsos_ilo_hotsosnotok.sql &&h_user'
from dual
where not exists (select null from all_users where upper(username) = upper('&&h_user'))

spool hotsos_ilo_install.tmp
/
spool off
start hotsos_ilo_install.tmp

start hotsos_ilo_install_user.sql

REM The following statement requires this script to be run with DBA privilege.

set echo off heading off termout off feedback off
spool hotsos_ilo_install.tmp
   SELECT 'PROMPT ... Installing DBMS_SUPPORT' || chr(13) || chr(10)
          || '@?' || f.sep || 'rdbms' || f.sep || 'admin' || f.sep || 'dbmssupp.sql'
   FROM Product_Component_Version v,
        (SELECT DECODE( TO_CHAR( INSTR( DBMS_UTILITY.PORT_STRING, '/WIN_', 1 ) ),
                        '0', '/',  -- Not Windows, so use UNIX separator
                        '\' ) sep
         FROM Dual) f
   WHERE SUBSTR( v.Version, 1, INSTR( Version, '.', 1 )-1 ) = '9'
     AND v.Product LIKE 'Oracle%'
     AND NOT EXISTS
        (SELECT 1
         FROM DBA_Objects o
         WHERE o.Object_Name = 'DBMS_SUPPORT'
           AND o.Object_Type = 'PACKAGE')
UNION ALL
   SELECT 'PROMPT ... Installing DBMS_MONITOR' || chr(13) || chr(10)
          || '@?' || f.sep || 'rdbms' || f.sep || 'admin' || f.sep || 'catmntr.sql'
   FROM Product_Component_Version v,
        (SELECT DECODE( TO_CHAR( INSTR( DBMS_UTILITY.PORT_STRING, '/WIN_', 1 ) ),
                        '0', '/',  -- Not Windows, so use UNIX separator
                        '\' ) sep
         FROM Dual) f
   WHERE SUBSTR( v.Version, 1, INSTR( Version, '.', 1 )-1 ) = '10'
     AND v.Product LIKE 'Oracle%'
     AND NOT EXISTS
        (SELECT 1
         FROM DBA_Objects o
         WHERE o.Object_Name = 'DBMS_MONITOR'
           AND o.Object_Type = 'PACKAGE');
spool off

set termout on
spool hotsos_ilo_install.log

@hotsos_ilo_install.tmp
PROMPT

set serveroutput on size 1000000
declare
  procedure create_public_synonym (p_synonym varchar2) is
    already_exists exception;
    PRAGMA EXCEPTION_INIT (already_exists, -955);
    v_owner dba_synonyms.table_owner%type;
  begin
    dbms_output.put_line('... Creating public synonym '||p_synonym||' for &&h_user..'||p_synonym);
    execute immediate 'create public synonym '||p_synonym||' for &&h_user..'||p_synonym;
  exception
    when already_exists then
      begin
        select table_owner into v_owner from dba_synonyms
          where owner = 'PUBLIC' and synonym_name = upper(p_synonym);
        if upper(v_owner) != upper('&&h_user') then
          dbms_output.put_line('********************************************************************************');
          dbms_output.put_line('****************************     WARNING      **********************************');
          dbms_output.put_line('********************************************************************************');
          dbms_output.put_line('***                                                                          ***');
          dbms_output.put_line('*** Public synonym '||p_synonym||' already exists for schema: '||v_owner);
          dbms_output.put_line('*** Modify the public synonyms manually if desired.');
          dbms_output.put_line('***                                                                          ***');
          dbms_output.put_line('********************************************************************************');
        end if;
      end;
  end create_public_synonym;
begin
  create_public_synonym('hotsos_ilo_task');
  create_public_synonym('hotsos_ilo_timer');
  create_public_synonym('hotsos_sysutil');
end;
/

-- For upgrades from 1.5 to 1.6, remove the obsolete SYS.HOTSOS_SYSUTIL
-- If a new install, leave it alone so they can coexist
declare
  procedure drop_package (p_package varchar2) is
    not_exists exception;
    PRAGMA EXCEPTION_INIT (not_exists, -4043);
  begin
    execute immediate 'drop package '||p_package;
    dbms_output.put_line('... Dropping obsolete package '||p_package);
  exception
    when not_exists then null;
  end drop_package;
begin
  for rec in (select object_name from all_objects where owner = '&&h_user' and object_name = 'HOTSOS_ILO_TASK' and object_type = 'PACKAGE')
  loop
    execute immediate 'select 1 from dual where hotsos.hotsos_ilo_task.get_version < 1.6';
    if sql%rowcount > 0 then
      drop_package('SYS.HOTSOS_SYSUTIL');
    end if;
  end loop;
exception when others then null;
end;
/

PROMPT ... Granting EXECUTE privs on SYS.DBMS_MONITOR or SYS.DBMS_SUPPORT to &&h_user
declare
  no_package exception;
  PRAGMA EXCEPTION_INIT (no_package, -4042);
begin
  begin
    execute immediate 'GRANT EXECUTE ON  SYS.DBMS_MONITOR TO &&h_user';
  exception when no_package then null;
  end;
  begin
    execute immediate 'GRANT EXECUTE ON  SYS.DBMS_SUPPORT TO &&h_user';
  exception when no_package then null;
  end;
end;
/

PROMPT =========================================================================
PROMPT
PROMPT ... Connecting as &&h_user
connect &&h_user/"&&h_pw&&tnsalias
PROMPT ... Installing HOTSOS_SYSUTIL Package Spec
@hotsos_sysutil.pks
/
show errors;
PROMPT ... Installing HOTSOS_SYSUTIL Package Body
@hotsos_sysutil.pkb
/
show errors;
PROMPT ... Installing HOTSOS_ILO_TASK Package Spec
@hotsos_ilo_task.pks
/
show errors;
PROMPT ... Installing HOTSOS_ILO_TIMER Package Spec
@hotsos_ilo_timer.pks
/
show errors;
PROMPT ... Installing HOTSOS_ILO_TIMER Package Body
@hotsos_ilo_timer.pkb
/
show errors;
PROMPT ... Installing HOTSOS_ILO_TASK Package Body
@hotsos_ilo_task.pkb
/
show errors;
PROMPT ... Granting EXECUTE privs on HOTSOS_* to PUBLIC
grant execute on HOTSOS_ILO_TASK to PUBLIC;
grant execute on HOTSOS_ILO_TIMER to PUBLIC;
grant execute on HOTSOS_SYSUTIL to PUBLIC;
PROMPT
PROMPT =========================================================================
PROMPT Installation of HOTSOS ILO complete.
PROMPT =========================================================================
spool off
-- exit
