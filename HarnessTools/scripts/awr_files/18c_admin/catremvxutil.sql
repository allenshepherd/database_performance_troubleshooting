Rem
Rem $Header: rdbms/admin/catremvxutil.sql /main/2 2014/02/20 12:45:43 surman Exp $
Rem
Rem catremvxutil.sql
Rem
Rem Copyright (c) 2011, 2014, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catremvxutil.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catremvxutil.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catremvxutil.sql
Rem SQL_PHASE: CATREMVXUTIL
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catxdbv.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    surman      01/23/14 - 13922626: Update SQL metadata
Rem    bhammers    07/25/11 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100

begin
  execute immediate 'drop public synonym DBA_XML_SCHEMA_NAMESPACES';
exception
  when others then
    commit;
end;
/

begin
  execute immediate 'drop  public synonym ALL_XML_SCHEMA_NAMESPACES';
exception
  when others then
    commit;
end;
/

begin
  execute immediate 'drop public synonym USER_XML_SCHEMA_NAMESPACES';
exception
  when others then
    commit;
end;
/

begin
  execute immediate 'drop public synonym DBA_XML_SCHEMA_ELEMENTS';
exception
  when others then
    commit;
end;
/

begin
  execute immediate 'drop public synonym ALL_XML_SCHEMA_ELEMENTS';
exception
  when others then
    commit;
end;
/

begin
  execute immediate 'drop public synonym USER_XML_SCHEMA_ELEMENTS';
exception
  when others then
    commit;
end;
/

begin
  execute immediate 'drop public synonym DBA_XML_SCHEMA_SUBSTGRP_MBRS';
exception
  when others then
    commit;
end;
/

begin
  execute immediate 'drop public synonym ALL_XML_SCHEMA_SUBSTGRP_MBRS';
exception
  when others then
    commit;
end;
/

begin
  execute immediate 'drop public synonym USER_XML_SCHEMA_SUBSTGRP_MBRS';
exception
  when others then
    commit;
end;
/

begin
  execute immediate 'drop public synonym DBA_XML_SCHEMA_SUBSTGRP_HEAD';
exception
  when others then
    commit;
end;
/

begin
  execute immediate 'drop public synonym ALL_XML_SCHEMA_SUBSTGRP_HEAD';
exception
  when others then
    commit;
end;
/

begin
  execute immediate 'drop public synonym USER_XML_SCHEMA_SUBSTGRP_HEAD';
exception
  when others then
    commit;
end;
/

begin
  execute immediate 'drop public synonym DBA_XML_SCHEMA_COMPLEX_TYPES';
exception
  when others then
    commit;
end;
/

begin
  execute immediate 'drop public synonym ALL_XML_SCHEMA_COMPLEX_TYPES';
exception
  when others then
    commit;
end;
/


begin
  execute immediate 'drop public synonym USER_XML_SCHEMA_COMPLEX_TYPES';
exception
  when others then
    commit;
end;
/

begin
  execute immediate 'drop public synonym DBA_XML_SCHEMA_SIMPLE_TYPES';
exception
  when others then
    commit;
end;
/

begin
  execute immediate 'drop public synonym ALL_XML_SCHEMA_SIMPLE_TYPES';
exception
  when others then
    commit;
end;
/

begin
  execute immediate 'drop public synonym USER_XML_SCHEMA_SIMPLE_TYPES';
exception
  when others then
    commit;
end;
/

begin
  execute immediate 'drop public synonym DBA_XML_SCHEMA_ATTRIBUTES';
exception
  when others then
    commit;
end;
/

begin
  execute immediate 'drop public synonym ALL_XML_SCHEMA_ATTRIBUTES';
exception
  when others then
    commit;
end;
/

begin
  execute immediate 'drop public synonym USER_XML_SCHEMA_ATTRIBUTES';
exception
  when others then
    commit;
end;
/

begin
  execute immediate 'drop public synonym DBA_XML_OUT_OF_LINE_TABLES';
exception
  when others then
    commit;
end;
/

begin
  execute immediate 'drop public synonym ALL_XML_OUT_OF_LINE_TABLES';
exception
  when others then
    commit;
end;
/

begin
  execute immediate 'drop public synonym USER_XML_OUT_OF_LINE_TABLES';
exception
  when others then
    commit;
end;
/

begin
  execute immediate 'drop public synonym  DBA_XMLTYPE_COLS';
exception
  when others then
    commit;
end;
/

begin
  execute immediate 'drop public synonym ALL_XMLTYPE_COLS';
exception
  when others then
    commit;
end;
/

begin
  execute immediate 'drop public synonym USER_XMLTYPE_COLS';
exception
  when others then
    commit;
end;
/

begin
  execute immediate 'drop public synonym DBA_XML_NESTED_TABLES';
exception
  when others then
    commit;
