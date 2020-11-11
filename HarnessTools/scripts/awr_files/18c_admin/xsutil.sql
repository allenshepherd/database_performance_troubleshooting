Rem
Rem $Header: rdbms/admin/xsutil.sql /main/32 2017/08/22 14:59:56 yanlili Exp $
Rem
Rem xsutil.sql
Rem
Rem Copyright (c) 2009, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      xsutil.sql - XS utility package
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/xsutil.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/xsutil.sql
Rem SQL_PHASE: XSUTIL
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpspec.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    yanlili     07/25/17 - Bug 26474062: Add ERR_RESERVED_USER
Rem    htzhang     05/02/16 - Bug 23107532: add OBJTYPE_SET_POLICY
Rem    youyang     04/08/16 - Bug 22865694: add OBJTYPE_REVOKEOP
Rem    raeburns    06/09/15 - Bug 21322727: Use FORCE for types with only type dependents
Rem    yanlili     05/28/15 - Fix bug 20897609: Add constant XSCONNECT
Rem    yohu        01/29/15 - Bug 18108943: Add validate_db_user
Rem    rbolarr     12/18/14 - Bug 19947350: Support 128 bytes identifier
Rem    yohu        09/26/14 - Bug 19691496: Add ORA-46118, 46119
Rem    yohu        08/27/14 - Proj 46902: Sesion Privilege Scoping
Rem    yanlili     08/03/14 - Proj 46907: Schema level policy admin
Rem    pradeshm    02/27/14 - Fix Bug 18315166: error msg added
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    pradeshm    04/24/13 - error code for insufficient privilege fix bug -
Rem                           16665620
Rem    pradeshm    01/23/13 - Fix Bug 14371526 : added a constant for error
Rem                           46055
Rem    yiru        11/12/12 - Bug 14475473: Add remove_dbuser_aces
Rem    minx        07/23/12 - Fix bug 14353015,14353042, block modifying
Rem                           seeded objects
Rem    pradeshm    06/15/12 - Add ERR_NO_STATIC_RULE 46025
Rem    weihwang    06/04/12 - Fix bug 14155082, remove OBJTYPE_XDS
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    minx        03/05/12 - ERR_ACL_REFERREDBY_NSTEMPLATE
Rem    taahmed     03/05/12 - def acl cleanup
Rem    pradeshm    02/06/12 - Fix bug 13616848: Fix minimum/maximum length of
Rem                           object names
Rem    yiru        10/25/11 - Fix bug 12899644: Add APIs to grant/revoke XS
Rem                           system privilege 
Rem    yiru        08/23/11 - Admin APIs revision
Rem    snadhika    06/11/11 - Add ERR_PROXY_SCHEMA_EXIST and 
Rem                           ERR_PROXY_SCHEMA_NOT_EXIST (project # 34785)
Rem    yiru        05/17/11 - Admin security project 2 - drop_schema_objects
Rem    yanlili     03/21/11 - Fix bug 9445377: add ERR_NO_DB_USER_ROLE 46238
Rem    yiru        03/14/11 - Add trusted callout VALIDATE_DB_OBJECT_NAME
Rem    yiru        05/09/10 - Full Drop6R cleanup before merge-down
Rem    snadhika    04/15/10 - Triton session enhancement project
Rem    yiru        02/28/10 - Add ERR_NO_SC_PARENTSC 46097
Rem    yiru        02/18/10 - Add ERR_NO_PROXY_ROLES 46085
Rem    yiru        01/21/10 - Put RAISE_ERROR in correct Library; cleanup
Rem    snadhika    01/18/10 - Replace application error with db error
Rem    jnarasin    12/15/09 - Late Binding Txn 3
Rem    weihwang    10/29/09 - Change object name to upper case
Rem    yiru        10/15/09 - Add more constants
Rem    rbhatti     10/08/09 - Add kzxi_generate_uid 
Rem    yiru        10/08/09 - Add XSNAME_TO_ID
Rem    yiru        09/24/09 - Add more application error code 
Rem    yiru        08/13/09 - Add DBMS_RXS_LIB creation; move DBMS_XSS_LIB
Rem                           from prvtkzxs.sql to here.  
Rem    snadhika    07/08/09 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql
    

CREATE OR replace library DBMS_RXS_LIB trusted AS STATIC;
/

--move DBMS_XSS_LIB here since SET_DEFAULT_WORKSPACE callout is in this lib.
CREATE OR REPLACE LIBRARY DBMS_XSS_LIB TRUSTED AS STATIC;
/

-- XS$LIST Type; a varray of varchar2
CREATE OR REPLACE TYPE XS$LIST FORCE IS VARRAY(1000) OF VARCHAR2(4000);
/

-- XS_ADMIN_UTIL Package; contains utility APIs to be used by other packages
CREATE OR REPLACE PACKAGE XS_ADMIN_UTIL AUTHID CURRENT_USER AS

COMMON_WORKSPACE           CONSTANT VARCHAR2(6)  := 'XS';
SCHEMA_ACL                 CONSTANT VARCHAR2(13) := 'XS$SCHEMA_ACL';
XSCONNECT                  CONSTANT VARCHAR2(9)  := 'XSCONNECT';

STRING_MAXLEN              CONSTANT PLS_INTEGER := 4000;
NON_EMPTY_STRING_MINLEN    CONSTANT PLS_INTEGER := 1;
STRING_MINLEN              CONSTANT PLS_INTEGER := 0;

XSNAME_MINLEN            CONSTANT PLS_INTEGER := 1;
XSNAME_MAXLEN            CONSTANT PLS_INTEGER := 130;

PARAMNAME_MINLEN           CONSTANT PLS_INTEGER := 1;
PARAMNAME_MAXLEN           CONSTANT PLS_INTEGER := 128;

XSQNAME_MINLEN            CONSTANT PLS_INTEGER := 1;
XSQNAME_MAXLEN            CONSTANT PLS_INTEGER := 261;

EXTERNAL_NAME_MINLEN     CONSTANT PLS_INTEGER := 1;
EXTERNAL_NAME_MAXLEN     CONSTANT PLS_INTEGER := 130;

WORKSPACE_MINLEN           CONSTANT PLS_INTEGER := 1;
WORKSPACE_MAXLEN           CONSTANT PLS_INTEGER := 128;

DBNAME_MINLEN              CONSTANT PLS_INTEGER := 1;
DBNAME_MAXLEN              CONSTANT PLS_INTEGER := 130;

OBJTYPE_PRINCIPAL          CONSTANT PLS_INTEGER := 1;
OBJTYPE_SECURITY_CLASS     CONSTANT PLS_INTEGER := 2;
OBJTYPE_ACL                CONSTANT PLS_INTEGER := 3;
OBJTYPE_PRIVILEGE          CONSTANT PLS_INTEGER := 4;
OBJTYPE_DATA_SECURITY      CONSTANT PLS_INTEGER := 5;
OBJTYPE_ROLESET            CONSTANT PLS_INTEGER := 6;
OBJTYPE_NSTEMPL            CONSTANT PLS_INTEGER := 7;

OBJTYPE_SYSOP             CONSTANT PLS_INTEGER := 101;
OBJTYPE_ADMOP             CONSTANT PLS_INTEGER := 102;
OBJTYPE_APPLY_POLICY      CONSTANT PLS_INTEGER := 103;
OBJTYPE_GRANTOP           CONSTANT PLS_INTEGER := 104;
OBJTYPE_REVOKEOP          CONSTANT PLS_INTEGER := 105;
OBJTYPE_SET_POLICY        CONSTANT PLS_INTEGER := 106;

-- These constants define the three delete options.
DEFAULT_OPTION               CONSTANT PLS_INTEGER := 1;
CASCADE_OPTION               CONSTANT PLS_INTEGER := 2;
ALLOW_INCONSISTENCIES_OPTION CONSTANT PLS_INTEGER := 3; 

-- These two constants specify if an object exists in the base table or not.
STATUS_EXISTS              CONSTANT PLS_INTEGER := 1;
STATUS_NOT_EXISTS          CONSTANT PLS_INTEGER := 0;

-- The following constants define the principal's type.
PTYPE_XS              CONSTANT PLS_INTEGER := 1;
PTYPE_DB              CONSTANT PLS_INTEGER := 2;
PTYPE_DN              CONSTANT PLS_INTEGER := 3;
PTYPE_EXTERNAL        CONSTANT PLS_INTEGER := 4;

-- Error Code
--existing error code
ERR_INVALID_LENGTH      CONSTANT NUMBER := 46076;
ERR_SET_PRIN_GUID       CONSTANT NUMBER := 46083;
ERR_DROP_SEEDED_OBJ     CONSTANT NUMBER := 46084;
ERR_NO_PROXY_ROLES      CONSTANT NUMBER := 46085;
ERR_DEFV_FREVNT_COEXIST CONSTANT NUMBER := 46096;
ERR_NO_ROLESET_ROLE     CONSTANT NUMBER := 46097;
ERR_NO_GRANTEDROLE_PRIN CONSTANT NUMBER := 46097;
ERR_NO_SC_PARENTSC      CONSTANT NUMBER := 46097;
ERR_DUP_PARENT          CONSTANT NUMBER := 46098;
ERR_DUP_LEAF            CONSTANT NUMBER := 46098;
ERR_DUP_PRIMARY_KEY     CONSTANT NUMBER := 46098;
ERR_DUP_ATTR_PRIV_PAIR  CONSTANT NUMBER := 46098;
ERR_DUP_PROXY           CONSTANT NUMBER := 46098;
ERR_DUP_ACL_PARAM       CONSTANT NUMBER := 46098;
ERR_DUP_ROLESET_ROLE    CONSTANT NUMBER := 46098;
ERR_DUP_POLICY_PARAM    CONSTANT NUMBER := 46098;
ERR_DUP_NS_ATTR         CONSTANT NUMBER := 46098;
ERR_AGGR_CYCLE          CONSTANT NUMBER := 46101;
ERR_SECCLS_CYCLE        CONSTANT NUMBER := 46103;
ERR_INVALID_VALUE       CONSTANT NUMBER := 46152;
ERR_NO_HANDLER_FUNC     CONSTANT NUMBER := 46202;
ERR_INVALID_ENTITY_LENGTH CONSTANT NUMBER := 46211;
ERR_DUP_NAME            CONSTANT NUMBER := 46212;
ERR_OBJ_REFERRED        CONSTANT NUMBER := 46214;
ERR_INVALID_OBJECT      CONSTANT NUMBER := 46215;
ERR_NO_OBJ_FOUND        CONSTANT NUMBER := 46215;
ERR_ACL_REFERREDBY_NSTEMPLATE CONSTANT NUMBER := 46116;
ERR_ACL_REFERREDBY_PRINCIPLAL CONSTANT NUMBER := 46117;
ERR_ACL_SCHEMA_NOT_SYS  CONSTANT NUMBER := 46118;
ERR_ACL_IS_NULL         CONSTANT NUMBER := 46119;
ERR_INSUFFICIENT_PRIV   CONSTANT NUMBER := 1031;
ERR_RESERVED_USER       CONSTANT NUMBER := 28222;

-- new Admin API error code
ERR_NO_STATIC_RULE          CONSTANT NUMBER := 46025;
ERR_INTERNAL                CONSTANT NUMBER := 46230;
ERR_GRANT_ROLE              CONSTANT NUMBER := 46231;
ERR_ROLE_GRANT_CYCLE        CONSTANT NUMBER := 46232;
ERR_PARENT_ACL_CYCLE        CONSTANT NUMBER := 46233;
ERR_NO_POLICY_PARAMETER     CONSTANT NUMBER := 46235;
ERR_INVALID_POLICY_TYPE     CONSTANT NUMBER := 46236;
ERR_MIDTIER_CACHE           CONSTANT NUMBER := 46237;
ERR_NO_DB_USER_ROLE         CONSTANT NUMBER := 46238;
ERR_PROXY_SCHEMA_EXIST      CONSTANT NUMBER := 46240;
ERR_PROXY_SCHEMA_NOT_EXIST  CONSTANT NUMBER := 46241;
ERR_GRANT_ROLE_XSGUEST      CONSTANT NUMBER := 46242;
ERR_ROLE_NOT_GRANTED        CONSTANT NUMBER := 46055;
ERR_FEATURE_NOT_SUPPORTED   CONSTANT NUMBER := 46099;

-- get the default workspace
FUNCTION GET_DEFAULT_WORKSPACE return VARCHAR2;

-- Length check
PROCEDURE CHECK_LENGTH
         (str        IN  VARCHAR2,
          min_length IN  PLS_INTEGER,
          max_length IN  PLS_INTEGER);

-- Raise an application error
PROCEDURE RAISE_ERROR
  (error_number IN PLS_INTEGER,
   error_str1   IN VARCHAR2 DEFAULT NULL,
   error_str2   IN VARCHAR2 DEFAULT NULL,
   keep_stack   IN BOOLEAN  DEFAULT TRUE) ;

-- set default workspace
PROCEDURE SET_DEFAULT_WORKSPACE
          (workspace IN VARCHAR2);

-- Get the object ID, Internal use. called by ADMIN APIs.
FUNCTION GET_OBJECT_ID(obj_name    IN VARCHAR2, 
                       obj_type    IN PLS_INTEGER,
                       workspace   IN VARCHAR2, 
                       status_flag IN PLS_INTEGER := NULL) RETURN NUMBER;

-- Utility Function: XS name to ID
FUNCTION XSNAME_TO_ID(obj_name IN VARCHAR2, 
                      obj_type IN PLS_INTEGER)
RETURN NUMBER; 

-- Validate DB object name. Internal use. 
PROCEDURE VALIDATE_DB_OBJECT_NAME
          (input_name IN VARCHAR2,           
           object_name OUT VARCHAR2,
           error_msg  IN VARCHAR2 DEFAULT NULL);

-- Validate DB user/schema. Internal use.  
PROCEDURE VALIDATE_DB_USER
          (input_name IN VARCHAR2,           
           error_msg  IN VARCHAR2 DEFAULT NULL);

-- Drop schema objects under a schema
PROCEDURE drop_schema_objects(schema_name IN VARCHAR2);
PRAGMA SUPPLEMENTAL_LOG_DATA(drop_schema_objects, MANUAL);

-- Grant System privilege to a user/role
PROCEDURE grant_system_privilege(
    priv_name  IN VARCHAR2,
    user_name  IN VARCHAR2,
    user_type  IN PLS_INTEGER := XS_ADMIN_UTIL.PTYPE_DB,
    schema     IN VARCHAR2 := NULL);
    PRAGMA SUPPLEMENTAL_LOG_DATA(grant_system_privilege, AUTO);

-- Revoke System privilege from a user/role
PROCEDURE revoke_system_privilege(
    priv_name  IN VARCHAR2,    
    user_name  IN VARCHAR2,
    user_type  IN PLS_INTEGER := XS_ADMIN_UTIL.PTYPE_DB,
    schema     IN VARCHAR2 := NULL);
    PRAGMA SUPPLEMENTAL_LOG_DATA(revoke_system_privilege, AUTO);

-- Revoke System privilege from a user/role
PROCEDURE remove_dbuser_aces(
    user_name  IN VARCHAR2);

-- Check whethe the object is seeded or not, internal use
PROCEDURE  CHECK_SEEDED(obj_id IN NUMBER);

END XS_ADMIN_UTIL;
/


show errors;

-- XS$NAME_LIST Type
CREATE OR REPLACE TYPE XS$NAME_LIST FORCE IS VARRAY(1000) OF VARCHAR2(261);
/

show errors;



@?/rdbms/admin/sqlsessend.sql
