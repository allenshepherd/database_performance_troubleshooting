Rem
Rem $Header: rdbms/admin/dbmsxutil.sql /main/31 2016/06/03 11:26:01 prthiaga Exp $
Rem
Rem dbmsxutil.sql
Rem
Rem Copyright (c) 2009, 2016, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsxutil.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      This file will be executed an various db versions and that conditional
Rem      compilation needs to be used if a procedure should not appear in all 
Rem      versions.  
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmsxutil.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmsxutil.sql
Rem SQL_PHASE: DBMSXUTIL
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catqm_int.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    prthiaga    06/01/16 - Bug 23494349: USER -> CURRENT_USER
Rem    huiz        11/18/15 - bug 21106662: ref partition exchange in/out proc
Rem    hxzhang     03/16/15 - bug#18918217 fwd merge, added GetTypeDDL
Rem    surman      01/22/14 - 13922626: Update SQL metadata
Rem    qyu         03/18/13 - Common start and end scripts
Rem    bhammers    06/25/12 - bug 14240303 
Rem    bhammers    05/18/11 - move package creation to xdbvxutil.sql
Rem    bhammers    01/21/11 - bug 10094590, 10324163 
Rem    shivsriv    01/14/11 - modify ALL_XMLTYPE_COL
Rem    bhammers    09/13/10 - move conditional compilation to dbmsxutil_otn.sql
Rem                         - use oracle error messages
Rem    bhammers    08/06/10 - add printWarnings
Rem    hxzhang     05/20/10 - exchange partition pre/post proc
Rem    shivsriv    04/12/10 - bug 9542232
Rem    shivsriv    02/11/10 - modify renameCollectionTable
Rem    bhammers    12/12/09 - incorporate change requests from MDRAKE
Rem    schakrab    05/27/09 - add OBJCOL_NAME in *_XMLTYPE_COLS
Rem    shivsriv    05/20/09 - change the procedure names
Rem    schakrab    02/27/09 - make XDB_INDEX_DDL_CACHE private
Rem    bhammers    01/13/09 - added XPath to xcolumn mapping
Rem    shivsriv    01/12/09 - added scopeXMLReferences/indexXMLRefences methods
Rem    bhammers    12/15/08 - moved implementation to prvtxutil.sql
Rem    bhammers    11/10/08 - Created 
Rem

@@?/rdbms/admin/sqlsessstart.sql

SET SERVEROUTPUT ON



BEGIN
  DBMS_LOCK.SLEEP(2);
END;
/


SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100