end;
/

begin
  execute immediate 'drop public synonym ALL_XML_NESTED_TABLES';
exception
  when others then
    commit;
end;
/

begin
  execute immediate 'drop public synonym USER_XML_NESTED_TABLES';
exception
  when others then
    commit;
end;
/



begin
  execute immediate 'drop view USER_XML_SCHEMA_NAMESPACES';
exception
  when others then
    commit;
end;
/

begin
  execute immediate 'drop view ALL_XML_SCHEMA_NAMESPACES';
exception
  when others then
    commit;
end;
/

begin
  execute immediate 'drop view DBA_XML_SCHEMA_NAMESPACES';
exception
  when others then
    commit;
end;
/


begin
  execute immediate 'drop view USER_XML_SCHEMA_ELEMENTS';
exception
  when others then
    commit;
end;
/

begin
  execute immediate 'drop view ALL_XML_SCHEMA_ELEMENTS';
exception
  when others then
    commit;
end;
/

begin
  execute immediate 'drop view DBA_XML_SCHEMA_ELEMENTS';
exception
  when others then
    commit;
end;
/


begin
  execute immediate 'drop view USER_XML_SCHEMA_SUBSTGRP_MBRS';
exception
  when others then
    commit;
end;
/

begin
  execute immediate 'drop view ALL_XML_SCHEMA_SUBSTGRP_MBRS';
exception
  when others then
    commit;
end;
/
begin
  execute immediate 'drop view DBA_XML_SCHEMA_SUBSTGRP_MBRS';
exception
  when others then
    commit;
end;
/



begin
  execute immediate 'drop view USER_XML_SCHEMA_SUBSTGRP_HEAD';
exception
  when others then
    commit;
end;
/

begin
  execute immediate 'drop view ALL_XML_SCHEMA_SUBSTGRP_HEAD';
exception
  when others then
    commit;
end;
/

begin
  execute immediate 'drop view DBA_XML_SCHEMA_SUBSTGRP_HEAD';
exception
  when others then
    commit;
end;
/


begin
  execute immediate 'drop view USER_XML_SCHEMA_COMPLEX_TYPES';
exception
  when others then
    commit;
end;
/

begin
  execute immediate 'drop view ALL_XML_SCHEMA_COMPLEX_TYPES';
exception
  when others then
    commit;
end;
/

begin
  execute immediate 'drop view DBA_XML_SCHEMA_COMPLEX_TYPES';
exception
  when others then
    commit;
end;
/



begin
  execute immediate 'drop view USER_XML_SCHEMA_SIMPLE_TYPES';
exception
  when others then
    commit;
end;
/

begin
  execute immediate 'drop view ALL_XML_SCHEMA_SIMPLE_TYPES';
exception
  when others then
    commit;
end;
/

begin
  execute immediate 'drop view DBA_XML_SCHEMA_SIMPLE_TYPES';
exception
  when others then
    commit;
end;
/



begin
  execute immediate 'drop view USER_XML_SCHEMA_ATTRIBUTES';
exception
  when others then
    commit;
end;
/

begin
  execute immediate 'drop view ALL_XML_SCHEMA_ATTRIBUTES';
exception
  when others then
    commit;
end;
/

begin
  execute immediate 'drop view DBA_XML_SCHEMA_ATTRIBUTES';
exception
  when others then
    commit;
end;
/



begin
  execute immediate 'drop view USER_XML_OUT_OF_LINE_TABLES';
exception
  when others then
    commit;
end;
/

begin
  execute immediate 'drop view ALL_XML_OUT_OF_LINE_TABLES';
exception
  when others then
    commit;
end;
/

begin
  execute immediate 'drop view DBA_XML_OUT_OF_LINE_TABLES';
exception
  when others then
    commit;
end;
/



begin
  execute immediate 'drop view USER_XMLTYPE_COLS';
exception
  when others then
    commit;
end;
/

begin
  execute immediate 'drop view ALL_XMLTYPE_COLS';
exception
  when others then
    commit;
end;
/

begin
  execute immediate 'drop view DBA_XMLTYPE_COLS';
exception
  when others then
    commit;
end;
/



begin
  execute immediate 'drop view USER_XML_NESTED_TABLES';
exception
  when others then
    commit;
end;
/

begin
  execute immediate 'drop view ALL_XML_NESTED_TABLES';
exception
  when others then
    commit;
end;
/

begin
  execute immediate 'drop view DBA_XML_NESTED_TABLES';
exception
  when others then
    commit;
end;
/



begin
  execute immediate 'drop TYPE PARENTIDARRAY force';
exception
  when others then
    commit;
end;
/

begin
  execute immediate 'drop PACKAGE PrvtParentChild';
exception
  when others then
    commit;
end;
/

@?/rdbms/admin/sqlsessend.sql
