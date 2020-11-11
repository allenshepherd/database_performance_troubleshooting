Rem
Rem $Header: rdbms/admin/dbmsjson.sql /main/21 2017/03/22 10:11:20 yinlu Exp $
Rem
Rem dbmsjson.sql
Rem
Rem Copyright (c) 2015, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsjson.sql - package dbms_json
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/dbmsjson.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/dbmsjson.sql
Rem    SQL_PHASE: 
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/catqm_int.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    yinlu       03/09/17 - bug 25698164: sys_dgadd to support extra args
Rem    yinlu       01/31/17 - bug 25357408: use dbms_assert.equote_name in
Rem                           dg$getFlatDg
Rem    yinlu       12/07/16 - bug 25248104: add sys_dgagg to aggregate 
Rem                           dataguide trees    
Rem    bhammers    12/05/16 - bug 25192476: NLSSORT
Rem    yinlu       11/08/16 - dg$getDgName to use C callout
Rem    yinlu       11/04/16 - directly query $dg instead of json_table for
Rem                           json_dataguide_fields views
Rem    yinlu       10/18/16 - bug 24965187: add *_json_dataguide_fields
Rem    yinlu       10/12/16 - add indicator to json_dataguide format/pretty
Rem    yinlu       06/08/16 - bug 23548844: dg$hasDGIndex
Rem    acolunga    04/15/16 - materialized view option for create view on path
Rem    yinlu       03/23/16 - bug 22992001: TYPE_STRING constant to be
Rem                           dataguide constant
Rem    yinlu       03/07/16 - update dataguide procedure names
Rem    yinlu       11/18/15 - bug 22235575: dropVC
Rem    yinlu       10/30/15 - bug 22127950: add json_hierdataguide
Rem    yinlu       10/07/15 - add dba/all/user_json_dataguide view
Rem    yinlu       07/20/15 - comment out gendataguide
Rem    yinlu       07/15/15 - change JSON_SCHEMS from constant variable to
Rem                           function so they can be invoked in SQL select
Rem                           statement
Rem    zliu        06/20/15 - add ctxagg
Rem    yinlu       06/09/15 - bug 21216323: add schema to getdataguide
Rem    zliu        04/21/15 - add inmemory prep support
Rem    acolunga    03/24/15 - add resourcePath argument to createviewOnPath
Rem    acolunga    03/23/15 - add format argument to getDataGuide
Rem    yinlu       03/18/15 - add json_dataguide aggregate operator
Rem    acolunga    03/17/15 - json data guide formatting options
Rem    yinlu       02/10/15 - generateDataguide
Rem    yinlu       01/07/15 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

CREATE OR REPLACE PACKAGE xdb.dbms_json AUTHID CURRENT_USER IS

---------------------------------------
-- JSON field types
---------------------------------------
TYPE_NULL    CONSTANT NUMBER(2)  := 1;
TYPE_BOOLEAN CONSTANT NUMBER(2)  := 2;
TYPE_NUMBER  CONSTANT NUMBER(2)  := 3;
TYPE_STRING  CONSTANT NUMBER(2)  := 4;
TYPE_OBJECT  CONSTANT NUMBER(2)  := 5;
TYPE_ARRAY   CONSTANT NUMBER(2)  := 6;

-----------------------------------------------
-- JSON Data guide formatting
-----------------------------------------------
FUNCTION FORMAT_HIERARCHICAL return NUMBER PARALLEL_ENABLE;
FUNCTION FORMAT_FLAT return NUMBER PARALLEL_ENABLE;
FUNCTION PRETTY return NUMBER PARALLEL_ENABLE;

-------------------------------------------
-- Data guide related procedures/functions
-------------------------------------------

---------------------------------------------
-- PROCEDURE rename_column(VARCHAR2, VARCHAR2, VARCHAR2, VARCHAR2)
--     The procedures allows a user to provide his preferred name for a JSON 
--     field. Internally, it updates the viewColName column in the $dg table.
-- Parameters -
--  tableName
--     The name of the table that contains the JSON column
--  jcolName
--     The name of the JSON column which has data guide enabled context index.
--     If the JSON column does not have a data guide enabled context index, 
--     an error will be raised.
--  path
--     A JSON path referring to a JSON field, e.g. $.purchaseOrder.items.name.
--  type
--     The type of the JSON field. Two JSON fields may have the same path, but
--     different types. One of the following values:
--       TYPE_NULL
--       TYPE_STRING
--       TYPE_NUMBER
--       TYPE_BOOLEAN
--       TYPE_OBJECT
--       TYPE_ARRAY
--  preferred_name 
--     The preferred name for the JSON field specified in path. If there is a
--     name conflict, it will use a system generated name.
---------------------------------------------
PROCEDURE rename_column(tableName VARCHAR2, 
                        jcolName VARCHAR2, 
                        path VARCHAR2, 
                        type NUMBER,
                        preferred_name VARCHAR2);

