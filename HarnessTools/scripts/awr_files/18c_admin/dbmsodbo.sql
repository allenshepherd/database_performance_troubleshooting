Rem
Rem $Header: rdbms/admin/dbmsodbo.sql /main/8 2017/09/25 01:53:16 sshringa Exp $
Rem
Rem dbmsodbo.sql
Rem
Rem Copyright (c) 2013, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsodbo.sql - Multi-Dimensional Sql ODBO package for MDX support
Rem
Rem    DESCRIPTION
Rem      PL/SQL definitions to support OLE DB for MDX
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    sshringa    09/08/17 - Adding start/end markers for rti-20225108
Rem    mstasiew    12/18/15 - add property_content_type, property_origin
Rem    sfeinste    12/04/15 - Bug 22029736: remove old interfaces
Rem    sfeinste    10/09/15 - Add query_properties to get_schema_rowset
Rem    mstasiew    07/17/15 - Bug 20777735 add caption to odbo_function
Rem    raeburns    06/18/15 - Use FORCE for types with only type dependents
Rem    mstasiew    09/19/14 - function schema rowset columns
Rem                           remove getFunctions, get_functions
Rem    sfeinste    09/15/14 - Rename MDS -> HCS
Rem    beiyu       06/30/14 - Add mdx_strip_component
Rem    mstasiew    07/07/14 - logging for schema rowsets,
Rem                           make get_members_schema_rowset private
Rem    beiyu       06/23/14 - Add get_mdx_function_names, get_functions
Rem    ddedonat    05/20/14 - Added exceptions 18259 and 18260
Rem    mstasiew    04/29/14 - remove test_mdx, test_mdx_parser
Rem    mstasiew    04/09/14 - remove validate_cube, now done at ddl time
Rem    ddedonat    03/27/14 - Added functions and procedures to support MDX schema
Rem                           rowset metadata views and schema rowset processing
Rem                           Added call to catmdsx.sql to create MDX Schema
Rem                           Rowset Metadata Views
Rem    sfeinste    03/20/14 - change test_mdx to be function
Rem    mstasiew    03/14/14 - validate_cube
Rem    mstasiew    03/12/14 - mdx_datatype
Rem    beiyu       02/26/14 - add test_mdx_parser to only parse mdx query and 
Rem                           change NVARCHAR to VARCHAR for mdx string argument
Rem    sfeinste    03/11/14 - Add old interface as wrappers since provider is
Rem                           still using that interface
Rem    dbardwel    02/25/14 - add object types and procedures for getting
Rem                           MDX keywords and property values
Rem    sfeinste    02/15/14 - add get_axis_data, get_cell_data, and close
Rem                           Also add queryProps to execute
Rem                           Also add odbo_*_sequence types
Rem    mstasiew    02/13/14 - add datatype to convert_format_string
Rem    mstasiew    01/31/14 - add convert_format_string, mdx_component_id
Rem    mstasiew    10/17/13 - created from mdsodbo.sql separated package
Rem                           header and package body
Rem    almurphy    09/22/13 - Change test_mdx to have single clob output
Rem    beiyu       08/26/13 - added execute procedure
Rem    beiyu       07/31/13 - moved from transaction glyon_mdxii
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/src/server/mds/sql/dbmsodbo.sql 
Rem    SQL_SHIPPED_FILE: 
Rem    SQL_PHASE: DBMSODBO
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: 
Rem    END SQL_FILE_METADATA

@?/rdbms/admin/sqlsessstart.sql


REM Create a type and table of type for the MDX keywords for table function
CREATE OR REPLACE TYPE DBMS_MDX_ODBO_KEYWORD_R FORCE AS OBJECT(
    KEYWORD_NAME VARCHAR2(128))
/

CREATE OR REPLACE TYPE DBMS_MDX_ODBO_KEYWORD_T AS TABLE OF
    DBMS_MDX_ODBO_KEYWORD_R
/

REM Create a type and table for MDX function names
CREATE OR REPLACE TYPE DBMS_MDX_ODBO_FUNCTION_R FORCE AS OBJECT(
    FUNCTION_NAME VARCHAR2(128),
    CAPTION VARCHAR2(128),
    DESCRIPTION VARCHAR2(1000),
    PARAM_LIST VARCHAR2(1000),
    INTERFACE_NAME VARCHAR2(128),
    object VARCHAR2(128))
/

CREATE OR REPLACE TYPE DBMS_MDX_ODBO_FUNCTION_T AS TABLE OF
    DBMS_MDX_ODBO_FUNCTION_R
/

REM Create a type and table of type for MDX property values for table function
CREATE OR REPLACE TYPE DBMS_MDX_ODBO_PROPVAL_R FORCE AS OBJECT(
    PROPERTY_VALUE NUMBER)
/

CREATE OR REPLACE TYPE DBMS_MDX_ODBO_PROPVAL_T AS TABLE OF
    DBMS_MDX_ODBO_PROPVAL_R
/

