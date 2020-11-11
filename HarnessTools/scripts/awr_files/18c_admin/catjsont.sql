Rem
Rem $Header: rdbms/admin/catjsont.sql /main/25 2017/10/25 18:01:33 raeburns Exp $
Rem
Rem catjsont.sql
Rem
Rem Copyright (c) 2014, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catjsont.sql - new opaque types to work with JSON in PL/SQL
Rem
Rem    DESCRIPTION
Rem      new opaque types to work with JSON in PL/SQL
Rem      also creates the object types that wrap the dom
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/catjsont.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/catjsont.sql 
Rem    SQL_PHASE: CATJSONT
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    10/20/17 - RTI 20225108: Fix SQL_METADATA
Rem    jspiegel    06/28/17 - add merge patch
Rem    bhammers    03/23/17 - bug 25775218, make types not persitable
Rem    bhammers    05/10/16 - bug 23254935, 
Rem                         - insert/overwrite mode for array
Rem    bhammers    03/08/16 - 22896662: add underscore
Rem    bhammers    01/05/16 - plsql compiler warnings, performance
Rem                           rename count to getSize
Rem    bhammers    01/11/15 - remove boolean param from object/array constructor
Rem                         - getClob procedure instead of function
Rem                         - deactive setLob for now, values till 32k supported
Rem    bhammers    10/06/15 - bug 21936972: support lob input (parse)
Rem    bhammers    09/31/15 - add parameter to not init object/array
Rem    bhammers    06/17/15 - reference semantics
Rem    bhammers    06/30/15 - bug 21351469
Rem    bhammers    06/29/15 - bug 21344897
Rem    bhammers    06/23/15 - bug 21184888, use invokers rights 
Rem    raeburns    06/17/15 - Use FORCE for types with only type dependents
Rem    bhammers    05/11/15 - bug 21029414
Rem    bhammers    04/16/15 - bugs 20894745, 20878130, 20895484
Rem    bhammers    04/01/15 - bug 20691301, fix getString for array
Rem    bhammers    03/25/15 - add patch/select(redact)
Rem    bhammers    03/24/15 - bug 20704694: add getKeys() 
Rem    bhammers    03/10/15 - add more stuff
Rem    bhammers    10/13/14 - Created
Rem
REM  ***************************************
REM  THIS PACKAGE MUST BE CREATED UNDER SYS
REM  ***************************************

@@?/rdbms/admin/sqlsessstart.sql

--alter session set plsql_warnings = 'ENABLE:ALL';

-- ====>>> TODO: which functions are 'deterministic' ? <=====

-- comment out below lines to make this script rerunnable
--drop type JSON_Object_T;
--drop type JSON_Array_T;
--drop type JSON_Scalar_T;
--drop type JSON_Element_T;
--drop type JDOM_T force;


CREATE OR REPLACE LIBRARY DBMS_JDOM_LIB TRUSTED AS STATIC;
/

CREATE OR REPLACE TYPE JSON_KEY_LIST FORCE AS VARRAY(32767) OF VARCHAR2(4000);
/

CREATE OR REPLACE PUBLIC SYNONYM JSON_KEY_LIST FOR sys.JSON_KEY_LIST
/
GRANT EXECUTE ON JSON_KEY_LIST TO public
/

CREATE OR REPLACE TYPE JDOM_T FORCE 
 OID '00000000000000000000000000020016' AUTHID DEFINER AS 
 OPAQUE VARYING (*) USING library DBMS_JDOM_LIB
(
  /* parse from string */
  STATIC FUNCTION  parse(jsn IN varchar2) return JDOM_T,  
  STATIC FUNCTION  parse(jsn IN CLOB) return JDOM_T, 
  STATIC FUNCTION  parse(jsn IN BLOB) return JDOM_T, 

  /* create empty object/array*/      
  STATIC FUNCTION  create_Obj return JDOM_T,
  STATIC FUNCTION  create_Arr return JDOM_T,

  /* serialize, convert */
  MEMBER FUNCTION  stringify      return VARCHAR2,
  MEMBER FUNCTION  to_String      return VARCHAR2,
  MEMBER FUNCTION  to_Clob(c CLOB) return CLOB, 
  MEMBER FUNCTION  to_Blob(b BLOB) return BLOB, 

  MEMBER FUNCTION  to_Boolean   return BOOLEAN,
  MEMBER FUNCTION  to_Number    return NUMBER,
  MEMBER FUNCTION  to_Date      return DATE,
  MEMBER FUNCTION  to_Timestamp return TIMESTAMP,

  /* introspection */
  MEMBER FUNCTION  is_Object    return BOOLEAN,
  MEMBER FUNCTION  is_Array     return BOOLEAN,  

  MEMBER FUNCTION  is_Scalar    return BOOLEAN,
  MEMBER FUNCTION  is_String    return BOOLEAN,    
  MEMBER FUNCTION  is_Number    return BOOLEAN,
  MEMBER FUNCTION  is_Boolean   return BOOLEAN,
  MEMBER FUNCTION  is_True      return BOOLEAN,
  MEMBER FUNCTION  is_False     return BOOLEAN,
  MEMBER FUNCTION  is_Null      return BOOLEAN,
  MEMBER FUNCTION  is_Date      return BOOLEAN,
  MEMBER FUNCTION  is_Timestamp return BOOLEAN,
  -- todo oranum, etc

  MEMBER FUNCTION  get_Size RETURN NUMBER,
 
  MEMBER FUNCTION  clone RETURN JDOM_T, 

  /* error handling, can be combined like flags (3 = 1+2) */
  /* 0: raise no error  */
  /* 1: raise error on missing key */
  /* 2: raise on type mismatch  */
  MEMBER FUNCTION  on_Error(val NUMBER) RETURN BOOLEAN,
  
  /* object functions */
  MEMBER FUNCTION  put(key VARCHAR2, val VARCHAR2) RETURN BOOLEAN,

  MEMBER FUNCTION  put(key VARCHAR2, val NUMBER) RETURN BOOLEAN,
  MEMBER FUNCTION  put(key VARCHAR2, val BOOLEAN) RETURN BOOLEAN,
  MEMBER FUNCTION  put(key VARCHAR2, val DATE) RETURN BOOLEAN,
  MEMBER FUNCTION  put(key VARCHAR2, val TIMESTAMP) RETURN BOOLEAN,
  --MEMBER FUNCTION  put(key VARCHAR2, val CLOB) RETURN BOOLEAN,
  --MEMBER FUNCTION  put(key VARCHAR2, val BLOB) RETURN BOOLEAN,
  MEMBER FUNCTION  put(key VARCHAR2, val JDOM_T) RETURN BOOLEAN,
  MEMBER FUNCTION  put_Null(key VARCHAR2) RETURN BOOLEAN,

  MEMBER FUNCTION  get(key VARCHAR2) RETURN JDOM_T,
  MEMBER FUNCTION  get_String(key VARCHAR2) RETURN VARCHAR2,
  MEMBER FUNCTION  get_Number(key VARCHAR2) RETURN NUMBER,
  MEMBER FUNCTION  get_Boolean(key VARCHAR2) RETURN BOOLEAN,
  MEMBER FUNCTION  get_Date(key VARCHAR2) RETURN DATE,
  MEMBER FUNCTION  get_Timestamp(key VARCHAR2) RETURN TIMESTAMP,
  MEMBER FUNCTION  get_Clob(key VARCHAR2, c CLOB) RETURN CLOB,
  MEMBER FUNCTION  get_Blob(key VARCHAR2, b BLOB) RETURN BLOB,

  MEMBER FUNCTION  has_Key(key VARCHAR2) RETURN BOOLEAN,
  MEMBER FUNCTION  get_Keys RETURN JSON_KEY_LIST,
  MEMBER FUNCTION  get_Type(key VARCHAR2) RETURN VARCHAR2,
  MEMBER FUNCTION  remove(key VARCHAR2) RETURN BOOLEAN,
  MEMBER FUNCTION  rename_Key(keyOld VARCHAR2, keyNew VARCHAR2) RETURN BOOLEAN,

  /* array functions*/
  MEMBER FUNCTION  append(val VARCHAR2) RETURN BOOLEAN,
  MEMBER FUNCTION  append(val NUMBER) RETURN BOOLEAN,
  MEMBER FUNCTION  append(val BOOLEAN) RETURN BOOLEAN,    
  MEMBER FUNCTION  append(val DATE) RETURN BOOLEAN,    
  MEMBER FUNCTION  append(val TIMESTAMP) RETURN BOOLEAN,  
  --MEMBER FUNCTION  append(val CLOB) RETURN BOOLEAN,  
  --MEMBER FUNCTION  append(val BLOB) RETURN BOOLEAN,  
  MEMBER FUNCTION  append(val JDOM_T) RETURN BOOLEAN,
  MEMBER FUNCTION  append_Null RETURN BOOLEAN,

  MEMBER FUNCTION  put(pos NUMBER, val VARCHAR2, overwrite BOOLEAN) 
                   RETURN BOOLEAN,
  MEMBER FUNCTION  put(pos NUMBER, val NUMBER, overwrite BOOLEAN) 
                   RETURN BOOLEAN,
  MEMBER FUNCTION  put(pos NUMBER, val BOOLEAN, overwrite BOOLEAN) 
                   RETURN BOOLEAN,
  MEMBER FUNCTION  put(pos NUMBER, val DATE, overwrite BOOLEAN) 
                   RETURN BOOLEAN,
  MEMBER FUNCTION  put(pos NUMBER, val TIMESTAMP, overwrite BOOLEAN) 
                   RETURN BOOLEAN,
  --MEMBER FUNCTION  put(pos NUMBER, val CLOB, overwrite BOOLEAN) 
  --                 RETURN BOOLEAN,
  --MEMBER FUNCTION  put(pos NUMBER, val BLOB, overwrite BOOLEAN) 
  --                 RETURN BOOLEAN,
  MEMBER FUNCTION  put(pos NUMBER, val JDOM_T, overwrite BOOLEAN) 
                   RETURN BOOLEAN,
  MEMBER FUNCTION  put_Null(pos NUMBER, overwrite BOOLEAN) RETURN BOOLEAN,

  MEMBER FUNCTION  get(pos NUMBER) RETURN JDOM_T,
  MEMBER FUNCTION  get_String(pos NUMBER) RETURN VARCHAR2,  
  MEMBER FUNCTION  get_Number(pos NUMBER) RETURN NUMBER,  
  MEMBER FUNCTION  get_Boolean(pos NUMBER) RETURN BOOLEAN,    
  MEMBER FUNCTION  get_Date(pos NUMBER) RETURN DATE,
  MEMBER FUNCTION  get_Timestamp(pos NUMBER) RETURN TIMESTAMP,
  MEMBER FUNCTION  get_Clob(pos NUMBER, c CLOB) RETURN CLOB,
  MEMBER FUNCTION  get_Blob(pos NUMBER, b BLOB) RETURN BLOB,

  MEMBER FUNCTION  get_Type(pos NUMBER) RETURN VARCHAR2,
  MEMBER FUNCTION  remove(pos NUMBER) RETURN BOOLEAN,

  /* modification ('select' is called 'redact') */
  MEMBER FUNCTION  patch(spec VARCHAR2) RETURN BOOLEAN,
  MEMBER FUNCTION  mergepatch(patch VARCHAR2) RETURN BOOLEAN,
  MEMBER FUNCTION  redact(spec VARCHAR2) RETURN BOOLEAN,
  MEMBER FUNCTION  patch(spec JDOM_T) RETURN BOOLEAN,
  MEMBER FUNCTION  mergepatch(patch JDOM_T) RETURN BOOLEAN,
  MEMBER FUNCTION  redact(spec JDOM_T) RETURN BOOLEAN 
)  NOT PERSISTABLE
/
show errors;


