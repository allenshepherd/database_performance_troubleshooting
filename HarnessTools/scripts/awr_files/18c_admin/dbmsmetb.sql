Rem
Rem $Header: rdbms/admin/dbmsmetb.sql /main/5 2014/02/20 12:45:51 surman Exp $
Rem
Rem dbmsmetb.sql
Rem
Rem Copyright (c) 2004, 2014, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem     dbmsmetb.sql - Package header for DBMS_METADATA_BUILD.
Rem     NOTE - Package body is in:
Rem            rdbms/src/server/datapump/ddl/prvtmetb.sql
Rem    DESCRIPTION
Rem     This file contains the package header for DBMS_METADATA_BUILD,
Rem     an invoker's rights package that implements lower-level functions
Rem     for defining heterogeneous object types
Rem
Rem    FUNCTIONS / PROCEDURES
Rem     PUT_LINE        - Write debugging output.
Rem     PUT_BOOL        - Write debugging output.
Rem     DROP_TYPE       - Drop a heterogeneous type.
Rem     CREATE_TYPE     - Begin creation of a heterogeneous type.
Rem     SET_TYPE_PARAM  - Set type attributes
Rem     CREATE_FILTER   - Begin creation of a filter for a type.
Rem     SET_FILTER_PARAM- Set filter attributes.
Rem     CLOSE           - Insert all types/filters into the dictionary.
Rem 
Rem    NOTES
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmsmetb.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmsmetb.sql
Rem SQL_PHASE: DBMSMETB
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    lbarton     09/02/10 - project 30934: export views as tables
Rem    lbarton     05/17/04 - Versioning support 
Rem    lbarton     04/27/04 - lbarton_bug-3334702
Rem    lbarton     01/28/04 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

CREATE OR REPLACE PACKAGE DBMS_METADATA_BUILD AUTHID CURRENT_USER AS

--------------------
--  PUBLIC CONSTANTS
--
  DATATYPE_MIN           CONSTANT NUMBER         := 1;
  DATATYPE_BOOLEAN       CONSTANT NUMBER         := 1;
  DATATYPE_NUMERIC       CONSTANT NUMBER         := 2;
  DATATYPE_TEXT          CONSTANT NUMBER         := 3;
  DATATYPE_CUSTOM_FILTER CONSTANT NUMBER         := 3;
  DATATYPE_TEXT_EXPR     CONSTANT NUMBER         := 4;
  DATATYPE_OBJNUM        CONSTANT NUMBER         := 5;
  DATATYPE_VAT_OBJNUM    CONSTANT NUMBER         := 6;
  DATATYPE_MAX           CONSTANT NUMBER         := 6;

  TYPE_HETEROGENEOUS     CONSTANT BOOLEAN        := TRUE;
  TYPE_HOMOGENEOUS       CONSTANT BOOLEAN        := FALSE;
  TOP_LEVEL_TYPE         CONSTANT NUMBER         := 0;
-------------
-- EXCEPTIONS
--

---------------------------
-- PROCEDURES AND FUNCTIONS
--
-- DROP_TYPE: Drop a heterogeneous type.  This deletes the type definition
--            and all dependent types, filters, etc.
-- PARAMETERS
--   name                       - type name

 PROCEDURE drop_type  ( name            IN VARCHAR2 );

-- CREATE_TYPE: Begin creation of a type.  The type will not be inserted into
-- the dictionary until CLOSE is called.
-- PARAMETERS
--   parent_handle              - handle of the parent heterogeneous type to
--                                which this type belongs.
--                                If TOP_LEVEL_TYPE, this is a top-level type
--                                (e.g., TABLE_EXPORT)
--   name                       - type name
--   type                       - either TYPE_HETEROGENEOUS
--                                or TYPE_HOMOGENEOUS
-- RETURNS
--   handle to the created type

 FUNCTION create_type ( parent_handle   IN NUMBER,
                        name            IN VARCHAR2,
                        type            IN BOOLEAN DEFAULT TYPE_HETEROGENEOUS )
        RETURN NUMBER;

