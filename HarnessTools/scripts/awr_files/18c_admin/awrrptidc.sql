Rem
Rem $Header: rdbms/admin/awrrptidc.sql /main/1 2017/01/25 10:44:17 kmorfoni Exp $
Rem
Rem awrrptidc.sql
Rem
Rem Copyright (c) 2016, Oracle and/or its affiliates. All rights reserved.
Rem
Rem    NAME
Rem      awrrptidc.sql - AWR report internal define con_dbid
Rem
Rem    DESCRIPTION
Rem      This is a SQL*Plus script that implements the logic of reading the
Rem      container DB Id (con_dbid) that the user is interested in.
Rem
Rem    NOTES
Rem      The script takes the default con_dbid as input parameter.
Rem      It defines a variable con_dbid that stores the value that the user
Rem      selects. The caller has access to this value through this variable.
Rem      The caller is responsible for undefining the variable after using it.
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/awrrptidc.sql
Rem    SQL_SHIPPED_FILE:
Rem    SQL_PHASE:
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    SQL_CALLING_FILE:
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    kmorfoni    12/06/16 - specify con_dbid in AWR SQL report
Rem    kmorfoni    12/06/16 - Created
Rem

-- Get the CON_DBID from the user
begin
  dbms_output.put_line('');
  dbms_output.put_line('');
  dbms_output.put_line('Specify the Container DB Id');
  dbms_output.put_line('~~~~~~~~~~~~~~~~~~~~~~~~~~~');
  dbms_output.put_line('The default value for Container DB Id is '|| &1 || '.');
  dbms_output.put_line('Press <return> to use the default value, or enter an '||
                       'alternative otherwise.');
  dbms_output.put_line('');
end;
/

set heading off;
set newpage none;
column con_dbid new_value con_dbid noprint;

select nvl('&con_dbid', &1) con_dbid
from dual;

undefine 1