CREATE OR REPLACE PUBLIC SYNONYM JDOM_T FOR sys.JDOM_T
/
GRANT EXECUTE ON JDOM_T TO public
/
-- #### TODO: only allow below types to use dom API


-- ==================================================================
-- Create the object types

CREATE OR REPLACE TYPE JSON_Element_T FORCE AUTHID CURRENT_USER AS OBJECT(   
   dom JDOM_T,
   STATIC FUNCTION  parse(jsn VARCHAR2) RETURN JSON_Element_T,
   STATIC FUNCTION  parse(jsn CLOB) RETURN JSON_Element_T,
   STATIC FUNCTION  parse(jsn BLOB) RETURN JSON_Element_T,

   MEMBER FUNCTION  stringify(self IN JSON_ELEMENT_T)   RETURN VARCHAR2,
   MEMBER FUNCTION  to_String(self IN JSON_ELEMENT_T)    RETURN VARCHAR2,
   MEMBER FUNCTION  to_Boolean(self IN JSON_ELEMENT_T)   RETURN BOOLEAN,
   MEMBER FUNCTION  to_Clob(self IN JSON_ELEMENT_T)      RETURN CLOB,
   MEMBER PROCEDURE to_Clob(self IN OUT NOCOPY JSON_ELEMENT_T, 
                            c IN OUT NOCOPY CLOB),
   MEMBER FUNCTION  to_Blob(self IN JSON_ELEMENT_T)      RETURN BLOB,
   MEMBER PROCEDURE to_Blob(self IN OUT NOCOPY JSON_ELEMENT_T, 
                            b IN OUT NOCOPY BLOB),
   MEMBER FUNCTION  to_Number(self IN JSON_ELEMENT_T)    RETURN NUMBER,
   MEMBER FUNCTION  to_Date (self IN JSON_ELEMENT_T)     RETURN DATE, 
   MEMBER FUNCTION  to_Timestamp(self IN JSON_ELEMENT_T) RETURN TIMESTAMP, 

   MEMBER FUNCTION  is_Object(self IN JSON_ELEMENT_T)     RETURN BOOLEAN,
   MEMBER FUNCTION  is_Array(self IN JSON_ELEMENT_T)      RETURN BOOLEAN,
   MEMBER FUNCTION  is_Scalar(self IN JSON_ELEMENT_T)     RETURN BOOLEAN,
   MEMBER FUNCTION  is_String(self IN JSON_ELEMENT_T)     RETURN BOOLEAN,    
   MEMBER FUNCTION  is_Number(self IN JSON_ELEMENT_T)     RETURN BOOLEAN,
   MEMBER FUNCTION  is_Boolean(self IN JSON_ELEMENT_T)    RETURN BOOLEAN,
   MEMBER FUNCTION  is_True(self IN JSON_ELEMENT_T)       RETURN BOOLEAN,
   MEMBER FUNCTION  is_False(self IN JSON_ELEMENT_T)      RETURN BOOLEAN,
   MEMBER FUNCTION  is_Null(self IN JSON_ELEMENT_T)       RETURN BOOLEAN,
   MEMBER FUNCTION  is_Date(self IN JSON_ELEMENT_T)       RETURN BOOLEAN,
   MEMBER FUNCTION  is_Timestamp(self IN JSON_ELEMENT_T)  RETURN BOOLEAN,

   MEMBER FUNCTION  get_Size(self IN JSON_ELEMENT_T) RETURN NUMBER,
   MEMBER PROCEDURE on_Error(self IN OUT NOCOPY JSON_ELEMENT_T, val NUMBER),
   MEMBER PROCEDURE patch(self IN OUT NOCOPY JSON_ELEMENT_T, spec VARCHAR2),
   MEMBER PROCEDURE mergepatch(self IN OUT NOCOPY JSON_ELEMENT_T, patch VARCHAR2),
   MEMBER PROCEDURE redact(self IN OUT NOCOPY JSON_ELEMENT_T, spec VARCHAR2),
   MEMBER PROCEDURE patch(self IN OUT NOCOPY JSON_ELEMENT_T, 
                          spec JSON_Element_T),
   MEMBER PROCEDURE mergepatch(self IN OUT NOCOPY JSON_ELEMENT_T, 
                          patch JSON_Element_T),
   MEMBER PROCEDURE redact(self IN OUT NOCOPY JSON_ELEMENT_T, 
                           spec JSON_Element_T)
) NOT FINAL NOT INSTANTIABLE NOT PERSISTABLE
/
show errors;

CREATE OR REPLACE TYPE JSON_Array_T FORCE AUTHID CURRENT_USER 
                       UNDER JSON_Element_T(
   dummy NUMBER,
   CONSTRUCTOR FUNCTION JSON_Array_T(self IN OUT JSON_ARRAY_T) 
                        RETURN SELF AS RESULT,
   CONSTRUCTOR FUNCTION JSON_Array_T(self IN OUT JSON_ARRAY_T, jsn VARCHAR2) 
                        RETURN SELF AS RESULT,
   CONSTRUCTOR FUNCTION JSON_Array_T(self IN OUT JSON_ARRAY_T, jsn JDOM_T) 
                        RETURN SELF AS RESULT,      
   CONSTRUCTOR FUNCTION JSON_Array_T(self IN OUT JSON_ARRAY_T, jsn CLOB) 
                        RETURN SELF AS RESULT,
   CONSTRUCTOR FUNCTION JSON_Array_T(self IN OUT JSON_ARRAY_T, jsn BLOB) 
                        RETURN SELF AS RESULT,
   CONSTRUCTOR FUNCTION JSON_Array_T(self IN OUT JSON_ARRAY_T, e JSON_ELEMENT_T)
                        RETURN SELF AS RESULT,
   
   -- override the 'parse' functions to directly RETURN Json_Array_T
   STATIC      FUNCTION  parse(jsn VARCHAR2) RETURN Json_Array_T,
   STATIC      FUNCTION  parse(jsn CLOB) RETURN Json_Array_T,
   STATIC      FUNCTION  parse(jsn BLOB) RETURN Json_Array_T,

   MEMBER      FUNCTION  clone(self IN JSON_ARRAY_T) RETURN JSON_ARRAY_T,

   MEMBER      FUNCTION  get(self IN JSON_ARRAY_T, pos NUMBER) 
                         RETURN JSON_Element_T,
   MEMBER      FUNCTION  get_String(self IN JSON_ARRAY_T, pos NUMBER) 
                         RETURN VARCHAR2,
   MEMBER      FUNCTION  get_Number(self IN JSON_ARRAY_T, pos NUMBER) 
                         RETURN NUMBER,
   MEMBER      FUNCTION  get_Boolean(self IN JSON_ARRAY_T, pos NUMBER) 
                         RETURN BOOLEAN,
   MEMBER      FUNCTION  get_Date(self IN JSON_ARRAY_T, pos NUMBER) 
                         RETURN DATE,
   MEMBER      FUNCTION  get_Timestamp(self IN JSON_ARRAY_T, pos NUMBER) 
                         RETURN TIMESTAMP,
   MEMBER      FUNCTION  get_Clob(self IN JSON_ARRAY_T, pos NUMBER) RETURN CLOB,
   MEMBER      PROCEDURE get_Clob(self IN OUT NOCOPY JSON_ARRAY_T, pos NUMBER,  
                                  c IN OUT NOCOPY CLOB),
   MEMBER      FUNCTION  get_Blob(self IN JSON_ARRAY_T, pos NUMBER) RETURN BLOB,
   MEMBER      PROCEDURE get_Blob(self IN OUT NOCOPY JSON_ARRAY_T, pos NUMBER, 
                                  b IN OUT NOCOPY BLOB),

 -- append at the end of array (no position needed)
   MEMBER      PROCEDURE append(self IN OUT NOCOPY JSON_ARRAY_T, val VARCHAR2),
   MEMBER      PROCEDURE append(self IN OUT NOCOPY JSON_ARRAY_T, val NUMBER),
   MEMBER      PROCEDURE append(self IN OUT NOCOPY JSON_ARRAY_T, val BOOLEAN),
   MEMBER      PROCEDURE append(self IN OUT NOCOPY JSON_ARRAY_T, val DATE),
   MEMBER      PROCEDURE append(self IN OUT NOCOPY JSON_ARRAY_T, val TIMESTAMP),
   --MEMBER      PROCEDURE append(val CLOB),
   --MEMBER      PROCEDURE append(val BLOB),
   MEMBER      PROCEDURE append(self IN OUT NOCOPY JSON_ARRAY_T, 
                                val JSON_Element_T),
   MEMBER      PROCEDURE append_Null(self IN OUT NOCOPY JSON_ARRAY_T),
 
   MEMBER      PROCEDURE put(self IN OUT NOCOPY JSON_ARRAY_T, pos NUMBER, 
                             val VARCHAR2, overwrite BOOLEAN DEFAULT FALSE),
   MEMBER      PROCEDURE put(self IN OUT NOCOPY JSON_ARRAY_T, pos NUMBER, 
                             val NUMBER, overwrite BOOLEAN DEFAULT FALSE),
   MEMBER      PROCEDURE put(self IN OUT NOCOPY JSON_ARRAY_T, pos NUMBER, 
                             val BOOLEAN, overwrite BOOLEAN DEFAULT FALSE),
   MEMBER      PROCEDURE put(self IN OUT NOCOPY JSON_ARRAY_T, pos NUMBER, 
                             val DATE, overwrite BOOLEAN DEFAULT FALSE),
   MEMBER      PROCEDURE put(self IN OUT NOCOPY JSON_ARRAY_T, pos NUMBER, 
                             val TIMESTAMP, overwrite BOOLEAN DEFAULT FALSE), 
   --MEMBER      PROCEDURE put(pos NUMBER, val CLOB, 
   --                            overwrite BOOLEAN DEFAULT FALSE),
   --MEMBER      PROCEDURE put(pos NUMBER, val BLOB, 
   --                           overwrite BOOLEAN DEFAULT FALSE),
   MEMBER      PROCEDURE put(self IN OUT NOCOPY JSON_ARRAY_T, pos NUMBER, 
                             val JSON_Element_T, 
                             overwrite BOOLEAN DEFAULT FALSE),
   MEMBER      PROCEDURE put_Null(self IN OUT NOCOPY JSON_ARRAY_T, pos NUMBER, 
                                  overwrite BOOLEAN DEFAULT FALSE),

   MEMBER      PROCEDURE remove(self IN OUT NOCOPY JSON_ARRAY_T, pos NUMBER),
   MEMBER      FUNCTION  get_Type(self IN JSON_ARRAY_T, pos NUMBER) 
                         RETURN VARCHAR2
) FINAL
/
show errors;

