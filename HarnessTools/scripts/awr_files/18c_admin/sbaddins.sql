Rem
Rem sbaddins.sql
Rem
Rem Copyright (c) 2006, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      sbaddins.sql - Standby Database Statistics Collection Add Instance
Rem
Rem    DESCRIPTION
Rem	 SQL*PLUS command file which adds a standby database instance
Rem      for performance data collection
Rem
Rem    NOTES
Rem      Must be run from standby perfstat owner, STDBYPERF
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/sbaddins.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/sbaddins.sql
Rem    SQL_PHASE: UTILITY
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    zhefan      07/08/15 - bug 21393238: Add tests for standby statspack
Rem    pmurthy     04/07/14 - To Fix Bug - 18531358
Rem    shsong      01/28/10 - remove v$lock_type
Rem    shsong      08/18/09 - add db_unique_name to stats$standby_config
Rem    shsong      03/04/07 - fix bug
Rem    wlohwass    12/04/06 - Created
Rem

set echo off;
whenever sqlerror exit;

spool sbaddins.lis

--
--  List configured standby instances
@@sblisins

prompt
prompt
prompt THE INSTANCE YOU ARE GOING TO ADD MUST BE ACCESSIBLE AND OPEN READ ONLY
prompt
prompt Do you want to continue (y/n) ?
prompt You entered: &&key

begin
  if upper('&&key') <> 'Y' then
    raise_application_error(-20101, 'Install failed - Aborted by user');
  end if;
end;
/

prompt
prompt
prompt Enter the TNS ALIAS that connects to the standby database instance
prompt ------------------------------------------------------------------

prompt Make sure the alias connects to only one instance (without load balancing).
prompt You entered: &&tns_alias

prompt
prompt
prompt Enter the PERFSTAT user's password of the standby database
prompt ----------------------------------------------------------

prompt You entered: &&perfstat_password

prompt
prompt ... Creating database link

create or replace procedure temp_procedure as
begin
execute immediate 'create database link stdby_link_&&tns_alias connect to perfstat identified by &&perfstat_password using ''&&tns_alias''';
end;
/

execute temp_procedure;

prompt
prompt ... Selecting database unique name
prompt
prompt ... Selecting instance name

create or replace procedure temp_procedure as
db_unique_name varchar2(30);
instance_name  varchar2(16);
begin
select db_unique_name into db_unique_name from v$database@stdby_link_&&tns_alias;
select instance_name into instance_name from v$instance@stdby_link_&&tns_alias;
insert into stats$standby_config values (db_unique_name, instance_name, 'STDBY_LINK_'||'&&tns_alias', 'STATSPACK_'||db_unique_name||'_'||instance_name);
commit;
end;
/

execute temp_procedure;

drop procedure temp_procedure;

commit;

-- get the package name 
 column pkg_name new_value pkg_name noprint;
 select package_name   pkg_name
  from stats$standby_config
 where db_link = 'STDBY_LINK_'||'&&tns_alias';

prompt
prompt
prompt ... Creating package
prompt

spool off;

--
-- Create statspack package
@@sbcpkg

undefine key tns_alias inst_name perfstat_password pkg_name db_unique_name


