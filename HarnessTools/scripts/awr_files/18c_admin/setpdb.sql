Rem
Rem $Header: rdbms/admin/setpdb.sql /main/2 2017/01/03 12:58:11 jaeblee Exp $
Rem
Rem setpdb.sql
Rem
Rem Copyright (c) 2016, Oracle and/or its affiliates. All rights reserved.
Rem
Rem    NAME
Rem      setpdb.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/setpdb.sql 
Rem    SQL_SHIPPED_FILE:rdbms/admin/setpdb.sql  
Rem    SQL_PHASE: SETPDB
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    jaeblee     12/21/16 - 25295968: only create trigger in CDB$ROOT
Rem    krajaman    03/24/16 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

begin
  if (sys_context('USERENV', 'CON_NAME') = 'CDB$ROOT')
  then
    execute immediate
      'create or replace trigger sys.dbms_set_pdb sharing=none after logon on database
       when (user = ''SYS'' or user = ''SYSTEM'')
         declare
         pdb_name varchar2(64);
         begin
           DBMS_SYSTEM.get_env (''ORACLE_PDB_SID'', pdb_name);
           if(pdb_name is not null)
            then
              EXECUTE IMMEDIATE ''alter session set container = '' || pdb_name;
            end if;
         exception
           when others then
           NULL;
         end dbms_set_pdb;';
  end if;
end;
/

show errors;

@?/rdbms/admin/sqlsessend.sql
