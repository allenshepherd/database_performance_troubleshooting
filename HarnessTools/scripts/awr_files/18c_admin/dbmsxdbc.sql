Rem
Rem $Header: rdbms/admin/dbmsxdbc.sql /main/11 2016/01/25 11:01:37 dmelinge Exp $
Rem
Rem dbmsxdb.sql
Rem
Rem Copyright (c) 2001, 2016, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsxdbc.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmsxdbc.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmsxdbc.sql
Rem SQL_PHASE: DBMSXDBC
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catqm_int.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    dmelinge    01/04/16 - Add ClearHttpDigest API, bug 22160989
Rem    dmelinge    11/04/15 - Global ports control, bug 21700204
Rem    dmelinge    11/05/14 - SetRemoteHttpPort, SR 38986558561
Rem    surman      01/23/14 - 13922626: Update SQL metadata
Rem    dmelinge    08/08/13 - Detect port conflict, bug 17213197
Rem    dmelinge    07/05/13 - Realm from sys.props, bug 16278103
Rem    qyu         03/18/13 - Common start and end scripts
Rem    bdagevil    06/17/12 - add [get/set]HTTPsPort()
Rem    yinlu       08/15/12 - bug 13558045: mark custom authentication related
Rem                           procedures unsupported
Rem    hxzhang     09/29/11 - move config related functions from dbms_xdb to here
Rem    spetride    03/31/11 - move rebuildhierarchicalindex to dbms_xdb_admin
Rem    spetride    03/11/11 - move movexdb_tablespace to dbms_xdb_admin
Rem    spetride    03/30/10 - add enableDigestAuth
Rem    spetride    08/14/09 - add getHTTPRequestHeader
Rem    spetride    06/03/09 - support custom auth follow up
Rem    badeoti     03/19/09 - clean up 11.2 packages
Rem                           Migrate*From9201,CleanSGAForUpgrade procs moved to dbms_xdbutil_int
Rem                           dbms_xdb.nfsfh2resid, syncResource moved to dbms_xdbnfs
Rem    spetride    02/16/09 - add {add|delete}HttpExpireMapping
Rem    atabar      02/06/09 - add xdbconfig default-type-mappings methods 
Rem    spetride    07/02/08 - add apis for custom authentication and trust
Rem    spetride    08/14/07 - createResource from varchar2 and xmltype: pass schemaurl
Rem    thbaby      06/25/07 - dbms_xdb.link doc
Rem    thbaby      06/21/07 - documentation for setListenerEndPoint and
Rem                           getListenerEndPoint
Rem    smalde      12/29/06 - sql injection bug 5739659
Rem    thbaby      11/02/06 - move SyncIndex from dbms_xdb to dbms_xmlindex
Rem    vkapoor     07/25/06 - XbranchMerge rtjoa_httplstapi from 
Rem                           st_rdbms_10.2xe 
Rem    taahmed     06/09/06 - Create wrapper for createResource as a 
Rem                           workaround for PL/SQL BOOLEAN type in JDBC 
Rem    smalde      06/12/06 - add getcontent apis 
Rem    smalde      06/07/06 - resource api 
Rem    pnath       03/15/05 - Introduce LockTokenListType 
Rem    pnath       01/20/05 - PL/SQL Locks API 
Rem    pnath       03/05/06 - dbms_xdb.processlinks API 
Rem    rmurthy     01/14/05 - add symbolic links 
Rem    rmurthy     09/28/04 - add weak links 
Rem    thbaby      02/08/06 - add SyncIndex
Rem    najain      03/09/05 - adding SyncResource
Rem    spannala    03/02/05 - adding nfsfh2resid 
Rem    smalde      08/04/05 - Add calcsize flag to create resource given a 
Rem                           ref. 
Rem    smalde      05/27/05 - Add refreshContentSize procedure 
Rem    mrafiq      10/11/05 - merging changes for upgrade/downgrade 
Rem    najain      03/09/05 - adding SyncResource
Rem    spannala    03/02/05 - adding nfsfh2resid 
Rem    thoang      09/22/04 - Add getResource method
Rem    rtjoa       11/15/05 - Add setListenerEndPoint API 
Rem    pnath       11/24/04 - PL/SQL API to get and set ports 
Rem    abagrawa    08/03/04 - Add new update resource metadata APIs 
Rem    abagrawa    02/21/04 - Add SB Res metadata APIs 
Rem    spannala    06/10/03 - adding cleansgaforupgrade
Rem    najain      06/05/03 - add getxdb_tablespace
Rem    najain      06/02/03 - add movexdb_tablespace
Rem    nmontoya    01/28/03 - ADD ExistsResource
Rem    nmontoya    10/28/02 - ADD optional sticky arg TO createres. FROM REF
Rem    thoang      08/15/02 - added csid parameter to CreateResource methods 
Rem    rmurthy     10/04/02 - add get_resoid, create_oidpath
Rem    njalali     08/13/02 - removing SET statements
Rem    njalali     06/27/02 - added qmxseq to qmxsq migration functions
Rem    spannala    06/03/02 - adding forced delete
Rem    sichandr    04/17/02 - fix createresource from bfile
Rem    nmontoya    02/12/02 - remove privilege constants
Rem    gviswana    01/29/02 - CREATE OR REPLACE SYNONYM
Rem    nmontoya    01/23/02 - added createresource from BFILE
Rem    nmontoya    01/24/02 - protype change FOR acl_check
Rem                             checkprivileges, changeprivileges
Rem    sidicula    01/29/02 - getPrivileges to return Privilege XOBD
Rem    njalali     01/16/02 - added createresource from REF
Rem    nmontoya    01/19/02 - change comment FOR dbms_xdb.link
Rem    nmontoya    01/10/02 - prototype change IN dbms_xdb.link
Rem    spannala    01/11/02 - making all systems types have standard TOIDs
Rem    nmontoya    01/03/02 - added createresource for xmltype and clob
Rem    nmontoya    01/04/02 - ADD changeprivileges
Rem    nmontoya    12/06/01 - ADD getprivileges
Rem    spannala    12/27/01 - script to run in arbitrary schema with dba
Rem    nmontoya    11/13/01 - add createfolder
Rem    nmontoya    10/23/01 - xdb configuration get fix
Rem    kmuthiah    10/19/01 - add RebuildHierarchicalIndex
Rem    nmontoya    10/17/01 - setacl function
Rem    nmontoya    10/15/01 - xdb configuration api
Rem    nmontoya    09/17/01 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

