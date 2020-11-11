Rem
Rem $Header: rdbms/admin/xsadmi.sql /main/15 2016/04/20 18:08:19 youyang Exp $
Rem
Rem xsadmi.sql
Rem
Rem Copyright (c) 2009, 2016, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      xsadmi.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/xsadmi.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/xsadmi.sql
Rem SQL_PHASE: XSADMI
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpspec.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    youyang     03/17/16 - bug22865694:add parameter in check_permission for
Rem                           error
Rem    htzhang     03/10/16 - Bug 22894034: Check common alter user privilege 
Rem                           when XS user proxying to DB user in CDB/APP root
Rem    yanlili     08/03/14 - Proj 46907: Schema level policy admin
Rem    pradeshm    03/11/14 - Fix Bug 18346338: Enhance check_permission for
Rem                           common privilege.
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    pradeshm    07/03/13 - Proj#46908: support auditing for set_profile
Rem                           operation
Rem    yiru        05/07/12 - Add a flag in kzxm_invalidate_entity to indicate
Rem                           if the API needs to clean up privileges
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    taahmed     02/10/12 - remove default acl
Rem    yanlili     07/12/11 - Triton audit support for admin APIs
Rem    yiru        06/30/11 - Admin Sec Prj enhancement: Change to IR package
Rem    yiru        04/29/11 - Admin security project 2 - check_permission
Rem    snadhika    07/15/10 - Triton session enhancement project
Rem    jnarasin    11/26/09 - Late Binding Txn 3
Rem    yiru        10/01/09 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

CREATE OR REPLACE PACKAGE XS_ADMIN_INT AUTHID CURRENT_USER AS

  -- Define DBMS_XS_AUDLIST type
  TYPE DBMS_XS_AUDLIST IS VARRAY(7) OF VARCHAR2(4000);

  --These constants represent dependency types.
  ROLE_GRANT_PROXY_DEP      CONSTANT PLS_INTEGER := 1;
  SC_INHERIT_DEP            CONSTANT PLS_INTEGER := 2;
  SCOPE_ACL_DEP             CONSTANT PLS_INTEGER := 3;
  ACL_INHERIT_DEP           CONSTANT PLS_INTEGER := 4;
  PROTECT_INST_SET_DEP      CONSTANT PLS_INTEGER := 5;
  GRANT_DENY_PRNC_DEP       CONSTANT PLS_INTEGER := 6;
  ROLE_ROLESET_DEP          CONSTANT PLS_INTEGER := 7;

  -- These constants represent the retured value from delete_entity.
  DELETE_SUCCESS            CONSTANT PLS_INTEGER := 0;
  WARN_DEP_EXISTS           CONSTANT PLS_INTEGER := 1;
  WARN_CONSTRIANTS_EXISTS   CONSTANT PLS_INTEGER := 2;

  -- These constants represent what status to be used when creating an object.
  OBJ_WITH_STATUS_EXTERNAL   CONSTANT PLS_INTEGER := 2;
  OBJ_WITH_STATUS_EXISTS     CONSTANT PLS_INTEGER := 1;
  OBJ_WITH_STATUS_NOT_EXISTS CONSTANT PLS_INTEGER := 0;

 -- These constants represent system privileges needed for operating non-schema
 -- objects.
  SPRIV_DBA          CONSTANT PLS_INTEGER := 0;
  SPRIV_CREATE_USER  CONSTANT PLS_INTEGER := 1;
  SPRIV_CREATE_ROLE  CONSTANT PLS_INTEGER := 2;
  SPRIV_DROP_USER    CONSTANT PLS_INTEGER := 3;
  SPRIV_DROP_ROLE    CONSTANT PLS_INTEGER := 4;
  SPRIV_GRANT_ROLE   CONSTANT PLS_INTEGER := 5;
  SPRIV_ALTER_USER   CONSTANT PLS_INTEGER := 6;
  SPRIV_ALTER_ROLE   CONSTANT PLS_INTEGER := 7;