---------------------------------------------
-- FUNCTION get_index_dataguide(VARCHAR2, VARCHAR2, VARCHAR2, NUMBER, NUMBER)
--     This function reads from the underlying $dg table and generates data 
--     guide in JSON format. If the underlying $dg table has statistic 
--     information, the generated data guide will include them. 
-- Parameters -
--  owner
--     The owner of the table
--  tableName
--     The name of the table that contains the JSON column
--  jcolName
--     The name of the JSON column which has data guide enabled context index.
--     If the JSON columns does not have a data guide enabled context index,
--     an error will be raised. 
--  format
--     The format in which the data guide will be displayed, two options:
--     .  FORMAT_HIERARCHICAL - hierarchical format
--     .  FORMAT_FLAT - flat format
--  pretty
--     If dbms_json.PRETTY, the returned data guide will have appropriate 
--     indention to improve readability.
---------------------------------------------
FUNCTION get_index_dataguide(owner VARCHAR2,
                             tableName VARCHAR2,
                             jcolName VARCHAR2,
                             format NUMBER,
                             pretty NUMBER DEFAULT 0) RETURN CLOB;


FUNCTION get_index_dataguide(tableName VARCHAR2,
                             jcolName VARCHAR2,
                             format NUMBER,
                             pretty NUMBER DEFAULT 0) RETURN CLOB;

---------------------------------------------
-- PROCEDURE create_view(VARCHAR2, VARCHAR2, VARCHAR2, CLOB)
--     The procedure will create a view with relational columns, and scalar
--     JSON fields (could be under an array) specified in the annotated data 
--     guide. It does not require the JSON column to have data guide enabled 
--     context index.
-- Parameters -
--  viewName
--     The name of the customized view
--  tableName
--     The name of the table containing the JSON column
--  jcolName
--     The name of the JSON column to create a view on.
--  dataguide
--     The annotated data guide
--  resourcePath
--     The resourcePath will be used to register the create view ddl statement
--     as resource by calling dbms_xdb.createresource(resourcePath, <ddl>);
---------------------------------------------
PROCEDURE create_view(viewName VARCHAR2, 
                      tableName VARCHAR2, 
                      jcolName VARCHAR2, 
                      dataguide CLOB,
                      resourcePath VARCHAR2 DEFAULT NULL);

---------------------------------------------
-- PROCEDURE create_view_on_path(VARCHAR2, VARCHAR2, VARCHAR2, VARCHAR2, NUMBER)
--     This procedure will create a view with relational columns, top-level 
--     scalar types, and fully expands sub-tree under the path. The view column
--     names are get from column viewColName in $dg table.
-- Parameters -
--  viewName
--     The name of the customized view
--  tableName
--     The name of the table containing the JSON column
--  jcolName 
--     The name of the JSON column which has data guide enabled context index.
--     If the JSON columns does not have a data guide enabled context index, 
--     an error will be raised.
--  path
--     The path of the JSON field to be expanded. It uses JSON path expression 
--     syntax, e.g. $ will create a view starting from the JSON document root; 
--     $.purchaseOrder will create a view starting from purchaseOrder. It 
--     expands the children/descendants under purchaseOrder, and create view 
--     columns for every scalar values.
--  frequency
--     The view will only display the JSON fields with frequency greater than 
--     the given frequency. It will NOT display JSON fields added after 
--     dbms_json.gatherStats if the given frequency is greater than 0, as their
--     statistic columns are NULL.
--     If the frequency value is 0, it will display all JSON fields including 
--     those added after dbms_json.gatherStat call. 
--     If user never invokes dbms_json.gatherStats, i.e. there is no statistic
--     information in the data guide, this argument will be ignored and all 
--     JSON fields will be displayed in the view.
--  resourcePath
--     The resourcePath will be used to register the create view ddl statement
--     as resource by calling dbms_xdb.createresource(resourcePath, <ddl>);
--  materialize
--     The materialize argument will be a boolean that will tell us whether the
--     view will be materialized or not.
---------------------------------------------
PROCEDURE create_view_on_path(viewName VARCHAR2, 
                           tableName VARCHAR2, 
                           jcolName VARCHAR2, 
                           path VARCHAR2,
                           frequency NUMBER DEFAULT 0,
                           resourcePath VARCHAR2 DEFAULT NULL,
                           materialize BOOLEAN DEFAULT FALSE);

---------------------------------------------
-- PROCEDURE add_virtual_columns(VARCHAR2, VARCHAR2, CLOB)
--     The procedure adds one virtual column for each scalar JSON field not 
--     under an array. The virtual column name 
--     is the value of o:preferred_column_name in the annotated data guide. It 
--     ignores JSON objects, arrays, and fields under arrays in the annotated
--      data guide.
--     It does not require the JSON column to have data guide enabled context
--     index.
--     It there already exist virtual columns added from this JSON column, the
--     old virtual columns will be removed. Internally, we comment each virtual
--     column with the JSON column name to track who adds them.
-- Parameters -
--  tableName
--     The name of the table containing the JSON column
--  jcolName 
--     The name of the JSON column to create virtual columns from
--  dataguide
--     The annotated data guide. When o:hidden in the annotated data guide
--     for a particular JSON field is set to TRUE, the corresponding virtual 
--     column is added as hidden. The default value of o:hiddend is FALSE.
---------------------------------------------
PROCEDURE add_virtual_columns(tableName VARCHAR2, 
                              jcolName VARCHAR2, 
                              dataguide CLOB);