CREATE OR REPLACE PACKAGE xdb.dbms_xdb_config AUTHID CURRENT_USER IS 
   
------------
-- CONSTANTS
--
------------
-- Constant number for 1st argument of setListenerEndPoint
XDB_ENDPOINT_HTTP  CONSTANT NUMBER := 1;
XDB_ENDPOINT_HTTP2 CONSTANT NUMBER := 2;
-- Permit https instead of http2, bug 17213197
XDB_ENDPOINT_HTTPS CONSTANT NUMBER := 2;
XDB_ENDPOINT_RHTTP CONSTANT NUMBER := 3;
XDB_ENDPOINT_RHTTPS CONSTANT NUMBER := 4;

-- Constant number for 4th argument of setListenerEndPoint
XDB_PROTOCOL_TCP   CONSTANT NUMBER := 1;
XDB_PROTOCOL_TCPS  CONSTANT NUMBER := 2;

-- Constant number for 1st argument of xdb_validate_port
-- Constant for service id, compatible with xdb.xdb$cdbports 
XDB_SERVICE_FTP   CONSTANT NUMBER := 1;
XDB_SERVICE_HTTP  CONSTANT NUMBER := 2;
XDB_SERVICE_HTTP2 CONSTANT NUMBER := 3;
-- Following is not used, reserve the value anyway.
XDB_SERVICE_NFS   CONSTANT NUMBER := 4;
XDB_SERVICE_RHTTP CONSTANT NUMBER := 5;
XDB_SERVICE_RHTTPS CONSTANT NUMBER := 6;

