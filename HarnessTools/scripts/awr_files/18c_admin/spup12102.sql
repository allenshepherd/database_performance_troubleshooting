Rem
Rem $Header: rdbms/admin/spup12102.sql /main/2 2015/07/28 06:30:19 zhefan Exp $
Rem
Rem spup12102.sql
Rem
Rem Copyright (c) 2013, 2015, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      spup12102.sql - Statspack Upgrade Script 12.1.0.2
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    zhefan      07/08/15 - bug 21393238: Add tests for standby statspack
Rem    kchou       11/07/13 - Bug#17504669:New Column remaster_type to
Rem                           V$DYNAMIC_REMASTER_STATS upgrade script 12.1.0.2
Rem    kchou       11/07/13 - Created
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/spup12102.sql 
Rem    SQL_SHIPPED_FILE: 
Rem    SQL_PHASE: 
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: 
Rem    END SQL_FILE_METADATA



prompt
prompt Statspack Upgrade script
prompt ~~~~~~~~~~~~~~~~~~~~~~~~
prompt
prompt Warning
prompt ~~~~~~~
prompt Converting existing Statspack data to 12.1 format may result in
prompt irregularities when reporting on pre-12.1 snapshot data.
prompt
prompt This script is provided for convenience, and is not guaranteed to
prompt work on all installations.  To ensure you will not lose any existing
prompt Statspack data, export the schema before upgrading.  A downgrade
prompt script is not provided.  Please see spdoc.txt for more details.
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
prompt -> You will be prompted for the PERFSTAT password, and for the
prompt    tablespace to create any new PERFSTAT tables/indexes.
prompt
prompt Press return before continuing
prompt &&confirmation

prompt
prompt Please specify the PERFSTAT password
prompt &&perfstat_password

spool spup12102a.lis

/* ------------------------------------------------------------------------- */

prompt Note:
prompt Please check remainder of upgrade log file, which is continued in
prompt the file spup11201b.lis

spool off
connect perfstat/&&perfstat_password

spool spup12102b.lis

show user
set verify off
set serveroutput on size 4000

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
        primary key (snap_id, dbid, instance_number, remaster_type);

commit;

/* ------------------------------------------------------------------------- */

prompt Note:
prompt Please check the log file of the package recreation, which is
prompt in the file spcpkg.lis

spool off

/* ------------------------------------------------------------------------- */

--
-- Upgrade the package
@@spcpkg

--  End of Upgrade script
