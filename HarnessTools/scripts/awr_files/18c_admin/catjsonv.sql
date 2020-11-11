Rem
Rem $Header: rdbms/admin/catjsonv.sql /main/7 2017/02/27 11:29:31 bhammers Exp $
Rem
Rem catjsonv.sql
Rem
Rem Copyright (c) 2014, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catjsonv.sql - view definitions for JSON data
Rem
Rem    DESCRIPTION
Rem      view definitions for JSON data
Rem
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/catjsonv.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/catjsonv.sql
Rem    SQL_PHASE: CATJSONV
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    SQL_CALLING_FILE: rdbms/admin/catptabs.sql
Rem    END SQL_FILE_METADATA
Rem
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    bhammers    02/13/17 - bug 25545239, add view columns to JSON views
Rem    stanaya     01/27/17 - Bug-25435915: adding sql metadata   
Rem    bhammers    12/05/16 - bug 25120568: NLSSORT
Rem    bhammers    09/15/15 - bug 21823036, exclude tables from recycle bin
Rem    bhammers    02/23/15 - fix for bugs 19703436, 19703660 and 19710520 
Rem    skayoor     11/30/14 - Proj 58196: Change Select priv to Read Priv
Rem    bhammers    02/20/14 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

CREATE OR REPLACE VIEW INT$DBA_JSON_TABLE_COLUMNS
(OBJECT_ID, OBJECT_TYPE#, OWNER, TABLE_NAME, OBJECT_TYPE, COLUMN_NAME, FORMAT, DATA_TYPE) AS
SELECT DISTINCT obj.obj#  "OBJECT_ID",
       obj.type# "OBJECT_TYPE#",
       usr.name  "OWNER",
       obj.name  "TABLE_NAME",
       'TABLE' "OBJECT_TYPE",
       col.name  "COLUMN_NAME",
       decode(bitand(cdef.defer, 126976), 
            4096, 'TEXT',
            8192, 'BSON',
            16384, 'AVRO',
            32768, 'PROTOBUF', 
            'UNDEFINED') "FORMAT",
       decode(col.type#, 
              1, decode(col.charsetform, 2, 'NVARCHAR2', 'VARCHAR2'),
              9, decode(col.charsetform, 2, 'NCHAR VARYING', 'VARCHAR'),
              23, 'RAW', 24, 'LONG RAW',
              112, decode(col.charsetform, 2, 'NCLOB', 'CLOB'),
              113, 'BLOB', 
              114, 'BFILE', 
              'UNDEFINED') "DATA_TYPE"
FROM sys.cdef$ CDEF, 
     sys."_CURRENT_EDITION_OBJ" OBJ, 
     sys.col$ COL, 
     sys.ccol$ CCOL, 
     sys.user$ USR
WHERE bitand(cdef.defer, 126976) > 0          
  AND cdef.obj# = obj.obj#
  AND cdef.con# = ccol.con#  
  AND col.col#  = ccol.col# 
  AND col.obj#  = obj.obj#
  AND usr.user# = obj.owner#
  AND col.type# IN (1,9,23,112,113,114) /* show only supported column types */
  AND bitand(col.property, 32) = 0      /* not hidden column */
  AND bitand(obj.flags, 128) = 0        /* not in recycle bin */
/


CREATE OR REPLACE VIEW INT$DBA_JSON_VIEW_COLUMNS
(OBJECT_ID, OBJECT_TYPE#, OWNER, TABLE_NAME, OBJECT_TYPE, COLUMN_NAME, FORMAT, DATA_TYPE) AS
SELECT DISTINCT obj.obj#  "OBJECT_ID",
       obj.type# "OBJECT_TYPE#",
       usr.name  "OWNER",
       obj.name  "TABLE_NAME",
       'VIEW' "OBJECT_TYPE",
       col.name  "COLUMN_NAME", 
       decode(bitand(col.property, 576460752303423488), 576460752303423488, 'TEXT', 
            decode(bitand(col.property, 1152921504606846976), 1152921504606846976, 'BINARY', 'UNDEFINED')) FORMAT,
       decode(col.type#, 
              1, decode(col.charsetform, 2, 'NVARCHAR2', 'VARCHAR2'),
              9, decode(col.charsetform, 2, 'NCHAR VARYING', 'VARCHAR'),
              23, 'RAW', 24, 'LONG RAW',
              112, decode(col.charsetform, 2, 'NCLOB', 'CLOB'),
              113, 'BLOB', 
              114, 'BFILE', 
              'UNDEFINED') "DATA_TYPE"
FROM sys."_CURRENT_EDITION_OBJ" OBJ, 
     sys.col$ COL, 
     sys.ccol$ CCOL, 
     sys.user$ USR
WHERE ((bitand(col.property, 576460752303423488) = 576460752303423488) OR
      (bitand(col.property, 1152921504606846976) = 1152921504606846976))
  AND col.col#  = ccol.col# 
  AND col.obj#  = obj.obj#
  AND usr.user# = obj.owner#
  AND col.type# IN (1,9,23,112,113,114) /* show only supported column types */
  AND bitand(col.property, 32) = 0      /* not hidden column */
  AND bitand(obj.flags, 128) = 0        /* not in recycle bin */
  AND obj.type# = 4                      /* only views */
/

CREATE OR REPLACE VIEW INT$DBA_JSON_COLUMNS
  (OBJECT_ID, OBJECT_TYPE#, OWNER, TABLE_NAME, OBJECT_TYPE, COLUMN_NAME, FORMAT, DATA_TYPE) AS
    SELECT OBJECT_ID, OBJECT_TYPE#, OWNER, TABLE_NAME, OBJECT_TYPE, COLUMN_NAME, FORMAT, DATA_TYPE
    FROM INT$DBA_JSON_VIEW_COLUMNS
  UNION ALL
    SELECT OBJECT_ID, OBJECT_TYPE#, OWNER, TABLE_NAME, OBJECT_TYPE, COLUMN_NAME, FORMAT, DATA_TYPE
    FROM INT$DBA_JSON_TABLE_COLUMNS
/

CREATE OR REPLACE VIEW DBA_JSON_COLUMNS 
  (OWNER, TABLE_NAME, OBJECT_TYPE, COLUMN_NAME, FORMAT, DATA_TYPE) AS
SELECT OWNER, TABLE_NAME, OBJECT_TYPE, COLUMN_NAME, FORMAT, DATA_TYPE
FROM INT$DBA_JSON_COLUMNS
/

grant select on DBA_JSON_COLUMNS to select_catalog_role;
create or replace public synonym DBA_JSON_COLUMNS for DBA_JSON_COLUMNS; 

comment on table DBA_JSON_COLUMNS is
'Comments on all JSON columns'
/

comment on column DBA_JSON_COLUMNS.OWNER is
'Owner of the table with the JSON column'
/

comment on column DBA_JSON_COLUMNS.OBJECT_TYPE is
'TABLE or VIEW'
/

-- materialized view TODO 

comment on column DBA_JSON_COLUMNS.TABLE_NAME is
'Name of the table/view with the JSON column'
/

comment on column DBA_JSON_COLUMNS.COLUMN_NAME is
'Name of the JSON column'
/

comment on column DBA_JSON_COLUMNS.FORMAT is
'Format of the JSON data'
/

comment on column DBA_JSON_COLUMNS.DATA_TYPE is
'Data type of the JSON column'
/



execute CDBView.create_cdbview(false, 'SYS','DBA_JSON_COLUMNS', 'CDB_JSON_COLUMNS');

grant select on SYS.CDB_JSON_COLUMNS to select_catalog_role
/
create or replace public synonym CDB_JSON_COLUMNS for SYS.CDB_JSON_COLUMNS
/



CREATE OR REPLACE VIEW USER_JSON_COLUMNS  
  (TABLE_NAME, OBJECT_TYPE, COLUMN_NAME, FORMAT, DATA_TYPE) 
AS 
SELECT TABLE_NAME, OBJECT_TYPE, COLUMN_NAME, FORMAT, DATA_TYPE
FROM INT$DBA_JSON_COLUMNS
WHERE NLSSORT(OWNER, 'NLS_SORT=BINARY') = 
      NLSSORT(SYS_CONTEXT('USERENV', 'CURRENT_USER'), 'NLS_SORT=BINARY')
/


grant read on USER_JSON_COLUMNS to public;
create or replace public synonym USER_JSON_COLUMNS for USER_JSON_COLUMNS; 

comment on table USER_JSON_COLUMNS is
'Comments on the JSON columns for which the user is the owner'
/

comment on column USER_JSON_COLUMNS.OBJECT_TYPE is
'TABLE or VIEW'
/

comment on column USER_JSON_COLUMNS.TABLE_NAME is
'Name of the table/view with the JSON column'
/

comment on column USER_JSON_COLUMNS.COLUMN_NAME is
'Name of the JSON column'
/

comment on column USER_JSON_COLUMNS.FORMAT is
'Format of the JSON data'
/

comment on column USER_JSON_COLUMNS.DATA_TYPE is
'Data type of the JSON column'
/




CREATE OR REPLACE VIEW ALL_JSON_COLUMNS  
  (OWNER, TABLE_NAME,OBJECT_TYPE, COLUMN_NAME, FORMAT, DATA_TYPE)
AS 
SELECT OWNER, TABLE_NAME, OBJECT_TYPE, COLUMN_NAME, FORMAT, DATA_TYPE
FROM INT$DBA_JSON_COLUMNS
WHERE (NLSSORT(OWNER, 'NLS_SORT=BINARY') = 
       NLSSORT(SYS_CONTEXT('USERENV', 'CURRENT_USER'), 'NLS_SORT=BINARY')
       OR OBJ_ID(OWNER, TABLE_NAME, OBJECT_TYPE#, OBJECT_ID) IN 
           (select obj# from sys.objauth$  where grantee# in 
              (select kzsrorol from x$kzsro))
       OR exists (select null from v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -397/* READ ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */))
      )
/

grant read on ALL_JSON_COLUMNS to public;
create or replace public synonym ALL_JSON_COLUMNS for ALL_JSON_COLUMNS; 


comment on table ALL_JSON_COLUMNS is
'Comments on the JSON columns accessible to the user'
/

comment on column ALL_JSON_COLUMNS.OWNER is
'Owner of the table with the JSON column'
/

comment on column ALL_JSON_COLUMNS.OBJECT_TYPE is
'TABLE or VIEW'
/

comment on column ALL_JSON_COLUMNS.TABLE_NAME is
'Name of the table/view with the JSON column'
/

comment on column ALL_JSON_COLUMNS.COLUMN_NAME is
'Name of the JSON column'
/

comment on column ALL_JSON_COLUMNS.FORMAT is
'Format of the JSON data'
/

comment on column ALL_JSON_COLUMNS.DATA_TYPE is
'Data type of the JSON column'
/

@?/rdbms/admin/sqlsessend.sql