CREATE OR REPLACE TYPE JSON_Object_T AUTHID CURRENT_USER UNDER JSON_Element_T(
   dummy NUMBER, 
   CONSTRUCTOR FUNCTION JSON_Object_T(self IN OUT JSON_OBJECT_T) 
                        RETURN SELF AS RESULT,
   CONSTRUCTOR FUNCTION JSON_Object_T(self IN OUT JSON_OBJECT_T, jsn JDOM_T) 
                        RETURN SELF AS RESULT,     
   CONSTRUCTOR FUNCTION JSON_Object_T(self IN OUT JSON_OBJECT_T, jsn VARCHAR2) 
                        RETURN SELF AS RESULT,
   CONSTRUCTOR FUNCTION JSON_Object_T(self IN OUT JSON_OBJECT_T, jsn CLOB) 
                        RETURN SELF AS RESULT,
   CONSTRUCTOR FUNCTION JSON_Object_T(self IN OUT JSON_OBJECT_T, jsn BLOB) 
                        RETURN SELF AS RESULT,
   CONSTRUCTOR FUNCTION JSON_Object_T(self IN OUT JSON_OBJECT_T, 
                                      e JSON_ELEMENT_T) RETURN SELF AS RESULT,  

   -- override the 'parse' functions to directly RETURN Json_Object_T
   STATIC      FUNCTION  parse(jsn VARCHAR2) RETURN Json_Object_T,
   STATIC      FUNCTION  parse(jsn CLOB) RETURN Json_Object_T,
   STATIC      FUNCTION  parse(jsn BLOB) RETURN Json_Object_T,

   MEMBER      FUNCTION  clone RETURN JSON_OBJECT_T,

   MEMBER      FUNCTION  get(self IN JSON_OBJECT_T, key VARCHAR2) 
                         RETURN JSON_Element_T,
   MEMBER      FUNCTION  get_Object(self IN JSON_OBJECT_T, key VARCHAR2) 
                         RETURN JSON_OBJECT_T,
   MEMBER      FUNCTION  get_Array(self IN JSON_OBJECT_T, key VARCHAR2) 
                         RETURN JSON_ARRAY_T,
   MEMBER      FUNCTION  get_String(self IN JSON_OBJECT_T, key VARCHAR2) 
                         RETURN VARCHAR2,
   MEMBER      FUNCTION  get_Number(self IN JSON_OBJECT_T, key VARCHAR2) 
                         RETURN NUMBER,
   MEMBER      FUNCTION  get_Boolean(self IN JSON_OBJECT_T, key VARCHAR2) 
                         RETURN BOOLEAN,
   MEMBER      FUNCTION  get_Date(self IN JSON_OBJECT_T, key VARCHAR2) 
                         RETURN DATE,
   MEMBER      FUNCTION  get_Timestamp(self IN JSON_OBJECT_T, key VARCHAR2) 
                         RETURN TIMESTAMP,
   MEMBER      FUNCTION  get_Clob(self IN JSON_OBJECT_T, key VARCHAR2) 
                         RETURN CLOB,
   MEMBER      PROCEDURE get_Clob(self IN OUT NOCOPY JSON_OBJECT_T, 
                                  key VARCHAR2, c IN OUT NOCOPY CLOB),
   MEMBER      FUNCTION  get_Blob(self IN JSON_OBJECT_T, key VARCHAR2) 
                         RETURN BLOB,
   MEMBER      PROCEDURE get_Blob(self IN OUT NOCOPY JSON_OBJECT_T, 
                                 key VARCHAR2, b IN OUT NOCOPY BLOB),
   MEMBER      PROCEDURE put(self IN OUT NOCOPY JSON_OBJECT_T, key VARCHAR2, 
                             val VARCHAR2),
   MEMBER      PROCEDURE put(self IN OUT NOCOPY JSON_OBJECT_T, key VARCHAR2, 
                             val NUMBER),
   MEMBER      PROCEDURE put(self IN OUT NOCOPY JSON_OBJECT_T, key VARCHAR2, 
                             val BOOLEAN),
   MEMBER      PROCEDURE put(self IN OUT NOCOPY JSON_OBJECT_T, key VARCHAR2, 
                             val DATE),
   MEMBER      PROCEDURE put(self IN OUT NOCOPY JSON_OBJECT_T, key VARCHAR2, 
                             val TIMESTAMP),
   --MEMBER      PROCEDURE put(key VARCHAR2, val CLOB),
   --MEMBER      PROCEDURE put(key VARCHAR2, val BLOB),
   MEMBER      PROCEDURE put(self IN OUT NOCOPY JSON_OBJECT_T, key VARCHAR2, 
                             val JSON_Element_T),
   MEMBER      PROCEDURE put_Null(self IN OUT NOCOPY JSON_OBJECT_T, 
                                 key VARCHAR2),
   MEMBER      FUNCTION  has(self IN JSON_OBJECT_T, key VARCHAR2) 
                         RETURN BOOLEAN,
   MEMBER      PROCEDURE remove(self IN OUT NOCOPY JSON_OBJECT_T, key VARCHAR2),
   MEMBER      FUNCTION  get_Type(self IN JSON_OBJECT_T, key VARCHAR2) 
                         RETURN VARCHAR2,
   MEMBER      FUNCTION  get_Keys(self IN JSON_OBJECT_T) RETURN JSON_KEY_LIST,
   MEMBER      PROCEDURE rename_Key(self IN OUT NOCOPY JSON_OBJECT_T, 
                                   keyOld VARCHAR2, keyNew VARCHAR2)
) FINAL
/
show errors;

CREATE OR REPLACE TYPE JSON_Scalar_T AUTHID CURRENT_USER UNDER JSON_Element_T(
   dummy NUMBER,
  
   CONSTRUCTOR FUNCTION JSON_Scalar_T(self IN OUT JSON_SCALAR_T, 
                                      jsn JDOM_T)  RETURN SELF AS RESULT,   
  
   CONSTRUCTOR FUNCTION JSON_Scalar_T(self IN OUT JSON_SCALAR_T, 
                                      e JSON_ELEMENT_T) RETURN SELF AS RESULT,

   MEMBER      FUNCTION  clone(self IN JSON_SCALAR_T) RETURN JSON_SCALAR_T

) FINAL
/
show errors;

CREATE OR REPLACE PUBLIC SYNONYM JSON_Element_T FOR sys.JSON_Element_T
/
GRANT EXECUTE ON JSON_Element_T TO public
/

CREATE OR REPLACE PUBLIC SYNONYM JSON_Object_T FOR sys.JSON_Object_T
/
GRANT EXECUTE ON JSON_Object_T TO public
/

CREATE OR REPLACE PUBLIC SYNONYM JSON_Array_T FOR sys.JSON_Array_T
/
GRANT EXECUTE ON JSON_Array_T TO public
/

CREATE OR REPLACE PUBLIC SYNONYM JSON_Scalar_T FOR sys.JSON_Scalar_T
/
GRANT EXECUTE ON JSON_Scalar_T TO public
/


-- ======================================
-- BODY Implementations

CREATE OR REPLACE TYPE BODY JDOM_T AS
 -- todo empty arry       
 -- parses string to dom
 STATIC FUNCTION parse(jsn IN varchar2) RETURN JDOM_T is EXTERNAL
    name "parse" library DBMS_JDOM_LIB WITH CONTEXT
    parameters(context, jsn OCIString, jsn INDICATOR sb4,
               RETURN DURATION OCIDuration, RETURN INDICATOR sb4, return);

STATIC FUNCTION parse(jsn IN CLOB) RETURN JDOM_T is EXTERNAL
    name "parseClob" library DBMS_JDOM_LIB WITH CONTEXT
    parameters(context, jsn OCILobLocator, jsn INDICATOR sb4,
               RETURN DURATION OCIDuration, RETURN INDICATOR sb4, return);

