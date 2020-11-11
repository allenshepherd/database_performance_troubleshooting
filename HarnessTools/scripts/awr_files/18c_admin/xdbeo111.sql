Rem
Rem $Header: rdbms/admin/xdbeo111.sql /main/9 2017/04/27 17:09:45 raeburns Exp $
Rem
Rem xdbeo111.sql
Rem
Rem Copyright (c) 2007, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      xdbeo111.sql - XDB downgradE Drop objects for downgrade to 11.1
Rem
Rem    DESCRIPTION
Rem      This script drops objects and performs other downgrade actions
Rem      that would invalidate other objects used during the XDB
Rem      downgrade processing.
Rem
Rem    NOTES
Rem      
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/xdbeo111.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/xdbeo111.sql 
Rem    SQL_PHASE: DOWNGRADE
Rem    SQL_STARTUP_MODE: DOWNGRADE 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/xdbe111.sql 
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    04/15/17 - Bug 25790192: Use DOWNGRADE for SQL_PHASE
Rem    qyu         07/25/16 - add file metadata
Rem    qyu         07/16/12 - drop GETXMLSCHEMADEPENDENCYLIST added in 11202
Rem    juding      07/29/11 - bug 12622803: invoke xdbeo112.sql
Rem    spetride    01/22/10 - drop DBA_XML_SCHEMA_DEPENDENCY 
Rem    achoi       11/13/08 - lrg3678340: move xdb_pi_trig to SYS
Rem    sipatel     09/29/08 - bug 7414934. drop Structured XMLIndex tables
Rem    sichandr    09/23/08 - drop XDB$REPOS tables
Rem    rburns      11/08/07 - drop objects for XDB
Rem    rburns      11/08/07 - Created

Rem ================================================================
Rem BEGIN XDB Object downgrade to 11.2.0
Rem ================================================================

-- uncomment for next release
@@xdbeo112.sql

Rem ================================================================
Rem END XDB Object downgrade to 11.2.0
Rem ================================================================

Rem ================================================================
Rem BEGIN XDB Object downgrade to 11.1.0
Rem ================================================================

Rem Drop XMLIdxStatsMethods
disassociate statistics from indextypes XDB.XMLIndex force;
drop type xdb.XMLIdxStatsMethods force;

Rem Drop Structured XMLIndex Tables (revert catxtbix)
begin
  execute immediate 'drop package XDB.xtimetadata_pkg force';
exception
  when others then null;
end;
/

begin
  execute immediate 'drop library XDB.xmltableindex_lib force';
exception
  when others then null;
end;
/

begin
  execute immediate
   'drop table xdb.xdb$xtabcols force';
exception
  when others then null;
end;
/

begin
  execute immediate
   'drop table xdb.xdb$xtabnmsp force';
exception
  when others then null;
end;
/

begin
  execute immediate
   'drop table xdb.xdb$xtab force';
exception
  when others then null;
end;
/

Rem Drop repository metadata tables
revoke execute on xdb.xdb$nlocks_t from public;

drop table xdb.xdb$mounts;
drop table xdb.xdb$repos;
drop trigger sys.xdb_pi_trig;

set serveroutput on
declare
   err_msg VARCHAR2(256);
begin
  begin
    execute immediate 'drop public synonym DBA_XMLSCHEMA_LEVEL_VIEW';
    exception
      when others then 
        if (SQLCODE != -1432) then
          err_msg := SUBSTR(SQLERRM, 1, 256);
          dbms_output.put_line('XDBNB: synonym DBA_XMLSCHEMA_LEVEL_VIEW not dropped'); 
          dbms_output.put_line(err_msg);
        end if;
  end;
  begin
    execute immediate 'drop view SYS.DBA_XMLSCHEMA_LEVEL_VIEW';
    exception
      when others then 
        if (SQLCODE != -942) then
          err_msg := SUBSTR(SQLERRM, 1, 256);
          dbms_output.put_line('XDBNB: view SYS.DBA_XMLSCHEMA_LEVEL_VIEW not dropped'); 
          dbms_output.put_line(err_msg);
        end if;
  end;
  begin
    execute immediate 'drop view SYS.DBA_XMLSCHEMA_LEVEL_VIEW_DUP';
    exception
      when others then 
        if (SQLCODE != -942) then
          err_msg := SUBSTR(SQLERRM, 1, 256);
          dbms_output.put_line('XDBNB: view SYS.DBA_XMLSCHEMA_LEVEL_VIEW_DUP not dropped'); 
          dbms_output.put_line(err_msg);
        end if;
  end;
  begin
    execute immediate 'drop public synonym DBA_XML_SCHEMA_DEPENDENCY';
    exception
      when others then 
        if (SQLCODE != -1432) then
          err_msg := SUBSTR(SQLERRM, 1, 256);
          dbms_output.put_line('XDBNB: synonym DBA_XML_SCHEMA_DEPENDENCY not dropped'); 
          dbms_output.put_line(err_msg);
        end if;
  end;
  begin
    execute immediate 'drop view SYS.DBA_XML_SCHEMA_DEPENDENCY';
    exception
      when others then
        if (SQLCODE != -942) then
          err_msg := SUBSTR(SQLERRM, 1, 256);
          dbms_output.put_line('XDBNB: view SYS.DBA_XML_SCHEMA_DEPENDENCY not dropped'); 
          dbms_output.put_line(err_msg);
        end if;
  end;
  begin
    execute immediate 'drop public synonym DBA_XML_SCHEMA_IMPORTS';
    exception
      when others then
        if (SQLCODE != -1432) then
          err_msg := SUBSTR(SQLERRM, 1, 256);
          dbms_output.put_line('XDBNB: synonym DBA_XML_SCHEMA_IMPORTS not dropped'); 
          dbms_output.put_line(err_msg);
        end if;
  end;
  begin
    execute immediate 'drop view SYS.DBA_XML_SCHEMA_IMPORTS';
    exception
      when others then
        if (SQLCODE != -942) then
          err_msg := SUBSTR(SQLERRM, 1, 256);
          dbms_output.put_line('XDBNB: view SYS.DBA_XML_SCHEMA_IMPORTS not dropped'); 
          dbms_output.put_line(err_msg);
        end if;
  end;
  begin
    execute immediate 'drop public synonym DBA_XML_SCHEMA_INCLUDES';
    exception
      when others then
        if (SQLCODE != -1432) then
          err_msg := SUBSTR(SQLERRM, 1, 256);
          dbms_output.put_line('XDBNB: synonym DBA_XML_SCHEMA_INCLUDES not dropped'); 
          dbms_output.put_line(err_msg);
        end if;
  end;
  begin
    execute immediate 'drop view SYS.DBA_XML_SCHEMA_INCLUDES';
    exception
      when others then 
        if (SQLCODE != -942) then
          err_msg := SUBSTR(SQLERRM, 1, 256);
          dbms_output.put_line('XDBNB: view SYS.DBA_XML_SCHEMA_INCLUDES not dropped'); 
          dbms_output.put_line(err_msg);
        end if;
  end;
end;
/
set serveroutput off

Rem drop function 
revoke execute on sys.getXMLSchemaDependencyList from public;
begin
  execute immediate 'drop function sys.getXMLSchemaDependencyList';
exception
  when others then null;
end;
/

Rem ================================================================
Rem END XDB Object downgrade to 11.1.0
Rem ================================================================