ON_DENY_NEXT_CUSTOM   CONSTANT NUMBER := 1;
ON_DENY_BASIC         CONSTANT NUMBER := 2;

---------------------------------------------
-- PROCEDURE - usedport
--     return the protocol port numbers of all pdbs
-- PARAMETERS -
---------------------------------------------
FUNCTION usedport RETURN sys.xmltype;

---------------------------------------------
-- PROCEDURE - setFTPPort
--     sets the FTP port to new value
-- PARAMETERS -
--     new_port
--         value that the ftp port will be set to
---------------------------------------------

PROCEDURE setFTPPort(new_port IN NUMBER);

---------------------------------------------
-- FUNCTION - getFTPPort
--     gets the current value of FTP port
-- PARAMETERS -
--     none
-- RETURNS
--     ftp_port
--         current value of ftp-port
---------------------------------------------

FUNCTION getFTPPort RETURN NUMBER;

---------------------------------------------
-- PROCEDURE - setHTTPPort
--     sets the HTTP port to new value
-- PARAMETERS -
--     new_port
--         value that the http port will be set to
---------------------------------------------

PROCEDURE setHTTPPort(new_port IN NUMBER);

---------------------------------------------
-- PROCEDURE - setHTTPsPort
--     sets the HTTPs port (with SSL) to new value
--
-- PARAMETERS -
--     new_port
--         value that the https port will be set to.
--
-- NOTE
--     The HTTPS port will be set using the second
--     HTTP end point
---------------------------------------------

PROCEDURE setHTTPsPort(new_port IN NUMBER);

---------------------------------------------
-- PROCEDURE - setRemoteHTTPPort
--     sets the Remote HTTP port to new value
-- PARAMETERS -
--     new_port
--         value that the remote http port will be set to
---------------------------------------------

PROCEDURE setRemoteHTTPPort(new_port IN NUMBER);

---------------------------------------------
-- PROCEDURE - setRemoteHTTPSPort
--     sets the Remote HTTP port (with SSL) to new value
-- PARAMETERS -
--     new_port
--         value that the remote http port will be set to
---------------------------------------------

PROCEDURE setRemoteHTTPSPort(new_port IN NUMBER);

---------------------------------------------
-- FUNCTION - getHTTPPort
--     gets the current value of HTTP port
-- PARAMETERS -
--     none
-- RETURNS
--     http_port
--         current value of http-port
---------------------------------------------

FUNCTION getHTTPPort RETURN NUMBER;

---------------------------------------------
-- FUNCTION - getHTTPsPort
--     gets the current value of HTTPs port
-- PARAMETERS -
--     none
-- RETURNS
--     https_port
--         current value of https-port. Return NULL
--         if none has been configured
---------------------------------------------

FUNCTION getHTTPsPort RETURN NUMBER;

---------------------------------------------
-- FUNCTION - getRemoteHTTPPort
--     gets the current value of remote HTTP port
-- PARAMETERS -
--     none
-- RETURNS
--     remote_http_port
--         current value of remote-http-port
---------------------------------------------

FUNCTION getRemoteHTTPPort RETURN NUMBER;

---------------------------------------------
-- FUNCTION - getRemoteHTTPSPort
--     gets the current value of remote HTTPs (with SSL) port
-- PARAMETERS -
--     none
-- RETURNS
--     remote_https_port
--         current value of remote-https-port
---------------------------------------------

FUNCTION getRemoteHTTPSPort RETURN NUMBER;

---------------------------------------------
-- PROCEDURE setListenerEndPoint(endpoint IN number, host IN varchar2, 
--                               port IN number, protocol IN number);

-- This procedure sets the parameters of a listener end point corresponding 
-- to the XML DB HTTP server. Both HTTP and HTTP2 end points can be set by 
-- invoking this procedure. 