STATIC FUNCTION parse(jsn IN BLOB) RETURN JDOM_T is EXTERNAL
    name "parseBlob" library DBMS_JDOM_LIB WITH CONTEXT
    parameters(context, jsn OCILobLocator, jsn INDICATOR sb4,
               RETURN DURATION OCIDuration, RETURN INDICATOR sb4, return);

 -- creates an empty dom (object)
 STATIC FUNCTION create_Obj RETURN JDOM_T is EXTERNAL
    name "createObj" library DBMS_JDOM_LIB WITH CONTEXT
    parameters(context, RETURN DURATION OCIDuration, 
               RETURN INDICATOR sb4, return);
 
  -- creates an empty dom (object)
 STATIC FUNCTION create_Arr RETURN JDOM_T is EXTERNAL
    name "createArr" library DBMS_JDOM_LIB WITH CONTEXT
    parameters(context, RETURN DURATION OCIDuration, 
               RETURN INDICATOR sb4, return);

  MEMBER FUNCTION stringify RETURN VARCHAR2 is EXTERNAL
    name "stringify" library DBMS_JDOM_LIB WITH CONTEXT
    parameters(context, self, self INDICATOR sb2, 
        RETURN INDICATOR sb4, RETURN OCIString);

  MEMBER FUNCTION to_String RETURN VARCHAR2 is EXTERNAL
    name "toString" library DBMS_JDOM_LIB WITH CONTEXT
    parameters(context, self, self INDICATOR sb2, 
        RETURN INDICATOR sb4, RETURN OCIString);

  MEMBER FUNCTION to_Number RETURN NUMBER IS EXTERNAL
     name "toNumber" library DBMS_JDOM_LIB WITH CONTEXT
     parameters(context, self, self INDICATOR sb2, 
        RETURN INDICATOR sb4, return);   

  MEMBER FUNCTION to_Clob(c CLOB) return CLOB IS EXTERNAL
     name "toClob" library DBMS_JDOM_LIB WITH CONTEXT
     parameters(context, self, self INDICATOR sb2, 
        c OCILobLocator, c INDICATOR sb2,
        RETURN DURATION OCIDuration,
        RETURN INDICATOR sb4, return);     

  MEMBER FUNCTION to_Blob(b BLOB) return BLOB IS EXTERNAL
     name "toBlob" library DBMS_JDOM_LIB WITH CONTEXT
     parameters(context, self, self INDICATOR sb2, 
        b OCILobLocator, b INDICATOR sb2,
        RETURN DURATION OCIDuration,
        RETURN INDICATOR sb4, return);   

  MEMBER FUNCTION to_Boolean RETURN BOOLEAN IS EXTERNAL
     name "toBoolean" library DBMS_JDOM_LIB WITH CONTEXT
     parameters(context, self, self INDICATOR sb2, 
        RETURN INDICATOR sb4, return);   

  MEMBER FUNCTION to_Date RETURN DATE IS EXTERNAL
     name "toDate" library DBMS_JDOM_LIB WITH CONTEXT
     parameters(context, self, self INDICATOR sb2, 
        RETURN INDICATOR sb4, return);   

  MEMBER FUNCTION to_Timestamp RETURN TIMESTAMP IS EXTERNAL
     name "toTStamp" library DBMS_JDOM_LIB WITH CONTEXT
     parameters(context, self, self INDICATOR sb2, 
        RETURN INDICATOR sb4, return OCIDateTime);  
 
  MEMBER FUNCTION is_Object RETURN BOOLEAN is EXTERNAL
     name "isObject" library DBMS_JDOM_LIB WITH CONTEXT
    parameters(context, self, self INDICATOR sb2, 
        RETURN INDICATOR sb4, return);   
   
   MEMBER FUNCTION is_Array RETURN BOOLEAN is EXTERNAL
     name "isArray" library DBMS_JDOM_LIB WITH CONTEXT
     parameters(context, self, self INDICATOR sb2, 
        RETURN INDICATOR sb4, return);  

   MEMBER FUNCTION is_Scalar RETURN BOOLEAN is EXTERNAL
     name "isScalar" library DBMS_JDOM_LIB WITH CONTEXT
     parameters(context, self, self INDICATOR sb2, 
        RETURN INDICATOR sb4, return);    

   MEMBER FUNCTION is_String RETURN BOOLEAN is EXTERNAL
     name "isString" library DBMS_JDOM_LIB WITH CONTEXT
     parameters(context, self, self INDICATOR sb2, 
        RETURN INDICATOR sb4, return); 

   MEMBER FUNCTION is_Number RETURN BOOLEAN is EXTERNAL
     name "isNumber" library DBMS_JDOM_LIB WITH CONTEXT
     parameters(context, self, self INDICATOR sb2, 
        RETURN INDICATOR sb4, return); 

   MEMBER FUNCTION is_Boolean RETURN BOOLEAN is EXTERNAL
     name "isBoolean" library DBMS_JDOM_LIB WITH CONTEXT
     parameters(context, self, self INDICATOR sb2, 
        RETURN INDICATOR sb4, return); 

   MEMBER FUNCTION is_True RETURN BOOLEAN is EXTERNAL
     name "isTrue" library DBMS_JDOM_LIB WITH CONTEXT
     parameters(context, self, self INDICATOR sb2, 
        RETURN INDICATOR sb4, return); 

   MEMBER FUNCTION is_False RETURN BOOLEAN is EXTERNAL
     name "isFalse" library DBMS_JDOM_LIB WITH CONTEXT
     parameters(context, self, self INDICATOR sb2, 
        RETURN INDICATOR sb4, return); 

  MEMBER FUNCTION is_Null RETURN BOOLEAN is EXTERNAL
     name "isNull" library DBMS_JDOM_LIB WITH CONTEXT
     parameters(context, self, self INDICATOR sb2, 
        RETURN INDICATOR sb4, return); 
  
  MEMBER FUNCTION is_Date RETURN BOOLEAN is EXTERNAL
     name "isDate" library DBMS_JDOM_LIB WITH CONTEXT
     parameters(context, self, self INDICATOR sb2, 
        RETURN INDICATOR sb4, return); 

  MEMBER FUNCTION is_Timestamp RETURN BOOLEAN is EXTERNAL
     name "isTStamp" library DBMS_JDOM_LIB WITH CONTEXT
     parameters(context, self, self INDICATOR sb2, 
        RETURN INDICATOR sb4, return); 

   MEMBER FUNCTION  get_Size RETURN NUMBER  is EXTERNAL
     name "getSize" library DBMS_JDOM_LIB WITH CONTEXT
     parameters(context, self, self INDICATOR sb2, 
        RETURN INDICATOR sb4, RETURN OCINumber);    
   
   MEMBER FUNCTION clone RETURN JDOM_T is EXTERNAL
     name "clone" library DBMS_JDOM_LIB WITH CONTEXT
     parameters(context, self, self INDICATOR sb2,
        return DURATION OCIDuration, return INDICATOR sb4, return);

   MEMBER FUNCTION on_Error(val NUMBER)  RETURN BOOLEAN is EXTERNAL
     name "onError" library DBMS_JDOM_LIB WITH CONTEXT
     parameters(context, self, self INDICATOR sb2,
               val OCINumber, val INDICATOR sb2,
        RETURN INDICATOR sb4, return);  

    -- returns TRUE iff object has the requested key
    MEMBER FUNCTION has_Key(key VARCHAR2) RETURN BOOLEAN is EXTERNAL
     name "hasKey_Obj" library DBMS_JDOM_LIB WITH CONTEXT
     parameters(context, self, self INDICATOR sb2, 
                key OCIString, key INDICATOR sb2,
                RETURN INDICATOR sb4, return);    

    MEMBER FUNCTION get_Keys RETURN JSON_KEY_LIST is EXTERNAL
     name "getKeys_Obj" library DBMS_JDOM_LIB WITH CONTEXT
     parameters(context, self, self INDICATOR sb2, 
                RETURN INDICATOR sb4, return); 

    MEMBER FUNCTION rename_Key(keyOld VARCHAR2, keyNew VARCHAR2) 
        RETURN BOOLEAN is EXTERNAL
     name "renameKey_Obj" library DBMS_JDOM_LIB WITH CONTEXT
     parameters(context, self, self INDICATOR sb2, 
                keyOld OCIString, keyOld INDICATOR sb2,
                keyNew OCIString, keyNew INDICATOR sb2,
                RETURN INDICATOR sb4, return);    

    MEMBER FUNCTION get_Type(key VARCHAR2) RETURN VARCHAR2 is EXTERNAL
     name "getType_Obj" library DBMS_JDOM_LIB WITH CONTEXT
     parameters(context, self, self INDICATOR sb2, 
                key OCIString, key INDICATOR sb2,
                RETURN INDICATOR sb4, RETURN OCIString);
    
    MEMBER FUNCTION get_Type(pos NUMBER) RETURN VARCHAR2 is EXTERNAL
     name "getType_Arr" library DBMS_JDOM_LIB WITH CONTEXT
     parameters(context, self, self INDICATOR sb2, 
                pos OCINumber, pos INDICATOR sb2,
                RETURN INDICATOR sb4, RETURN OCIString);

    MEMBER FUNCTION remove(key VARCHAR2) RETURN BOOLEAN is EXTERNAL
     name "remove_Obj" library DBMS_JDOM_LIB WITH CONTEXT
     parameters(context, self, self INDICATOR sb2, 
                key OCIString, key INDICATOR sb2,
                RETURN INDICATOR sb4, return);
  
     MEMBER FUNCTION remove(pos NUMBER) RETURN BOOLEAN is EXTERNAL
     name "remove_Arr" library DBMS_JDOM_LIB WITH CONTEXT
     parameters(context, self, self INDICATOR sb2, 
                pos OCINumber, pos INDICATOR sb2,
                RETURN INDICATOR sb4, return);

    -- the putters should be procedures instead of functions
   MEMBER FUNCTION put(key VARCHAR2, val VARCHAR2) RETURN BOOLEAN is EXTERNAL
     name "setString_Obj" library DBMS_JDOM_LIB WITH CONTEXT
     parameters(context, self, self INDICATOR sb2,
                       key OCIString, key INDICATOR sb2,
                       val OCIString, val INDICATOR sb2,
                       RETURN INDICATOR sb4, return);

    MEMBER FUNCTION put(key VARCHAR2, val NUMBER) RETURN BOOLEAN is EXTERNAL
     name "setNumber_Obj" library DBMS_JDOM_LIB WITH CONTEXT
     parameters(context, self, self INDICATOR sb2,
                       key OCIString, key INDICATOR sb2,
                       val OCINumber, val INDICATOR sb2,
                       RETURN INDICATOR sb4, return);

    MEMBER FUNCTION put(key VARCHAR2, val BOOLEAN) RETURN BOOLEAN is EXTERNAL
     name "setBoolean_Obj" library DBMS_JDOM_LIB WITH CONTEXT
     parameters(context, self, self INDICATOR sb2,
                       key OCIString, key INDICATOR sb2,
                       val, val INDICATOR sb2,
                       RETURN INDICATOR sb4, return);
  
    MEMBER FUNCTION put(key VARCHAR2, val DATE) RETURN BOOLEAN is EXTERNAL
     name "setDate_Obj" library DBMS_JDOM_LIB WITH CONTEXT
     parameters(context, self, self INDICATOR sb2,
                       key OCIString, key INDICATOR sb2,
                       val OCIDate, val INDICATOR sb2,
                       RETURN INDICATOR sb4, return);

    MEMBER FUNCTION put(key VARCHAR2, val TIMESTAMP) RETURN BOOLEAN 
                                                       IS EXTERNAL
     name "setTStamp_Obj" library DBMS_JDOM_LIB WITH CONTEXT
     parameters(context, self, self INDICATOR sb2,
                       key OCIString, key INDICATOR sb2,
                       val OCIDateTime, val INDICATOR sb2,
                       RETURN INDICATOR sb4, return);

     --MEMBER FUNCTION put(key VARCHAR2, val CLOB) RETURN BOOLEAN IS EXTERNAL
     --name "setClob_Obj" library DBMS_JDOM_LIB WITH CONTEXT
     --parameters(context, self, self INDICATOR sb2,
     --                  key OCIString, key INDICATOR sb2,
     --                  val OCILobLocator, val INDICATOR sb2,
     --                  RETURN INDICATOR sb4, return);

    --MEMBER FUNCTION put(key VARCHAR2, val BLOB) RETURN BOOLEAN IS EXTERNAL
    -- name "setBlob_Obj" library DBMS_JDOM_LIB WITH CONTEXT
    -- parameters(context, self, self INDICATOR sb2,
    --                   key OCIString, key INDICATOR sb2,
    --                   val OCILobLocator, val INDICATOR sb2,
    --                   RETURN INDICATOR sb4, return);

    MEMBER FUNCTION put(key VARCHAR2, val JDOM_T) RETURN BOOLEAN IS EXTERNAL
     name "set_Obj" library DBMS_JDOM_LIB WITH CONTEXT
     parameters(context, self, self INDICATOR sb2,
                       key OCIString, key INDICATOR sb2,
                       val, val INDICATOR sb2,
                       RETURN INDICATOR sb4, return);

    MEMBER FUNCTION put_Null(key VARCHAR2) RETURN BOOLEAN is EXTERNAL
     name "setNull_Obj" library DBMS_JDOM_LIB WITH CONTEXT
     parameters(context, self, self INDICATOR sb2,
                       key OCIString, key INDICATOR sb2,
                       RETURN INDICATOR sb4, return);

    -- put with pos
    MEMBER FUNCTION  put(pos NUMBER, val VARCHAR2, overwrite BOOLEAN) 
                     RETURN BOOLEAN is EXTERNAL
     name "setString_Arr" library DBMS_JDOM_LIB WITH CONTEXT
     parameters(context, self, self INDICATOR sb2,
                        pos OCINumber, pos INDICATOR sb2,
                        val OCIString, val INDICATOR sb2,
                        overwrite, overwrite  INDICATOR sb2,
                        RETURN INDICATOR sb4, return);

    MEMBER FUNCTION put(pos NUMBER, val NUMBER, overwrite BOOLEAN) 
                    RETURN BOOLEAN is EXTERNAL
     name "setNumber_Arr" library DBMS_JDOM_LIB WITH CONTEXT
     parameters(context, self, self INDICATOR sb2,
                        pos OCINumber, pos INDICATOR sb2,
                        val OCINumber, val INDICATOR sb2,
                        overwrite, overwrite  INDICATOR sb2,
                        RETURN INDICATOR sb4, return);

    MEMBER FUNCTION put(pos NUMBER, val BOOLEAN, overwrite BOOLEAN) 
                    RETURN BOOLEAN is EXTERNAL
     name "setBoolean_Arr" library DBMS_JDOM_LIB WITH CONTEXT
     parameters(context, self, self INDICATOR sb2,
                        pos OCINumber, pos INDICATOR sb2,
                        val, val INDICATOR sb2,
                        overwrite, overwrite  INDICATOR sb2,
                        RETURN INDICATOR sb4, return);

   MEMBER FUNCTION put(pos NUMBER, val DATE, overwrite BOOLEAN) 
                   RETURN BOOLEAN is EXTERNAL
     name "setBoolean_Arr" library DBMS_JDOM_LIB WITH CONTEXT
     parameters(context, self, self INDICATOR sb2,
                        pos OCINumber, pos INDICATOR sb2,
                        val OCIDate, val INDICATOR sb2,
                        overwrite, overwrite  INDICATOR sb2,
                        RETURN INDICATOR sb4, return);

    MEMBER FUNCTION put(pos NUMBER, val TIMESTAMP, overwrite BOOLEAN) 
                    RETURN BOOLEAN is EXTERNAL
     name "setTStamp_Arr" library DBMS_JDOM_LIB WITH CONTEXT
     parameters(context, self, self INDICATOR sb2,
                        pos OCINumber, pos INDICATOR sb2,
                        val OCIDateTime, val INDICATOR sb2,
                        overwrite, overwrite  INDICATOR sb2,
                        RETURN INDICATOR sb4, return);

    MEMBER FUNCTION put(pos NUMBER, val CLOB, overwrite BOOLEAN) 
                    RETURN BOOLEAN is EXTERNAL
     name "setClob_Arr" library DBMS_JDOM_LIB WITH CONTEXT
     parameters(context, self, self INDICATOR sb2,
                        pos OCINumber, pos INDICATOR sb2,
                        val OCILobLocator, val INDICATOR sb2,
                        overwrite, overwrite  INDICATOR sb2,
                        RETURN INDICATOR sb4, return);

    MEMBER FUNCTION put(pos NUMBER, val BLOB, overwrite BOOLEAN) 
                    RETURN BOOLEAN is EXTERNAL
     name "setBlob_Arr" library DBMS_JDOM_LIB WITH CONTEXT
     parameters(context, self, self INDICATOR sb2,
                        pos OCINumber, pos INDICATOR sb2,
                        val OCILobLocator, val INDICATOR sb2,
                        overwrite, overwrite  INDICATOR sb2,
                        RETURN INDICATOR sb4, return);

    MEMBER FUNCTION put(pos NUMBER, val JDOM_T, overwrite BOOLEAN) 
                    RETURN BOOLEAN is EXTERNAL
     name "set_Arr" library DBMS_JDOM_LIB WITH CONTEXT
     parameters(context, self, self INDICATOR sb2,
                        pos OCINumber, pos INDICATOR sb2,
                        val, val INDICATOR sb2,
                        overwrite, overwrite  INDICATOR sb2,
                        RETURN INDICATOR sb4, return);   

    MEMBER FUNCTION put_Null(pos NUMBER, overwrite BOOLEAN) 
                    RETURN BOOLEAN is EXTERNAL
     name "setNull_Arr" library DBMS_JDOM_LIB WITH CONTEXT
     parameters(context, self, self INDICATOR sb2,
                       pos OCINumber, pos INDICATOR sb2,
                       overwrite, overwrite  INDICATOR sb2,
                       RETURN INDICATOR sb4, return);

 
   -- append (end of array)   
    MEMBER FUNCTION append(val JDOM_T) RETURN BOOLEAN is EXTERNAL
     name "add_Arr" library DBMS_JDOM_LIB WITH CONTEXT
     parameters(context, self, self INDICATOR sb2,
                        val, val INDICATOR sb2,
                        RETURN INDICATOR sb4, return);
    
    MEMBER FUNCTION append(val VARCHAR2) RETURN BOOLEAN is EXTERNAL
     name "addString_Arr" library DBMS_JDOM_LIB WITH CONTEXT
     parameters(context, self, self INDICATOR sb2,
                        val OCIString, val INDICATOR sb2,
                        RETURN INDICATOR sb4, return);

    MEMBER FUNCTION append(val NUMBER) RETURN BOOLEAN is EXTERNAL
     name "addNumber_Arr" library DBMS_JDOM_LIB WITH CONTEXT
     parameters(context, self, self INDICATOR sb2,
                        val OCINumber, val INDICATOR sb2,
                        RETURN INDICATOR sb4, return);

    MEMBER FUNCTION append(val BOOLEAN) RETURN BOOLEAN is EXTERNAL
     name "addBoolean_Arr" library DBMS_JDOM_LIB WITH CONTEXT
     parameters(context, self, self INDICATOR sb2,
                        val , val INDICATOR sb2,
                        RETURN INDICATOR sb4, return);
  
    MEMBER FUNCTION append(val DATE) RETURN BOOLEAN is EXTERNAL
     name "addDate_Arr" library DBMS_JDOM_LIB WITH CONTEXT
     parameters(context, self, self INDICATOR sb2,
                        val OCIDate, val INDICATOR sb2,
                        RETURN INDICATOR sb4, return);
  
    MEMBER FUNCTION append(val TIMESTAMP) RETURN BOOLEAN is EXTERNAL
     name "addTStamp_Arr" library DBMS_JDOM_LIB WITH CONTEXT
     parameters(context, self, self INDICATOR sb2,
                        val OCIDateTime, val INDICATOR sb2,
                        RETURN INDICATOR sb4, return);
  
    --MEMBER FUNCTION append(val CLOB) RETURN BOOLEAN is EXTERNAL
    -- name "addClob_Arr" library DBMS_JDOM_LIB WITH CONTEXT
    -- parameters(context, self, self INDICATOR sb2,
    --                    val OCILobLocator, val INDICATOR sb2,
    --                    RETURN INDICATOR sb4, return);

    --MEMBER FUNCTION append(val BLOB) RETURN BOOLEAN is EXTERNAL
    -- name "addBlob_Arr" library DBMS_JDOM_LIB WITH CONTEXT
    -- parameters(context, self, self INDICATOR sb2,
    --                    val OCILobLocator, val INDICATOR sb2,
    --                    RETURN INDICATOR sb4, return);

    MEMBER FUNCTION append_Null RETURN BOOLEAN is EXTERNAL
     name "addNull_Arr" library DBMS_JDOM_LIB WITH CONTEXT
     parameters(context, self, self INDICATOR sb2,
                        RETURN INDICATOR sb4, return);

    MEMBER FUNCTION get(key VARCHAR2) RETURN JDOM_T is EXTERNAL
     name "get_Obj" library DBMS_JDOM_LIB WITH CONTEXT
     parameters(context, self, self INDICATOR sb2, 
                key OCIString, key INDICATOR sb2,
                RETURN DURATION OCIDuration,
                RETURN INDICATOR sb4, return);     
    
    MEMBER FUNCTION get(pos NUMBER) RETURN JDOM_T is EXTERNAL
     name "get_Arr" library DBMS_JDOM_LIB WITH CONTEXT
     parameters(context, self, self INDICATOR sb2, 
                pos OCINumber, pos INDICATOR sb2,
                RETURN DURATION OCIDuration,
                RETURN INDICATOR sb4, return);     

   -- RETURN an Scalar val as VARCHAR2, non string vals will be casted to
   -- to strings. If a key does not exist we RETURN NULL;
   MEMBER FUNCTION get_String(key VARCHAR2) RETURN VARCHAR2 is EXTERNAL
     name "getString_Obj" library DBMS_JDOM_LIB WITH CONTEXT
     parameters(context, self, self INDICATOR sb2, 
                key OCIString, key INDICATOR sb2,
                RETURN INDICATOR sb4, RETURN OCIString);

   MEMBER FUNCTION get_String(pos NUMBER) RETURN VARCHAR2 is EXTERNAL
     name "getString_Arr" library DBMS_JDOM_LIB WITH CONTEXT
     parameters(context, self, self INDICATOR sb2, 
                pos OCINumber, pos INDICATOR sb2,
                RETURN INDICATOR sb4, RETURN OCIString);

   MEMBER FUNCTION get_Number(key VARCHAR2) RETURN NUMBER is EXTERNAL
     name "getNumber_Obj" library DBMS_JDOM_LIB WITH CONTEXT
     parameters(context, self, self INDICATOR sb2, 
                key OCIString, key INDICATOR sb2,
                RETURN INDICATOR sb4, RETURN OCINumber);

   MEMBER FUNCTION get_Number(pos NUMBER) RETURN NUMBER is EXTERNAL
     name "getNumber_Arr" library DBMS_JDOM_LIB WITH CONTEXT
     parameters(context, self, self INDICATOR sb2, 
                pos OCINumber, pos INDICATOR sb2,
                RETURN INDICATOR sb4, RETURN OCINumber);

   MEMBER FUNCTION get_Date(key VARCHAR2) RETURN DATE is EXTERNAL
     name "getDate_Obj" library DBMS_JDOM_LIB WITH CONTEXT
     parameters(context, self, self INDICATOR sb2, 
                key OCIString, key INDICATOR sb2,
                RETURN INDICATOR sb4, RETURN OCIDate);

   MEMBER FUNCTION get_Date(pos NUMBER) RETURN DATE is EXTERNAL
     name "getDate_Arr" library DBMS_JDOM_LIB WITH CONTEXT
     parameters(context, self, self INDICATOR sb2, 
                pos OCINumber, pos INDICATOR sb2,
                RETURN INDICATOR sb4, RETURN OCIDate);
 
   MEMBER FUNCTION get_Timestamp(key VARCHAR2) RETURN TIMESTAMP is EXTERNAL
     name "getTStamp_Obj" library DBMS_JDOM_LIB WITH CONTEXT
     parameters(context, self, self INDICATOR sb2, 
                key OCIString, key INDICATOR sb2,
                RETURN INDICATOR sb4, RETURN OCIDateTime);

   MEMBER FUNCTION get_Timestamp(pos NUMBER) RETURN TIMESTAMP is EXTERNAL
     name "getTStamp_Arr" library DBMS_JDOM_LIB WITH CONTEXT
     parameters(context, self, self INDICATOR sb2, 
                pos OCINumber, pos INDICATOR sb2,
                RETURN INDICATOR sb4, RETURN OCIDateTime);

   MEMBER FUNCTION get_Boolean(key VARCHAR2) RETURN BOOLEAN is EXTERNAL
     name "getBoolean_Obj" library DBMS_JDOM_LIB WITH CONTEXT
     parameters(context, self, self INDICATOR sb2, 
                key OCIString, key INDICATOR sb2,
                RETURN INDICATOR sb4, RETURN);

   MEMBER FUNCTION get_Boolean(pos NUMBER) RETURN BOOLEAN is EXTERNAL
     name "getBoolean_Arr" library DBMS_JDOM_LIB WITH CONTEXT
     parameters(context, self, self INDICATOR sb2, 
                pos OCINumber, pos INDICATOR sb2,
                RETURN INDICATOR sb4, RETURN );

   MEMBER FUNCTION get_Clob(key VARCHAR2, c CLOB) 
      RETURN CLOB is EXTERNAL
     name "getClob_Obj" library DBMS_JDOM_LIB WITH CONTEXT
     parameters(context, self, self INDICATOR sb2, 
                key OCIString, key INDICATOR sb2,
                c OCILobLocator, c INDICATOR sb2,
                RETURN DURATION OCIDuration,
                RETURN INDICATOR sb4, RETURN);

   MEMBER FUNCTION get_Blob(key VARCHAR2, b BLOB) 
     RETURN BLOB is EXTERNAL
     name "getBlob_Obj" library DBMS_JDOM_LIB WITH CONTEXT
     parameters(context, self, self INDICATOR sb2, 
                key OCIString, key INDICATOR sb2,
                b OCILobLocator, b INDICATOR sb2,
                RETURN DURATION OCIDuration,
                RETURN INDICATOR sb4, RETURN);

   MEMBER FUNCTION get_Clob(pos NUMBER, c CLOB) 
     RETURN CLOB is EXTERNAL
     name "getClob_Arr" library DBMS_JDOM_LIB WITH CONTEXT
     parameters(context, self, self INDICATOR sb2, 
                pos OCINumber, pos INDICATOR sb2,
                c OCILobLocator, c INDICATOR sb2,
                RETURN DURATION OCIDuration,
                RETURN INDICATOR sb4, RETURN );

    MEMBER FUNCTION get_Blob(pos NUMBER, b BLOB) 
     RETURN BLOB is EXTERNAL
     name "getBlob_Arr" library DBMS_JDOM_LIB WITH CONTEXT
     parameters(context, self, self INDICATOR sb2, 
                pos OCINumber, pos INDICATOR sb2,
                b OCILobLocator, b INDICATOR sb2,
                RETURN DURATION OCIDuration,
                RETURN INDICATOR sb4, RETURN );

   MEMBER FUNCTION patch(spec VARCHAR2) RETURN BOOLEAN is EXTERNAL
     name "patchStr" library DBMS_JDOM_LIB WITH CONTEXT
     parameters(context, self, self INDICATOR sb2,
                spec OCIString, spec INDICATOR sb2,
                RETURN INDICATOR sb4, return);

   MEMBER FUNCTION mergepatch(patch VARCHAR2) RETURN BOOLEAN is EXTERNAL
     name "mergePatchStr" library DBMS_JDOM_LIB WITH CONTEXT
     parameters(context, self, self INDICATOR sb2,
                patch OCIString, patch INDICATOR sb2,
                RETURN INDICATOR sb4, return);

   MEMBER FUNCTION redact(spec VARCHAR2) RETURN BOOLEAN is EXTERNAL
     name "selectStr" library DBMS_JDOM_LIB WITH CONTEXT
     parameters(context, self, self INDICATOR sb2,
                spec OCIString, spec INDICATOR sb2,
                RETURN INDICATOR sb4, return);

   MEMBER FUNCTION patch(spec JDOM_T) RETURN BOOLEAN is EXTERNAL
     name "patchPls" library DBMS_JDOM_LIB WITH CONTEXT
     parameters(context, self, self INDICATOR sb2,
                spec, spec INDICATOR sb2,
                RETURN INDICATOR sb4, return);

   MEMBER FUNCTION mergepatch(patch JDOM_T) RETURN BOOLEAN is EXTERNAL
     name "mergePatchPls" library DBMS_JDOM_LIB WITH CONTEXT
     parameters(context, self, self INDICATOR sb2,
                patch, patch INDICATOR sb2,
                RETURN INDICATOR sb4, return);

   MEMBER FUNCTION redact(spec JDOM_T) RETURN BOOLEAN is EXTERNAL
     name "selectPls" library DBMS_JDOM_LIB WITH CONTEXT
     parameters(context, self, self INDICATOR sb2,
                spec, spec INDICATOR sb2,
                RETURN INDICATOR sb4, return);