-- The following constants define Triton admin audit actions.
  AUDIT_CREATE_USER            CONSTANT PLS_INTEGER := 1;            
  AUDIT_UPDATE_USER            CONSTANT PLS_INTEGER := 2;
  AUDIT_DELETE_USER            CONSTANT PLS_INTEGER := 3;
  AUDIT_CREATE_ROLE            CONSTANT PLS_INTEGER := 4;
  AUDIT_UPDATE_ROLE            CONSTANT PLS_INTEGER := 5;
  AUDIT_DELETE_ROLE            CONSTANT PLS_INTEGER := 6;
  AUDIT_GRANT_ROLE             CONSTANT PLS_INTEGER := 7;
  AUDIT_REVOKE_ROLE            CONSTANT PLS_INTEGER := 8;
  AUDIT_ADD_PROXY              CONSTANT PLS_INTEGER := 9;
  AUDIT_REMOVE_PROXY           CONSTANT PLS_INTEGER := 10;
  AUDIT_SET_PASSWORD           CONSTANT PLS_INTEGER := 11;
  AUDIT_SET_VERIFIER           CONSTANT PLS_INTEGER := 12;
  AUDIT_CREATE_ROLESET         CONSTANT PLS_INTEGER := 13;
  AUDIT_UPDATE_ROLESET         CONSTANT PLS_INTEGER := 14;
  AUDIT_DELETE_ROLESET         CONSTANT PLS_INTEGER := 15;
  AUDIT_CREATE_SECURITY_CLASS  CONSTANT PLS_INTEGER := 16;
  AUDIT_UPDATE_SECURITY_CLASS  CONSTANT PLS_INTEGER := 17;
  AUDIT_DELETE_SECURITY_CLASS  CONSTANT PLS_INTEGER := 18;
  AUDIT_CREATE_NAMESPACE       CONSTANT PLS_INTEGER := 19;                    
  AUDIT_UPDATE_NAMESPACE       CONSTANT PLS_INTEGER := 20;                    
  AUDIT_DELETE_NAMESPACE       CONSTANT PLS_INTEGER := 21;                     
  AUDIT_CREATE_ACL             CONSTANT PLS_INTEGER := 22;
  AUDIT_UPDATE_ACL             CONSTANT PLS_INTEGER := 23;
  AUDIT_DELETE_ACL             CONSTANT PLS_INTEGER := 24;                  
  AUDIT_CREATE_DATA_SECURITY   CONSTANT PLS_INTEGER := 25;
  AUDIT_UPDATE_DATA_SECURITY   CONSTANT PLS_INTEGER := 26;
  AUDIT_DELETE_DATA_SECURITY   CONSTANT PLS_INTEGER := 27;
  AUDIT_ENABLE_DATA_SECURITY   CONSTANT PLS_INTEGER := 28;
  AUDIT_DISABLE_DATA_SECURITY  CONSTANT PLS_INTEGER := 29;
  AUDIT_ENABLE_ROLE            CONSTANT PLS_INTEGER := 33;
  AUDIT_DISABLE_ROLE           CONSTANT PLS_INTEGER := 34;
  AUDIT_SET_PROFILE            CONSTANT PLS_INTEGER := 47;
  AUDIT_GRANT_PRIVILEGE        CONSTANT PLS_INTEGER := 48;
  AUDIT_REVOKE_PRIVILEGE       CONSTANT PLS_INTEGER := 49;

-- The following constants define indices in DBMS_XS_AUDLIST.
  AUD_TARGETPNAME              CONSTANT PLS_INTEGER := 1;
  AUD_PROXYUNAME               CONSTANT PLS_INTEGER := 2;
  AUD_POLICYNAME               CONSTANT PLS_INTEGER := 3;
  AUD_SCHEMANAME               CONSTANT PLS_INTEGER := 4;
  AUD_ENABLEDROLE              CONSTANT PLS_INTEGER := 5;
  AUD_OBJOWN                   CONSTANT PLS_INTEGER := 6; 
  AUD_OBJNAME                  CONSTANT PLS_INTEGER := 7;