--   (a) endpoint - The end point to be set. Its value can be 
--       XDB_ENDPOINT_HTTP or XDB_ENDPOINT_HTTP2. 
--   (b) host - The interface on which the listener end point is to listen. 
--       Its value can be 'localhost,' null, or a hostname. If its value is 
--       'localhost,' then the listener end point is permitted to only listen 
--       on the localhost interface. If its value is null or hostname, then 
--       the listener end point is permitted to listen on both localhost and 
--       non-localhost interfaces. 
--   (c) port - The port on which the listener end point is to listen. 
--   (d) protocol - The transport protocol that the listener end point is to 
--       accept. Its value can be XDB_PROTOCOL_TCP or XDB_PROTOCOL_TCPS. 
---------------------------------------------

PROCEDURE setListenerEndPoint(endpoint IN number, host IN varchar2, 
                              port IN number, protocol IN number);

---------------------------------------------
--  PROCEDURE getListenerEndPoint(endpoint IN NUMBER, host OUT VARCHAR2,
--                                port OUT NUMBER, protocol OUT NUMBER);

-- This procedure retrieves the parameters of a listener end point 
-- corresponding to the XML DB HTTP server. The parameters of both HTTP 
-- and HTTP2 end points can be retrieved by invoking this procedure. 

--  (a) endpoint - The end point whose parameters are to be retrieved. Its 
--      value can be XDB_ENDPOINT_HTTP or XDB_ENDPOINT_HTTP2. 
--  (b) host - The interface on which the listener end point listens. 
--  (c) port - The port on which the listener end point listens.
--  (d) protocol - The transport protocol accepted by the listener end point. 
---------------------------------------------

PROCEDURE getListenerEndPoint(endpoint IN NUMBER, host OUT VARCHAR2,
                              port OUT NUMBER, protocol OUT NUMBER);

---------------------------------------------
-- PROCEDURE setListenerLocalAccess(l_access boolean);
-- This procedure restricts all listener end points of the XML DB HTTP server 
-- to listen only on the localhost interface (when l_access is TRUE) or 
-- allows all listener end points of the XML DB HTTP server to listen on 
-- both localhost and non-localhost interfaces (when l_access is FALSE). 

--  (a) l_access - TRUE or FALSE. See description of procedure above. 
---------------------------------------------
PROCEDURE setListenerLocalAccess(l_access boolean);

---------------------------------------------
-- PROCEDURE - refresh
--     Refreshes the session configuration with the latest configuration
---------------------------------------------
PROCEDURE cfg_refresh;

---------------------------------------------
-- FUNCTION - get
--     retrieves the xdb configuration
-- RETURNS -
--     XMLType for xdb configuration
---------------------------------------------
FUNCTION cfg_get RETURN sys.xmltype;

---------------------------------------------
-- PROCEDURE - update
--     Updates the xdb configuration with the input xmltype document
-- PARAMETERS -
--  xdbconfig
---     XMLType for xdb configuration
--------------------------------------------
PROCEDURE cfg_update(xdbconfig IN sys.xmltype);

-----------------------------------------------------------
-- XDB Config Update APIs
-- PROCEDURE ADDMIMEMAPPING         Add a mime mapping
-- PROCEDURE DELETEMIMEMAPPING      Delete a mime mapping
-- PROCEDURE ADDXMLEXTENSION        Add an xml extension
-- PROCEDURE DELETEXMLEXTENSION     Delete an xml extension
-- PROCEDURE ADDSERVLETMAPPING      Add a servlet mapping
-- PROCEDURE DELETESERVLETMAPPING   Delete a servlet mapping
-- PROCEDURE ADDSCHEMALOCMAPPING    Add a schema location mapping
-- PROCEDURE DELETESCHEMALOCMAPPING Delete a schema location mapping
-- PROCEDURE ADDSERVLET             Add a servlet
-- PROCEDURE DELETESERVLET          Delete a servlet
-- PROCEDURE ADDSERVLETSECROLE      Add a security role ref to a servlet
-- PROCEDURE DELETESERVLETSECROLE   Delete a security role ref from a servlet
-----------------------------------------------------------

