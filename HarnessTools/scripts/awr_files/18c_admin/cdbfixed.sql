Rem
Rem $Header: rdbms/admin/cdbfixed.sql /main/1 2015/04/16 18:22:31 thbaby Exp $
Rem
Rem cdbfixed.sql
Rem
Rem Copyright (c) 2015, Oracle and/or its affiliates. All rights reserved.
Rem
Rem    NAME
Rem      cdbfixed.sql - Creation of CV$ Views
Rem
Rem    DESCRIPTION
Rem      Support for Creation of CV$ Views
Rem
Rem    NOTES
Rem      
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/cdbfixed.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/cdbfixed.sql
Rem    SQL_PHASE: CDBFIXED
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: NONE
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    thbaby      04/11/15 - 20869766: add CON$NAME, CDB$NAME to CV$ views
Rem    thbaby      03/31/15 - Support for CV$ views
Rem    thbaby      03/31/15 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

declare
  statement  varchar2(4000);
  cursor create_view_statement_cur is 
    select 'CREATE OR REPLACE VIEW CV$' || substr(table_name,4) || ' AS ' ||
           'SELECT k.*, k.CON$NAME, k.CDB$NAME FROM CONTAINERS(' || 
           synonym_name || ') k' as statement 
    from   dba_synonyms 
    where  synonym_name like 'V$%'
    and    table_name like 'V_$%';
  cursor grant_statement_cur is 
    select 'GRANT SELECT ON SYS.CV$' || substr(table_name,4) || ' TO ' ||
           'SELECT_CATALOG_ROLE' as statement 
    from   dba_synonyms 
    where  synonym_name like 'V$%'
    and    table_name like 'V_$%';
  cursor create_synonym_statement_cur is 
    select 'CREATE OR REPLACE PUBLIC SYNONYM CV$' || substr(table_name,4) || 
           ' FOR SYS.CV$' || substr(table_name,4) as statement 
    from   dba_synonyms 
    where  synonym_name like 'V$%'
    and    table_name like 'V_$%';
begin
  open  create_view_statement_cur;
  loop
    fetch create_view_statement_cur into statement;
    exit when create_view_statement_cur%NOTFOUND;
    if statement is not NULL then 
      -- dbms_output.put_line(statement);
      execute immediate statement;
    end if;
  end loop;
  close create_view_statement_cur;

  open  grant_statement_cur;
  loop
    fetch grant_statement_cur into statement;
    exit when grant_statement_cur%NOTFOUND;
    if statement is not NULL then 
      -- dbms_output.put_line(statement);
      -- execute immediate statement;
    end if;
  end loop;
  close grant_statement_cur;

  open  create_synonym_statement_cur;
  loop
    fetch create_synonym_statement_cur into statement;
    exit when create_synonym_statement_cur%NOTFOUND;
    if statement is not NULL then 
      -- dbms_output.put_line(statement);
      execute immediate statement;
    end if;
  end loop;
  close create_synonym_statement_cur;
end;
/

@?/rdbms/admin/sqlsessend.sql
