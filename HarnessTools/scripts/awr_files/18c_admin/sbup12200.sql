Rem
Rem $Header: rdbms/admin/sbup12200.sql /main/1 2015/09/09 10:24:39 kchou Exp $
Rem
Rem sbup12200.sql
Rem
Rem Copyright (c) 2013, 2015, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      sbup12200.sql - Standby Statspack Upgrade Script 12.2.2.0
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    kchou       08/20/15 - Bug# 20459844, 2044566 - upgrade to DB 12.2
Rem    kchou       08/21/05 - Bug#s: 20459844, 20445666 Long Identifier object_alias type
Rem                            to varchar2(261) for DB 12.2 upgrade
Rem    zhefan      07/08/15 - bug 21393238: Add tests for standby statspack
Rem    zhefan      11/06/14 - Bug 19933671
Rem    kchou       11/07/13 - Bug#17504669:New Column remaster_type to
Rem                           V$DYNAMIC_REMASTER_STATS upgrade script 12.1.0.2
Rem    kchou       11/07/13 - Created
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/sbup12200.sql 
Rem    SQL_SHIPPED_FILE: 
Rem    SQL_PHASE: 
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: 
Rem    END SQL_FILE_METADATA

prompt
prompt Standby Statspack Upgrade script
prompt ~~~~~~~~~~~~~~~~~~~~~~~~
prompt
prompt Warning
prompt ~~~~~~~
prompt You MUST upgrade Primany Statspack to 12.1 schema before upgrading 
prompt the Standby Statspack. 
prompt
prompt Converting existing Standby Statspack data to 12.1 format may result in
prompt irregularities when reporting on pre-12.1 snapshot data.
prompt
prompt This script is provided for convenience, and is not guaranteed to
prompt work on all installations.  To ensure you will not lose any existing
prompt Statspack data, export the schema before upgrading.  A downgrade
prompt script is not provided.  
prompt
prompt Press return before continuing
prompt &&confirmation
prompt
prompt Usage
prompt ~~~~~
prompt -> Disable any programs which run Statspack (including any dbms_jobs),
prompt    before continuing, or this upgrade will fail.
prompt
prompt -> You MUST be connected as a user with SYSDBA privilege to successfully
prompt    run this script.
prompt
prompt -> You will be prompted for the STDBYPERF password, and for the
prompt    tablespace to create any new STDBYPERF tables/indexes.
prompt
prompt Press return before continuing
prompt &&confirmation

prompt
prompt Please specify the STDBYPERF password
prompt &&stdbyuser_password  

prompt
prompt Specify the tablespace to create any new SDTBYPERF tables and indexes
prompt Tablespace specified &&tablespace_name
prompt

connect stdbyperf/&&stdbyuser_password
spool sbup12200.lis

show user

set verify off
set serveroutput on size 4000

/* ------------------------------------------------------------------------- */
prompt
prompt
prompt Enter the TNS ALIAS that connects to the standby database instance
prompt ------------------------------------------------------------------

prompt Make sure the alias connects to only one instance (without load balancing).
prompt You entered: &&tns_alias

column inst_name heading "Instance"  new_value inst_name format a12;

prompt
prompt ... Selecting instance name 

select i.instance_name   inst_name
from v$instance@stdby_link_&&tns_alias i;

/* ------------------------------------------------------------------------- */
--
-- Bug# 17504669: Add New Column remaster_type to V$DYNAMIC_REMASTER_STATS
--


alter table STATS$DYNAMIC_REMASTER_STATS add
        (remaster_type varchar2(11) default 'AFFINITY' not null);

alter table STATS$DYNAMIC_REMASTER_STATS drop constraint
stats$dynamic_rem_stats_pk;

alter table STATS$DYNAMIC_REMASTER_STATS add constraint
stats$dynamic_rem_stats_pk
        primary key (snap_id, db_unique_name, instance_name, remaster_type);

commit;

/* ------------------------------------------------------------------------- */

prompt Note:
prompt Please check the log file of the package recreation, which is
prompt in the file sbcpkg.lis

spool off
/* ------------------------------------------------------------------------- */

-- get the package name 
column pkg_name new_value pkg_name noprint;
select package_name   pkg_name
  from stats$standby_config
where db_link = 'STDBY_LINK_'||'&&tns_alias';

--
-- Upgrade the package
@@sbcpkg

undefine tns_alias inst_name stdbyuser_password
--  End of Upgrade script



