Rem
Rem $Header: rdbms/admin/dbmssodapls.sql /st_rdbms_18.0/1 2018/04/11 10:34:43 sriksure Exp $
Rem
Rem dbmssodapls.sql
Rem
Rem Copyright (c) 2016, 2018, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmssodapls.sql - DBMS SODA PL/SQL package and types specification
Rem
Rem    DESCRIPTION
Rem      Specification of the xdb.dbms_soda package and SODA types
Rem      
Rem    NOTES
Rem      Package dbms_soda           - 
Rem      Type SODA_Collection_T      -
Rem      Type SODA_CollName_List_T   -
Rem      Type SODA_Key_List_T        -
Rem      Type SODA_Document_T        -  
Rem      Type SODA_Document_List_T   -
Rem      Type SODA_Operation_T       -  
Rem      Type SODA_Cursor_T          -
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/dbmssodapls.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/dbmssodapls.sql
Rem    SQL_PHASE:DBMSSODAPLS
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    SQL_CALLING_FILE:
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    sriksure    04/02/18 - Bug 27698424: Backport SODA bugs from main
Rem    sriksure    10/23/17 - Bug 27013347: Add close() method in SODA_Cursor_T
Rem    morgiyan    10/20/17 - Bug 27033953: collection create mode
Rem    sriksure    09/01/17 - Bug 26769325: Add Operation and Cursor types
Rem    prthiaga    07/05/17 - Bug 26403429: Comment SODA_OPERATION_T
Rem    prthiaga    06/22/17 - Bug 26326368: Add FINAL, remove insert_and_get
Rem                           and remove free methods
Rem    prthiaga    06/06/17 - Bug 26222011: Add insert_one_and_get
Rem    prthiaga    05/24/17 - Bug 26138465: Add insert_one and replace_one
Rem    prthiaga    04/20/17 - Bug 25927228: Add list_collection_names
Rem    sriksure    04/12/17 - Bug 25896806: Rename to insert_And_Get
Rem    prthiaga    04/02/17 - Bug 25879653: Change filter/key to functions
Rem    sriksure    02/28/17 - Bug 25545209: Add get_Version member function in
Rem                           SODA_Document_T type
Rem    prthiaga    03/22/17 - Bug 25713769: Add Soda_Operation_T.key and
Rem                           Soda_Operation_T.filter
Rem    sriksure    03/10/17 - Mark the opaque types not persistable
Rem    sriksure    03/02/17 - Bug 25713784: Add free methods in dbms_soda for
Rem                           collection and document types
Rem    prthiaga    02/15/17 - Bug 25776753: replace_one_and_get
Rem    prthiaga    02/21/17 - Bug 25577443: CREATE TYPE -> CREATE TYPE FORCE
Rem    sriksure    02/16/17 - Bug 25585931: Mark key field as optional in
Rem                           SODA_Document_T constructor
Rem    prthiaga    02/07/17 - Bug 25513039: Comment out drop type/package
Rem    sriksure    11/11/16 - Project: 68452 - Creation
Rem

SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100

@@?/rdbms/admin/sqlsessstart.sql

CREATE OR REPLACE LIBRARY DBMS_SODA_LIB TRUSTED AS STATIC;
/

CREATE OR REPLACE LIBRARY DBMS_SODACOLL_LIB TRUSTED AS STATIC;
/

CREATE OR REPLACE LIBRARY DBMS_SODADOC_LIB TRUSTED AS STATIC;
/

CREATE OR REPLACE LIBRARY DBMS_SODAOPR_LIB TRUSTED AS STATIC;
/

CREATE OR REPLACE LIBRARY DBMS_SODACUR_LIB TRUSTED AS STATIC;
/

-- Uncomment out the drop statements if you want to re-run
--DROP PACKAGE dbms_soda;
--DROP TYPE SODA_Collection_T force;
--DROP TYPE SODA_Document_T force;
--DROP TYPE SODA_Operation_T force;
--DROP TYPE SODA_Cursor_T force;

/* ############################################################################
** Type SODA_Document_T
** ##########################################################################*/

