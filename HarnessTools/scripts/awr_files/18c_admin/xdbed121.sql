Rem
Rem $Header: rdbms/admin/xdbed121.sql /main/6 2017/04/04 09:12:44 raeburns Exp $
Rem
Rem xdbed121.sql
Rem
Rem Copyright (c) 2013, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      xdbed121.sql - XDB Dependent Object Downgrade to 12.1
Rem
Rem    DESCRIPTION
Rem      This script downgrades XDB user data to 12.1.0
Rem
Rem    NOTES
Rem      This script is invoked from xdbe121.sql and from xdbed112.sql
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/xdbed121.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/xdbed121.sql 
Rem    SQL_PHASE: DOWNGRADE 
Rem    SQL_STARTUP_MODE: DOWNGRADE
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/xdbdwgrd.sql 
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    03/25/17 - Bug 25752691: Use SQL_PHASE DOWNGRADE
Rem    qyu         11/10/16 - invoke xdbed122.sql
Rem    hxzhang     09/27/16 - bug 24706168,Rather than delete and reregister
Rem                           schemas, use convert_to_local
Rem    hxzhang     09/09/16 - bug#24618516, drop and register XDB schemas
Rem    qyu         07/25/16 - add file metadata
Rem    raeburns    05/22/14 - drop obsolete migr9202status table
Rem    raeburns    11/04/13 - XDB 12.1 downgrade
Rem    raeburns    11/04/13 - Created

Rem ================================================================
Rem BEGIN XDB Dependent Object downgrade to 12.2.0
Rem ================================================================

@@xdbed122.sql

Rem ================================================================
Rem END XDB Dependent Object downgrade to 12.2.0
Rem ================================================================

Rem ================================================================
Rem BEGIN XDB Dependent Object downgrade to 12.1.0
Rem ================================================================

-- If we are downgrading a PDB, convert all xml schema related objects to
-- local (as they were in 12.1.0.2).
--

DECLARE
   con_id    VARCHAR2(100);
   con_name  VARCHAR2(128);
   stmt      VARCHAR2(1000);
   obj_name  VARCHAR2(128);
   namespace NUMBER;
   type      cursor_type is ref cursor;
   query_crs cursor_type;

BEGIN

  con_id := sys_context('USERENV', 'CON_ID');
  con_name := sys_context('USERENV', 'CON_NAME');
  if (con_id <> 0) AND (con_name <> 'CDB$ROOT') then
    stmt := ' select object_name, namespace from dba_objects ' ||
            ' where owner = ''XDB'' and OBJECT_TYPE =''TYPE''' ||
            ' and SHARING = ''METADATA LINK'''  ||
            ' and (object_name like ''%Typ'' )';

    open query_crs for stmt;
    loop
      fetch query_crs into obj_name, namespace;
      exit when query_crs%NOTFOUND ;

      begin
        sys.dbms_pdb.convert_to_local('XDB', obj_name, namespace);

      exception when others then
        null;
      end;
    end loop;
    close query_crs;
  end if;
END;
/

Rem Restore migrate status table for 11.1 downgrade
Rem xdbuuc4.sql, invoked from xdbes111.sql, has PL/SQL functions 
Rem that use this table.
CREATE TABLE xdb.migr9202status (n INTEGER);
TRUNCATE TABLE xdb.migr9202status;
INSERT INTO xdb.migr9202status VALUES (1000);
COMMIT;

Rem ================================================================
Rem END XDB Object downgrade to 12.1.0
Rem ================================================================