END;
/
show errors;


-- ==================================================================
-- Create the object types

CREATE OR REPLACE TYPE BODY JSON_Element_T AS 
  STATIC FUNCTION parse(jsn VARCHAR2) RETURN JSON_Element_T AS
    dom JDOM_T;
    inv_type exception;
    pragma exception_init(inv_type, -40587); 
  BEGIN
    dom :=  jdom_t.parse(jsn);
    IF (dom.is_Object) THEN
        RETURN JSON_Object_T(dom);  
    ELSIF (dom.is_Array) THEN
        RETURN JSON_Array_T(dom);
    ELSE 
        raise inv_type;    
    END IF;  
  END;
 
  STATIC FUNCTION parse(jsn CLOB) RETURN JSON_Element_T AS
    dom JDOM_T;
    inv_type exception;
    pragma exception_init(inv_type, -40587);
  BEGIN
    dom :=  jdom_t.parse(jsn);
    IF (dom.is_Object) THEN
        RETURN JSON_Object_T(dom);
    ELSIF (dom.is_Array) THEN
        RETURN JSON_Array_T(dom);
    ELSE 
        raise inv_type;
    END IF;  
  END;

  STATIC FUNCTION parse(jsn BLOB) RETURN JSON_Element_T AS
    dom JDOM_T;
    inv_type exception;
    pragma exception_init(inv_type, -40587);
  BEGIN
    dom :=  jdom_t.parse(jsn);
    IF (dom.is_Object) THEN
        RETURN JSON_Object_T(dom);
    ELSIF (dom.is_Array) THEN
        RETURN JSON_Array_T(dom);
    ELSE 
        raise inv_type;
    END IF;  
  END;

  MEMBER FUNCTION stringify(self IN JSON_ELEMENT_T) RETURN VARCHAR2 AS
  BEGIN
    RETURN dom.stringify;
  END;
 
  MEMBER FUNCTION to_String(self IN JSON_ELEMENT_T) RETURN VARCHAR2 AS
  BEGIN
    RETURN dom.to_String;
  END;

  MEMBER FUNCTION to_Clob(self IN JSON_ELEMENT_T) RETURN CLOB AS
  BEGIN
    RETURN dom.to_Clob(null);
  END;

  MEMBER PROCEDURE to_Clob(self IN OUT NOCOPY JSON_ELEMENT_T, 
                           c IN OUT NOCOPY CLOB) AS
   inp_null exception;
   pragma exception_init(inp_null, -64403);
  BEGIN
     IF (c IS NOT NULL) THEN
       c := dom.to_Clob(c);
     ELSE
       raise inp_null;
     END IF;
  END;

  MEMBER FUNCTION to_Blob(self IN JSON_ELEMENT_T) RETURN BLOB AS
  BEGIN
    RETURN dom.to_Blob(null);
  END;

  MEMBER PROCEDURE to_Blob(self IN OUT NOCOPY JSON_ELEMENT_T, 
                          b IN OUT NOCOPY BLOB) AS
  BEGIN
    b := dom.to_Blob(b);
  END;

  MEMBER FUNCTION to_Boolean(self IN JSON_ELEMENT_T) RETURN BOOLEAN AS
  BEGIN
    RETURN dom.to_Boolean;
  END;

  MEMBER FUNCTION to_Number(self IN JSON_ELEMENT_T) RETURN NUMBER AS
  BEGIN
    RETURN dom.to_Number;
  END;

  MEMBER FUNCTION to_Date(self IN JSON_ELEMENT_T) RETURN DATE AS
  BEGIN
    RETURN dom.to_Date;
  END;

  MEMBER FUNCTION to_Timestamp(self IN JSON_ELEMENT_T) RETURN TIMESTAMP AS
  BEGIN
    RETURN dom.to_Timestamp;
  END;

  MEMBER FUNCTION is_Object(self IN JSON_ELEMENT_T) RETURN BOOLEAN AS
  BEGIN
    RETURN dom.is_Object;
  END;
 
  MEMBER FUNCTION is_Array(self IN JSON_ELEMENT_T) RETURN BOOLEAN AS
  BEGIN
    RETURN dom.is_Array;
  END;

  MEMBER FUNCTION is_Scalar(self IN JSON_ELEMENT_T) RETURN BOOLEAN AS
  BEGIN
    RETURN dom.is_Scalar;
  END; 

  MEMBER FUNCTION is_String(self IN JSON_ELEMENT_T) RETURN BOOLEAN AS
  BEGIN
    RETURN dom.is_String;
  END; 

  MEMBER FUNCTION is_Number(self IN JSON_ELEMENT_T) RETURN BOOLEAN AS
  BEGIN
    RETURN dom.is_Number;
  END; 

  MEMBER FUNCTION is_Boolean(self IN JSON_ELEMENT_T) RETURN BOOLEAN AS
  BEGIN
    RETURN dom.is_Boolean;
  END; 

  MEMBER FUNCTION is_True(self IN JSON_ELEMENT_T) RETURN BOOLEAN AS
  BEGIN
    RETURN dom.is_True;
  END; 

  MEMBER FUNCTION is_False(self IN JSON_ELEMENT_T) RETURN BOOLEAN AS
  BEGIN
    RETURN dom.is_False;
  END; 

  MEMBER FUNCTION is_Null(self IN JSON_ELEMENT_T) RETURN BOOLEAN AS
  BEGIN
    RETURN dom.is_Null;
  END; 

  MEMBER FUNCTION is_Date(self IN JSON_ELEMENT_T) RETURN BOOLEAN AS
  BEGIN
    RETURN dom.is_Date;
  END; 

  MEMBER FUNCTION is_Timestamp(self IN JSON_ELEMENT_T) RETURN BOOLEAN AS
  BEGIN
    RETURN dom.is_Timestamp;
  END; 

  MEMBER FUNCTION get_Size(self IN JSON_ELEMENT_T) RETURN NUMBER AS
  BEGIN
    RETURN dom.get_Size;
  END;

  MEMBER PROCEDURE on_Error(self IN OUT NOCOPY JSON_ELEMENT_T, val NUMBER) AS
    hack boolean;
  BEGIN
    hack := dom.on_Error(val);
  END;

  MEMBER PROCEDURE patch(self IN OUT NOCOPY JSON_ELEMENT_T, spec VARCHAR2) AS
    hack boolean;
  BEGIN
    hack := dom.patch(spec);
  END;

  MEMBER PROCEDURE mergepatch(self IN OUT NOCOPY JSON_ELEMENT_T, patch VARCHAR2) AS
    hack boolean;
  BEGIN
    hack := dom.mergepatch(patch);
  END;

  MEMBER PROCEDURE redact(self IN OUT NOCOPY JSON_ELEMENT_T, spec VARCHAR2) AS
    hack boolean;
  BEGIN
    hack := dom.redact(spec);
  END;

  MEMBER PROCEDURE patch(self IN OUT NOCOPY JSON_ELEMENT_T, 
                         spec JSON_Element_T) AS
    hack boolean;
  BEGIN
    hack := dom.patch(spec.dom);
  END;

  MEMBER PROCEDURE mergepatch(self IN OUT NOCOPY JSON_ELEMENT_T, 
                         patch JSON_Element_T) AS
    hack boolean;
  BEGIN
    hack := dom.mergepatch(patch.dom);
  END;

  MEMBER PROCEDURE redact(self IN OUT NOCOPY JSON_ELEMENT_T, 
                          spec JSON_Element_T) AS
    hack boolean;
  BEGIN
    hack := dom.redact(spec.dom);
  END;     