---------------------------------------------
-- PROCEDURE add_virtual_columns(VARCHAR2, VARCHAR2, NUMBER, BOOLEAN)
--     The procedure looks up the $dg table and adds one virtual column for
--     every scalar field not under an array with frequency greater than the
--     given value. The virtual column name is got
--     from column viewColName in $dg table. It ignores JSON objects, arrays,
--     and fields under arrays.
-- Parameters -
--  tableName
--     The name of the table containing the JSON column
--  jcolName
--     The name of the JSON column which has data guide enabled context index.
--     If the JSON columns does not have a data guide enabled context index,
--     an error will be raised. 
--  frequency
--     Only display the JSON fields with frequency greater than the given 
--     frequency. It will NOT display JSON fields added after 
--     dbms_json.gatherStats if the given frequency is greater than 0, as 
--     their statistic columns are NULL.
--     If the frequency value is 0, it will display all JSON fields including
--     those added after dbms_json.gatherStat call. 
--     If user never invokes dbms_json.gatherStats, i.e. there is no statistic
--     information in the data guide, this argument will be ignored and all 
--     JSON fields will be displayed in the view.
--  hidden
--     Whether the virtual columns will be added as hidden. 
--     The default is FALSE.
---------------------------------------------
PROCEDURE add_virtual_columns(tableName VARCHAR2, 
                              jcolName VARCHAR2, 
                              frequency NUMBER DEFAULT 0,
                               hidden BOOLEAN DEFAULT FALSE);

---------------------------------------------
-- PROCEDURE drop_virtual_columns(VARCHAR2, VARCHAR2)
--     The procedure drops the virtual columns created by the data guide,
--     either through the previous addVC call or the pre-implmeneted trigger
--     add_vc.
-- Parameters -
--  tableName
--     The name of the table containing the JSON column
--  jcolName
--     The name of the JSON column which has data guide enabled context index.
--     If the JSON columns does not have a data guide enabled context index,
--     an error will be raised. 
---------------------------------------------
PROCEDURE drop_virtual_columns(tableName VARCHAR2, 
                               jcolName VARCHAR2);

---------------------------------------------
-- PROCEDURE generateDataGuide(VARCHAR2, VARCHAR2, VARCHAR2, NUMBER)
--     The procedure scans the given JSON collection, builds data guide on 
--     the fly, then creates a table to store the data guide information.
-- Parameters -
--  dgTabName
--     The name of the table to store data guide information
--  tabViewName
--     The name of the table or view containing the JSON column
--  jcolName
--     The name of the JSON column to create data guide on 
--  estimate_percent
--     Percentage of JSON rows to sample. The valid range is [0.000001,100]. 
--     Similar to the argument in dbms_stats.gather_table_stats.
---------------------------------------------
/*
PROCEDURE generateDataGuide(dgTabName VARCHAR2,
                            tabViewName VARCHAR2, 
                            jcolName VARCHAR2,
                            estimate_percent NUMBER DEFAULT 2);
*/

--------------------------------------------------
-- End of data guide related procedures/functions
--------------------------------------------------

-------------------------------------------
-- JSON inmemory related procedures/functions
-------------------------------------------
---------------------------------------------
-- PROCEDURE prepJColInM(VARCHAR2, VARCHAR2)
--  For this json column (IS JSON check constraint) that is created prior to
--  12.2 release, this procedure upgrades such json column to prepare to
--  take advantage of in memory json processing that is new in 12.2 release.
-- Parameters -
--  tabName
--     The table name of the table to which this json column belongs.
--  jcolName
--     The column name of the json column
-- Note the database server must set compatible=12.2.0.0
-- max_string_size=extended in order to run this procedure.
---------------------------------------------
PROCEDURE prepJColInM(tabName VARCHAR2, jcolName VARCHAR2);
---------------------------------------------
-- PROCEDURE prepTabJColInM(VARCHAR2)
--  For table containing json columns (IS JSON check constraint) that are
--  created prior to
--  12.2 release, this procedure upgrades all of these json columns in this
--  table  to parepare to take advantage of in memory json processing that is 
--  new in 12.2 release.
-- Parameters -
--  tabName
--     The table name of the table.
-- Note the database server must set compatible=12.2.0.0 
-- max_string_size=extended in order to run this procedure.
---------------------------------------------
PROCEDURE prepTabJColInM(tabName VARCHAR2);

-- PROCEDURE  prepAllJColInM
--  For all the tables containing json columns (IS JSON check constraint) that 
--  are  created prior to
--  12.2 release, this procedure upgrades all of these json columns 
--  in all these tables  to prepare to take advantage of in memory json 
--  processing that is new in 12.2 release.
--  All of these tables are owned by current user.
-- Parameters -
--     NONE
-- Note the database server must set compatible=12.2.0.0 
-- max_string_size=extended in order to run this procedure.
PROCEDURE prepAllJColInM;
--------------------------------------------------
-- End of JSON inemmory related procedures/functions
--------------------------------------------------
end dbms_json;
/
show errors;

CREATE OR REPLACE PUBLIC SYNONYM dbms_json FOR xdb.dbms_json
/
GRANT EXECUTE ON xdb.dbms_json TO PUBLIC
/
show errors;

