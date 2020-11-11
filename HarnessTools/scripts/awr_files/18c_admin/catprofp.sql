Rem
Rem $Header: rdbms/admin/catprofp.sql /main/12 2016/08/30 13:50:01 youyang Exp $
Rem
Rem catprofp.sql
Rem
Rem Copyright (c) 2010, 2016, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catprofp.sql - privilege capture package header
Rem
Rem    DESCRIPTION
Rem      Package sys.dbms_privilege_capture header
Rem      Package sys.dbms_priv_capture header
Rem
Rem    NOTES
Rem      Run in catpdbms.sql; 
Rem      package bodies are defined in prvtpprof.sql(run in catpprvt.sql).
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catprofp.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catprofp.sql
Rem SQL_PHASE: CATPROFP
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    youyang     08/25/16 - XbranchMerge youyang_bug-23541205 from
Rem                           st_rdbms_12.2.0.1.0
Rem    youyang     08/12/16 - bug23541205:remove has_ procedures
Rem    youyang     07/10/16 - bug23716655:change ses_has_role_priv and
Rem                           ses_has_sys_priv
Rem    youyang     05/09/16 - bug23254521:change has_obj_priv
Rem    youyang     10/08/15 - bug21963542:remove unused synonyms
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    jheng       07/31/13 - Bug 17251375: add extra privilege check funcs
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    jheng       12/01/11 - Change API names
Rem    jheng       10/11/11 - lrg 5949112
Rem    jheng       06/17/11 - Add privilege capture functions for PL/SQL
Rem                           packages
Rem    jheng       04/09/10 - API to administrate privilege capture
Rem    jheng       04/09/10 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

CREATE OR REPLACE PACKAGE sys.dbms_privilege_capture AS
 -- Capture Types
  g_database            CONSTANT NUMBER := 1;
  g_role                CONSTANT NUMBER := 2;
  g_context             CONSTANT NUMBER := 3;
  g_role_and_context    CONSTANT NUMBER := 4;

  
  PROCEDURE create_capture(
    name            IN  VARCHAR2,
    description     IN  VARCHAR2 DEFAULT NULL, 
    type            IN  NUMBER DEFAULT G_DATABASE,
    roles           IN  role_name_list DEFAULT role_name_list(),
    condition       IN  VARCHAR2   DEFAULT NULL);

  PROCEDURE drop_capture(name  IN VARCHAR2);

  PROCEDURE enable_capture(name  IN VARCHAR2, run_name IN VARCHAR2 DEFAULT NULL);

  PROCEDURE disable_capture(name IN VARCHAR2);
  
  PROCEDURE generate_result(name     IN VARCHAR2,
                            run_name IN VARCHAR2 DEFAULT NULL,
                            dependency  IN BOOLEAN DEFAULT NULL);

  PROCEDURE delete_run(name  IN VARCHAR2, run_name IN VARCHAR2);
  PROCEDURE capture_dependency_privs;

END;
/

show errors;

CREATE OR REPLACE PUBLIC SYNONYM dbms_privilege_capture FOR sys.dbms_privilege_capture;

GRANT execute on dbms_privilege_capture to capture_admin;

/**
* Package dbms_priv_capture is defined as invoker right's  API.
* Procedures and functions with package dbms_priv_capture are intended to 
* capture a privilege use in Oracle defined PL/SQL packages..
*
* The purpose of this project #32973 is to capture privileges used for an 
* operation. Privileges checked in the kernel(e.g, through KZP layer) have 
* been collected.
*
* However, many Oracle defined PL/SQL packages query privilege related 
* dictionary tables/views(for example, session_privs, 
* session_roles, sysauth$, objauth$, etc.) to check whether a user has a given
* privilege. For such cases, APIs in this package have been used to replace 
* orginal check. For queries that cannot be replaced, privileges are collected
* directly by calling dbms_priv_capture.capture_privilege_use.
*
* In the future, if you need to do privilege checks in PL/SQL. Please
* use the functions defined in this package. Please choose the right functions
* from the following based on your needs:
* ses_has_sys_priv: whether the current user has a given system privilege
* ses_has_role_priv: whether the current user has a given role
* has_sys_priv: whether the given input user as a given system privilege
* has_obj_priv: whether the current user has a given object privilege
* has_sys_priv_direct: whether the given input user as a direct granted
*                      system privilege
*
* If none of the above privilege check functions satisfy your needs, please 
* contact the file owner and file backup.
*
* Note: when you use dbms_priv_capture APIs in your pacakge, procedure or 
*       function, you need to "grant execute on dbms_priv_capture" to package,
*       procedure, or function owner, unless the owner is SYS.
**/
CREATE OR REPLACE PACKAGE sys.dbms_priv_capture AUTHID CURRENT_USER
AS

