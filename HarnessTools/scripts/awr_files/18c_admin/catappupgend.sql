Rem
Rem $Header: rdbms/admin/catappupgend.sql /main/5 2017/09/29 14:04:55 pyam Exp $
Rem
Rem catappupgend.sql
Rem
Rem Copyright (c) 2015, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catappupgend.sql - End App Upgrade
Rem
Rem    DESCRIPTION
Rem      Ends upgrade of APP$CDB$CATALOG
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/catappupgend.sql 
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
Rem    pyam        12/16/16 - 24740425: disable module match check
Rem    pyam        11/10/16 - rename file, remove parameters
Rem    pyam        05/20/15 - cdb upgrade optimizations
Rem    pyam        05/19/15 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

alter session set "_enable_module_match"=false;

declare
  newvsn varchar2(30);
begin
  select tgtver into newvsn from fed$versions v, fed$apps a
    where a.app_status=2 and a.appid#=v.appid# and v.ver#=a.ver#+1
      and a.app_name='APP$CDB$CATALOG';
  execute immediate 'alter pluggable database application APP$CDB$CATALOG ' ||
                    'end upgrade';
exception
  when no_data_found then null;
  when others then
  if sqlcode in (-65090, -65212, -65214, -1403) then null;
  else raise;
  end if;
end;
/

alter system set "_enable_cdb_upgrade_capture"=false scope=memory;

@?/rdbms/admin/sqlsessend.sql
