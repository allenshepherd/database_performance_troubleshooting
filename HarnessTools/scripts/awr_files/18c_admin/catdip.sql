rem
Rem $Header: rdbms/admin/catdip.sql /main/5 2014/02/20 12:45:46 surman Exp $
Rem
Rem catdip.sql
Rem
Rem Copyright (c) 2002, 2014, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catdip.sql - Creates a DIP account for provisioning event processing.
Rem
Rem    DESCRIPTION
Rem      Creates a generic user account DIP for processing events propagated
Rem      by DIP. This account would be used by all applications using
Rem      the DIP provisioning service when connecting to the database.
Rem
Rem    NOTES
Rem      Called from catproc.sql
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catdip.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catdip.sql
Rem SQL_PHASE: CATDIP
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catptabs.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    rpang       07/25/11 - Proj 32719: revoke inherit priv on dip
Rem    lburgess    03/27/06 - use lowercase for password 
Rem    srtata      01/22/03 - srtata_bug-2629661
Rem    srtata      12/17/02 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

create user DIP identified by dip password expire account lock;

grant create session to DIP;

Rem Revoke automatic grant of INHERIT PRIVILEGES from public
declare
  already_revoked exception;
  pragma exception_init(already_revoked,-01927);
begin
  execute immediate 'revoke inherit privileges on user DIP from public';
exception
  when already_revoked then
    null;
end;
/

@?/rdbms/admin/sqlsessend.sql