-- The following constants define entity type for auditing.
  AUD_ENTITY_TYPE_USER           CONSTANT PLS_INTEGER := 1;
  AUD_ENTITY_TYPE_SECURITY_CLASS CONSTANT PLS_INTEGER := 2;
  AUD_ENTITY_TYPE_ACL            CONSTANT PLS_INTEGER := 3;
  AUD_ENTITY_TYPE_ROLE           CONSTANT PLS_INTEGER := 4;
  AUD_ENTITY_TYPE_DATA_SECURITY  CONSTANT PLS_INTEGER := 5;
  AUD_ENTITY_TYPE_ROLESET        CONSTANT PLS_INTEGER := 6;
  AUD_ENTITY_TYPE_NSTEMPL        CONSTANT PLS_INTEGER := 7;

-- Get the entity ID
  PROCEDURE get_entity_id(
    obj_name    IN  VARCHAR2,
    obj_type    IN  PLS_INTEGER,
    obj_status  OUT PLS_INTEGER,
    obj_schema  OUT VARCHAR2,
    obj_oname   OUT VARCHAR2,
    obj_id      OUT NUMBER);

-- Create a triton object
  PROCEDURE create_entity(
    obj_name   IN VARCHAR2,
    obj_type   IN PLS_INTEGER,
    obj_status IN PLS_INTEGER,
    obj_id     OUT NUMBER);

-- Delete a triton object
  PROCEDURE delete_entity(
    obj_name   IN VARCHAR2,
    obj_type   IN PLS_INTEGER,
    opt        IN PLS_INTEGER,
    obj_id     IN OUT NUMBER,
    ret_status OUT PLS_INTEGER);

-- Create a triton dependency
  PROCEDURE create_dependency(
    dep_type  IN PLS_INTEGER,
    obj_name1 IN VARCHAR2,
    obj_type1 IN PLS_INTEGER,
    obj_id1   IN OUT NUMBER,
    obj_name2 IN VARCHAR2,
    obj_type2 IN PLS_INTEGER,
    obj_id2   IN OUT NUMBER);

-- Delete a triton dependency
  PROCEDURE delete_dependency(
    dep_type  IN PLS_INTEGER,
    obj_name1 IN VARCHAR2,
    obj_type1 IN PLS_INTEGER,
    obj_id1   IN OUT NUMBER,
    obj_name2 IN VARCHAR2,
    obj_type2 IN PLS_INTEGER,
    obj_id2   IN OUT NUMBER);

-- Invalidate a triton object
  PROCEDURE invalidate_entity(
    obj_id   IN NUMBER,
    obj_type IN PLS_INTEGER,
    cleanup_priv IN BOOLEAN := FALSE);

-- Check permisson
  PROCEDURE check_permission(
    obj_name                IN VARCHAR2,
    obj_type                IN PLS_INTEGER,
    sys_priv                IN PLS_INTEGER := NULL,
    scope                   IN PLS_INTEGER := 1,
    aclid                   IN NUMBER := NULL,
    access_type             IN PLS_INTEGER := NULL,
    tab_schema              IN VARCHAR2 := NULL,
    check_any_privs         IN BOOLEAN := FALSE);

-- Audit wrapper
  PROCEDURE admin_audit (
    act               IN     PLS_INTEGER,
    auderr            IN     PLS_INTEGER,
    entitytype        IN     PLS_INTEGER,
    audrec_index1     IN     PLS_INTEGER := 0,
    audrec1           IN     VARCHAR2    := NULL,
    audrec_index2     IN     PLS_INTEGER := 0,
    audrec2           IN     VARCHAR2    := NULL,
    audrec_index3     IN     PLS_INTEGER := 0,
    audrec3           IN     VARCHAR2    := NULL);

-- Parse and validate RAS Qualified name - schema_name.entity_name
  PROCEDURE validate_entity_name(
    obj_name      IN  VARCHAR2, 
    obj_type      IN  PLS_INTEGER,
    obj_schema    OUT VARCHAR2,
    obj_ename     OUT VARCHAR2);

END XS_ADMIN_INT;
/

show errors;

@?/rdbms/admin/sqlsessend.sql