procedure ADDMIMEMAPPING (
	extension IN VARCHAR2,
	mimetype  IN VARCHAR2
);

procedure DELETEMIMEMAPPING (
	extension IN VARCHAR2
);

procedure ADDXMLEXTENSION (
	extension IN VARCHAR2
);

procedure DELETEXMLEXTENSION (
	extension IN VARCHAR2
);

procedure ADDSERVLETMAPPING (
 	pattern IN VARCHAR2,
 	name    IN VARCHAR2
);

procedure DELETESERVLETMAPPING (
 	name IN VARCHAR2
);

procedure ADDSERVLET (
	name     IN VARCHAR2,
	language IN VARCHAR2,
	dispname IN VARCHAR2,
	icon     IN VARCHAR2 := NULL,
	descript IN VARCHAR2 := NULL,
	class    IN VARCHAR2 := NULL,
	jspfile  IN VARCHAR2 := NULL,
	plsql    IN VARCHAR2 := NULL,
	schema   IN VARCHAR2 := NULL
);

procedure DELETESERVLET (
 	name IN VARCHAR2
);

procedure ADDSERVLETSECROLE (
 	servname IN VARCHAR2,
 	rolename IN VARCHAR2,
 	rolelink IN VARCHAR2,
 	descript IN VARCHAR2 := NULL
);

procedure DELETESERVLETSECROLE (
	servname IN VARCHAR2,
	rolename IN VARCHAR2
);

procedure ADDSCHEMALOCMAPPING (
	namespace IN VARCHAR2,
	element   IN VARCHAR2,
	schemaURL IN VARCHAR2
);

procedure DELETESCHEMALOCMAPPING (
	schemaURL IN VARCHAR2
);

---------------------------------------------
-- PROCEDURE - addAuthenticationMapping
--     Adds a mapping from the authentication method name to a
--      URL pattern (in xdb$onfig).
-- PARAMETERS - 
--     pattern - URL pattern
--     name    - authentication method name
---------------------------------------------
procedure addAuthenticationMapping(pattern IN VARCHAR2, 
                                   name IN VARCHAR2,
                                   user_prefix IN VARCHAR2 := NULL,
                                   on_deny IN NUMBER := NULL);
PRAGMA SUPPLEMENTAL_LOG_DATA(addAuthenticationMapping, UNSUPPORTED_WITH_COMMIT);

---------------------------------------------
-- PROCEDURE - deleteAuthenticationMapping
--     Deletes a mapping from the authentication method name to a
--      URL pattern (from xdb$onfig).
-- PARAMETERS - 
--     pattern - URL pattern
--     name    - authentication method name
---------------------------------------------
procedure deleteAuthenticationMapping(pattern IN VARCHAR2, 
                                      name IN VARCHAR2);
PRAGMA SUPPLEMENTAL_LOG_DATA(deleteAuthenticationMapping, UNSUPPORTED_WITH_COMMIT);

---------------------------------------------
-- PROCEDURE - addAuthenticationMethod
--     Adds to xdb$config a custom authentication method entry.
-- PARAMETERS - 
--     name    - authentication method name (the name the 
--               custom authentication routine will be known to XDB)
--     description - some note on the authentication method
--     implement_schema - the owner of the routine that implements
--                        the authentication 
--     implement_method - the name of the routine that implements
--                        the authentication 
--     language         - the language in which the implementation 
--                        routine is written (currently only PL/SQL)
---------------------------------------------
procedure addAuthenticationMethod(name IN VARCHAR2, 
                                  description IN VARCHAR2,
                                  implement_schema IN VARCHAR2,
                                  implement_method IN VARCHAR2,
                                  language  IN VARCHAR2 := 'PL/SQL');
PRAGMA SUPPLEMENTAL_LOG_DATA(addAuthenticationMethod, UNSUPPORTED_WITH_COMMIT);

