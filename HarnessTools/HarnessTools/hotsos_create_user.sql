set echo off heading off termout off feedback off verify off
set define '&'

VARIABLE tspace varchar2(200);
begin
  begin
    select property_value into :tspace from database_properties
      where property_name = 'DEFAULT_PERMANENT_TABLESPACE';
  exception when no_data_found then
    begin
      select tablespace_name into :tspace from dba_tablespaces 
        where tablespace_name = 'USERS'
          and contents = 'PERMANENT'
          and status = 'ONLINE';
    exception when no_data_found then
      select tablespace_name into :tspace from dba_tablespaces 
        where tablespace_name != 'SYSTEM'
          and contents = 'PERMANENT'
          and status = 'ONLINE'
          and rownum = 1;
    end;
  end;
exception when others then :tspace := 'USERS';
end;
/

VARIABLE tspacet varchar2(200);
begin
  begin
    select property_value into :tspacet from database_properties
      where property_name = 'DEFAULT_TEMP_TABLESPACE';
  exception when no_data_found then
    begin
      select tablespace_name into :tspacet from dba_tablespaces 
        where tablespace_name = 'TEMP'
          and contents = 'TEMPORARY'
          and status = 'ONLINE';
    exception when no_data_found then
      select tablespace_name into :tspacet from dba_tablespaces 
        where tablespace_name != 'SYSTEM'
          and contents = 'TEMPORARY'
          and status = 'ONLINE'
          and rownum = 1;
    end;
  end;
exception when others then :tspacet := 'TEMP';
end;
/

rem create the tspace subst variable for usage below
column temp new_value tspace
column temp2 new_value tspacet
select :tspace temp, :tspacet temp2 from dual;
set heading on termout on feedback on


PROMPT Creating new schema owner &&h_user...
PROMPT
ACCEPT h_tspace char default &&tspace  prompt '*** Enter the default tablespace for this user [&&tspace]: '
ACCEPT h_temp   char default &&tspacet prompt '*** Enter the temporary tablespace for this user [&&tspacet]: '
PROMPT

CREATE USER &&h_user
IDENTIFIED BY &&h_pw
DEFAULT TABLESPACE &&h_tspace
TEMPORARY TABLESPACE &&h_temp
PROFILE DEFAULT
ACCOUNT UNLOCK;

ALTER USER &&h_user DEFAULT ROLE ALL;
ALTER USER &&h_user QUOTA UNLIMITED ON &&h_tspace;
 