----
-- library for JSON (dataguide) related C callouts
----
CREATE OR REPLACE LIBRARY JSON_LIB TRUSTED AS STATIC
/

-------------------------------------------------------
-- json_dataguide aggregate function implementation
-------------------------------------------------------
-- TODO: get a valid OID
create or replace type JsonDgImp OID '00000000000000000000000000025000'
   authid current_user as object
(
  key RAW(8),

  static function ODCIAggregateInitialize(sctx OUT JsonDgImp, outopn IN RAW, 
                                          inpopn IN RAW, format IN NUMBER,
                                          pretty IN NUMBER)
    return pls_integer
    is language c
    name "JsonDgAggInitialize"
    library json_lib
    with context
    parameters (
      context,
      sctx, sctx INDICATOR STRUCT, sctx DURATION OCIDuration,
      outopn OCIRaw,
      inpopn OCIRaw,
      format OCINumber,
      format INDICATOR sb4,
      pretty OCINumber,
      pretty INDICATOR sb4,
      return INT
    ),

  member function ODCIAggregateIterate(self IN OUT NOCOPY JsonDgImp,
                                       value IN AnyData) return pls_integer
    is language c
    name "JsonDgAggIterate"
    library json_lib
    with context
    parameters (
      context,
      self, self INDICATOR STRUCT, self DURATION OCIDuration,
      value, value INDICATOR sb2,
      return INT
    ),

  member function ODCIAggregateTerminate(self IN OUT NOCOPY JsonDgImp,
                                         returnValue OUT CLOB,
                                         flags IN number)
                  return pls_integer
    is language c
    name "JsonDgAggTerminate"
    library json_lib
    with context
    parameters (
      context,
      self, self INDICATOR STRUCT,
      returnValue, returnValue INDICATOR sb2, returnValue DURATION OCIDuration,
      flags, flags INDICATOR sb2,
      return INT
    ),

  member function ODCIAggregateMerge(self IN OUT NOCOPY JsonDgImp,
                                     valueB IN JsonDgImp) return pls_integer
    is language c
    name "JsonDgAggMerge"
    library json_lib
    with context
    parameters (
      context,
      self, self INDICATOR STRUCT, self DURATION OCIDuration,
      valueB, valueB INDICATOR STRUCT,
      return INT
    ),

  member function ODCIAggregateWrapContext(self IN OUT NOCOPY JsonDgImp)
                  return pls_integer
    is language c
    name "JsonDgAggWrap"
    library json_lib
    with context
    parameters (
      context,
      self, self INDICATOR STRUCT, self DURATION OCIDuration,
      return INT
    )
);
/
show errors;

create or replace function JSON_DATAGUIDE(input AnyData,
                           format NUMBER DEFAULT DBMS_JSON.FORMAT_FLAT,
                           pretty NUMBER DEFAULT 0)
return CLOB aggregate using JsonDgImp;
/
show errors;

grant execute on JSON_DATAGUIDE to public;
create or replace public synonym JSON_DATAGUIDE for JSON_DATAGUIDE;

-------------------------------------------------------
-- json_hierdataguide aggregate function implementation
-------------------------------------------------------
-- TODO: get a valid OID
create or replace type JsonHDgImp OID '00000000000000000000000000025001'
   authid current_user as object
(
  key RAW(8),

  static function ODCIAggregateInitialize(sctx OUT JsonHDgImp, outopn IN RAW, 
                                          inpopn IN RAW ) return pls_integer
    is language c
    name "JsonDgAggHierInitialize"
    library json_lib
    with context
    parameters (
      context,
      sctx, sctx INDICATOR STRUCT, sctx DURATION OCIDuration,
      outopn OCIRaw,
      inpopn OCIRaw,
      return INT
    ),

  member function ODCIAggregateIterate(self IN OUT NOCOPY JsonHDgImp,
                                       value IN AnyData) return pls_integer
    is language c
    name "JsonDgAggIterate"
    library json_lib
    with context
    parameters (
      context,
      self, self INDICATOR STRUCT, self DURATION OCIDuration,
      value, value INDICATOR sb2,
      return INT
    ),

  member function ODCIAggregateTerminate(self IN OUT NOCOPY JsonHDgImp,
                                         returnValue OUT CLOB,
                                         flags IN number)
                  return pls_integer
    is language c
    name "JsonDgAggHierTerminate"
    library json_lib
    with context
    parameters (
      context,
      self, self INDICATOR STRUCT,
      returnValue, returnValue INDICATOR sb2, returnValue DURATION OCIDuration,
      flags, flags INDICATOR sb2,
      return INT
    ),

  member function ODCIAggregateMerge(self IN OUT NOCOPY JsonHDgImp,
                                     valueB IN JsonHDgImp) return pls_integer
    is language c
    name "JsonDgAggMerge"
    library json_lib
    with context
    parameters (
      context,
      self, self INDICATOR STRUCT, self DURATION OCIDuration,
      valueB, valueB INDICATOR STRUCT,
      return INT
    ),

  member function ODCIAggregateWrapContext(self IN OUT NOCOPY JsonHDgImp)
                  return pls_integer
    is language c
    name "JsonDgAggWrap"
    library json_lib
    with context
    parameters (
      context,
      self, self INDICATOR STRUCT, self DURATION OCIDuration,
      return INT
    )
);
/
show errors;

