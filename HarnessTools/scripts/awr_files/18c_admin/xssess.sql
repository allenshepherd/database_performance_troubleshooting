Rem
Rem $Header: rdbms/admin/xssess.sql /main/8 2015/08/19 11:54:52 raeburns Exp $
Rem
Rem xssess.sql
Rem
Rem Copyright (c) 2011, 2015, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      xssess.sql - package header for dbms_xs_sessions package
Rem
Rem    DESCRIPTION
Rem      Triton session package (dbms_xs_sessions) header. 
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/xssess.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/xssess.sql
Rem SQL_PHASE: XSSESS
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    06/11/15 - Bug 21322727: Use FORCE for types with only type dependents
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    snadhika    06/28/12 - Bug # 14228669, Added get_sessionid_from_cookie
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    snadhika    03/14/12 - Namespace privilege changes
Rem    minx        01/27/12 - Update comments for namespace behavior change
Rem    snadhika    01/03/12 - Remove redundant handling events
Rem    snadhika    09/19/11 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

-- Type to contain namespace, attribute, attribute value triplet. List of 
-- DBMS_XS_NSATTR type can be passed during create, attach, switch allowing
-- namespace to be created with attributes, and attribute value to be set.
CREATE OR REPLACE TYPE DBMS_XS_NSATTR FORCE AS OBJECT 
( 
  --- Member variables   
  namespace        varchar2(130),  /* Namespace name, 128 + 2 = 130 char 
                                      long to allow case sensitive (double 
                                      quoted) 128 char namespace names   */
  attribute        varchar2(4000),                     /* Attribute name */
  attribute_value  varchar2(4000),                    /* Attribute value */

  --- Constructor for DBMS_XS_NSATTR type
  --- Only namespace name is mandatory
  CONSTRUCTOR FUNCTION DBMS_XS_NSATTR(
     namespace         IN VARCHAR2,
     attribute         IN VARCHAR2 DEFAULT NULL,
     attribute_value   IN VARCHAR2 DEFAULT NULL)
  RETURN SELF AS RESULT
);
/

CREATE OR REPLACE TYPE BODY DBMS_XS_NSATTR AS
  CONSTRUCTOR FUNCTION DBMS_XS_NSATTR(
     namespace         IN VARCHAR2,
     attribute         IN VARCHAR2 DEFAULT NULL,
     attribute_value   IN VARCHAR2 DEFAULT NULL)
  RETURN SELF AS RESULT
  AS
  BEGIN
    SELF.namespace := namespace;
    SELF.attribute := attribute;
    SELF.attribute_value := attribute_value;
    RETURN;
  END;
END;
/

CREATE OR REPLACE PUBLIC SYNONYM DBMS_XS_NSATTR FOR SYS.DBMS_XS_NSATTR;
/

CREATE OR REPLACE TYPE DBMS_XS_NSATTRLIST AS VARRAY(1000) OF DBMS_XS_NSATTR;
/

CREATE OR REPLACE PUBLIC SYNONYM DBMS_XS_NSATTRLIST FOR SYS.DBMS_XS_NSATTRLIST;
/

GRANT EXECUTE ON DBMS_XS_NSATTR TO PUBLIC;

GRANT EXECUTE ON DBMS_XS_NSATTRLIST TO PUBLIC;