END;
/
show error;


CREATE OR REPLACE TYPE BODY JSON_Object_T AS 
   CONSTRUCTOR FUNCTION JSON_Object_T(self IN OUT JSON_OBJECT_T) 
                        RETURN SELF AS RESULT AS
   BEGIN
     self.dom :=  jdom_t.create_Obj;
     RETURN;
   END;

   CONSTRUCTOR FUNCTION JSON_Object_T(self IN OUT JSON_OBJECT_T, jsn JDOM_T) 
                        RETURN SELF AS RESULT AS
   inv_type exception;
    pragma exception_init(inv_type, -40587);
   BEGIN
     IF (jsn.is_Object) THEN
       self.dom := jsn;
     ELSE
       RAISE inv_type;
     END IF;
     RETURN;
   END; 
 
   CONSTRUCTOR FUNCTION JSON_Object_T(self IN OUT JSON_OBJECT_T, jsn VARCHAR2) 
                        RETURN SELF AS RESULT AS
   dom JDOM_T;
     inv_type exception;
     pragma exception_init(inv_type, -40587);
   BEGIN
     dom :=  jdom_t.parse(jsn);
     IF (dom.is_Object) THEN
       self.dom := dom;
     ELSE
       RAISE inv_type;
     END IF;
     RETURN;
   END;

   CONSTRUCTOR FUNCTION JSON_Object_T(self IN OUT JSON_OBJECT_T, jsn CLOB) 
                        RETURN SELF AS RESULT AS
   dom JDOM_T;
     inv_type exception;
     pragma exception_init(inv_type, -40587);
   BEGIN
     dom :=  jdom_t.parse(jsn);
     IF (dom.is_Object) THEN
       self.dom := dom;
     ELSE
       RAISE inv_type;
     END IF;
     RETURN;
   END;

   CONSTRUCTOR FUNCTION JSON_Object_T(self IN OUT JSON_OBJECT_T, jsn BLOB) 
                        RETURN SELF AS RESULT AS
   dom JDOM_T;
     inv_type exception;
     pragma exception_init(inv_type, -40587);
   BEGIN
     dom :=  jdom_t.parse(jsn);
     IF (dom.is_Object) THEN
       self.dom := dom;
     ELSE
       RAISE inv_type;
     END IF;
     RETURN;
   END;

  CONSTRUCTOR FUNCTION JSON_Object_T(self IN OUT JSON_OBJECT_T, 
                                     e Json_Element_T) RETURN SELF AS RESULT AS
     inv_type exception;
     pragma exception_init(inv_type, -40587);
   BEGIN
     IF (e.dom.is_Object) THEN
       self.dom := e.dom;
     ELSE
       RAISE inv_type;
     END IF;
     RETURN;
   END; 

   STATIC FUNCTION parse(jsn VARCHAR2) RETURN Json_Object_T AS
     dom JDOM_T;
     obj JSON_Object_T;
     inv_type exception;
     pragma exception_init(inv_type, -40587);
   BEGIN
     dom :=  jdom_t.parse(jsn);
     IF (dom.is_Object) THEN
        RETURN JSON_Object_T(dom);
     ELSE 
        RAISE inv_type;
     END IF;  
   END;

   STATIC FUNCTION parse(jsn CLOB) RETURN Json_Object_T AS
     dom JDOM_T;
     obj JSON_Object_T;
     inv_type exception;
     pragma exception_init(inv_type, -40587);
   BEGIN
     dom :=  jdom_t.parse(jsn);
     IF (dom.is_Object) THEN
        RETURN JSON_Object_T(dom);
     ELSE 
        RAISE inv_type;
     END IF;  
   END;

   STATIC FUNCTION parse(jsn BLOB) RETURN Json_Object_T AS
     dom JDOM_T;
     obj JSON_Object_T;
     inv_type exception;
     pragma exception_init(inv_type, -40587);
   BEGIN
     dom :=  jdom_t.parse(jsn);
     IF (dom.is_Object) THEN
        RETURN JSON_Object_T(dom);
     ELSE 
        RAISE inv_type;
     END IF;  
   END;
 
   MEMBER FUNCTION clone RETURN JSON_OBJECT_T AS
     obj JSON_Object_T;
   BEGIN
     RETURN JSON_Object_T(dom.clone);
   END;

   MEMBER PROCEDURE put(self IN OUT NOCOPY JSON_OBJECT_T, key VARCHAR2, 
                        val VARCHAR2) AS
     hack boolean;
   BEGIN
     hack := dom.put(key, val);
   END;

   MEMBER PROCEDURE put(self IN OUT NOCOPY JSON_OBJECT_T, key VARCHAR2, 
                        val NUMBER) AS
     hack boolean;
   BEGIN
     hack := dom.put(key, val);
   END;

   MEMBER PROCEDURE put(self IN OUT NOCOPY JSON_OBJECT_T, key VARCHAR2, 
                        val BOOLEAN) AS
     hack boolean;
   BEGIN
     hack := dom.put(key, val);
   END;

   MEMBER PROCEDURE put(self IN OUT NOCOPY JSON_OBJECT_T, key VARCHAR2, 
                        val DATE) AS
     hack boolean;
   BEGIN
     hack := dom.put(key, val);
   END;

   MEMBER PROCEDURE put(self IN OUT NOCOPY JSON_OBJECT_T, key VARCHAR2, 
                        val TIMESTAMP) AS
     hack boolean;
   BEGIN
     hack := dom.put(key, val);
   END;

   --MEMBER PROCEDURE put(key VARCHAR2, val CLOB) AS
   --  hack boolean;
   --BEGIN
   --  hack := dom.put(key, val);
   --END;

   --MEMBER PROCEDURE put(key VARCHAR2, val BLOB) AS
   --  hack boolean;
   --BEGIN
   --  hack := dom.put(key, val);
   --END;

   MEMBER PROCEDURE put(self IN OUT NOCOPY JSON_OBJECT_T, key VARCHAR2, 
                        val JSON_Element_T) AS
     hack boolean;
   BEGIN
     hack := dom.put(key, val.dom);
   END;
 
   MEMBER PROCEDURE put_Null(self IN OUT NOCOPY JSON_OBJECT_T, key VARCHAR2) AS
     hack boolean;
   BEGIN
     hack := dom.put_Null(key);
   END;


   MEMBER FUNCTION get(self IN JSON_OBJECT_T, key VARCHAR2) 
                   RETURN JSON_Element_T AS
     elem JSON_Element_T;
     typ  VARCHAR2(10);
   BEGIN
     typ := get_Type(key);
     IF (typ IS NULL) THEN
       RETURN NULL;
     ELSIF (typ = 'OBJECT') THEN
       RETURN JSON_Object_T(dom.get(key));
     ELSIF (typ = 'ARRAY') THEN
       RETURN JSON_Array_T(dom.get(key));
     ELSIF (typ = 'SCALAR') THEN
       elem := JSON_Scalar_T(dom.get(key));
     ELSE
       RETURN NULL; 
     END IF;

     elem.dom := dom.get(key);
     RETURN elem; 
   END;

   MEMBER FUNCTION get_Object(self IN JSON_OBJECT_T, key VARCHAR2) 
                   RETURN JSON_Object_T AS
     obj JSON_Object_T;
     typ  VARCHAR2(10);
   BEGIN
     typ := get_Type(key);
     IF (typ IS NULL) THEN
       RETURN NULL;
     ELSIF (typ = 'OBJECT') THEN
       RETURN JSON_Object_T(dom.get(key));
     ELSE
       RETURN NULL; 
     END IF;

     --obj.dom := dom.get(key);
     --RETURN obj; 
   END;

   MEMBER FUNCTION get_Array(self IN JSON_OBJECT_T, key VARCHAR2) 
                   RETURN JSON_Array_T AS
     arr JSON_Array_T;
     typ  VARCHAR2(10);
   BEGIN
     typ := get_Type(key);
     IF (typ IS NULL) THEN
       RETURN NULL;
     ELSIF (typ = 'ARRAY') THEN
      return JSON_Array_T(dom.get(key));
     ELSE
       RETURN NULL; 
     END IF;

     --arr.dom := dom.get(key);
     --RETURN arr; 
   END;

   MEMBER FUNCTION get_String(self IN JSON_OBJECT_T, key VARCHAR2) 
                   RETURN VARCHAR2 AS
   BEGIN
      RETURN dom.get_String(key);
   END;

   MEMBER FUNCTION get_Number(self IN JSON_OBJECT_T, key VARCHAR2) 
                   RETURN NUMBER AS
   BEGIN
      RETURN dom.get_Number(key);
   END;

   MEMBER FUNCTION get_Boolean(self IN JSON_OBJECT_T, key VARCHAR2) 
                   RETURN BOOLEAN AS
   BEGIN
      RETURN dom.get_Boolean(key);
   END;

   MEMBER FUNCTION get_Date(self IN JSON_OBJECT_T, key VARCHAR2) RETURN DATE AS
   BEGIN
      RETURN dom.get_Date(key);
   END;

   MEMBER FUNCTION get_Timestamp(self IN JSON_OBJECT_T, key VARCHAR2) 
                   RETURN TIMESTAMP AS
   BEGIN
      RETURN dom.get_Timestamp(key);
   END;

   MEMBER FUNCTION get_Clob(self IN JSON_OBJECT_T, key VARCHAR2) RETURN CLOB AS
   BEGIN
      RETURN dom.get_Clob(key, NULL);
   END;

   MEMBER PROCEDURE get_Clob(self IN OUT NOCOPY JSON_OBJECT_T, key VARCHAR2, 
                            c IN OUT NOCOPY CLOB) AS
      inp_null exception;
      pragma exception_init(inp_null, -64403);
   BEGIN
      IF (c IS NOT NULL) THEN
          c := dom.get_Clob(key, c);
      ELSE
          raise inp_null;
      END IF;
   END;

   MEMBER FUNCTION get_Blob(self IN JSON_OBJECT_T, key VARCHAR2) RETURN BLOB AS
   BEGIN
      RETURN dom.get_Blob(key, NULL);
   END;

   MEMBER PROCEDURE get_Blob(self IN OUT NOCOPY JSON_OBJECT_T, key VARCHAR2, 
                            b IN OUT NOCOPY BLOB) AS
   BEGIN
      b := dom.get_Blob(key, b);
   END;

   MEMBER FUNCTION has(self IN JSON_OBJECT_T, key VARCHAR2) RETURN BOOLEAN AS
   BEGIN
      RETURN dom.has_Key(key);
   END;

   MEMBER FUNCTION get_Type(self IN JSON_OBJECT_T, key VARCHAR2) 
                   RETURN VARCHAR2 AS
   BEGIN
     RETURN dom.get_Type(key);
   END;
  
   MEMBER FUNCTION get_Keys(self IN JSON_OBJECT_T) RETURN JSON_KEY_LIST AS
   BEGIN
     RETURN dom.get_Keys;
   END;

   MEMBER PROCEDURE remove(self IN OUT NOCOPY JSON_OBJECT_T, key VARCHAR2) AS
     hack boolean;
   BEGIN
     hack := dom.remove(key);
   END;

   MEMBER PROCEDURE rename_Key(self IN OUT NOCOPY JSON_OBJECT_T, 
                              keyOld VARCHAR2, keyNew VARCHAR2) AS
     hack boolean;
   BEGIN
     hack := dom.rename_Key(keyOld, keyNew);
   END;
 