-- CREATE Constants package 
-- *******************************************************************
CREATE OR REPLACE PACKAGE XDB.DBMS_XDB_CONSTANTS authid CURRENT_USER AS 

  C_UTF8_ENCODING              constant VARCHAR2(32)  
                  := 'AL32UTF8';
  C_WIN1252_ENCODING           constant VARCHAR2(32)  
                  := 'WE8MSWIN1252';
  C_ISOLATIN1_ENCODING         constant VARCHAR2(32)  
                  := 'WE8ISO8859P1';
  C_DEFAULT_ENCODING           constant VARCHAR2(32)  
                  := C_UTF8_ENCODING;
  C_ORACLE_NAMESPACE           constant VARCHAR2(128) 
                  := 'http://xmlns.oracle.com';
  C_ORACLE_XDB_NAMESPACE       constant VARCHAR2(128) 
                  := C_ORACLE_NAMESPACE || '/xdb';
  C_XDBSCHEMA_NAMESPACE        constant VARCHAR2(128) 
                  := C_ORACLE_XDB_NAMESPACE || '/XDBSchema.xsd';
  C_RESOURCE_NAMESPACE         constant VARCHAR2(128) 
                  := C_ORACLE_XDB_NAMESPACE || '/XDBResource.xsd';
  C_ACL_NAMESPACE              constant VARCHAR2(128) 
                  := C_ORACLE_XDB_NAMESPACE || '/acl.xsd';
  C_XMLSCHEMA_NAMESPACE        constant VARCHAR2(128) 
                  := 'http://www.w3.org/2001/XMLSchema';
  C_XMLINSTANCE_NAMESPACE      constant VARCHAR2(128) 
                  := 'http://www.w3.org/2001/XMLSchema-instance';
  C_RESOURCE_PREFIX_R          constant VARCHAR2(128) 
                  := 'xmlns:r="'   || C_RESOURCE_NAMESPACE    || '"';
  C_ACL_PREFIX_ACL             constant VARCHAR2(128) 
                  := 'xmlns:acl="' || C_ACL_NAMESPACE         || '"';
  C_XDBSCHEMA_PREFIX_XDB       constant VARCHAR2(128) 
                  := 'xmlns:xdb="' || C_ORACLE_XDB_NAMESPACE  || '"';
  C_XMLSCHEMA_PREFIX_XSD       constant VARCHAR2(128) 
                  := 'xmlns:xsd="' || C_XMLSCHEMA_NAMESPACE   || '"';
  C_XMLINSTANCE_PREFIX_XSI     constant VARCHAR2(128) 
                  := 'xmlns:xsi="' || C_XMLINSTANCE_NAMESPACE || '"';  
  C_XDBSCHEMA_LOCATION         constant VARCHAR2(128) 
                  := C_ORACLE_XDB_NAMESPACE || '/XDBSchema.xsd';
  C_XDBCONFIG_LOCATION         constant VARCHAR2(128) 
                  := C_ORACLE_XDB_NAMESPACE ||  '/xdbconfig.xsd';
  C_ACL_LOCATION               constant VARCHAR2(128) 
                  := C_ORACLE_XDB_NAMESPACE || '/acl.xsd';
  C_RESOURCE_LOCATION          constant VARCHAR2(128) 
                  := C_ORACLE_XDB_NAMESPACE || '/XDBResource.xsd';
  C_BINARY_CONTENT             constant VARCHAR2(128) 
                  := C_XDBSCHEMA_LOCATION  || '#binary';
  C_TEXT_CONTENT               constant VARCHAR2(128) 
                  := C_XDBSCHEMA_LOCATION  || '#text';
  C_ACL_CONTENT                constant VARCHAR2(128) 
                  := C_ACL_LOCATION     || '#acl';    
  C_XDBSCHEMA_PREFIXES         constant VARCHAR2(256) 
                  := C_XMLSCHEMA_PREFIX_XSD || ' ' || C_XDBSCHEMA_PREFIX_XDB;
  C_EXIF_NAMESPACE             constant VARCHAR2(128) 
                  := C_ORACLE_NAMESPACE || '/ord/meta/exif';
  C_IPTC_NAMESPACE             constant VARCHAR2(128) 
                  := C_ORACLE_NAMESPACE || '/ord/meta/iptc';
  C_DICOM_NAMESPACE            constant VARCHAR2(128) 
                  := C_ORACLE_NAMESPACE || '/ord/meta/dicomImage';
  C_ORDIMAGE_NAMESPACE         constant VARCHAR2(128) 
                  := C_ORACLE_NAMESPACE || '/ord/meta/ordimage';
  C_XMP_NAMESPACE              constant VARCHAR2(128) 
                  := C_ORACLE_NAMESPACE || '/ord/meta/xmp';
  C_XDBCONFIG_NAMESPACE        constant VARCHAR2(128) 
                  := C_ORACLE_XDB_NAMESPACE ||  '/xdbconfig.xsd';
  C_EXIF_PREFIX_EXIF           constant VARCHAR2(128) 
                  := 'xmlns:exif="'  || C_EXIF_NAMESPACE     || '"';
  C_IPTC_PREFIX_IPTC           constant VARCHAR2(128) 
                  := 'xmlns:iptc="'  || C_IPTC_NAMESPACE     || '"';
  C_DICOM_PREFIX_DICOM         constant VARCHAR2(128) 
                  := 'xmlns:dicom="' || C_DICOM_NAMESPACE    || '"';
  C_ORDIMAGE_PREFIX_ORD        constant VARCHAR2(128) 
                  := 'xmlns:ord="'   || C_ORDIMAGE_NAMESPACE || '"';
  C_XMP_PREFIX_XMP             constant VARCHAR2(128) 
                  := 'xmlns:xmp="'   || C_XMP_NAMESPACE      || '"';
  C_RESOURCE_CONFIG_NAMESPACE  constant VARCHAR2(128) 
                  := C_ORACLE_XDB_NAMESPACE || '/XDBResConfig.xsd';
  C_XMLDIFF_NAMESPACE          constant VARCHAR2(128) 
                  := C_ORACLE_XDB_NAMESPACE || '/xdiff.xsd';
  C_RESOURCE_CONFIG_PREFIX_RC  constant VARCHAR2(128) 
                  := 'xmlns:rc="' || C_RESOURCE_CONFIG_NAMESPACE || '"';
  C_XMLDIFF_PREFIX_XD          constant VARCHAR2(128) 
                  := 'xmlns:xd="' || C_XMLDIFF_NAMESPACE        || '"';
  C_NSPREFIX_XDBCONFIG_CFG     constant VARCHAR2(128) 
                  := 'xmlns:cfg="' || C_XDBCONFIG_NAMESPACE        || '"';

  C_GROUP        constant VARCHAR2(32) := 'group';      
  C_ELEMENT      constant VARCHAR2(32) := 'element';     
  C_ATTRIBUTE    constant VARCHAR2(32) := 'attribute';
  C_COMPLEX_TYPE constant VARCHAR2(32) := 'complexType';

