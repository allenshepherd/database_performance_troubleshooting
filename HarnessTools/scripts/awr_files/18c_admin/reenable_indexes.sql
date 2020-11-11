Rem
Rem $Header: rdbms/admin/reenable_indexes.sql /main/3 2015/02/04 13:57:27 sylin Exp $
Rem
Rem reenable_indexes.sql
Rem
Rem Copyright (c) 2014, 2015, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      reenable_indexes.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/reenable_indexes.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/reenable_indexes.sql
Rem    SQL_PHASE: REENABLE_INDEXES
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/noncdb_to_pdb.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    sylin       01/30/15 - bug20422151 - longer identifier
Rem    surman      01/08/15 - 19475031: Update SQL metadata
Rem    pyam        04/03/14 - Reenable indexes based on sys.enabled$indexes
Rem                           (formerly in utlprp.sql)
Rem    pyam        04/03/14 - Created
Rem

Rem
Rem Declare function local_enquote_name to pass FALSE 
Rem into underlying dbms_assert.enquote_name function
Rem 
CREATE OR REPLACE FUNCTION local_enquote_name (str varchar2)
 return varchar2 is
   begin
        return dbms_assert.enquote_name(str, FALSE);
   end local_enquote_name; 
/
Rem
Rem If sys.enabled$index table exists, then re-enable
Rem list of functional indexes that were enabled prior to upgrade
Rem The table sys.enabled$index table is created in catupstr.sql 
Rem
SET serveroutput on
DECLARE
   TYPE tab_char IS TABLE OF VARCHAR2(32767) INDEX BY BINARY_INTEGER;
   commands tab_char;
   p_null   CHAR(1);
   p_schemaname  dbms_id;
   p_indexname   dbms_id;
   rebuild_idx_msg BOOLEAN := FALSE;
   non_existent_index exception;
   recycle_bin_objs exception;
   cannot_change_obj exception;
   no_such_table  exception;
   pragma exception_init(non_existent_index, -1418);
   pragma exception_init(recycle_bin_objs, -38301);
   pragma exception_init(cannot_change_obj, -30552);
   pragma exception_init(no_such_table, -942);
   type cursor_t IS REF CURSOR;
   reg_cursor   cursor_t;

BEGIN
   -- Check for existence of the table marking disabled functional indices

   SELECT NULL INTO p_null FROM DBA_OBJECTS
   WHERE owner = 'SYS' and object_name = 'ENABLED$INDEXES' and
            object_type = 'TABLE' and rownum <=1;

      -- Select indices to be re-enabled
      EXECUTE IMMEDIATE q'+
         SELECT 'ALTER INDEX ' || 
                 local_enquote_name(e.schemaname) || '.' || 
                 local_enquote_name(e.indexname) || ' ENABLE'
            FROM   enabled$indexes e, ind$ i
            WHERE  e.objnum = i.obj# AND bitand(i.flags, 1024) != 0 AND
                   bitand(i.property, 16) != 0+'
      BULK COLLECT INTO commands;

      IF (commands.count() > 0) THEN
         FOR i IN 1 .. commands.count() LOOP
            BEGIN
            EXECUTE IMMEDIATE commands(i);
            EXCEPTION
               WHEN NON_EXISTENT_INDEX THEN NULL;
               WHEN RECYCLE_BIN_OBJS THEN NULL;
               WHEN CANNOT_CHANGE_OBJ THEN rebuild_idx_msg := TRUE;
            END;
         END LOOP;     
      END IF;
      
      -- Output any indexes in the table that could not be re-enabled
      -- due to ORA-30552 during ALTER INDEX...ENBLE command

      IF  rebuild_idx_msg THEN
       BEGIN
         DBMS_OUTPUT.PUT_LINE
('The following indexes could not be re-enabled and may need to be rebuilt:');

         OPEN reg_cursor FOR  
             'SELECT e.schemaname, e.indexname
              FROM   enabled$indexes e, ind$ i 
              WHERE  e.objnum = i.obj# AND bitand(i.flags, 1024) != 0';

         LOOP
           FETCH reg_cursor INTO p_schemaname, p_indexname;
           EXIT WHEN reg_cursor%NOTFOUND;
           DBMS_OUTPUT.PUT_LINE
              ('.... INDEX ' || p_schemaname || '.' || p_indexname);
         END LOOP;
         CLOSE reg_cursor;

       EXCEPTION
            WHEN NO_DATA_FOUND THEN CLOSE reg_cursor;
            WHEN NO_SUCH_TABLE THEN CLOSE reg_cursor;
            WHEN OTHERS THEN CLOSE reg_cursor; raise; 
       END;

      END IF;

      EXECUTE IMMEDIATE 'DROP TABLE sys.enabled$indexes';

   EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;

END;
/

DROP function local_enquote_name;
SET serveroutput off