CREATE OR REPLACE TYPE SODA_Document_T FORCE
OID '00000000000000000000000000020018'
authid current_user
AS OPAQUE VARYING (*)
USING library DBMS_SODADOC_LIB
(
    -- Constructors
    CONSTRUCTOR FUNCTION SODA_Document_T (key        VARCHAR2 DEFAULT NULL,
                                          b_Content  BLOB,
                                          media_Type VARCHAR2 DEFAULT NULL)
    RETURN SELF AS RESULT,

    CONSTRUCTOR FUNCTION SODA_Document_T (key        VARCHAR2 DEFAULT NULL,
                                          c_Content  CLOB,
                                          media_Type VARCHAR2 DEFAULT NULL)
    RETURN SELF AS RESULT,

    CONSTRUCTOR FUNCTION SODA_Document_T (key        VARCHAR2 DEFAULT NULL,
                                          v_Content  VARCHAR2,
                                          media_Type VARCHAR2 DEFAULT NULL)
    RETURN SELF AS RESULT,

    -- Methods
    MEMBER FUNCTION get_Blob
    RETURN BLOB,

    MEMBER FUNCTION get_Clob
    RETURN CLOB,

    MEMBER FUNCTION get_Created_On
    RETURN VARCHAR2,

    MEMBER FUNCTION get_Data_Type
    RETURN PLS_INTEGER,

    MEMBER FUNCTION get_Key
    RETURN VARCHAR2,

    MEMBER FUNCTION get_Last_Modified
    RETURN VARCHAR2,

    MEMBER FUNCTION get_Media_Type
    RETURN VARCHAR2,

    MEMBER FUNCTION get_Varchar2
    RETURN VARCHAR2,

    MEMBER FUNCTION get_Version
    RETURN VARCHAR2
) FINAL NOT PERSISTABLE;
/

SHOW errors;

CREATE OR REPLACE PUBLIC SYNONYM SODA_Document_T
FOR sys.SODA_Document_T
/

GRANT EXECUTE ON SODA_Document_T TO PUBLIC
/

/* ############################################################################
** Type SODA_Document_List_T
** ##########################################################################*/

CREATE OR REPLACE TYPE SODA_Document_List_T FORCE
AS TABLE OF (SODA_Document_T) NOT PERSISTABLE;
/

show errors;

CREATE OR REPLACE PUBLIC SYNONYM SODA_Document_List_T
FOR sys.SODA_Document_List_T
/

/* ############################################################################
** Type SODA_Cursor_T
** ##########################################################################*/

CREATE OR REPLACE TYPE SODA_Cursor_T FORCE
OID '00000000000000000000000000020020'
authid current_user
AS OPAQUE VARYING (*)
USING library DBMS_SODACUR_LIB
(
    -- Methods
    MEMBER FUNCTION has_Next
    RETURN BOOLEAN,

    MEMBER FUNCTION next
    RETURN SODA_Document_T,

    MEMBER FUNCTION close
    RETURN BOOLEAN

) FINAL NOT PERSISTABLE;
/

SHOW errors;

CREATE OR REPLACE PUBLIC SYNONYM SODA_Cursor_T
FOR sys.SODA_Cursor_T
/

GRANT EXECUTE ON SODA_Cursor_T TO PUBLIC
/

/* ############################################################################
** Type SODA_Key_List_T
** ##########################################################################*/

CREATE OR REPLACE TYPE SYS.SODA_Key_List_T FORCE
AS TABLE OF VARCHAR2(255)
/

SHOW errors;

CREATE OR REPLACE PUBLIC SYNONYM SODA_Key_List_T
FOR SYS.SODA_Key_List_T
/
GRANT EXECUTE ON SODA_Key_List_T TO PUBLIC
/

/* ############################################################################
** Type SODA_Operation_T
** ##########################################################################*/

CREATE OR REPLACE TYPE SODA_Operation_T FORCE
OID '00000000000000000000000000020019'
authid current_user
AS OPAQUE VARYING (*)
USING library DBMS_SODAOPR_LIB
(
    --  Methods
    MEMBER FUNCTION	count
    RETURN NUMBER,

    MEMBER FUNCTION key (key VARCHAR2) 
    RETURN SODA_Operation_T,

    MEMBER FUNCTION filter (qbe VARCHAR2)
    RETURN SODA_Operation_T,

    MEMBER FUNCTION	get_Cursor
    RETURN SODA_Cursor_T,

    MEMBER FUNCTION	get_One
    RETURN SODA_Document_T,

    MEMBER FUNCTION	keys (key_List SODA_Key_List_T)
    RETURN SODA_Operation_T,

    MEMBER FUNCTION	limit (limit NUMBER)
    RETURN SODA_Operation_T,

    MEMBER FUNCTION	remove
    RETURN NUMBER,

    MEMBER FUNCTION	replace_One (document SODA_Document_T)
    RETURN NUMBER,

    MEMBER FUNCTION	replace_One_And_Get (document SODA_Document_T)
    RETURN SODA_Document_T,

    MEMBER FUNCTION	skip (offset NUMBER)
    RETURN SODA_Operation_T,

    MEMBER FUNCTION	version (version VARCHAR2)
    RETURN SODA_Operation_T

) FINAL NOT PERSISTABLE;
/

