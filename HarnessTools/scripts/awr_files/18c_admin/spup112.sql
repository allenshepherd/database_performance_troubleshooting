Rem
Rem $Header: rdbms/admin/spup112.sql /main/5 2017/05/28 22:46:11 stanaya Exp $
Rem
Rem spup112.sql
Rem
Rem Copyright (c) 2012, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      spup112.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/spup112.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/spup112.sql
Rem    SQL_PHASE: UTILITY
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    zhefan      11/06/14 - Bug #19933671
Rem    pmurthy     02/05/14 - To Fix STATSPACK Bug - 18159090
Rem    pmurthy     02/20/14 - To Fix Bug - 18284201 and 18273117
Rem    kchou       09/05/12 - Bug#14380383: 12.1 spdoc.txt update
Rem    kchou       09/05/12 - Bug#14380383 11.2 to 12.1 Upgrade spup112.sql
Rem    kchou       09/05/12 - Created
Rem

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
accept confirmation prompt "Press return before continuing ";
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
accept confirmation prompt "Press return before continuing ";

prompt
prompt Please specify the PERFSTAT password
prompt &&perfstat_password

spool spup112a.lis

/* ------------------------------------------------------------------------- */

prompt Note:
prompt Please check remainder of upgrade log file, which is continued in
prompt the file spup112b.lis

spool off

-- Added the Below Code to Fix Bug - 18159090
-- --------------------------------------------------------------
grant select on V_$IOSTAT_FUNCTION_DETAIL    to PERFSTAT;
-- --------------------------------------------------------------

connect perfstat/&&perfstat_password

spool spup112b.lis

show user
set verify off
set serveroutput on size 4000

/* ------------------------------------------------------------------------- */

--
-- Add any new idle events, and Statspack Levels  
-- 8/10/2010  KCHOU  11.2.0.2 MISSING IDLE EVENTS
--
/*------------------------------------------------------------*/
/* 8/11/2010 Bug#9800868 Add Missing Idle Events for 11.2.0.2 */
/*------------------------------------------------------------*/
insert into STATS$IDLE_EVENT (event) values ('GCR sleep');
insert into STATS$IDLE_EVENT (event) values ('LogMiner builder: branch');
insert into STATS$IDLE_EVENT (event) values ('LogMiner builder: idle');
insert into STATS$IDLE_EVENT (event) values ('LogMiner client: transaction');
insert into STATS$IDLE_EVENT (event) values ('LogMiner preparer: idle');
insert into STATS$IDLE_EVENT (event) values ('parallel recovery control message reply');
/*--------------------------------------*/
/* 21/02/2014 Bug#18284201 and 18273117 */
/* Add Missing Idle Events for 11.2.0.4 */
/*--------------------------------------*/
insert into STATS$IDLE_EVENT (event) values ('virtual circuit next request');
/*--------------------------------------*/
/* 21/02/2014 Bug#18284201 and 18273117 */
/* Add Missing Idle Events for 12.1.0.1 */
/*--------------------------------------*/
insert into STATS$IDLE_EVENT (event) values ('AQ Cross Master idle');
insert into STATS$IDLE_EVENT (event) values ('AQ: 12c message cache init wait');
insert into STATS$IDLE_EVENT (event) values ('AQPC idle');
insert into STATS$IDLE_EVENT (event) values ('Emon coordinator main loop');
insert into STATS$IDLE_EVENT (event) values ('Emon slave main loop');
insert into STATS$IDLE_EVENT (event) values ('LGWR worker group idle');
insert into STATS$IDLE_EVENT (event) values ('OFS idle');
insert into STATS$IDLE_EVENT (event) values ('REPL Apply: txns');
insert into STATS$IDLE_EVENT (event) values ('REPL Capture/Apply: RAC AQ qmn coordinator');
insert into STATS$IDLE_EVENT (event) values ('REPL Capture/Apply: messages');
insert into STATS$IDLE_EVENT (event) values ('REPL Capture: archive log');
insert into STATS$IDLE_EVENT (event) values ('Recovery Server Comm SGA setup wait');
insert into STATS$IDLE_EVENT (event) values ('Recovery Server Servlet wait');
insert into STATS$IDLE_EVENT (event) values ('Recovery Server Surrogate wait');
insert into STATS$IDLE_EVENT (event) values ('Recovery Server waiting for work');
insert into STATS$IDLE_EVENT (event) values ('Recovery Server waiting restore start');
insert into STATS$IDLE_EVENT (event) values ('Sharded  Queues : Part Maintenance idle');
insert into STATS$IDLE_EVENT (event) values ('Streams AQ: load balancer idle');
insert into STATS$IDLE_EVENT (event) values ('gopp msggopp msg');
insert into STATS$IDLE_EVENT (event) values ('heartbeat redo informer');
insert into STATS$IDLE_EVENT (event) values ('iowp file id');
insert into STATS$IDLE_EVENT (event) values ('iowp msg');
insert into STATS$IDLE_EVENT (event) values ('lreg timer');
insert into STATS$IDLE_EVENT (event) values ('netp network');
insert into STATS$IDLE_EVENT (event) values ('parallel recovery coordinator idle wait');
insert into STATS$IDLE_EVENT (event) values ('recovery merger idle wait');
insert into STATS$IDLE_EVENT (event) values ('recovery receiver idle wait');
insert into STATS$IDLE_EVENT (event) values ('recovery sender idle wait');
/*--------------------------------------*/
/* 21/02/2014 Bug#18284201 and 18273117 */
/* Add Missing Idle Events for 12.1.0.2 */
/*--------------------------------------*/
insert into STATS$IDLE_EVENT (event) values ('imco timer');
insert into STATS$IDLE_EVENT (event) values ('process in prespawned state');
commit;

/*------------------------------------------------------------*/
/* Bug#19933671 - Release 12.0 has increased size of column   */
/* 'pool' in V$SGASTAT to 14 from 12. When an 11.2 database   */
/* is upgraded to 12, we need to increase size of column      */
/* 'pool' in STATS$SGASTAT to 14 to avoid runtime problem.    */
/*------------------------------------------------------------*/
ALTER TABLE STATS$SGASTAT MODIFY pool varchar2(14);
commit;

create table STATS$IOSTAT_FUNCTION_DETAIL
(snap_id number not null
,dbid number not null
,instance_number number not null
,func_id number
,func_name varchar2(20)
,filetyp_id number
,filetyp_name varchar2(30)
,smallrd_MB number
,smallwt_MB number
,largerd_MB number
,largewt_MB number
,num_waits number
,wait_time number
,constraint STATS$IOSTAT_FUNC_PK primary key
(snap_id, dbid, instance_number, func_id, filetyp_id)
using index
storage (initial 1m next 1m pctincrease 0)
,constraint STATS$IOSTAT_FUNC_FK foreign key
(snap_id, dbid, instance_number)
references STATS$SNAPSHOT on delete cascade)
storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;

create public synonym  STATS$IOSTAT_FUNCTION_DETAIL for STATS$IOSTAT_FUNCTION_DETAIL;
commit;
-- --------------------------------------------------------------

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
