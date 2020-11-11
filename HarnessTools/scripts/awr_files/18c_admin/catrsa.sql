Rem
Rem $Header: rdbms/admin/catrsa.sql /main/3 2017/10/25 18:01:32 raeburns Exp $
Rem
Rem catrsa.sql
Rem
Rem Copyright (c) 2014, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catrsa.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/catrsa.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/catrsa.sql
Rem    SQL_PHASE: CATRSA
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/catptabs.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    10/20/17 - RTI 20225108: correct SQL_PHASE
Rem    jlingow     12/02/15 - revoke inherit privileges on
Rem                           remote_scheduler_agent from public
Rem    jlingow     09/10/14 - proj-58146 Create the Remote Scheduler Agent User
Rem    jlingow     09/10/14 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

-- create a user to return results to the scheduler
declare
  already_exists exception;
  pragma exception_init(already_exists, -01920 );
begin
  execute immediate 
    ' create user remote_scheduler_agent identified by remote_scheduler_agent
      account lock password expire';
exception
  when already_exists then
    null;
end;
/

declare 
  already_revoked exception; 
  pragma exception_init(already_revoked,-01927); 
begin 
  execute immediate 
    ' REVOKE INHERIT PRIVILEGES ON USER REMOTE_SCHEDULER_AGENT FROM public '; 
exception 
  when already_revoked then 
    null; 
end; 
/ 

@?/rdbms/admin/sqlsessend.sql