SHOW errors;

CREATE OR REPLACE PUBLIC SYNONYM SODA_Operation_T
FOR SYS.SODA_Operation_T
/

GRANT EXECUTE ON SYS.SODA_Operation_T TO PUBLIC
/

/* ############################################################################
** Type SODA_Collection_T
** ##########################################################################*/

CREATE OR REPLACE TYPE SODA_Collection_T FORCE
OID '00000000000000000000000000020017'
authid current_user
AS OPAQUE VARYING (*)
USING library DBMS_SODACOLL_LIB
(
    -- Methods
    MEMBER FUNCTION create_Index (specification VARCHAR2)
    RETURN NUMBER,

    MEMBER FUNCTION drop_Index (index_Name VARCHAR2,
                                force      BOOLEAN DEFAULT FALSE)
    RETURN NUMBER,

    MEMBER FUNCTION find
    RETURN SODA_Operation_T,

    MEMBER FUNCTION find_One (key VARCHAR2)
    RETURN SODA_Document_T,

    MEMBER FUNCTION get_Data_Guide
    RETURN CLOB,

    MEMBER FUNCTION get_Metadata
    RETURN VARCHAR2,

    MEMBER FUNCTION get_Name
    RETURN NVARCHAR2,

    MEMBER FUNCTION insert_Many (document_List SODA_Document_List_T)
    RETURN NUMBER,

    MEMBER FUNCTION insert_One (document SODA_Document_T)
    RETURN NUMBER,

    MEMBER FUNCTION insert_One_And_Get (document SODA_Document_T)
    RETURN SODA_Document_T,

    MEMBER FUNCTION remove_One (key VARCHAR2)
    RETURN NUMBER,

    MEMBER FUNCTION replace_One (key      VARCHAR2,
                                 document SODA_Document_T)
    RETURN NUMBER,

    MEMBER FUNCTION replace_One_And_Get (key      VARCHAR2,
                                         document SODA_Document_T)
    RETURN SODA_Document_T

) FINAL NOT PERSISTABLE;
/

SHOW errors;

CREATE OR REPLACE PUBLIC SYNONYM SODA_Collection_T
FOR SYS.SODA_Collection_T
/

GRANT EXECUTE ON SYS.SODA_Collection_T TO PUBLIC
/

/* ############################################################################
** Type SODA_CollName_List_T
** ##########################################################################*/

CREATE OR REPLACE TYPE SYS.SODA_CollName_List_T FORCE
AS TABLE OF NVARCHAR2(255)
/

SHOW errors;

CREATE OR REPLACE PUBLIC SYNONYM SODA_CollName_List_T
FOR SYS.SODA_CollName_List_T
/
GRANT EXECUTE ON SODA_CollName_List_T TO PUBLIC
/

/* ############################################################################
** Package dbms_soda
** ##########################################################################*/

CREATE OR REPLACE PACKAGE sys.dbms_soda authid current_user
AS

    -- Content type constants
    DOC_VARCHAR2     CONSTANT PLS_INTEGER := 1;
    DOC_BLOB         CONSTANT PLS_INTEGER := 2;
    DOC_CLOB         CONSTANT PLS_INTEGER := 3;

    -- Collection create mode constants
    CREATE_MODE_DDL  CONSTANT PLS_INTEGER := 1;
    CREATE_MODE_MAP  CONSTANT PLS_INTEGER := 2;

    -- Functions
    FUNCTION create_Collection (collection_Name NVARCHAR2,
                                metadata        VARCHAR2 DEFAULT NULL,
                                create_mode     PLS_INTEGER DEFAULT CREATE_MODE_DDL)
    RETURN SODA_Collection_T;

    FUNCTION drop_Collection (collection_Name NVARCHAR2)
    RETURN NUMBER;

    FUNCTION list_Collection_Names
    RETURN SODA_CollName_List_T;

    FUNCTION open_Collection (collection_Name NVARCHAR2)
    RETURN SODA_Collection_T;

END dbms_soda;
/

SHOW errors;

CREATE OR REPLACE PUBLIC SYNONYM dbms_soda
FOR sys.dbms_soda
/

GRANT EXECUTE ON dbms_soda TO PUBLIC
/

@?/rdbms/admin/sqlsessend.sql

