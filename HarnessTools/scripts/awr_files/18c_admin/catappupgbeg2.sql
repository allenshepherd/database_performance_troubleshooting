Rem
Rem $Header: rdbms/admin/catappupgbeg2.sql /main/4 2017/09/29 14:04:55 pyam Exp $
Rem
Rem catappupgbeg2.sql
Rem
Rem Copyright (c) 2016, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catappupgbeg2.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/catappupgbeg2.sql
Rem    SQL_SHIPPED_FILE:
Rem    SQL_PHASE: INSTALL
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    SQL_CALLING_FILE:
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    pyam        09/27/17 - Bug 26856671: alter system with scope=memory
Rem    pyam        08/28/17 - Bug 25857770: set _enable_cdb_upgrade_capture
Rem                           only during upgrade
Rem    pyam        06/09/17 - RTI 19984265: catch no_data_found
Rem    pyam        11/17/16 - Catalog Application Upgrade Begin Part 2
Rem    pyam        11/17/16 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

alter system set "_enable_cdb_upgrade_capture"=true scope=memory;

-- issue begin upgrade
declare
  fromvsn varchar2(30);
  tovsn   varchar2(30);
  cdbroot number := 0;
begin
  select sys_context('USERENV','CON_ID') into cdbroot from dual;
  if (cdbroot = 1) then
    select tgtver into fromvsn from fed$versions v, fed$apps a
     where v.ver#=a.ver# and v.appid#=a.appid# and a.app_name='APP$CDB$CATALOG';
    select version into tovsn from v$instance;
    execute immediate 'alter pluggable database application APP$CDB$CATALOG ' ||
                      'begin upgrade ''' || fromvsn || ''' to ''' || tovsn || '''';
  end if;
exception
  when no_data_found then null;
  when others then
    if sqlcode in (-65090, -65212, -65221, -65251, -65213) then null;
    else raise;
    end if;
end;
/

@?/rdbms/admin/sqlsessend.sql
 
