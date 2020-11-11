Rem
Rem $Header: rdbms/admin/xspatch.sql /main/2 2017/05/28 22:46:14 stanaya Exp $
Rem
Rem xspatch.sql
Rem
Rem Copyright (c) 2010, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      xspatch.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/xspatch.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/xspatch.sql
Rem    SQL_PHASE: UTILITY
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    yiru        06/17/10 - Created
Rem

-- fix for lrg 4720543
-- Remove PREDICATE index
begin
  execute immediate 'drop index xdb.prin_xidx';
exception
  when others then
  NULL;
end;
/

begin
  execute immediate 'drop index xdb.sc_xidx';
exception
  when others then
  NULL;
end;
/