create or replace function JSON_HIERDATAGUIDE(input AnyData)
return CLOB aggregate using JsonHDgImp;
/
show errors;

grant execute on JSON_HIERDATAGUIDE to public;
create or replace public synonym JSON_HIERDATAGUIDE for JSON_HIERDATAGUIDE;

-------------------------------------------------------
-- sys_dgagg aggregate function implementation
-------------------------------------------------------
-- TODO: get a valid OID
create or replace type SysDgAggImp OID '00000000000000000000000000025100'
   authid current_user as object
(
  key RAW(8),

  static function ODCIAggregateInitialize(sctx OUT SysDgAggImp, outopn IN RAW,
                                          inpopn IN RAW, format IN NUMBER,
                                          pretty IN NUMBER)
    return pls_integer
    is language c
    name "JsonDgAggInitialize"
    library json_lib
    with context
    parameters (
      context,
      sctx, sctx INDICATOR STRUCT, sctx DURATION OCIDuration,
      outopn OCIRaw,
      inpopn OCIRaw,
      format OCINumber,
      format INDICATOR sb4,
      pretty OCINumber,
      pretty INDICATOR sb4,
      return INT
    ),

  member function ODCIAggregateIterate(self IN OUT NOCOPY SysDgAggImp,
                                       value IN CLOB) return pls_integer
    is language c
    name "SysDgAggIterate"
    library json_lib
    with context
    parameters (
      context,
      self, self INDICATOR STRUCT, self DURATION OCIDuration,
      value, value INDICATOR sb2,
      return INT
    ),

  member function ODCIAggregateTerminate(self IN OUT NOCOPY SysDgAggImp,
                                         returnValue OUT CLOB,
                                         flags IN number)
                  return pls_integer
    is language c
    name "JsonDgAggTerminate"
    library json_lib
    with context
    parameters (
      context,
      self, self INDICATOR STRUCT,
      returnValue, returnValue INDICATOR sb2, returnValue DURATION OCIDuration,
      flags, flags INDICATOR sb2,
      return INT
    ),

  member function ODCIAggregateMerge(self IN OUT NOCOPY SysDgAggImp,
                                     valueB IN SysDgAggImp) return pls_integer
    is language c
    name "JsonDgAggMerge"
    library json_lib
    with context
    parameters (
      context,
      self, self INDICATOR STRUCT, self DURATION OCIDuration,
      valueB, valueB INDICATOR STRUCT,
      return INT
    ),

  member function ODCIAggregateWrapContext(self IN OUT NOCOPY SysDgAggImp)
                  return pls_integer
    is language c
    name "JsonDgAggWrap"
    library json_lib
    with context
    parameters (
      context,
      self, self INDICATOR STRUCT, self DURATION OCIDuration,
      return INT
    )
);
/
show errors;

create or replace function SYS_DGAGG(input CLOB,
                            format NUMBER DEFAULT DBMS_JSON.FORMAT_FLAT,
                            pretty NUMBER DEFAULT 0)
return CLOB aggregate using SysDgAggImp;
/
show errors;

grant execute on SYS_DGAGG to public;
create or replace public synonym SYS_DGAGG for SYS_DGAGG;


-------------------------------------------------------
-- sys_hierdgagg aggregate function implementation
-------------------------------------------------------
-- TODO: get a valid OID
create or replace type SysHierDgAggImp OID '00000000000000000000000000025101'
   authid current_user as object
(
  key RAW(8),

  static function ODCIAggregateInitialize(sctx OUT SysHierDgAggImp, outopn IN RAW,
                                          inpopn IN RAW ) return pls_integer
    is language c
    name "JsonDgAggHierInitialize"
    library json_lib
    with context
    parameters (
      context,
      sctx, sctx INDICATOR STRUCT, sctx DURATION OCIDuration,
      outopn OCIRaw,
      inpopn OCIRaw,
      return INT
    ),

  member function ODCIAggregateIterate(self IN OUT NOCOPY SysHierDgAggImp,
                                       value IN CLOB) return pls_integer
    is language c
    name "SysDgAggHierIterate"
    library json_lib
    with context
    parameters (
      context,
      self, self INDICATOR STRUCT, self DURATION OCIDuration,
      value, value INDICATOR sb2,
      return INT
    ),

  member function ODCIAggregateTerminate(self IN OUT NOCOPY SysHierDgAggImp,
                                         returnValue OUT CLOB,
                                         flags IN number)
                  return pls_integer
    is language c
    name "JsonDgAggHierTerminate"
    library json_lib
    with context
    parameters (
      context,
      self, self INDICATOR STRUCT,
      returnValue, returnValue INDICATOR sb2, returnValue DURATION OCIDuration,
      flags, flags INDICATOR sb2,
      return INT
    ),

  member function ODCIAggregateMerge(self IN OUT NOCOPY SysHierDgAggImp,
                                     valueB IN SysHierDgAggImp) return pls_integer
    is language c
    name "JsonDgAggMerge"
    library json_lib
    with context
    parameters (
      context,
      self, self INDICATOR STRUCT, self DURATION OCIDuration,
      valueB, valueB INDICATOR STRUCT,
      return INT
    ),

  member function ODCIAggregateWrapContext(self IN OUT NOCOPY SysHierDgAggImp)
                  return pls_integer
    is language c
    name "JsonDgAggWrap"
    library json_lib
    with context
    parameters (
      context,
      self, self INDICATOR STRUCT, self DURATION OCIDuration,
      return INT
    )
);
/
show errors;