/**
* Procedure to capture a privilege usage, if a privilege capture conditions
* are met. This procedure is called when a privilege is used in PL/SQL and JAVA.
*
* @param userid  ID of the user having the privilege
* @param syspriv ID of the system privilege used
* @param role    Name of the role used
* @param objpriv ID of the object privilege used
* @param obj     ID of the object accessed
* @param domain   List of role IDs used to check privilege use (i.e. domain)
* @param domain_str List of role names used to check privilege use
*/
  PROCEDURE capture_privilege_use(
    userid    IN  NUMBER,
    syspriv   IN  NUMBER DEFAULT NULL,
    role      IN  VARCHAR2 DEFAULT NULL,
    objpriv   IN  NUMBER DEFAULT NULL,
    obj       IN  NUMBER DEFAULT NULL,
    domain    IN  role_array DEFAULT NULL,
    domain_str IN  rolename_array DEFAULT NULL);

/**
* Procedure to capture a privilege usage, if a privilege capture conditions
* are met. This procedure is called when a privilege is used in PL/SQL and JAVA.
*
* Note: it does the same thing with the above procedure,except the input 
* parameters are strings for user's convenience.
*
* @param username Name of the user having the privilege
* @param syspriv  Name of the system privilege used
* @param role     Name of the role used
* @param objpriv  Name of the object privilege used
* @param owner    Name of the object owner
* @param object   Name of the object accessed
* @param domain   Security domain (id) used to check privilege use
* @param domain_str Security domain with names
*/
  PROCEDURE capture_privilege_use(
    username  IN  VARCHAR2,
    syspriv   IN  VARCHAR2 DEFAULT NULL,
    role      IN  VARCHAR2 DEFAULT NULL,
    objpriv   IN  VARCHAR2 DEFAULT NULL,
    owner     IN  VARCHAR2 DEFAULT NULL,
    object    IN  VARCHAR2 DEFAULT NULL,
    domain     IN  role_array DEFAULT NULL,
    domain_str IN  rolename_array DEFAULT NULL);

/**
* Function to check whether the current user has a given object privilege
* If a capture is enabled, capture the privilege usage.
*
* @param objpriv    Name of the object privilege to check
* @param objowner   Name of the object owner
* @param objname    Name of the object
* @param nmspace    Namespace of the object (default is 1 TABLE namespace)
*      
* Return TRUE if privilege exists,  FALSE otherwise.
* Note: this function checks privileges directly or indirectly granted to
* the current user's enabled roles.
*/
  FUNCTION SES_HAS_OBJ_PRIV(
    objpriv      IN VARCHAR2,
    objowner     IN VARCHAR2,
    objname      IN VARCHAR2,
    nmspace      IN PLS_INTEGER DEFAULT 1) RETURN BOOLEAN;

/**
* Function to check whether the session user has s given system privilege.
* If a capture is turned on, capture the privilege usage.
*
* @param syspriv  Name of the system privilege to check
*
* Return 1 if privilege exists, 0 otherwise.
* Note: this function is a wrapper for "SELECT from session_privs". 
*/
  FUNCTION SES_HAS_SYS_PRIV(systempriv IN VARCHAR2) RETURN PLS_INTEGER;

/**
* Function to check whether the session user has s given role.
* If a capture is turned on, capture the privilege usage.
*
* @param role  Name of the role to check
*
* Return 1 if privilege exists, 0 otherwise.
* Note: this function is a wrapper for "SELECT from session_roles". 
*/
  FUNCTION SES_HAS_ROLE_PRIV(rolename IN VARCHAR2) RETURN PLS_INTEGER;
END;
/


show errors;

CREATE OR REPLACE PUBLIC SYNONYM dbms_priv_capture FOR sys.dbms_priv_capture;

@?/rdbms/admin/sqlsessend.sql