-- SET_TYPE_PARAM: Set type attributes
-- PARAMETERS
--   handle                     - handle returned by CREATE_TYPE
--   name                       - parameter name:
--      SCHEMA_OBJECT (boolean) - TRUE = type is a schema object, i.e., it has a
--                                      SCHEMA filter whose value defaults to
--                                      the current user
--      SAVE_OBJNUM (boolean)   - TRUE = save objnums returned by this type
--                                     (default FALSE)
--      SAVE_SORTED_OBJNUM (boolean)
--                              - TRUE = save objnums and dependency#s
--                                     returned by this type
--                                     (default FALSE)
--      ALIAS (text)            - node name to use for this type when 
--                                     constructing a path to the type
--                                     (defaults to type name)
--      DESCRIPTION (text)      - Text description of the type
--                                (for *_EXPORT_OBJECTS view)
--      INTERSECTS (text)       - 
--      BASE_STEP (numeric)     - handle of base step
--      VERSION (text)          - version number of the first RDBMS version
--                                     that supports this type
--                                     Format n.n.n[.n[.n]], e.g., 10.2.0
--   value                      - parameter value

 PROCEDURE set_type_param (     handle  IN NUMBER,
                                name    IN VARCHAR2,
                                value   IN VARCHAR2 );

 PROCEDURE set_type_param (     handle  IN NUMBER,
                                name    IN VARCHAR2,
                                value   IN BOOLEAN );

 PROCEDURE set_type_param (     handle  IN NUMBER,
                                name    IN VARCHAR2,
                                value   IN NUMBER );

-- CREATE_FILTER: Begin creation of a filter for a type.
--                The filter will not be inserted into the dictionary
--                until CLOSE is called.  If the owning type (designated 
--                by 'handle') is not heterogeneous, then the filter must
--                already be defined in sys.metafilter$.
-- PARAMETERS
--   handle                     - handle of the type to which this filter
--                                belongs.
--   name                       - filter name
--   datatype                   - datatype:
--                                 DATATYPE_BOOLEAN
--                                 DATATYPE_NUMERIC
--                                 DATATYPE_TEXT
--                                 DATATYPE_TEXT_EXPR
--                                 DATATYPE_OBJNUM
-- RETURNS
--   handle to the created filter

 FUNCTION create_filter(handle          IN NUMBER,
                        name            IN VARCHAR2,
                        datatype        IN NUMBER)
        RETURN NUMBER;

-- SET_FILTER_PARAM: Set filter attributes
-- PARAMETERS
--   handle                     - handle returned by CREATE_FILTER
--   name                       - parameter name:
--      DEFAULT         - filter default value
--      DEFINITION      - (text) filter definition
--      VALUE           - fixed filter value
--      PARENT_NAME     - (text) name of parent filter from which to inherit
--      OBJNUM_FILTER   - (boolean) this is an objnum filter
--      REPLACEABLE     - (boolean) filter is replaceable
--      FILTER_LEAF     - (boolean) filters specific leaves, e.g.,
--                              BEGIN_WITH, PRIVILEGED_USER
--      FILTER_BRANCH   - (boolean) filters whole branches of the tree,
--                              e.g., EXCLUDE_PATH_EXPR
--      APPLY_IF_TRUE   - (boolean) a "special boolean filter".  Most boolean
--                              filters (e.g., 'PRIMARY') default to TRUE;
--                              they are not applied unless the user
--                              sets them FALSE meaning "don't return
--                              this kind of object".  Special boolean filters
--                              (e.g., 'WORK_PHASE') default to FALSE
--                              and are only applied when the user
--                              sets them TRUE.
--   value                      - parameter value

 PROCEDURE set_filter_param (   handle  IN NUMBER,
                                name    IN VARCHAR2,
                                value   IN VARCHAR2 );

 PROCEDURE set_filter_param (   handle  IN NUMBER,
                                name    IN VARCHAR2,
                                value   IN BOOLEAN );

 PROCEDURE set_filter_param (   handle  IN NUMBER,
                                name    IN VARCHAR2,
                                value   IN NUMBER );

-- CLOSE: Insert all types and filters into the dictionary.
-- PARAMETERS
--   handle                     - handle returned by CREATE_TYPE
--                                for the top-level type

 PROCEDURE close (              handle  IN NUMBER );

-- SET_DEBUG: Set the internal debug switch.
-- PARAMETERS:
--      on_off          - new switch state.

  PROCEDURE set_debug(
                on_off          IN BOOLEAN);

-- SET_DEBUG_PARAM: Set debugging parameters.
-- PARAMETERS:
--   name                       - parameter name:
--      DIRECTORY         - Directory where debug file is written.
--                          Defaults to 'DATA_PUMP_DIR'
--      FILE              - Debug file name.
--                          Defaults to 'debug.trc'
--   value                      - parameter value

 PROCEDURE set_debug_param (   name    IN VARCHAR2,
                               value   IN VARCHAR2 );

END DBMS_METADATA_BUILD;
/
GRANT EXECUTE ON sys.dbms_metadata_build TO EXECUTE_CATALOG_ROLE; 
CREATE OR REPLACE PUBLIC SYNONYM dbms_metadata_build
 FOR sys.dbms_metadata_build;


@?/rdbms/admin/sqlsessend.sql
