Rem
Rem $Header: plsql/admin/profload.sql /main/4 2015/08/12 22:44:40 sylin Exp $
Rem
Rem profload.sql
Rem
Rem Copyright (c) 1998, 2015, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      profload.sql - Load PROFiler server side packages
Rem
Rem    DESCRIPTION
Rem      Installs the server side PL/SQL profiler package
Rem
Rem    NOTES
Rem      Must be executed as sys
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    sylin       07/30/15 - bug14087223 - do not load DBMS_PROFILER package
Rem    jmallory    12/18/01 - Set serveroutput off at end
Rem    jmuller     05/28/99 - Fix bug 708690: TAB -> blank
Rem    astocks     10/21/98 - Detect non-sys users
Rem    ciyer       10/10/98 - install profiler package
Rem    ciyer       10/10/98 - Created
Rem

rem bug 14087223 - do not load DBMS_PROFILER package
rem In 10g and beyond, the DBMS_PROFILER package is loaded automatically when
rem the database is created.
rem @@dbmspbp.sql
rem @@prvtpbp.plb

-- Verify package version of package matches internal version. If check
-- fails, deinstall the package immediately.

set serveroutput on

declare

  -- drop profiler objects
  --
  procedure deinstall_profiler is
    type stmt_tab_t is table of varchar2(256) index by binary_integer;
    stmts stmt_tab_t;
    each  pls_integer;
  begin
    stmts(1) := 'drop package sys.dbms_profiler';
    stmts(2) := 'drop public synonym dbms_profiler';
    stmts(3) := 'drop library sys.dbms_profiler_lib';

    each := stmts.first;
    while (each is not null) loop
      execute immediate stmts(each);
      each := stmts.next(each);
    end loop;
  end deinstall_profiler;

  -- match version of profiler package against version in database
  --
  function profiler_version_check return pls_integer is
    stmt   varchar2(256);
    result binary_integer;
  begin
    stmt := 'begin
               :result := sys.dbms_profiler.internal_version_check;
             end;';
    execute immediate stmt using out result;
    return result;
  end;

  -- sanity check the install. verify all objects exists and are valid.
  --
  function check_one_object(package_name IN varchar2,
                            package_type IN varchar2) return boolean is
    number_of_objects pls_integer;

    cursor c(package_name varchar2, package_type varchar2) is
      select owner from all_objects 
      where object_name = package_name
      and status = 'VALID'
      and object_type = package_type;
      
    sys_seen boolean := false;

  begin
    for owner in c(package_name, package_type) loop
      if (owner.owner = 'SYS') then
        sys_seen := true;
      else
        dbms_output.put_line('Warning: user "' || owner.owner || '" has a private ' || package_type ||
          ' named ' || package_name);
      end if;
    end loop;

    if (not sys_seen) then
      dbms_output.put_line(package_type || ' ' || 'sys.' || package_name ||
                           ' - missing or invalid');
      return false;
    end if;

  return true;
  end check_one_object;

  function check_profiler_objects return boolean is

    synonym_name constant varchar2(32) := 'DBMS_PROFILER';
    package_name constant varchar2(32) := 'DBMS_PROFILER';

    number_of_objects pls_integer;
    success boolean := true;

  begin
    -- check for a valid synonym
    select count(*) into number_of_objects from all_synonyms
      where synonym_name = check_profiler_objects.synonym_name
        and owner = 'PUBLIC' and table_owner = 'SYS';

    if (number_of_objects <> 1) then
      dbms_output.put_line(synonym_name || ' - missing or invalid synonym');
      success := false;
    end if;

    -- verify package spec/body is valid
    success := check_one_object(package_name, 'PACKAGE') AND
               check_one_object(package_name, 'PACKAGE BODY');

    if (success) then
       dbms_output.put_line('SYS.' || package_name || ' successfully loaded.');
    end if;
  return success;
  end check_profiler_objects;

begin

  dbms_output.new_line;
  dbms_output.new_line;
  dbms_output.new_line;

  dbms_output.put_line(
    'In 12.2c and beyond, the Oracle-supplied profload.sql script is a ' ||
    'verification script, not an installation script.');
  dbms_output.put_line('Testing for correct installation');
  if (check_profiler_objects) then
    if (profiler_version_check <> 0) then
      dbms_output.put('Version of package is incompatible.');
      dbms_output.put_line(' Deinstalling...');
      deinstall_profiler;
    end if;
  end if;
end;
/

set serveroutput off