create or replace function SYS_HIERDGAGG(input CLOB) return CLOB
aggregate using SysHierDgAggImp;
/
show errors;

grant execute on SYS_HIERDGAGG to public;
create or replace public synonym SYS_HIERDGAGG for SYS_HIERDGAGG;


------ add kci_cxagg for json search index-------------------------
----
-- library for JSON (dataguide) related C callouts
----
CREATE OR REPLACE LIBRARY kci_ctxagg_lib TRUSTED AS STATIC
/

-------------------------------------------------------
-- kcisys_ctxagg aggregate function implementation
-------------------------------------------------------
-- TODO: get a valid OID
create or replace type CtxAggimp OID '00000000000000000000000000026000'
   authid current_user as object
(
  key RAW(8),

  static function ODCIAggregateInitialize(sctx OUT CtxAggimp, outopn IN RAW, 
                                          inpopn IN RAW ) return pls_integer
    is language c
    name "KciCtxAggInitialize"
    library kci_ctxagg_lib
    with context
    parameters (
      context,
      sctx, sctx INDICATOR STRUCT, sctx DURATION OCIDuration,
      outopn OCIRaw,
      inpopn OCIRaw,
      return INT
    ),

  member function ODCIAggregateIterate(self IN OUT NOCOPY CtxAggimp,
                                       value IN AnyData) return pls_integer
    is language c
    name "KciCtxAggIterate"
    library kci_ctxagg_lib
    with context
    parameters (
      context,
      self, self INDICATOR STRUCT, self DURATION OCIDuration,
      value, value INDICATOR sb2,
      return INT
    ),

  member function ODCIAggregateTerminate(self IN OUT NOCOPY CtxAggimp,
                                         returnValue OUT BLOB,
                                         flags IN number)
                  return pls_integer
    is language c
    name "KciCtxAggTerminate"
    library kci_ctxagg_lib
    with context
    parameters (
      context,
      self, self INDICATOR STRUCT,
      returnValue, returnValue INDICATOR sb2, returnValue DURATION OCIDuration,
      flags, flags INDICATOR sb2,
      return INT
    ),

  member function ODCIAggregateMerge(self IN OUT NOCOPY CtxAggimp,
                                     valueB IN CtxAggimp) return pls_integer
    is language c
    name "KciCtxAggMerge"
    library kci_ctxagg_lib
    with context
    parameters (
      context,
      self, self INDICATOR STRUCT, self DURATION OCIDuration,
      valueB, valueB INDICATOR STRUCT,
      return INT
    ),

  member function ODCIAggregateWrapContext(self IN OUT NOCOPY CtxAggimp)
                  return pls_integer
    is language c
    name "KciCtxAggWrap"
    library kci_ctxagg_lib
    with context
    parameters (
      context,
      self, self INDICATOR STRUCT, self DURATION OCIDuration,
      return INT
    )
);
/
show errors;

create or replace function KCISYS_CTXAGG(input AnyData) return BLOB
aggregate using CtxAggimp;
/
show errors;

grant execute on KCISYS_CTXAGG to public;
create or replace public synonym KCISYS_CTXAGG for KCISYS_CTXAGG;

/*===================== data guide related views ====================== */
create or replace function dg$hasDGIndex(owner VARCHAR2, 
                                         tableName VARCHAR2, 
                                         jcolName VARCHAR2) return NUMBER
IS
  userId      NUMBER;
  tableId     NUMBER;
  indexName   varchar2(130);
  ret         number := 0;
