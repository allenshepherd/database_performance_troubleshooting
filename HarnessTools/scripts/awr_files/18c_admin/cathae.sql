Rem
Rem $Header: rdbms/admin/cathae.sql /main/10 2014/02/20 12:45:50 surman Exp $
Rem
Rem cathae.sql
Rem
Rem Copyright (c) 2004, 2014, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      cathae.sql - Catalog changes for HA Event notification
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/cathae.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/cathae.sql
Rem SQL_PHASE: CATHAE
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catptabs.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    talliu      06/28/13 - Add CDB view for DBA view
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    kneel       05/31/06 - support upgrade 
Rem    kneel       04/05/06 - support critical alerts in kjhn 
Rem    aahluwal    05/10/05 - [Bug 4351043]: restrict HAE_SUB rule to HA 
Rem                           message group only 
Rem    kneel       11/26/04 - lrg 1795216: duplicate jobs in logical standby 
Rem    kneel       11/09/04 - lrg 1795206 index key too long 
Rem    kneel       11/02/04 - Changing object and alert names 
Rem    kneel       10/14/04 - changing TIMESTAMP WITH TIMEZONE to TIMESTAMP 
Rem    kneel       10/07/04 - changing TIMESTAMP WITH LOCAL TIME ZONE columns 
Rem    kneel       10/04/04 - moving prvtkjhn.plb call to cathae.sql 
Rem    kneel       09/17/04 - making recent_resource_incarnations$ 
Rem                           index-organized 
Rem    kneel       09/16/04 - support for DataGuard standbys 
Rem    kneel       09/08/04 - define subscriber for instance down events 
Rem    kmeiyyap    07/21/04 - use internal add_subscriber API 
Rem    nikeda      07/05/04 - nikeda_oci_events_p3
Rem    aahluwal    06/28/04 - add rule for HAE_SUB 
Rem    kneel       06/25/04 - instance down alert reliability work 
Rem    aahluwal    06/23/04 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql


rem =============================================================
rem table used to track resource incarnations and ensure clients
rem receive notification of resource incarnation death
rem =============================================================
CREATE TABLE recent_resource_incarnations$
( resource_type    varchar2(30),
  resource_id      number,
  resource_name    varchar2(256),
  db_unique_name   varchar2(30),
  db_domain        varchar2(128),
  instance_name    varchar2(30),
  host_name        varchar2(512),
  location         varchar2(512),
  incarnation      varchar2(30),
  startup_time     timestamp(9),
  shutdown_time    timestamp(9),
  description      varchar2(4000),
  CONSTRAINT recent_resource_incarnations$p PRIMARY KEY (
   resource_type, db_domain, db_unique_name, instance_name,
   incarnation, startup_time)
)
ORGANIZATION INDEX
OVERFLOW TABLESPACE sysaux
/
comment on column recent_resource_incarnations$.STARTUP_TIME is
'Resource startup date and time in universal time (UTC)'
/
comment on column recent_resource_incarnations$.SHUTDOWN_TIME is
'Resource shutdown date and time in universal time (UTC)'
/

create or replace view DBA_RESOURCE_INCARNATIONS
as select RESOURCE_TYPE, RESOURCE_NAME,
          DB_UNIQUE_NAME, DB_DOMAIN, INSTANCE_NAME, HOST_NAME,
          from_tz(STARTUP_TIME, '+00:00') at local as STARTUP_TIME
     from RECENT_RESOURCE_INCARNATIONS$
/
comment on table DBA_RESOURCE_INCARNATIONS is
'Resource incarnations that are running or eligible for HA status notification'
/
comment on column DBA_RESOURCE_INCARNATIONS.RESOURCE_TYPE is
'Resource type'
/
comment on column DBA_RESOURCE_INCARNATIONS.RESOURCE_NAME is
'Resource name'
/
comment on column DBA_RESOURCE_INCARNATIONS.DB_UNIQUE_NAME is
'Databae unique name'
/
comment on column DBA_RESOURCE_INCARNATIONS.DB_DOMAIN is
'Database domain'
/
comment on column DBA_RESOURCE_INCARNATIONS.INSTANCE_NAME is
'Name of instance at which resource is located'
/
comment on column DBA_RESOURCE_INCARNATIONS.HOST_NAME is
'Name of host at which resource is located'
/
comment on column DBA_RESOURCE_INCARNATIONS.STARTUP_TIME is
'Resource startup date and time'
/
create or replace public synonym DBA_RESOURCE_INCARNATIONS
  for sys.DBA_RESOURCE_INCARNATIONS
/
grant select on DBA_RESOURCE_INCARNATIONS to select_catalog_role
/



execute CDBView.create_cdbview(false,'SYS','DBA_RESOURCE_INCARNATIONS','CDB_RESOURCE_INCARNATIONS');
grant select on SYS.CDB_RESOURCE_INCARNATIONS to select_catalog_role
/
create or replace public synonym CDB_RESOURCE_INCARNATIONS for SYS.CDB_RESOURCE_INCARNATIONS
/


@?/rdbms/admin/sqlsessend.sql
