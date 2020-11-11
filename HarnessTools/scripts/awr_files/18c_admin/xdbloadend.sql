Rem
Rem $Header: rdbms/admin/xdbloadend.sql /main/2 2017/04/27 17:09:46 raeburns Exp $
Rem
Rem xdbloadend.sql
Rem
Rem Copyright (c) 2013, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      xdbloadend.sql - XDB LOAD END
Rem
Rem    DESCRIPTION
Rem      This script performs the final state of the XDB load
Rem
Rem    NOTES
Rem      
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    04/15/17 - Bug 25790192: Use UPGRADE for SQL_PHASE
Rem    raeburns    12/03/13 - restructure xdbrelod for parallel upgrade
Rem    raeburns    12/03/13 - Created
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/xdbloadend.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/xdbloadend.sql 
Rem    SQL_PHASE: UPGRADE
Rem    SQL_STARTUP_MODE: UPGRADE
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/xdbload.sql
Rem    END SQL_FILE_METADATA

@?/rdbms/admin/sqlsessstart.sql

Rem reload dbmsxdbt package if CONTEXT in the Database
COLUMN xdb_name NEW_VALUE xdb_file NOPRINT;
SELECT dbms_registry.script('CONTEXT','@dbmsxdbt.sql') AS xdb_name FROM DUAL;
@&xdb_file

Rem
Rem XDB Schema Migration Utilities (SYS.XDB_MIGRATESCHEMA) for APPS
Rem
Rem Reload only if it is already in the Database

COLUMN :migschema_dbms_name NEW_VALUE migschema_dbms_file NOPRINT
VARIABLE migschema_dbms_name VARCHAR2(50)
COLUMN :migschema_prvt_name NEW_VALUE migschema_prvt_file NOPRINT
VARIABLE migschema_prvt_name VARCHAR2(50)

DECLARE
  found number := 0;
BEGIN
  select 1 into found from dba_objects
  where owner       ='SYS' and
        object_name = 'XDB_MIGRATESCHEMA' and
        object_type = 'PACKAGE';

  :migschema_dbms_name := '@dbmsxdbschmig.sql';
  :migschema_prvt_name := '@prvtxdbschmig.plb';
EXCEPTION
   WHEN NO_DATA_FOUND THEN
       :migschema_dbms_name := '@nothing.sql';
       :migschema_prvt_name := '@nothing.sql';
END;
/

select :migschema_dbms_name from dual;
@&migschema_dbms_file;
select :migschema_prvt_name from dual;
@&migschema_prvt_file; 

--bug-8503519 re-enable all function-based indexes
--fix for lrg-3019679, bug-8328600 re-enable function-based indexes
--alter index xdb.xdb$acl_xidx enable;

set serveroutput on
VARIABLE xidxddl_name VARCHAR2(50)

declare
  TYPE tab_char IS TABLE OF VARCHAR2(32767) INDEX BY BINARY_INTEGER;
  xdbindexes tab_char;
  cannot_change_obj exception;
  pragma exception_init(cannot_change_obj, -30552);
begin
  -- Select indices to be re-enabled
  EXECUTE IMMEDIATE q'+
    select '"XDB".' || dbms_assert.enquote_name(index_name)
      from dba_indexes
     where owner = 'XDB'
       and index_name like 'XDB%'
       and index_type like 'FUNCTION-BASED%'+'
  BULK COLLECT INTO xdbindexes;

  :xidxddl_name := 'NO';

  IF (xdbindexes.count() > 0) THEN
    FOR i IN 1 .. xdbindexes.count() LOOP
      BEGIN
        EXECUTE IMMEDIATE 'alter index ' || xdbindexes(i) || ' enable';
        dbms_output.put_line('Index ' || xdbindexes(i) || ' successfully re-enabled');
        
      EXCEPTION
        WHEN CANNOT_CHANGE_OBJ THEN
          if xdbindexes(i) like '%ACL_XIDX%' then 
            :xidxddl_name := 'YES';
          else  
            dbms_output.put_line('Warning: Index ' || xdbindexes(i) || 
                               ' could not be re-enabled and may need to be rebuilt');
          end if;
      END;
    END LOOP;
  END IF;
end;
/

@?/rdbms/admin/sqlsessend.sql