BEGIN
  -- get index name, owner's id and table number by checking if the 
  -- column has a context index
  EXECUTE IMMEDIATE
   'select ix.index_name, u.user_id, o.object_id
    from dba_ind_columns ic, dba_indexes ix, dba_users u, dba_objects o
    where  
      ic.table_owner = ix.table_owner and 
      ic.index_name = ix.index_name and 
      ic.table_name = ix.table_name and 
      ic.table_owner = u.username and
      u.username = o.owner and
      o.object_name = ic.table_name and
      o.object_type = ''TABLE'' and
      ic.column_name= :1 and 
      ic.table_name= :2 and 
      u.username= :3 and
      ix.ITYP_OWNER = ''CTXSYS'' and 
      (ix.ITYP_NAME= ''CONTEXT'' or ix.ITYP_NAME = ''CONTEXT_V2'')'
  INTO indexName, userId, tableId 
  USING jcolName, tableName, owner;

  -- check if dataguide is enabled and get idx_option
  /* bug 23548844: execute immediate without into does not raise
     no_data_found error */
  EXECUTE IMMEDIATE 
   'select count(*)
    from ctxsys.dr$index
    where 
      idx_name = :1 and 
      idx_table# = :2 and 
      idx_table_owner# = :3 and
      idx_option like ''%d%'''
  INTO ret
  USING indexName, tableId, userId;

  return ret;

  EXCEPTION 
    WHEN no_data_found THEN
     ret := 0; /* no index error */
     return ret;
END;
/

CREATE OR REPLACE FUNCTION dg$getDgQuoteName(owner VARCHAR2,
                             tableName VARCHAR2,
                             jcolName VARCHAR2,
                             format NUMBER,
                             pretty NUMBER) RETURN CLOB
AS
uname VARCHAR2(130);
tname VARCHAR2(130);
cname VARCHAR2(130);
BEGIN
  /* add quote around the input names */
  uname := '"' || owner || '"';
  tname := '"' || tableName || '"';
  cname := '"' || jcolName || '"';
  return dbms_json.get_index_dataguide(uname, tname, cname, format, pretty);
END;
/

CREATE OR REPLACE VIEW INT$DBA_JSON_DATAGUIDES
(OBJECT_ID, OBJECT_TYPE#, OWNER, TABLE_NAME, COLUMN_NAME, DATAGUIDE) AS
SELECT OBJECT_ID, OBJECT_TYPE#, OWNER, TABLE_NAME, COLUMN_NAME,
       dg$getDgQuoteName(OWNER, TABLE_NAME, COLUMN_NAME, 
                         dbms_json.format_flat, dbms_json.pretty)
FROM INT$DBA_JSON_COLUMNS
WHERE dg$hasDGIndex(OWNER, TABLE_NAME, COLUMN_NAME) > 0
/

CREATE OR REPLACE VIEW DBA_JSON_DATAGUIDES 
  (OWNER, TABLE_NAME, COLUMN_NAME, DATAGUIDE) AS
SELECT OWNER, TABLE_NAME, COLUMN_NAME, DATAGUIDE
FROM INT$DBA_JSON_DATAGUIDES
/

grant select on DBA_JSON_DATAGUIDES to select_catalog_role;
create or replace public synonym DBA_JSON_DATAGUIDES for DBA_JSON_DATAGUIDES; 

execute CDBView.create_cdbview(false,'SYS','DBA_JSON_DATAGUIDES', 'CDB_JSON_DATAGUIDES');
grant select on SYS.CDB_JSON_DATAGUIDES to select_catalog_role
/
create or replace public synonym CDB_JSON_DATAGUIDES for SYS.CDB_JSON_DATAGUIDES
/


CREATE OR REPLACE VIEW USER_JSON_DATAGUIDES
  (TABLE_NAME, COLUMN_NAME, DATAGUIDE) 
AS 
SELECT TABLE_NAME, COLUMN_NAME, DATAGUIDE
FROM INT$DBA_JSON_DATAGUIDES
WHERE NLSSORT(OWNER, 'NLS_SORT=BINARY') = 
      NLSSORT(SYS_CONTEXT('USERENV', 'CURRENT_USER'), 'NLS_SORT=BINARY')
/

grant read on USER_JSON_DATAGUIDES to public;
create or replace public synonym USER_JSON_DATAGUIDES for USER_JSON_DATAGUIDES;


CREATE OR REPLACE VIEW ALL_JSON_DATAGUIDES
  (OWNER, TABLE_NAME, COLUMN_NAME, DATAGUIDE)
AS 
SELECT OWNER, TABLE_NAME, COLUMN_NAME, DATAGUIDE
FROM INT$DBA_JSON_DATAGUIDES
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

grant read on ALL_JSON_DATAGUIDES to public;
create or replace public synonym ALL_JSON_DATAGUIDES for ALL_JSON_DATAGUIDES;

/*===================== [DBA|ALL|USER]_JSON_DATAGUIDE_FIELDS ==============*/

create or replace type dg$row force as object
(JPATH   VARCHAR2(4000),
 JTYPE   VARCHAR2(40),
 TLENGTH NUMBER);
/

create or replace type dg$rowset as table of dg$row;
/

create or replace function dg$getFlatDg(owner VARCHAR2,
                             tableName VARCHAR2,
                             jcolName VARCHAR2) RETURN dg$rowset PIPELINED
IS
  procedure dg$getDgName(owner VARCHAR2,
                         indexName VARCHAR2,
                         dgName OUT VARCHAR2) IS
    LANGUAGE C
    NAME "DG_GETDGNAME"
    LIBRARY JSON_LIB
    WITH CONTEXT
    PARAMETERS (context,
                owner                         STRING,
                owner                  INDICATOR sb4,
                owner                     LENGTH sb4,
                indexName                     STRING,
                indexName              INDICATOR sb4,
                indexName                 LENGTH sb4,
                dgName                        STRING,
                dgName                 INDICATOR sb4,
                dgName                    LENGTH sb4,
                dgName                    MAXLEN sb4
               );
  userId      NUMBER;
  tableId     NUMBER;
  indexName   varchar2(130);
  dgtab varchar2(4000);
  stmt  varchar2(4000);
  TYPE  CurTyp IS REF CURSOR;
  cur   CurTyp := null;
  ret   dg$row := dg$row(NULL, NULL, NULL);
  jpath varchar2(4000);
  jtype number;
  tlength number;
BEGIN
  -- get index name, owner's id and table number by checking if the 
  -- column has a context index
  EXECUTE IMMEDIATE
   'select ix.index_name, u.user_id, o.object_id
    from dba_ind_columns ic, dba_indexes ix, dba_users u, dba_objects o
    where  
      ic.table_owner = ix.table_owner and 
      ic.index_name = ix.index_name and 
      ic.table_name = ix.table_name and 
      ic.table_owner = u.username and
      u.username = o.owner and
      o.object_name = ic.table_name and
      o.object_type = ''TABLE'' and
      ic.column_name= :1 and 
      ic.table_name= :2 and 
      u.username= :3 and
      ix.ITYP_OWNER = ''CTXSYS'' and 
      (ix.ITYP_NAME= ''CONTEXT'' or ix.ITYP_NAME = ''CONTEXT_V2'')'
  INTO indexName, userId, tableId 
  USING jcolName, tableName, owner;

  -- get $dg table name
  dg$getDgName(owner, indexName, dgtab);

  stmt := 'select path, type, tlength from ' || 
           dbms_assert.enquote_name(owner, FALSE) || '.' || 
           dbms_assert.enquote_name(dgtab, FALSE);

  OPEN cur for stmt;
  LOOP
    FETCH cur INTO jpath, jtype, tlength;
    EXIT WHEN cur%NOTFOUND;
    
    ret.jpath := jpath;
    ret.tlength := tlength;
    if (jtype > 1000) then
      jtype := jtype - 1000;
    end if;
    CASE jtype
      WHEN 1 then ret.jtype := 'null';
      WHEN 2 then ret.jtype := 'boolean';
      WHEN 3 then ret.jtype := 'number';
      WHEN 4 then ret.jtype := 'string';
      WHEN 5 then ret.jtype := 'object';
      WHEN 6 then ret.jtype := 'array';
    END CASE;

    PIPE ROW(ret);
  END LOOP;
  CLOSE cur;

EXCEPTION
  WHEN OTHERS THEN
    IF cur%ISOPEN THEN
      CLOSE cur;
    end if;
    null;
END;
/

show errors;

CREATE OR REPLACE VIEW INT$DBA_JSON_DG_COLS
(OBJECT_ID, OBJECT_TYPE#, OWNER, TABLE_NAME, COLUMN_NAME, PATH, TYPE, LENGTH) AS
SELECT OBJECT_ID, OBJECT_TYPE#, OWNER, TABLE_NAME, COLUMN_NAME, 
       JT.JPATH AS PATH, JT.JTYPE AS TYPE, JT.TLENGTH AS LENGTH
FROM INT$DBA_JSON_COLUMNS, 
     TABLE(SYS.dg$getFlatDg(OWNER, TABLE_NAME, COLUMN_NAME)) JT
WHERE SYS.dg$hasDGIndex(OWNER, TABLE_NAME, COLUMN_NAME) > 0
/

CREATE OR REPLACE VIEW DBA_JSON_DATAGUIDE_FIELDS
  (OWNER, TABLE_NAME, COLUMN_NAME, PATH, TYPE, LENGTH) AS
SELECT OWNER, TABLE_NAME, COLUMN_NAME, PATH, TYPE, LENGTH
FROM INT$DBA_JSON_DG_COLS
/
grant select on DBA_JSON_DATAGUIDE_FIELDS to select_catalog_role;
create or replace public synonym DBA_JSON_DATAGUIDE_FIELDS 
                                 for DBA_JSON_DATAGUIDE_FIELDS;

execute CDBView.create_cdbview(false,'SYS','DBA_JSON_DATAGUIDE_FIELDS', 'CDB_JSON_DATAGUIDE_FIELDS');
grant select on SYS.CDB_JSON_DATAGUIDE_FIELDS to select_catalog_role
/
create or replace public synonym CDB_JSON_DATAGUIDE_FIELDS 
                                 for SYS.CDB_JSON_DATAGUIDE_FIELDS
/

CREATE OR REPLACE VIEW USER_JSON_DATAGUIDE_FIELDS
  (TABLE_NAME, COLUMN_NAME, PATH, TYPE, LENGTH)
AS
SELECT TABLE_NAME, COLUMN_NAME, PATH, TYPE, LENGTH
FROM INT$DBA_JSON_DG_COLS
WHERE NLSSORT(OWNER, 'NLS_SORT=BINARY') = 
      NLSSORT(SYS_CONTEXT('USERENV', 'CURRENT_USER'), 'NLS_SORT=BINARY')
/

grant read on USER_JSON_DATAGUIDE_FIELDS to public;
create or replace public synonym USER_JSON_DATAGUIDE_FIELDS 
                                 for USER_JSON_DATAGUIDE_FIELDS;


CREATE OR REPLACE VIEW ALL_JSON_DATAGUIDE_FIELDS
  (OWNER, TABLE_NAME, COLUMN_NAME, PATH, TYPE, LENGTH)
AS
SELECT OWNER, TABLE_NAME, COLUMN_NAME, PATH, TYPE, LENGTH
FROM INT$DBA_JSON_DG_COLS
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
grant read on ALL_JSON_DATAGUIDE_FIELDS to public;
create or replace public synonym ALL_JSON_DATAGUIDE_FIELDS 
                                 for ALL_JSON_DATAGUIDE_FIELDS;

@?/rdbms/admin/sqlsessend.sql