END;
/
show errors;


CREATE OR REPLACE TYPE BODY JSON_Array_T AS 

   CONSTRUCTOR FUNCTION JSON_Array_T(self IN OUT JSON_ARRAY_T)  
                                       RETURN SELF AS RESULT AS
   BEGIN
     self.dom :=  jdom_t.create_Arr;
     RETURN;
   END;

   CONSTRUCTOR FUNCTION JSON_Array_T(self IN OUT JSON_ARRAY_T, jsn JDOM_T) 
                        RETURN SELF AS RESULT AS
    inv_type exception;
    pragma exception_init(inv_type, -40587);
   BEGIN
     IF (jsn.is_Array) THEN
       self.dom := jsn;
     ELSE
       RAISE inv_type;
     END IF;
     RETURN;
   END; 
  
   CONSTRUCTOR FUNCTION JSON_Array_T(self IN OUT JSON_ARRAY_T, jsn VARCHAR2) 
                        RETURN SELF AS RESULT AS
   dom JDOM_T;
      inv_type exception;
      pragma exception_init(inv_type, -40587);
   BEGIN
     dom :=  jdom_t.parse(jsn);
     IF (dom.is_Array) THEN
       self.dom := dom;
     ELSE
       RAISE inv_type;
     END IF;
     RETURN;
   END;

   CONSTRUCTOR FUNCTION JSON_Array_T(self IN OUT JSON_ARRAY_T, jsn CLOB) 
                        RETURN SELF AS RESULT AS
   dom JDOM_T;
      inv_type exception;
      pragma exception_init(inv_type, -40587);
   BEGIN
     dom :=  jdom_t.parse(jsn);
     IF (dom.is_Array) THEN
       self.dom := dom;
     ELSE
       RAISE inv_type;
     END IF;
     RETURN;
   END;

   CONSTRUCTOR FUNCTION JSON_Array_T(self IN OUT JSON_ARRAY_T, jsn BLOB) 
                        RETURN SELF AS RESULT AS
   dom JDOM_T;
     inv_type exception;
     pragma exception_init(inv_type, -40587);
   BEGIN
     dom :=  jdom_t.parse(jsn);
     IF (dom.is_Array) THEN
       self.dom := dom;
     ELSE
       RAISE inv_type;
     END IF;
     RETURN;
   END;

   CONSTRUCTOR FUNCTION JSON_Array_T(self IN OUT JSON_ARRAY_T, 
                                     e Json_Element_T) RETURN SELF AS RESULT AS
     inv_type exception;
     pragma exception_init(inv_type, -40587);
  BEGIN
     IF (e.dom.is_Array) THEN
       self.dom := e.dom;
     ELSE
       RAISE inv_type;
     END IF;
     RETURN;
   END; 

   STATIC FUNCTION parse(jsn VARCHAR2) RETURN Json_Array_T AS
     dom JDOM_T;
     obj JSON_Array_T;
     inv_type exception;
     pragma exception_init(inv_type, -40587);
   BEGIN
     dom :=  jdom_t.parse(jsn);
     IF (dom.is_Array) THEN
        obj := JSON_Array_T(dom);
        RETURN obj;
     ELSE 
        RAISE inv_type;
        --RETURN NULL;
     END IF;  
   END;  

   STATIC FUNCTION parse(jsn CLOB) RETURN Json_Array_T AS
     dom JDOM_T;
     obj JSON_Array_T;
     inv_type exception;
     pragma exception_init(inv_type, -40587);
   BEGIN
     dom :=  jdom_t.parse(jsn);
     IF (dom.is_Array) THEN
        RETURN JSON_Array_T(dom);
     ELSE 
        RAISE inv_type;
        --RETURN NULL;
     END IF;  
   END;    

   STATIC FUNCTION parse(jsn BLOB) RETURN Json_Array_T AS
     dom JDOM_T;
     obj JSON_Array_T;
     inv_type exception;
     pragma exception_init(inv_type, -40587);
   BEGIN
     dom :=  jdom_t.parse(jsn);
     IF (dom.is_Array) THEN
        RETURN JSON_Array_T(dom);
     ELSE 
        RAISE inv_type;
        --RETURN NULL;
     END IF;  
   END;    

   MEMBER FUNCTION clone(self IN JSON_ARRAY_T) RETURN JSON_ARRAY_T AS
     arr JSON_Array_T;
   BEGIN
     RETURN JSON_Array_T(dom.clone);
   END;

   MEMBER PROCEDURE append(self IN OUT NOCOPY JSON_ARRAY_T, val VARCHAR2) AS
     hack boolean;
   BEGIN
     hack := dom.append(val);
   END;

   MEMBER PROCEDURE append(self IN OUT NOCOPY JSON_ARRAY_T, val NUMBER) AS
     hack boolean;
   BEGIN
     hack := dom.append(val);
   END;

   MEMBER PROCEDURE append(self IN OUT NOCOPY JSON_ARRAY_T, val BOOLEAN) AS
     hack boolean;
   BEGIN
     hack := dom.append(val);
   END;

   MEMBER PROCEDURE append(self IN OUT NOCOPY JSON_ARRAY_T, val DATE) AS
     hack boolean;
   BEGIN
     hack := dom.append(val);
   END;

   MEMBER PROCEDURE append(self IN OUT NOCOPY JSON_ARRAY_T, val TIMESTAMP) AS
     hack boolean;
   BEGIN
     hack := dom.append(val);
   END;

   --MEMBER PROCEDURE append(val CLOB) AS
   --  hack boolean;
   --BEGIN
   --  hack := dom.append(val);
   --END;

   --MEMBER PROCEDURE append(val BLOB) AS
   --  hack boolean;
   --BEGIN
   --  hack := dom.append(val);
   --END;

   MEMBER PROCEDURE append(self IN OUT NOCOPY JSON_ARRAY_T, 
                           val JSON_Element_T) AS
     hack boolean;
   BEGIN
     hack := dom.append(val.dom);
   END;

   MEMBER PROCEDURE append_Null(self IN OUT NOCOPY JSON_ARRAY_T) AS
     hack boolean;
   BEGIN
     hack := dom.append_Null;
   END;
  
   MEMBER PROCEDURE put(self IN OUT NOCOPY JSON_ARRAY_T, pos NUMBER, 
                        val VARCHAR2, overwrite BOOLEAN DEFAULT FALSE) AS
     hack boolean;
   BEGIN
     hack := dom.put(pos, val, overwrite);
   END;

   MEMBER PROCEDURE put(self IN OUT NOCOPY JSON_ARRAY_T, pos NUMBER, 
                        val NUMBER, overwrite BOOLEAN DEFAULT FALSE) AS
     hack boolean;
   BEGIN
     hack := dom.put(pos, val, overwrite);
   END;

   MEMBER PROCEDURE put(self IN OUT NOCOPY JSON_ARRAY_T, pos NUMBER, 
                        val BOOLEAN, overwrite BOOLEAN DEFAULT FALSE) AS
     hack boolean;
   BEGIN
     hack := dom.put(pos, val, overwrite);
   END;

   MEMBER PROCEDURE put(self IN OUT NOCOPY JSON_ARRAY_T, pos NUMBER, 
                        val DATE, overwrite BOOLEAN DEFAULT FALSE) AS
     hack boolean;
   BEGIN
     hack := dom.put(pos, val, overwrite);
   END;

   MEMBER PROCEDURE put(self IN OUT NOCOPY JSON_ARRAY_T, pos NUMBER, 
                        val TIMESTAMP, overwrite BOOLEAN DEFAULT FALSE) AS
     hack boolean;
   BEGIN
     hack := dom.put(pos, val, overwrite);
   END;

   --MEMBER PROCEDURE put(pos NUMBER, val CLOB, 
   --                     overwrite BOOLEAN DEFAULT FALSE) AS
   --  hack boolean;
   --BEGIN
   --  hack := dom.put(pos, val, overwrite);
   --END;

   --MEMBER PROCEDURE put(pos NUMBER, val BLOB, 
   --                     overwrite BOOLEAN DEFAULT FALSE) AS
   --  hack boolean;
   --BEGIN
   --  hack := dom.put(pos, val, overwrite);
   --END;

   MEMBER PROCEDURE put(self IN OUT NOCOPY JSON_ARRAY_T, pos NUMBER, 
                        val JSON_Element_T, overwrite BOOLEAN DEFAULT FALSE) AS
     hack boolean;
   BEGIN
     hack := dom.put(pos, val.dom, overwrite);
   END;

   MEMBER PROCEDURE put_Null(self IN OUT NOCOPY JSON_ARRAY_T, pos NUMBER, 
                             overwrite BOOLEAN DEFAULT FALSE) AS
     hack boolean;
   BEGIN
     hack := dom.put_Null(pos, overwrite);
   END;


   MEMBER FUNCTION get_Type(self IN JSON_ARRAY_T, pos NUMBER) RETURN VARCHAR2 AS
   BEGIN
     RETURN dom.get_Type(pos);
   END;
   
   MEMBER FUNCTION get(self IN JSON_ARRAY_T, pos NUMBER) 
                       RETURN JSON_Element_T AS
     elem JSON_Element_T;
     typ  VARCHAR2(10);
   BEGIN
     typ := get_Type(pos);
     IF (typ IS NULL) THEN
       RETURN NULL;
     ELSIF (typ = 'OBJECT') THEN
       RETURN JSON_Object_T(dom.get(pos));
     ELSIF (typ = 'ARRAY') THEN
       RETURN JSON_Array_T(dom.get(pos));
     ELSIF (typ = 'SCALAR') THEN
       elem := JSON_Scalar_T(dom.get(pos));
     ELSE
       RETURN NULL; 
     END IF;

     elem.dom := dom.get(pos);
     RETURN elem; 
   END;

   MEMBER FUNCTION get_String(self IN JSON_ARRAY_T, pos NUMBER) 
                   RETURN VARCHAR2 AS
   BEGIN
     RETURN dom.get_String(pos);
   END;
   
   MEMBER FUNCTION get_Number(self IN JSON_ARRAY_T, pos NUMBER) RETURN NUMBER AS
   BEGIN
     RETURN dom.get_Number(pos);
   END; 

   MEMBER FUNCTION get_Boolean(self IN JSON_ARRAY_T, pos NUMBER) 
                   RETURN BOOLEAN AS
   BEGIN
     RETURN dom.get_Boolean(pos);
   END;     
     
   MEMBER FUNCTION get_Date(self IN JSON_ARRAY_T, pos NUMBER) RETURN DATE AS
   BEGIN
     RETURN dom.get_Date(pos);
   END;

   MEMBER FUNCTION get_Timestamp(self IN JSON_ARRAY_T, pos NUMBER) 
                   RETURN TIMESTAMP AS
   BEGIN
     RETURN dom.get_Timestamp(pos);
   END;

   MEMBER FUNCTION get_Clob(self IN JSON_ARRAY_T, pos NUMBER) RETURN CLOB AS
   BEGIN
     RETURN dom.get_Clob(pos, NULL);
   END;

   MEMBER PROCEDURE get_Clob(self IN OUT NOCOPY JSON_ARRAY_T, pos NUMBER, 
                             c IN OUT NOCOPY CLOB) AS
    inp_null exception;
    pragma exception_init(inp_null, -64403);
   BEGIN
      IF (c IS NOT NULL) THEN
          c := dom.get_Clob(pos, c);
      ELSE
          raise inp_null;
      END IF;
   END;

   MEMBER FUNCTION get_Blob(self IN JSON_ARRAY_T, pos NUMBER) RETURN BLOB AS
   BEGIN
     RETURN dom.get_Blob(pos, NULL);
   END;

   MEMBER PROCEDURE get_Blob(self IN OUT NOCOPY JSON_ARRAY_T, pos NUMBER, 
                            b IN OUT NOCOPY BLOB) AS
   BEGIN
     b := dom.get_Blob(pos, b);
   END;

   MEMBER PROCEDURE remove(self IN OUT NOCOPY JSON_ARRAY_T, pos NUMBER) AS
     hack boolean;
   BEGIN
     hack := dom.remove(pos);
   END;