function ENCODING_UTF8        return varchar2 deterministic;
--        returns 'AL32UTF8'

function ENCODING_ISOLATIN1        return varchar2 deterministic;
--        returns 'WE8ISO8859P1'

function ENCODING_WIN1252     return varchar2 deterministic;
--        returns 'WE8MSWIN1252'

function ENCODING_DEFAULT     return varchar2 deterministic;
--        returns 'AL32UTF8'

function NAMESPACE_ORACLE_XDB        return varchar2 deterministic;
--        returns 'http://xmlns.oracle.com/xdb'

function NAMESPACE_RESOURCE          return varchar2 deterministic;
--        returns ' http://xmlns.oracle.com/xdb/XDBResource.xsd

function NAMESPACE_XDBSCHEMA          return varchar2 deterministic;
--        returns ' http://xmlns.oracle.com/xdb/XDBSchema.xsd

function NAMESPACE_ACL               return varchar2 deterministic;
--          returns ' http://xmlns.oracle.com/xdb/acl.xsd'

function NAMESPACE_ORACLE         return varchar2 deterministic;
--        returns 'http://xmlns.oracle.com'

function NAMESPACE_XMLSCHEMA         return varchar2 deterministic;
--        returns 'http://www.w3.org/2001/XMLSchema'

function NAMESPACE_XMLINSTANCE       return varchar2 deterministic;
--        returns 'http://www.w3.org/2001/XMLSchema-instance'

function NAMESPACE_RESOURCE_CONFIG   return varchar2 deterministic;
--           returns 'http://xmlns.oracle.com/xdb/XDBResConfig.xsd'

function NAMESPACE_XMLDIFF           return varchar2 deterministic;
--        returns 'http://xmlns.oracle.com/xdb/xdiff.xsd'

function NAMESPACE_XDBCONFIG          return varchar2 deterministic;
--        returns 'http://xmlns.oracle.com/xdb/xdbconfig.xsd'

function SCHEMAURL_XDBCONFIG          return varchar2 deterministic;
--        returns 'http://xmlns.oracle.com/xdb/xdbconfig.xsd'

function NSPREFIX_RESOURCE_R         return varchar2 deterministic;
--        returns 'xmlns:r="http://xmlns.oracle.com/XDBResource.xsd"'

function NSPREFIX_ACL_ACL              return varchar2 deterministic;
--        returns 'xmlns:acl= 'http://xmlns.oracle.com/acl.xsd"'

function NSPREFIX_XDB_XDB        return varchar2 deterministic;
--        returns 'xmlns:xdb= “http://xmlns.oracle.com/xdb" '

function NSPREFIX_XMLSCHEMA_XSD        return varchar2 deterministic;
--        returns 'xmlns:xsd="http://www.w3.org/2001/XMLSchema"'