GRANT EXECUTE ON DBMS_MDX_ODBO_KEYWORD_R TO PUBLIC;
GRANT EXECUTE ON DBMS_MDX_ODBO_KEYWORD_T TO PUBLIC;
GRANT EXECUTE ON DBMS_MDX_ODBO_FUNCTION_R TO PUBLIC;
GRANT EXECUTE ON DBMS_MDX_ODBO_FUNCTION_T TO PUBLIC;
GRANT EXECUTE ON DBMS_MDX_ODBO_PROPVAL_R TO PUBLIC;
GRANT EXECUTE ON DBMS_MDX_ODBO_PROPVAL_T TO PUBLIC;

CREATE OR REPLACE LIBRARY DBMS_HCS_LIB TRUSTED AS STATIC
/

CREATE OR REPLACE PACKAGE DBMS_MDX_ODBO AUTHID CURRENT_USER AS

  MDX_DATE CONSTANT VARCHAR2(8) := 'MDX_DATE';
  MDX_NUMBER CONSTANT VARCHAR2(10) := 'MDX_NUMBER';

  MDSCHEMA_ACTIONS CONSTANT BINARY_INTEGER := 1;
  MDSCHEMA_CUBES CONSTANT BINARY_INTEGER := 2;
  MDSCHEMA_DIMENSIONS CONSTANT BINARY_INTEGER := 3;
  MDSCHEMA_FUNCTIONS CONSTANT BINARY_INTEGER := 4;
  MDSCHEMA_HIERARCHIES CONSTANT BINARY_INTEGER := 5;
  MDSCHEMA_LEVELS CONSTANT BINARY_INTEGER := 6;
  MDSCHEMA_MEASURES CONSTANT BINARY_INTEGER := 7;
  MDSCHEMA_PROPERTIES CONSTANT BINARY_INTEGER := 8;
  MDSCHEMA_MEMBERS CONSTANT BINARY_INTEGER := 9;
  MDSCHEMA_SETS CONSTANT BINARY_INTEGER := 10;
  MDSCHEMA_ROWSET_MAX CONSTANT BINARY_INTEGER := 11;

  -- RDBMS bug (fixed in MAIN) prevents use of SMALLINT here
  --TYPE odbo_boolean_sequence  IS VARRAY(32767) OF SMALLINT;
  --TYPE odbo_short_sequence IS VARRAY(32767) OF SMALLINT;
  TYPE odbo_boolean_sequence IS VARRAY(32767) OF NUMBER;
  TYPE odbo_short_sequence IS VARRAY(32767) OF NUMBER;
  TYPE odbo_number_sequence IS VARRAY(32767) OF NUMBER;
  TYPE odbo_string_sequence IS VARRAY(32767) OF VARCHAR2(10922);
 
  INVALID_ROWSET_TYPE EXCEPTION;
      PRAGMA EXCEPTION_INIT(INVALID_ROWSET_TYPE, -18259);  

  INVALID_ROWSET_ARRAYS EXCEPTION;
      PRAGMA EXCEPTION_INIT(INVALID_ROWSET_ARRAYS, -18260);  

  INVALID_QRY_PROPS EXCEPTION;
      PRAGMA EXCEPTION_INIT(INVALID_QRY_PROPS, -18264);      
	  
  PROCEDURE execute(
    mdx_str IN VARCHAR2,
    query_properties IN odbo_string_sequence,
    column_axis OUT SYS_REFCURSOR, row_axis OUT SYS_REFCURSOR,
    page_axis OUT SYS_REFCURSOR, chapter_axis OUT SYS_REFCURSOR,
    section_axis OUT SYS_REFCURSOR, slicer OUT SYS_REFCURSOR,
    mdx_info OUT CLOB, query_id OUT NUMBER);

  FUNCTION GET_MDX_DATE_TYPE RETURN VARCHAR2;
  FUNCTION GET_MDX_NUMBER_TYPE RETURN VARCHAR2;

  FUNCTION GET_MDSCHEMA_ACTIONS RETURN BINARY_INTEGER;
  FUNCTION GET_MDSCHEMA_CUBES RETURN BINARY_INTEGER;
  FUNCTION GET_MDSCHEMA_DIMENSIONS RETURN BINARY_INTEGER;
  FUNCTION GET_MDSCHEMA_FUNCTIONS RETURN BINARY_INTEGER;
  FUNCTION GET_MDSCHEMA_HIERARCHIES RETURN BINARY_INTEGER;
  FUNCTION GET_MDSCHEMA_LEVELS RETURN BINARY_INTEGER;
  FUNCTION GET_MDSCHEMA_MEASURES RETURN BINARY_INTEGER;
  FUNCTION GET_MDSCHEMA_PROPERTIES RETURN BINARY_INTEGER;
  FUNCTION GET_MDSCHEMA_MEMBERS RETURN BINARY_INTEGER;
  FUNCTION GET_MDSCHEMA_SETS RETURN BINARY_INTEGER;
  FUNCTION GET_MDSCHEMA_ROWSET_MAX RETURN BINARY_INTEGER;

  PROCEDURE get_axis_data(
    query_id IN NUMBER,
    axis_index IN NUMBER,
    axis_data OUT SYS_REFCURSOR);

  PROCEDURE get_cell_data(
    query_id IN NUMBER,
    cell_range IN odbo_number_sequence,
    cell_data OUT SYS_REFCURSOR);

  PROCEDURE close(query_id IN NUMBER);

  FUNCTION convert_format_string (
    orcl_fmt_str         IN VARCHAR2,
    datatype             IN VARCHAR2)
  RETURN VARCHAR2;

  FUNCTION mdx_component_id (
    component1 	 IN VARCHAR2,
    component2   IN VARCHAR2 DEFAULT NULL,
    component3   IN VARCHAR2 DEFAULT NULL,
    component4   IN VARCHAR2 DEFAULT NULL)
  RETURN VARCHAR2;

  FUNCTION mdx_strip_component (
    id           IN VARCHAR2)
  RETURN VARCHAR2;

  FUNCTION get_mdx_keyword_names
  return sys.dbms_mdx_odbo_keyword_t
  pipelined;

  FUNCTION get_mdx_function_names
  return sys.dbms_mdx_odbo_function_t
  pipelined;

  FUNCTION get_mdx_property_values
  return sys.dbms_mdx_odbo_propval_t
  pipelined;

  PROCEDURE get_dso_properties(mdpropvals OUT odbo_short_sequence);

  PROCEDURE get_keywords(keywords OUT VARCHAR2);
 
  PROCEDURE get_schema_rowset(
      rowset_type IN NUMBER,
      restrictions IN odbo_string_sequence,
      empty IN odbo_boolean_sequence,
      rowset OUT SYS_REFCURSOR,
      query_properties IN odbo_string_sequence);
  
  PROCEDURE close_schema_rowset(
      rowset_type IN NUMBER,
	  rowset In OUT SYS_REFCURSOR);

  -- Function to return Dimension Types  
  FUNCTION mdx_dimension_type(dimtype IN VARCHAR2)
      RETURN INTEGER DETERMINISTIC;
  
  -- Function to return Measure Cardinality  
  FUNCTION mdx_get_measure_cardinality(
      cubeowner IN VARCHAR2,
	  cubename IN VARCHAR2)	
      RETURN INTEGER DETERMINISTIC;

  -- Function to return Dimension Cardinality  
  FUNCTION mdx_get_dimension_cardinality(
      cubeowner IN VARCHAR2,
	  cubename IN VARCHAR2,
	  dimalias IN VARCHAR2)
      RETURN INTEGER DETERMINISTIC;

  -- Function to return Level Cardinality  
  FUNCTION mdx_get_level_cardinality(
      cubeowner IN VARCHAR2,
	  cubename IN VARCHAR2,
	  dimalias IN VARCHAR2,
	  hierarchyalias IN VARCHAR2,
	  levelname IN VARCHAR2)
      RETURN INTEGER DETERMINISTIC;	

  -- Function to return Hierarchy Cardinality  
  FUNCTION mdx_get_hierarchy_cardinality(
      cubeowner IN VARCHAR2,
	  cubename IN VARCHAR2,
	  dimalias IN VARCHAR2,
	  hierarchyalias IN VARCHAR2)
      RETURN INTEGER DETERMINISTIC;
	
  -- Function to return Hierarchy Structures  
  FUNCTION mdx_hierarchy_structure(structuretype IN VARCHAR2)
    RETURN INTEGER DETERMINISTIC;
	
  -- Function to return Hierarchy and Level Origins  
  FUNCTION mdx_origin(origintype IN VARCHAR2)
    RETURN INTEGER DETERMINISTIC;

  -- Function to return Hierarchy Instance Selections  
  FUNCTION mdx_hierarchy_inst_selection(selectiontype IN VARCHAR2)
    RETURN INTEGER DETERMINISTIC;
	
  -- Function to return Level Unique Settings  
  FUNCTION mdx_level_unique_settings(type IN VARCHAR2)
    RETURN INTEGER DETERMINISTIC;
	
  -- Function to return Measure Aggregation Value  
  FUNCTION mdx_measure_aggregator(aggtype IN VARCHAR2)
    RETURN INTEGER DETERMINISTIC;		
	
  -- Function to return Property Types  
  FUNCTION mdx_property_type(propertytype IN VARCHAR2)
    RETURN INTEGER DETERMINISTIC;			

  -- Function to return Property Content Types  
  FUNCTION mdx_property_content_type(propertytype IN VARCHAR2)
    RETURN INTEGER DETERMINISTIC;

  -- Function to return Property Origins  
  FUNCTION mdx_property_origin(propertytype IN VARCHAR2)
    RETURN INTEGER DETERMINISTIC;

  FUNCTION mdx_datatype (orclDt IN VARCHAR2)
  RETURN NUMBER DETERMINISTIC;

END;
/

show errors;

-- Synonyms and grants
CREATE OR REPLACE PUBLIC SYNONYM DBMS_MDX_ODBO FOR sys.DBMS_MDX_ODBO;
GRANT EXECUTE ON DBMS_MDX_ODBO TO PUBLIC;

Rem *********************************************************************
Rem Create MDX Schema Rowset Metadata Views
Rem *********************************************************************
@@cathcsx.sql

@?/rdbms/admin/sqlsessend.sql