---------------------------------------------
-- PROCEDURE - deleteAuthenticationMethod
--    Deletes from  xdb$config a custom authentication method entry.
-- PARAMETERS - 
--     name    - authentication method name (the name the 
--               custom authentication routine will be known to XDB)
---------------------------------------------
procedure deleteAuthenticationMethod(name IN VARCHAR2);
PRAGMA SUPPLEMENTAL_LOG_DATA(deleteAuthenticationMethod, UNSUPPORTED_WITH_COMMIT);

procedure addTrustScheme(name IN VARCHAR2, 
                         description IN VARCHAR2,
                         session_user IN VARCHAR2,
                         parsing_schema IN VARCHAR2,
                         system_level IN BOOLEAN := TRUE,
                         require_parsing_schema IN BOOLEAN := TRUE,
                         allow_registration IN BOOLEAN := TRUE);
PRAGMA SUPPLEMENTAL_LOG_DATA(addTrustScheme, UNSUPPORTED_WITH_COMMIT);

procedure deleteTrustScheme(name IN VARCHAR2, 
                            system_level IN BOOLEAN := TRUE);
PRAGMA SUPPLEMENTAL_LOG_DATA(deleteTrustScheme, UNSUPPORTED_WITH_COMMIT);

procedure addTrustMapping(pattern IN VARCHAR2, 
                          auth_name IN VARCHAR2,
                          trust_name IN VARCHAR2,
                          user_prefix IN VARCHAR2 := NULL);
PRAGMA SUPPLEMENTAL_LOG_DATA(addTrustMapping, UNSUPPORTED_WITH_COMMIT);

procedure deleteTrustMapping(pattern IN VARCHAR2, 
                             name IN VARCHAR2);
PRAGMA SUPPLEMENTAL_LOG_DATA(deleteTrustMapping, UNSUPPORTED_WITH_COMMIT);

procedure enableCustomAuthentication;
PRAGMA SUPPLEMENTAL_LOG_DATA(enableCustomAuthentication, UNSUPPORTED_WITH_COMMIT);

procedure enableCustomTrust;
PRAGMA SUPPLEMENTAL_LOG_DATA(enableCustomTrust, UNSUPPORTED_WITH_COMMIT);

procedure setDynamicGroupStore(is_dynamic IN BOOLEAN := TRUE);
PRAGMA SUPPLEMENTAL_LOG_DATA(setDynamicGroupStore, UNSUPPORTED_WITH_COMMIT);

procedure enableDigestAuthentication;
PRAGMA SUPPLEMENTAL_LOG_DATA(enableDigestAuthentication, UNSUPPORTED_WITH_COMMIT);

function getHttpConfigRealm
  return VARCHAR2;

procedure setHttpConfigRealm(realm IN VARCHAR2);
PRAGMA SUPPLEMENTAL_LOG_DATA(setHttpConfigRealm, UNSUPPORTED_WITH_COMMIT);

-------------------------------------------------------------------------------
-- FUNCTION - IsGlobalPortEnabled
--  Returns the flag that determines if a servlet will permit/disable global
--  port messages.  If not defined the default value is returned, which is
--  FALSE for the root and TRUE for pdbs.
--  New feature in 12.2
-------------------------------------------------------------------------------
function IsGlobalPortEnabled
  return BOOLEAN;
PRAGMA SUPPLEMENTAL_LOG_DATA(IsGlobalPortEnabled, UNSUPPORTED_WITH_COMMIT);

-----------------------------------------------------------
-- PROCEDURE - SetGlobalPortEnabled
--  sets/clears flag in servlet that will permit/disable global port messages
--  from the root's port to executing the servlet in a target pdb
--  New feature in 12.2
--
-- PARAMETERS -
--  isenabled(IN) - Accepted values: TRUE to permit, FALSE to disable
-----------------------------------------------------------
procedure  SetGlobalPortEnabled(isenabled IN BOOLEAN := TRUE);
PRAGMA SUPPLEMENTAL_LOG_DATA(SetGlobalPortEnabled, UNSUPPORTED_WITH_COMMIT);