function NSPREFIX_XMLINSTANCE_XSI      return varchar2 deterministic;
--        returns 'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '

function NSPREFIX_RESCONFIG_RC   return varchar2 deterministic;
--        returns 'xmlns:rc="' || NAMESPACE_RESOURCE_CONFIG

function NSPREFIX_XMLDIFF_XD           return varchar2 deterministic;
--        returns  xmlns:xd="' || NAMESPACE_XMLDIFF

function NSPREFIX_XDBCONFIG_CFG        return varchar2 deterministic;
--        returns xmlns:cfg="http://xmlns.oracle.com/xdb/xdbconfig.xsd"

function SCHEMAURL_XDBSCHEMA          return varchar2 deterministic;
--        returns 'http://xmlns.oracle.com/xdb/XDBSchema.xsd';

function SCHEMAURL_ACL                return varchar2 deterministic;
--        returns 'http://xmlns.oracle.com/xdb/acl.xsd';

function SCHEMAURL_RESOURCE           return varchar2 deterministic;
--        returns 'http://xmlns.oracle.com/xdb/XDBResource.xsd';

function SCHEMAELEM_RESCONTENT_BINARY              return varchar2 deterministic;
--        returns SCHEMAURL_XDBSCHEMA || '#binary'

function SCHEMAELEM_RESCONTENT_TEXT                return varchar2 deterministic;
--        returns SCHEMAURL_XDBSCHEMA || '#text'

function SCHEMAELEM_RES_ACL                 return varchar2 deterministic;
--        returns SCHEMAURL_XDBSCHEMA || '#acl'

function XSD_GROUP             return VARCHAR2 deterministic;
--        returns 'group'

function XSD_ELEMENT           return VARCHAR2 deterministic;
--        returns 'element' 

function XSD_ATTRIBUTE         return VARCHAR2 deterministic;
--        returns 'attribute'

function XSD_COMPLEX_TYPE      return VARCHAR2 deterministic;
--        returns 'complexType'

function XDBSCHEMA_PREFIXES  return VARCHAR2 deterministic;
--        returns  DBMS_XDB_CONSTANTS.PREFIX_DEF_XDB || ' ' || 
--                 DBMS_XDB_CONSTANTS.PREFIX_DEF_XMLSCHEMA

END DBMS_XDB_CONSTANTS;
/
SHOW ERRORS;

grant execute on XDB.DBMS_XDB_CONSTANTS to public;

CREATE OR REPLACE PUBLIC SYNONYM DBMS_XDB_CONSTANTS 
          for XDB.DBMS_XDB_CONSTANTS;
/


 -- *******************************************************************