CREATE OR REPLACE PACKAGE DBMS_XS_SESSIONS AUTHID CURRENT_USER AS

  -- The following constants define operation codes passed into namespace
  -- event handling functions.
  attribute_first_read_operation CONSTANT PLS_INTEGER := 1;
  modify_attribute_operation     CONSTANT PLS_INTEGER := 2;

  -- The following constants represent bit values that identify events of 
  -- interest for a particular attribute in a namespace that has an event 
  -- handling function.
  attribute_first_read_event     CONSTANT PLS_INTEGER := 1;
  modify_attribute_event         CONSTANT PLS_INTEGER := 2;

  -- The following constants define return codes that can be returned by a
  -- namespace event handling function.
  event_handling_succeeded       CONSTANT PLS_INTEGER := 0;
  event_handling_failed          CONSTANT PLS_INTEGER := 1;

  -- The following constants are used as input into the 
  -- add/delete/enable_global_callback procedure.
  create_session_event       CONSTANT PLS_INTEGER := 1;
  attach_session_event       CONSTANT PLS_INTEGER := 2;
  guest_to_user_event        CONSTANT PLS_INTEGER := 3;
  proxy_to_user_event        CONSTANT PLS_INTEGER := 4;
  revert_to_user_event       CONSTANT PLS_INTEGER := 5;
  enable_role_event          CONSTANT PLS_INTEGER := 6;
  disable_role_event         CONSTANT PLS_INTEGER := 7;
  enable_dynamic_role_event  CONSTANT PLS_INTEGER := 8;
  disable_dynamic_role_event CONSTANT PLS_INTEGER := 9;
  detach_session_event       CONSTANT PLS_INTEGER := 10;
  terminate_session_event    CONSTANT PLS_INTEGER := 11;
  direct_login_event         CONSTANT PLS_INTEGER := 12;
  direct_logoff_event        CONSTANT PLS_INTEGER := 13;
  
  -- Create a Triton session with specified username. username is 128 char 
  -- case sensitive string. It is mandatory parameter. Unique identifier of 
  -- the session is returned in sessionid parameter. This can be used to 
  -- refer to the session in future calls. To create an anonymous session,
  -- 'XSGUEST' username is specified. is_external parameter specifies 
  -- whether the session is to be created as external principal session. It 
  -- is an optional parameter and default value of this parameter is false, 
  -- indicating by default regular Triton session will be created. NULL value 
  -- for this parameter is taken as false. is_trusted specifies if session is 
  -- to be created in trusted mode or secure mode. In trusted mode, data 
  -- security checks are bypassed; in secure mode, they are enforced. It is an 
  -- optional parameter and default value is false, indicating secure mode. 
  -- NULL value is taken as false. The combination regular session in trusted 
  -- mode is not supported. Other combinations, regular session in secure mode,
  -- external session in trusted mode, external session in secure mode are
  -- supported. namespaces parameter is a list of triplet namespace to be 
  -- created, attribute to be created, attribute value to be set. This is 
  -- optional parameter with default value NULL. XS$GLOBAL_VAR and XS$SESSION 
  -- namespace and their attributes are always available to the session. 
  -- cookie parameter specifies the server cookie to be set for Triton 
  -- session. This is optional parameter with default value NULL. Maximum 
  -- allowed length of cookie is 1024. For creating a Triton session executing 
  -- user need to have CREATE_SESSION privilege. If namespaces are specified, 
  -- during creation of session appropriate privilege (MODIFY_NAMESPACE, 
  -- MODIFY_ATTRIBUTE) on the namespaces or ADMIN_ANY_NAMESPACE system 
  -- privilege is required.
  
  PROCEDURE create_session (username       IN  VARCHAR2,
                            sessionid      OUT NOCOPY RAW,
                            is_external    IN  BOOLEAN DEFAULT FALSE,
                            is_trusted     IN  BOOLEAN DEFAULT FALSE,
                            namespaces     IN  DBMS_XS_NSATTRLIST DEFAULT NULL,
                            cookie         IN  VARCHAR2 DEFAULT NULL);

  -- Attach to an already created Triton session specified by the sessionid. 
  -- The attached session will have the following roles enabled - the roles 
  -- granted (directly or indirectly) to the Triton user with which the 
  -- session was created, the session scope roles that were enabled till the 
  -- last detach of this session. In addition, optional parameters 
  -- enable_dynamic_roles, disable_dynamic_roles specify the lists of dynamic 
  -- role to be enabled and disabled. If any of the dynamic roles specified 
  -- does not exist, attach session will fail. If the session is external 
  -- principal session, a list of external roles can be specified for enabling. 
  -- These roles will remain enabled till detach and won't be enabled in next 
  -- attach by default. A list of triplet - namespace, attribute, attribute 
  -- value can be specified during attach. The namespaces and attributes will 
  -- be created and attribute value will be set. This is in addition to the 
  -- namespaces and attributes that were present in the session till last 
  -- detach. Optional parameter authentication_time updates the authentication 
  -- time of the session. For attaching to a Triton session, the executing user 
  -- requires ATTACH_SESSION privilege. If dynamic roles are specified 
  -- ADMINISTER_SESSION privilege is required. If namespaces are specified, 
  -- appropriate privilege (MODIFY_NAMESPACE, MODIFY_ATTRIBUTE) on the 
  -- namespaces or ADMIN_ANY_NAMESPACE system privilege is required.
  
  PROCEDURE attach_session
        (sessionid              IN RAW,
         enable_dynamic_roles   IN XS$NAME_LIST             DEFAULT NULL,
         disable_dynamic_roles  IN XS$NAME_LIST             DEFAULT NULL,
         external_roles         IN XS$NAME_LIST             DEFAULT NULL,
         authentication_time    IN TIMESTAMP WITH TIME ZONE DEFAULT NULL,
         namespaces             IN DBMS_XS_NSATTRLIST       DEFAULT NULL);

  -- Switch / proxy from current user to another user in currently assigned
  -- Triton session. This operation changes the security context of 
  -- the current lightweight user session to a newly initialized security 
  -- context based on the user identified by username. Switch cannot be 
  -- performed from a external user or to a external user. It cannot be 
  -- performed if already in a proxy session unless the switch operation 
  -- means to revert back to old username. username is 128 char case-sensitive 
  -- string. sessionid is optional and if not specified current session is 
  -- taken. If keep_state is set to true, all session state shall be retained,
  -- otherwise all previous state in the session is cleared. If the target 
  -- user of the proxy operation has a list of filtering roles (proxy roles) 
  -- set up, they are enabled in the session. A list of triplet - namespace, 
  -- attribute, attribute value can be specified during switch. The namespaces 
  -- and attributes will be created and attribute value will be set. This is 
  -- in addition to the namespaces and attributes that were already available 
  -- to the session before this operation (provided keep_state is true). If 
  -- namespaces are specified, appropriate privilege (MODIFY_NAMESPACE, 
  -- MODIFY_ATTRIBUTE) on the namespaces or ADMIN_ANY_NAMESPACE system 
  -- privilege is required.
  
  PROCEDURE switch_user (username       IN VARCHAR2,
                         keep_state     IN BOOLEAN              DEFAULT FALSE,
                         namespaces     IN DBMS_XS_NSATTRLIST   DEFAULT NULL) ;

  -- Assign a named user to currently attached anonymous Triton session 
  -- sessionid. username is 128 char case-sensitive string. Error is thrown, if
  -- an attempt is made to assign user to a session not created by XSGUEST user. 
  -- Roles enabled in current session are retained after this operation. 
  -- Optional parameters enable_dynamic_roles, disable_dynamic_roles specify 
  -- the lists of dynamic role to be enabled and disabled. If any of the 
  -- dynamic roles specified, error is thrown. If the assigned user is 
  -- external, a list of external roles can be supplied for enabling. A list 
  -- of triplet - namespace, attribute, attribute value can be specified 
  -- during assign. The namespaces and attributes will be created and
  -- attribute value will be set. This is in addition to the namespaces 
  -- and attributes that were already available to the session before this 
  -- operation. Optional parameter authentication_time updates the 
  -- authentication time of the session. Assign user operation requires 
  -- ASSIGN_USER privilege. If namespaces are specified, appropriate 
  -- privilege (MODIFY_NAMESPACE, MODIFY_ATTRIBUTE) on the namespaces or 
  -- ADMIN_ANY_NAMESPACE system privilege is required.

  PROCEDURE assign_user(username              IN VARCHAR2,
                        is_external           IN BOOLEAN       DEFAULT FALSE,
                        enable_dynamic_roles  IN XS$NAME_LIST  DEFAULT NULL,
                        disable_dynamic_roles IN XS$NAME_LIST  DEFAULT NULL,
                        external_roles        IN XS$NAME_LIST  DEFAULT NULL,
                        authentication_time   IN TIMESTAMP WITH TIME ZONE 
                                                               DEFAULT NULL,
                        namespaces            IN DBMS_XS_NSATTRLIST 
                                                               DEFAULT NULL);
  
  -- Detaches the current Database session from the Triton session it is 
  -- currently attached to. If abort flag is set true, it olls back the 
  -- changes done in current session. Otherwise, all changes done in the 
  -- Triton session are persisted. Default value for abort is false. If
  -- NULL value is supplied for this parameter it is treated as false.
  -- This operation does not require any privilege. It can only be 
  -- performed from an attached session and after this operation database 
  -- session goes back to the context it was in prior to attaching to the 
  -- Triton session.
  
  PROCEDURE detach_session(abort  IN BOOLEAN DEFAULT FALSE);

  -- Save / persist the changes done in currently attached Triton session to 
  -- metadata table. It can only be performed from an attached session. It 
  -- does not require any privilege. Database session remains attached to the 
  -- Triton session after this operation as it was before this operation.
  
  PROCEDURE save_session;

  -- Destroy / terminate the session specified by the sessionid. If force is 
  -- true, this operation implicitly detaches all database session from the 
  -- Triton session. Otherwise, if there are attached session, an error is 
  -- thrown. force is an optional parameter and default value for this 
  -- parameter is false. After session is destroyed no further attaches can
  -- be made to the session. destroy session operation cannot destroy Triton 
  -- sessions created through direct logon of Triton user. destriy session
  -- operation requires TERMINATE_SESSION privilege.
 
  PROCEDURE destroy_session (sessionid IN RAW, 
                             force     IN BOOLEAN DEFAULT FALSE);

  -- Enable the specified regular Triton role in the currently attached Triton 
  -- session. role is 128 char case sensitive string. If the role does not 
  -- exist an error will be thrown. If role is already enabled, the procedure 
  -- does nothing. This operation can only be used to enable directly granted
  -- (to the Triton session user) regular Triton role. For external principal 
  -- session this API will throw error. This operation requires 
  -- ADMINISTER_SESSION privilege.
  
  PROCEDURE enable_role (role       IN  VARCHAR2);

  -- Disable the specified regular Triton role in the currently attached 
  -- Triton session. role is 128 char case sensitive string. If the role does 
  -- not exist an error will be thrown. If role is already enabled, the 
  -- procedure does nothing. This operation can only be used to disable 
  -- directly granted (to the Triton session user) regular Triton role. For 
  -- external principal session this API will throw error. This operation 
  -- requires ADMINISTER_SESSION privilege. It can only be performed when
  -- attached to a Triton session.
  
  PROCEDURE disable_role (role       IN  VARCHAR2);

  -- Create the specified namespace in the currently attached Triton session. 
  -- namespace is 128 char case sensitive string. The namespace template 
  -- corresponding to the namespace need to exist in the system, else this 
  -- operation will throw error. After this operation, the namespace along 
  -- with its attributes are available to the session. This operation 
  -- requires MODIFY_NAMESPACE privilege. It can only be performed when
  -- attached to a Triton session.
  
  PROCEDURE create_namespace (namespace    IN VARCHAR2);

  -- Delete the specified namespace from the currently attached Triton 
  -- session. namespace is 128 char case sensitive string. If the namespace
  -- is not there in the session or already deleted error is thrown. This 
  -- operation requires MODIFY_NAMESPACE privilege. It can only be performed
  -- when attached to a Triton session.
  
  PROCEDURE delete_namespace (namespace    IN VARCHAR2);

  -- Create an attribute in the application namespace specified in currently 
  -- attached Triton session. If namespace is not already available in the 
  -- session or no such namespace templates exist  error is thrown. namespace
  -- is 128 char case-sensitive string while attribute can be 4000 char long. 
  -- Value for attribute is optional and if specified the value is set. value 
  -- can be 4000 char long at maximum. Optional parameter eventreg specifies 
  -- an event for which handler is executed for the attribute. Events can be 
  -- registered only the namespace has an event handler, else error is thrown. 
  -- Allowed value for eventreg are 0 (no event), 1 (first read event), 
  -- 2 (update event), 3 (first read plus update event). If the attribute is 
  -- registered for first read event, then handler will be executed if the 
  -- attribute is uninitialized, before returning the value. If update event is
  -- registered the handler gets called whenever the attribute is modified. 
  -- This operation requires MODIFY_ATTRIBUTE privilege. It can only be 
  -- performed if attached to a Triton session.
  
  PROCEDURE create_attribute (namespace    IN VARCHAR2,
                              attribute    IN VARCHAR2,
                              value        IN VARCHAR2     DEFAULT NULL,
                              eventreg     IN PLS_INTEGER  DEFAULT NULL);

  -- Resets the value for the specified attribute to default value (if present)
  -- or NULL in the namespace in currently attached session. Valid namespace 
  -- name is 128 char case-sensitive string. attribute can be 4000 char long. 
  -- If the specified attribute does not exist, it is a no-op. This 
  -- operation requires MODIFY_ATTRIBUTE privilege. It can only be performed 
  -- when attached to a Triton session.

  PROCEDURE reset_attribute (namespace    IN VARCHAR2,
                             attribute    IN VARCHAR2);
  
  -- Sets the value for the specified attribute to the specified value in the 
  -- namespace in the currently attached session. Valid namespace name is 128 
  -- char case-sensitive string. If the namespace does not exist or mark for 
  -- deletion, an error is thrown. If no template corresponding to the 
  -- namespace exist an error is thrown. attribute and value can be 4000 char 
  -- long. If the specified attribute does not exist, error  is thrown. This 
  -- operation requires MODIFY_ATTRIBUTE privilege. It can only be performed 
  -- when attached to a Triton session.
  
  PROCEDURE set_attribute (namespace    IN VARCHAR2,
                           attribute    IN VARCHAR2,
                           value        IN VARCHAR2);

  -- Gets the value for the specified attribute in the namespace in currently
  -- attached session. Valid namespace name is 128 char case-sensitive 
  -- string. If the namespace does not exist, return empty string. 
  -- namespace. If no template corresponding to the namespace exist an error 
  -- is thrown. attribute can be 4000 char long. If the specified attribute 
  -- does not exist, return empty string. This operation does not require any
  -- privilege. It can only be performed if attached to a Triton session.
  
  PROCEDURE get_attribute (namespace    IN         VARCHAR2,
                           attribute    IN         VARCHAR2,
                           value        OUT NOCOPY VARCHAR2);
                           
  -- Deletes the specified attribute and its associated value from the 
  -- namespace in currently attached session. Valid namespace name is 128 char
  -- case-sensitive string. If sessionid is NULL, then the session is assumed
  -- to be the currently attached Triton session. If the specified attribute 
  -- does not exist, error is thrown. This operation requires MODIFY_ATTRIBUTE
  -- privilege. It can only be performed if attached to a Triton session.
  
  PROCEDURE delete_attribute (namespace  IN VARCHAR2,
                              attribute  IN VARCHAR2);

  -- This operation updates the last authentication time for the session as 
  -- the current time. If sessionid is NULL, it is assumed to be the session 
  -- identifier of the currently attached Triton session. sessionid parameter
  -- is optional and default value of this parameter is NULL. This operation 
  -- requires MODIFY_SESSION privilege.
  
  PROCEDURE reauth_session (sessionid IN RAW DEFAULT NULL);

  -- Sets the inactivity timeout (in minutes) for the session specified by 
  -- sessionid. Inactivity timeout value represent the maximum period of 
  -- inactivity allowed before the session can be terminated and resource 
  -- be reclaimed. If session has exceeded more time than inactivity timeout 
  -- since last update it is available for termination. Trying to set 
  -- negative value will throw error. If invalid session is specified or 
  -- the session does not exist, error is thrown. Default value for sessionid
  -- is NULL, meaning currently attached Triton session. O value for the 
  -- timeout means infinite, i.e session will never expire due to inactivity. 
  -- This operation requires MODIFY_SESSION privilege.
  
  PROCEDURE set_inactivity_timeout (time      IN NUMBER,
                                    sessionid IN RAW DEFAULT NULL);

  -- Set the cookie for the session specified by sessionid. The cookie has 
  -- to be unique string. Maximum allowed length for cookie is 1024 char. If 
  -- a cookie already exists for the session, the new cookie value replaces 
  -- the old value. If the specified session does not exist or the cookie is 
  -- not unique among all the Triton sessions, then error is thrown. Default
  -- value for sessionid is NULL, meaning currently attached Triton session.
  -- This operation requires MODIFY_SESSION privilege.
  
  PROCEDURE set_session_cookie (cookie     IN VARCHAR2,
                                sessionid  IN RAW DEFAULT NULL);

  -- Get SID for the specified cookie. This operation does not require any
  -- additional privilege. If no session with specified cookie exist, error
  -- is thrown.
  PROCEDURE get_sessionid_from_cookie (cookie     IN  VARCHAR2,
                                       sessionid  OUT NOCOPY RAW);

  -- Adds the global callback procedure for the session event specified by 
  -- event_type. The schema of the callback procedure needs to be specified. 
  -- callback_package is optional parameter and needs to be specified only 
  -- if the callback procedure is in a package. Existance check for the 
  -- procedure is done for this operation. If the callback procedure does not 
  -- exist error is thrown. If invalid event type is specified error is thrown.
  -- Adding the global callback, enables the callback procedure for execution.
  -- More than one callback procedure can be added for same session event. 
  -- If more than one callback is added for the same session event, they are 
  -- executed in according to their registartion sequence, i.e. the callback 
  -- proecdure that was registered first, is executed first.

  PROCEDURE add_global_callback (event_type         IN PLS_INTEGER,
                                 callback_schema    IN VARCHAR2,
                                 callback_package   IN VARCHAR2,
                                 callback_procedure IN VARCHAR2);

  -- Deletes the global callback procedure for the session event specified by
  -- event_type. If callback procedure is not specified, all callback
  -- procedures associated with this global callback are deleted. If invalid 
  -- event type is specified error is thrown.
  
  PROCEDURE delete_global_callback(event_type         IN PLS_INTEGER,
                                   callback_schema    IN VARCHAR2 DEFAULT NULL,
                                   callback_package   IN VARCHAR2 DEFAULT NULL,
                                   callback_procedure IN VARCHAR2 DEFAULT NULL);
  
  -- Enables or disables the global callback for the session event specified by
  -- event_type. enable specifies if the global callback is to be enabled or 
  -- disabled. Default value is true, meaning enable. If no callback procedure
  -- is specified all callback procedures associated with the global calbback 
  -- are enabled. If invalid even type is specified error is thrown.

  PROCEDURE enable_global_callback(event_type         IN PLS_INTEGER,
                                   enable             IN BOOLEAN  DEFAULT TRUE,
                                   callback_schema    IN VARCHAR2 DEFAULT NULL,
                                   callback_package   IN VARCHAR2 DEFAULT NULL,
                                   callback_procedure IN VARCHAR2 DEFAULT NULL);

END  DBMS_XS_SESSIONS;
/

CREATE OR REPLACE PUBLIC SYNONYM DBMS_XS_SESSIONS FOR SYS.DBMS_XS_SESSIONS;
/

GRANT EXECUTE ON DBMS_XS_SESSIONS TO PUBLIC;


@?/rdbms/admin/sqlsessend.sql