-----------------------------------------------------------
-- PROCEDURE - ClearHttpDigests
--  Clears the MD5 digests stored in sys.user$.  Before 12.2.0.1 they were
--  generated for each user, now they can be but by default are not.  This
--  procedure is intended to be used by a DBA after upgrade to clear out
--  old digests so they cannot be a security risk.
--  New feature in 12.2.0.1
--
-- PARAMETERS -
--  none
-----------------------------------------------------------
procedure ClearHttpDigests;
PRAGMA SUPPLEMENTAL_LOG_DATA(ClearHttpDigests, UNSUPPORTED_WITH_COMMIT);


-----------------------------------------------------------
-- PROCEDURE - addDefaultTypeMappings
--  creats a default-type-mappings entry in xdbconfig. 
--  Default is pre-11.2
--
-- PARAMETERS -
--  version (IN) - Accepted values: "pre-11.2" or "post-11.2"   
--                 Default is pre-11.2
-----------------------------------------------------------
PROCEDURE addDefaultTypeMappings ( version IN VARCHAR2 := 'pre-11.2');


-----------------------------------------------------------
-- PROCEDURE - deleteDefaultTypeMappings
--  deletes the default type mappings from xdbconfig. 
--
-- PARAMETERS -
-----------------------------------------------------------
PROCEDURE deleteDefaultTypeMappings;

-----------------------------------------------------------
-- PROCEDURE - setDefaultTypeMappings
--  sets the value of default-type-mappings in xdbconfig 
--
-- PARAMETERS -
--  type (IN) - Accepted values: "pre-11.2" or "post-11.2" 
-----------------------------------------------------------
PROCEDURE setDefaultTypeMappings ( version IN VARCHAR2 );


-------------------------------------------------------------------------------
-- PROCEDURE - addHttpExpireMapping
--    Adds to xdb$config a mapping of the URL pattern to an
--     expiration date. This will control the Expire headers
--     for URLs matching the pattern.
-- PARAMETERS - 
--     pattern  -- URL pattern (only * accepted as wildcards)
--     expire   -- expiration directive, follows the ExpireDefault
--                 in Apache's mod_expires, i.e., 
--                 base [plus] (num type)*
--                 -- base: now | modification
--                 -- type: year|years|month|months|week|weeks|day|days|
--                          minute|minutess|second|seconds
-- EXAMPLE
--  dbms_xdb.addHttpExpireMapping('/public/test1/*', 'now plus 4 weeks');
--  dbms_xdb.addHttpExpireMapping('/public/test2/*', 
--                                'modification plus 1 day 30 seconds');
-------------------------------------------------------------------------------
procedure addHttpExpireMapping(pattern IN VARCHAR2,
                               expire IN VARCHAR2);

-------------------------------------------------------------------------------
-- PROCEDURE - deleteHttpExpireMapping
--    Deletes from xdb$config all mappings of the URL pattern to an
--     expiration date. 
-- PARAMETERS - 
--     pattern  -- URL pattern (only * accepted as wildcards)
-------------------------------------------------------------------------------
procedure deleteHttpExpireMapping(pattern IN VARCHAR2);

-------------------------------------------------------------------------------
-- FUNCTION - getHTTPRequestHeader
--    If called during an HTTP request serviced by XDB, it returns the values
--    of the passed header. It returns NULL in case the header is not present
--    in the request, or for AUTHENTICATION, for security reasons.
--    Expected to be used by routines that implement custom authentication.
-------------------------------------------------------------------------------
function getHTTPRequestHeader(header_name IN VARCHAR2)
  return VARCHAR2;

end dbms_xdb_config;
/
show errors;

CREATE OR REPLACE PUBLIC SYNONYM DBMS_XDB_CONFIG FOR xdb.dbms_xdb_config
/
GRANT EXECUTE ON xdb.dbms_xdb_config TO PUBLIC
/
show errors;

@?/rdbms/admin/sqlsessend.sql