CREATE OR REPLACE PACKAGE XDB.DBMS_XMLSCHEMA_ANNOTATE authid CURRENT_USER AS
  
  procedure printWarnings(value in BOOLEAN default TRUE);


  procedure addXDBNamespace(xmlschema in out XMLType);
  -- Adds the XDB namespace that is required for xdb annotation. 
  -- This procedure is called implicitly by any other procedure that adds a 
  -- schema annotation. Without further annotations the xdb namespace 
  -- annotations does not make sense, therefore this procedure might mostly 
  -- be called by other annotations procedures and not by the user directly.
  -- The procedure gets an XML Schema as XMLType, performs the annotation and
  -- returns it.

  procedure setDefaultTable(xmlschema in out XMLType,  
                            globalElementName VARCHAR2, 
                            tableName VARCHAR2,  
                            overwrite BOOLEAN default TRUE);
  -- Sets the name of the default table for a given global element that is 
  -- specified by its name

  procedure removeDefaultTable(xmlschema in out XMLType, 
                              globalElementName VARCHAR2);
  -- Removes the default table attribute for the given element. 
  -- After calling this
  -- function system generated table names will be used. The procedure will
  -- always overwrite.

  procedure setTableProps(xmlschema in out XMLType, 
                          globalElementName VARCHAR2, 
                          tableProps VARCHAR2, 
                          overwrite BOOLEAN default TRUE);
  -- Specifies the TABLE storage clause that is appended to the default 
  -- CREATE TABLE statement.

  procedure removeTableProps(xmlschema in out XMLType, 
                            globalElementName VARCHAR2);
  -- removes the table storage props.

  procedure setTableProps(xmlschema in out XMLType, 
                          globalObject VARCHAR2, 
                          globalObjectName VARCHAR2, 
                          localElementName VARCHAR2, 
                          tableProps VARCHAR2, 
                          overwrite BOOLEAN default TRUE);
  -- Specifies the TABLE storage clause that is appended to the 
  -- default CREATE TABLE statement.

  procedure removeTableProps(xmlschema in out XMLType, 
                          globalObject VARCHAR2, 
                          globalObjectName VARCHAR2, 
                          localElementName VARCHAR2);
  -- Removes the TABLE storage clause that is appended to the 
  -- default CREATE TABLE statement.

  procedure disableDefaultTableCreation(xmlschema in out XMLType, 
                                         globalElementName VARCHAR2);
  -- Add a default table attribute with an empty value to the 
  -- top level element with the specified name. 
  -- No table will be created for that element. 
  -- The procedure will always overwrite.


  procedure disableDefaultTableCreation(xmlschema in out XMLType);
  -- Add a default table attribute with an empty value to ALL top level 
  -- elements that have no defined default table name. 
  -- The procedure will never overwrite existing annotations since this 
  -- would lead to no table creation at all.  
  -- This is the way to prevent XDB from creating many and unused tables 
  -- for elements that are no root elements of 
  -- instance documents.
 /* TODO This function
  * This functions should test that at least one default table with a given
  * name exists. If no default table name is assigned calling this
  * disableTopLevelTableCreation would lead to no table creation at all. */

  procedure enableDefaultTableCreation(xmlschema in out XMLType, 
                                        globalElementName VARCHAR2);
  -- Enables the creation of top level tables by removing the empty default 
  -- table name annotation.

  procedure enableDefaultTableCreation(xmlschema in out XMLType);
  -- Enables the creation of ALL top level tables by removing the empty 
  -- default table name annotation.
 
  procedure setSQLName (xmlschema in out XMLType, 
                        globalObject VARCHAR2, 
                        globalObjectName VARCHAR2, 
                        localObject VARCHAR2, 
                        localObjectName VARCHAR2, 
                        sqlName VARCHAR2, 
                        overwrite BOOLEAN default TRUE);
  -- assigns a sqlname to an element

  procedure removeSQLName (xmlschema in out XMLType, 
                           globalObject VARCHAR2, 
                           globalObjectName VARCHAR2, 
                           localObject VARCHAR2, 
                           localObjectName VARCHAR2);
  -- removes a sqlname from a global element

  procedure setSQLType (xmlschema in out XMLType, 
                        globalElementName VARCHAR2, 
                        sqlType VARCHAR2, 
                        overwrite BOOLEAN default TRUE);
  -- assigns a sqltype to a global element

  procedure removeSQLType (xmlschema in out XMLType, 
                           globalElementName VARCHAR2);
  -- removes a sqltype from a global element

  procedure setSQLType(xmlschema in out XMLType, 
                       globalObject VARCHAR2, 
                       globalObjectName VARCHAR2, 
                       localObject VARCHAR2, 
                       localObjectName VARCHAR2, 
                       sqlType VARCHAR2, 
                       overwrite BOOLEAN default TRUE);
  -- assigns a sqltype inside a complex type (local)

  procedure removeSQLType    (xmlschema in out XMLType, 
                              globalObject VARCHAR2, 
                              globalObjectName VARCHAR2, 
                              localObject VARCHAR2, 
                              localObjectName VARCHAR2);
  -- removes a sqltype inside a complex type (local)
                                 
  procedure setSQLTypeMapping(xmlschema in out XMLType, 
                              schemaTypeName VARCHAR2, 
                              sqlTypeName VARCHAR2, 
                              overwrite BOOLEAN default TRUE);
  -- defines a mapping of schema type and sqltype. 
  -- The addSQLType procedure do not have to be called on all instances of 
  -- the schema type instead the schema is traversed and the 
  -- sqltype is assigned automatically.

  procedure removeSQLTypeMapping(xmlschema in out XMLType, 
                                 schemaTypeName VARCHAR2);
  -- removes the sqltype mapping for the given schema type. 

  procedure setTimeStampWithTimeZone(xmlschema in out xmlType, 
                                     overwrite BOOLEAN default TRUE);
  -- sets the TimeStampWithTimeZone datatype to dateTime typed element.

  procedure removeTimeStampWithTimeZone(xmlschema in out xmlType);
  -- removes the TimeStampWithTimeZone datatype to dateTime typed element.

  procedure setAnyStorage (xmlschema in out XMLType, 
                           complexTypeName VARCHAR2, 
                           sqlTypeName VARCHAR2, 
                           overwrite BOOLEAN default TRUE);
  -- sets the sqltype of any

  procedure removeAnyStorage (xmlschema in out XMLType, 
                              complexTypeName VARCHAR2);
  -- removes the sqltype of any

  procedure setSQLCollType(xmlschema in out XMLType, 
                           elementName VARCHAR2, 
                           sqlCollType VARCHAR2, 
                           overwrite BOOLEAN default TRUE);
  -- sets the name of the SQL collection type that corresponds 
  -- to this XML element

  procedure removeSQLCollType(xmlschema in out XMLType, 
                              elementName VARCHAR2);
  -- removes the sql collection type

  procedure setSQLCollType(xmlschema in out XMLType, 
                           globalObject VARCHAR2, 
                           globalObjectName VARCHAR2, 
                           localElementName VARCHAR2, 
                           sqlCollType VARCHAR2, 
                           overwrite BOOLEAN default TRUE );
  -- Name of the SQL collection type that corresponds to this 
  -- XML element. inside a complex type.

  procedure removeSQLCollType(xmlschema in out XMLType, 
                              globalObject VARCHAR2, 
                              globalObjectName VARCHAR2, 
                              localElementName VARCHAR2);
  -- removes the sql collection type

  procedure disableMaintainDom(xmlschema in out XMLType, 
                               overwrite BOOLEAN default TRUE);
  -- sets dom fidelity to FALSE to ALL complex types irregardless 
  -- of their names

  procedure enableMaintainDom(xmlschema in out XMLType, 
                              overwrite BOOLEAN default TRUE);
  -- sets dom fidelity to TRUE to ALL complex types irregardless 
  -- of their names

  procedure disableMaintainDom(xmlschema in out XMLType, 
                               complexTypeName VARCHAR2, 
                               overwrite BOOLEAN default TRUE);
  -- sets the dom fidelity attribute for the given complex type name to FALSE.

  procedure enableMaintainDom(xmlschema in out XMLType, 
                              complexTypeName VARCHAR2, 
                              overwrite BOOLEAN default TRUE);
  -- sets the dom fidelity attribute for the given complex type name to TRUE

  procedure removeMaintainDom(xmlschema in out XMLType);
  -- removes all maintain dom annotations from given schema  

  procedure setOutOfLine(xmlschema in out XMLType, 
                          elementName VARCHAR2, 
                          elementType VARCHAR2, 
                          defaultTableName VARCHAR2, 
                          overwrite BOOLEAN default TRUE);
  -- set the sqlInline attribute to false and forces the out of line storage
  -- for the element specified by its name.

  procedure removeOutOfLine(xmlschema in out XMLType, 
                            elementName VARCHAR2, 
                            elementType VARCHAR2);
  -- removes the sqlInline attribute for the element specified by its name.

  procedure setOutOfLine (xmlschema in out XMLType, 
                           globalObject VARCHAR2, 
                           globalObjectName VARCHAR2, 
                           localElementName VARCHAR2, 
                           defaultTableName VARCHAR2, 
                           overwrite BOOLEAN default TRUE);
  -- set the sqlInline attribute to false and forces the out of line storage 
  -- for the element specified by its   local and global name  

  procedure removeOutOfLine (xmlschema in out XMLType, 
                             globalObject VARCHAR2, 
                             globalObjectName VARCHAR2, 
                             localElementName VARCHAR2);
  -- removes the sqlInline attribute for the element specified by its 
  -- global and local name

  procedure setOutOfLine(xmlschema in out XMLType, 
                          reference VARCHAR2, 
                          defaultTableName VARCHAR2, 
                          overwrite BOOLEAN default TRUE);
  -- sets the default table name and sqlinline attribute for all references 
  -- to a particular global Element

  procedure removeOutOfLine(xmlschema in out XMLType, reference VARCHAR2);
  -- removes the the sqlInline attribute for the global element



  function getSchemaAnnotations(xmlschema xmlType) return XMLType;
  --  creates a diff of the annotated xml schema and the 
  --  non-annotated  xml schema.
  --  This diff can be used to apply all annotation again on a 
  --  non-annotated schema. 
  --  A user calls this function to save all annotations in one document.

  procedure setSchemaAnnotations(xmlschema in out xmlType, annotations XMLTYPE);
  -- Will take the annotations 
  -- (diff result from call to 'getSchemaAnnotations' 
  -- and will patch in provided XML schema.




END DBMS_XMLSCHEMA_ANNOTATE;
/
SHOW ERRORS;

grant execute on XDB.DBMS_XMLSCHEMA_ANNOTATE to public;

CREATE OR REPLACE PUBLIC SYNONYM DBMS_XMLSCHEMA_ANNOTATE 
     for XDB.DBMS_XMLSCHEMA_ANNOTATE;

--**************************************************


-- Create type required for dbms_manage_xmlstorage
-- **************************************************
create or replace TYPE XDB.XMLTYPE_REF_TABLE_T IS TABLE of REF XMLTYPE
/
grant execute on XDB.XMLTYPE_REF_TABLE_T to public
/
--**************************************************


-- Create package dbms_manage_xmlstorage
-- **************************************************
CREATE OR REPLACE PACKAGE XDB.DBMS_XMLSTORAGE_MANAGE authid CURRENT_USER AS 

  procedure renameCollectionTable (owner_name varchar2 :=
                                   SYS_CONTEXT('USERENV','CURRENT_USER'),
                                   tab_name varchar2,
                                   col_name varchar2 default NULL,
                                   xpath varchar2,
                                   collection_table_name varchar2,
                                   namespaces IN VARCHAR2 default NULL);


  -- Renames a collection table from the system generated name 
  -- to the given table name.
  -- This function is called AFTER registering the xml schema.
  -- NOTE: Since there is no direct schema annotation for this purpose 
  -- this post registration 
  -- function has to be used. Because all other functions are used before 
  -- registration this 
  -- function breaks the consistency. In addition, this is the only case 
  -- where we encourage the 
  -- user/dba to change a table/type name after registration. 
  -- Since one goal of the schema annotation is to enable more readable 
  -- query execution plans   
  -- we recommend to derive the name of a collection table by its 
  -- corresponding collection type name. 
  -- Since we have an annotation for collection type we should use this one
  -- when creating the collection 
  -- table. This might make the renameCollectionTable obsolete.


  procedure scopeXMLReferences;
  -- Will scope all XML references. Scoped REF types require 
  -- less storage space and allow more 
  -- efficient access than unscoped REF types.
  -- Note: This procedure does not need to be exposed 
  -- to customer if called automatically from 
  -- schema registration code. 
  -- In this case we will either move the procedure into a prvt package 
  -- or call the body of scopeXMLReferences from schema registration code 
  -- directly so that the 
  -- procedure would not be published at all.

  procedure indexXMLReferences( owner_name VARCHAR2 :=
                                SYS_CONTEXT('USERENV','CURRENT_USER'),
                                table_name VARCHAR2,
                                column_name VARCHAR2 default NULL,
                                index_name VARCHAR2);
  -- This procedure creates unique indexes on the ref columns
  -- of the given XML type tables or XML type column of a given table. 
  -- In case of an XML type table the column name does not 
  -- have to be specified. 
  -- The index_name will be used to name the index- since multiple ref 
  -- columns could be affected the table name gets a iterator concatenated 
  -- at the end. 
  -- For instance if two ref columns are getting indexed they will be named 
  -- index_name_1 and index_name_2.
  -- The procdure indexXMLReferences will not recursively index refs in child
  -- tables of the table that this procedure is called on. 
  -- If this is desired we recommend to call the 
  -- procedure from within a loop  over the 
  -- DBA|ALL|USER_ XML_OUT_OF_LINE_TABLES or 
  -- DBA|ALL|USER_ XML_NESTED_TABLES view. 
  -- The index_name could then be created from the current 
  -- value of a view's column.
  -- Indexed refs lead to higher performance when joins between the 
  -- child table and base table 
  -- occur in the query plan. If the selectivity of the child table 
  -- is higher than the join of one 
  -- row in the child table with the base table leads to a full table 
  -- scan of the base table if no indexes are present. 
  -- This is the exact motivation for indexing the refs in the base table. 
  -- If the base table has a higher selectivity than the child table there 
  -- is no need to index the refs.
  -- Indexing the refs makes only sense if the refs are scoped. 

  -- ** Bulkload functionality
procedure  disableIndexesAndConstraints(owner_name varchar2 :=
                                        SYS_CONTEXT('USERENV','CURRENT_USER'),
                                        table_name varchar2,
                                        column_name varchar2 default NULL,
                                        clear Boolean default FALSE);


  -- This procedure will be used to drop the indexes and disable 
  -- the constraints for both xmltype 
  -- table (no P_COL_NAME) and xmltype columns. 
  -- For xmltype tables, the user needs to pass the xmltype-table 
  -- name on which the bulk load operation is to be performed. 
  -- For xmltype columns, the user needs to pass 
  -- the relational table_name and the corresponding xmltype column name.

procedure enableIndexesAndConstraints(owner_name varchar2 :=
                                      SYS_CONTEXT('USERENV','CURRENT_USER'),
                                      table_name varchar2,
                                      column_name varchar2 default NULL);
 

  -- This procedure will rebuild all indexes and enable the constraints 
  -- on the P_TABLE_NAME including its 
  -- child and out of line tables. 
  -- When P_COL_NAME is passed, it does the same for this xmltype column.


-- routine to disable constraints before exchange partition
procedure  ExchangePreProc(owner_name varchar2 :=
                           SYS_CONTEXT('USERENV','CURRENT_USER'),
                           table_name varchar2);
-- routine to enable constraints after exchange partition
procedure  ExchangePostProc(owner_name varchar2 :=
                            SYS_CONTEXT('USERENV','CURRENT_USER'),
                            table_name varchar2);

-- routine to exchange reference partition in
procedure  RefPartitionExchangeIn(owner_name varchar2 :=
                                  SYS_CONTEXT('USERENV','CURRENT_USER'),
                      parent_table_name varchar2,
                      child_table_name varchar2,
                      parent_exchange_table_name varchar2,
                      child_exchange_table_name varchar2,
                      parent_exchange_stmt clob,
                      child_exchange_stmt clob);

-- routine to exchange reference partition out 
procedure  RefPartitionExchangeOut(owner_name varchar2 :=
                                   SYS_CONTEXT('USERENV','CURRENT_USER'),
                       parent_table_name varchar2,
                       child_table_name varchar2,
                       parent_exchange_table_name varchar2,
                       child_exchange_table_name varchar2,
                       parent_exchange_stmt clob,
                       child_exchange_stmt clob);

function xpath2TabColMapping(owner_name VARCHAR2 :=
                             SYS_CONTEXT('USERENV','CURRENT_USER'),
                             table_name IN VARCHAR2,     
                             column_name IN VARCHAR2 default NULL,
                             xpath IN VARCHAR2,
                             namespaces IN VARCHAR2 default NULL) RETURN XMLTYPE;  

function getSIDXDefFromView(viewName  IN VARCHAR2) RETURN CLOB; 

--routine to get type creation DDLs for all CDB invalid types after PDB plugin
procedure GetTypeDDL ;

END DBMS_XMLSTORAGE_MANAGE;
/
SHOW ERRORS;

grant execute on XDB.DBMS_XMLSTORAGE_MANAGE to public;


CREATE OR REPLACE PUBLIC SYNONYM DBMS_XMLSTORAGE_MANAGE
     for XDB.DBMS_XMLSTORAGE_MANAGE;


@?/rdbms/admin/sqlsessend.sql