END;
/
show errors;



CREATE OR REPLACE TYPE BODY JSON_Scalar_T AS 

   CONSTRUCTOR FUNCTION JSON_Scalar_T(self IN OUT JSON_SCALAR_T, jsn JDOM_T) 
                                      RETURN SELF AS RESULT AS
     inv_type exception;
     pragma exception_init(inv_type, -40587);
   BEGIN
     IF (jsn.is_Scalar) THEN
       self.dom := jsn;
     ELSE
       RAISE inv_type;
     END IF;
     RETURN;
   END; 

   CONSTRUCTOR FUNCTION JSON_Scalar_T(self IN OUT JSON_SCALAR_T, 
                                      e Json_Element_T) RETURN SELF AS RESULT AS
     inv_type exception;
     pragma exception_init(inv_type, -40587);
   BEGIN
     IF (e.dom.is_Scalar) THEN
       self.dom := e.dom;
     ELSE
       RAISE inv_type;
     END IF;
     RETURN;
   END; 

   MEMBER FUNCTION clone(self IN JSON_SCALAR_T) RETURN JSON_Scalar_T AS
     sca JSON_Scalar_T;
   BEGIN
     RETURN JSON_Scalar_T(dom.clone);
   END;
END;
/
show errors;

@?/rdbms/admin/sqlsessend.sql

