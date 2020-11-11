Rem
Rem $Header: rdbms/admin/dbmsxdbr.sql /main/5 2014/02/20 12:46:25 surman Exp $
Rem
Rem dbmsxdb.sql
Rem
Rem Copyright (c) 2001, 2014, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsxdbr.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmsxdbr.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmsxdbr.sql
Rem SQL_PHASE: DBMSXDBR
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catqm_int.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    surman      01/22/14 - 13922626: Update SQL metadata
Rem    qyu         03/18/13 - Common start and end scripts
Rem    qyu         12/04/12 - add getxdb_tablespace
Rem    hxzhang     09/29/11 - move resource functions from dbms_xdb to here
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

CREATE OR REPLACE PACKAGE xdb.dbms_xdb_repos AUTHID CURRENT_USER IS 
   
------------
-- CONSTANTS
--
------------
DELETE_RESOURCE        CONSTANT NUMBER := 1;
DELETE_RECURSIVE       CONSTANT NUMBER := 2;
DELETE_FORCE           CONSTANT NUMBER := 3;
DELETE_RECURSIVE_FORCE CONSTANT NUMBER := 4;

DELETE_RES_METADATA_CASCADE   CONSTANT NUMBER := 1;
DELETE_RES_METADATA_NOCASCADE CONSTANT NUMBER := 2;


DEFAULT_LOCK_TIMEOUT CONSTANT PLS_INTEGER := (60*60);

LINK_TYPE_HARD        CONSTANT NUMBER := 1;
LINK_TYPE_WEAK        CONSTANT NUMBER := 2;
LINK_TYPE_SYMBOLIC    CONSTANT NUMBER := 3;


---------------------------------------------
-- FUNCTION - LockResource
--     Gets a webdav-like lock for XDB resource given its path
-- PARAMETERS -
--  abspath
--     Absolute path in the Hierarchy of the resource 
--  depthzero
--     depth zero boolean
--  shared
--     shared boolean
-- RETURNS -
--     Returns TRUE if successful
---------------------------------------------
FUNCTION LockResource(abspath IN VARCHAR2, depthzero IN BOOLEAN, 
                                           shared IN boolean) 
              RETURN boolean;

---------------------------------------------
-- FUNCTION - LockResource
--     Gets a webdav-like lock for XDB resource given its path
-- PARAMETERS -
--  abspath
--     Absolute path in the Hierarchy of the resource 
--  depthzero
--     depth zero boolean
--  shared
--     shared boolean
--  token
--     generated token
--  timeout 
--     time (in seconds) after which lock expires
-- RETURNS -
--     Returns TRUE if successful
---------------------------------------------
FUNCTION LockResource(abspath IN VARCHAR2, depthzero IN BOOLEAN, 
                      shared IN boolean, token OUT VARCHAR2,
                      timeout IN PLS_INTEGER := DEFAULT_LOCK_TIMEOUT)
              RETURN boolean; 

---------------------------------------------
-- PROCEDURE - RefreshLock
--     Refreshes a webdav-like lock for XDB resource given its path
-- PARAMETERS -
--  abspath
--     Absolute path in the Hierarchy of the resource 
--  token
--     token corresponding to the lock to be refreshed
--  newTimeout
--     new timeout (in seconds) after which lock will expire
-- NOTE -
--     If the timeout is less than the remaining time to expiry, 
--     lock will not be refreshed
---------------------------------------------

PROCEDURE RefreshLock(abspath IN VARCHAR2, token IN VARCHAR2,
                     newTimeout IN  PLS_INTEGER := DEFAULT_LOCK_TIMEOUT);

---------------------------------------------
-- FUNCTION - LockDiscovery
--     Gets Locks element on resource defined by abspath
-- PARAMETERS -
--  abspath
--     Absolute path in the Hierarchy of the resource
-- RETURNS -
--     the Locks element as XMLType
---------------------------------------------
FUNCTION LockDiscovery(abspath IN VARCHAR2)
               RETURN SYS.XMLType;

---------------------------------------------
-- PROCEDURE - GetLockToken
--     Gets lock token for current user for XDB resource given its path
-- PARAMETERS -
--  abspath
--     Absolute path in the Hierarchy of the resource 
--  locktoken (OUT)
--     Returns lock token
---------------------------------------------
PROCEDURE GetLockToken(abspath IN VARCHAR2, locktoken OUT VARCHAR2);

---------------------------------------------
-- FUNCTION - Unlock
--     Removes lock for XDB resource given lock token
-- PARAMETERS -
--  abspath
--     Absolute path in the Hierarchy of the resource 
--  delToken
--     Lock token name to be removed
-- RETURNS -
--     Returns TRUE if successful
---------------------------------------------
FUNCTION UnlockResource(abspath IN VARCHAR2, deltoken IN VARCHAR2 := NULL) 
                        RETURN boolean;

---------------------------------------------
-- PROCEDURE - AddToLockTokenList
--     Adds specified token to the session lock token list
-- PARAMETERS -
--  token
--     token to be added to token list
---------------------------------------------
PROCEDURE AddToLockTokenList(token IN VARCHAR2);

---------------------------------------------
-- FUNCTION - DeleteFromLockTokenList
--     Deletes specified token from the session lock token list
-- PARAMETERS -
--  token
--     token to be deleted from token list
-- RETURNS -
--     returns TRUE if delete was successful
---------------------------------------------
FUNCTION DeleteFromLockTokenList(token IN VARCHAR2)
                        RETURN boolean;

---------------------------------------------
-- FUNCTION - GetLockTokenList
--     Gets the session lock token list
-- PARAMETERS -
--  None
-- RETURNS -
--  The session lock token list
---------------------------------------------
FUNCTION GetLockTokenList RETURN LockTokenListType;

---------------------------------------------
-- FUNCTION - ExistsResource(VARCHAR2)
--     Given a string, returns true if the resource exists in the hierarchy.
-- PARAMETERS - 
--  abspath
--     Absolute path to the resource
-- RETURNS -
--     Returns TRUE if resource was found in the hierarchy.
---------------------------------------------
FUNCTION ExistsResource(abspath IN VARCHAR2) RETURN BOOLEAN;

---------------------------------------------
-- FUNCTION - CreateResource(VARCHAR2, VARCHAR2, VARCHAR2, VARCHAR2)
--     Given a string, inserts a new resource into the hierarchy with
--     the string as the contents.
-- PARAMETERS - 
--  abspath
--     Absolute path to the resource
--  data
--     String buffer containing the resource contents
--  schemaurl
--     for XML data, schema URL data conforms to (default null)
--  elem
--     element name (default null)
-- RETURNS -
--     Returns TRUE if resource was successfully inserted or updated
---------------------------------------------
FUNCTION CreateResource(abspath IN VARCHAR2, 
                        data IN VARCHAR2,
                        schemaurl IN VARCHAR2 := NULL,
                        elem IN VARCHAR2 := NULL) RETURN BOOLEAN;

---------------------------------------------
-- FUNCTION - CreateResource(VARCHAR2, SYS.XMLTYPE, VARCHAR2, VARCHAR2)
--     Given an XMLTYPE and a schema URL, inserts a new resource 
--     into the hierarchy with the XMLTYPE as the contents.
-- PARAMETERS - 
--  abspath
--     Absolute path to the resource
--  data
--     XMLTYPE containing the resource contents
--  schemaurl
--     schema URL the XmlType conforms to (default null)
--  elem
--     element name (default null)
-- RETURNS -
--     Returns TRUE if resource was successfully inserted or updated
---------------------------------------------
FUNCTION CreateResource(abspath IN VARCHAR2, 
                        data IN SYS.XMLTYPE,
                        schemaurl IN VARCHAR2 := NULL,
                        elem IN VARCHAR2 := NULL) RETURN BOOLEAN;


---------------------------------------------
-- FUNCTION - CreateResource(VARCHAR2, REF SYS.XMLTYPE, BOOLEAN, BOOLEAN)
--     Given a PREF to an existing XMLType row, inserts a new resource
--     whose contents point directly at that row.  That row should
--     not already exist inside another resource.
-- PARAMETERS - 
--  abspath
--     Absolute path to the resource
--  data
--     REF to the XMLType row containing the resource contents
--  sticky
--     If TRUE creates a sticky REF, otherwise non-sticky.
--     Default is TRUE (for backwards compatibility).
--  calcSize
--     If true, calculate the content size of the resource. Default is
--     false for performance reasons.
-- RETURNS -
--     Returns TRUE if resource was successfully inserted or updated
---------------------------------------------
FUNCTION CreateResource(abspath IN VARCHAR2, 
                        data IN REF SYS.xmltype, 
                        sticky IN BOOLEAN := TRUE,
                        calcSize IN BOOLEAN := FALSE) RETURN BOOLEAN;

---------------------------------------------
-- FUNCTION - CreateResource(VARCHAR2, CLOB)
--     Given a CLOB, inserts a new resource into the hierarchy with
--     the CLOB as the contents.
-- PARAMETERS - 
--  abspath
--     Absolute path to the resource
--  data
--     CLOB containing the resource contents
-- RETURNS -
--     Returns TRUE if resource was successfully inserted or updated
---------------------------------------------
FUNCTION CreateResource(abspath IN VARCHAR2, 
                        data IN CLOB) RETURN BOOLEAN;

---------------------------------------------
-- FUNCTION - CreateResource(VARCHAR2, BFILE, NUMBER)
--     Given a BFILE, inserts a new resource into the hierarchy with
--     the contents loaded from the BFILE.
-- PARAMETERS - 
--  abspath
--     Absolute path to the resource
--  data
--     BFILE containing the resource contents
--  csid
--     character set id of the input bfile
-- RETURNS -
--     Returns TRUE if resource was successfully inserted or updated
---------------------------------------------
FUNCTION CreateResource(abspath IN VARCHAR2, 
                        data IN BFILE,
                        csid IN NUMBER := 0) RETURN BOOLEAN;

---------------------------------------------
-- FUNCTION - CreateResource(VARCHAR2, BLOB, NUMBER)
--     Given a BLOB, inserts a new resource into the hierarchy with
--     the BLOB as the contents.
-- PARAMETERS -
--  abspath
--     Absolute path to the resource
--  data
--     BLOB containing the resource contents
--  csid
--     character set id of the input blob
-- RETURNS -
--     Returns TRUE if resource was successfully inserted or updated
---------------------------------------------
FUNCTION CreateResource(abspath IN VARCHAR2,
                        data IN BLOB,
                        csid IN NUMBER := 0) RETURN BOOLEAN;


---------------------------------------------
-- FUNCTION - CreateFolder
--     Creates a folder in the Repository 
-- PARAMETERS - 
--  abspath
--     Absolute path iin the Hierarchy were the resource will be stored
-- RETURNS -
--     Returns TRUE if folder was created succesfully in Repository
---------------------------------------------
FUNCTION CreateFolder(abspath IN VARCHAR2) RETURN BOOLEAN;

---------------------------------------------
-- FUNCTION - AddResource(VARCHAR2, VARCHAR2)
--     Given a string, inserts a new resource into the hierarchy with
--     the string as the contents.
-- PARAMETERS - 
--  abspath
--     Absolute path to the resource
--  data
--     String buffer containing the resource contents
-- RETURNS -
--     Returns 2 if resource already exists
--             1 if resource was successfully inserted 
--             0 otherwise
---------------------------------------------
FUNCTION AddResource(abspath IN VARCHAR2, 
                        data IN VARCHAR2) RETURN NUMBER;

---------------------------------------------
-- PROCEDURE - DeleteResource
--     Deletes a resource from the Hierarchy
-- PARAMETERS - 
--  abspath
--     Absolute path in the Hierarchy for resource to be deleted
--  delete_option : one of the following
--    DELETE_RESOURCE ::
--      delete the resource alone. Fails if the resource has children
--    DELETE_RECURSIVE ::
--      delete the resource with the children, if any.
--    DELETE_FORCE ::
--      delete the resource even if the object it contains is invalid.
--    DELETE_RECURSIVE_FORCE ::
--      delete the resource and all children, ignoring any errors raised
--      by contained objects being invalid
---------------------------------------------
PROCEDURE DeleteResource(abspath IN VARCHAR2,
                         delete_option IN pls_integer := DELETE_RESOURCE);

---------------------------------------------
-- PROCEDURE - Link
--     Creates a link from a specified folder to a specified resource. 
-- PARAMETERS -
--  srcpath
--     Path name of the resource to which a link is created. 
--  linkfolder
--     Folder in which the new link is placed.  
--  linkname
--     Name of the new link.
--  linktype
--     Type of link to be created.
--     One of the following: 
--         DBMS_XDB.LINK_TYPE_HARD (default)
--         DBMS_XDB.LINK_TYPE_WEAK
--         DBMS_XDB.LINK_TYPE_SYMBOLIC
---------------------------------------------
PROCEDURE Link(srcpath IN VARCHAR2, linkfolder IN VARCHAR2,
               linkname IN VARCHAR2, 
               linktype IN PLS_INTEGER := DBMS_XDB.LINK_TYPE_HARD);

---------------------------------------------
-- PROCEDURE - Rename
--     Renames a XDB resource
-- PARAMETERS -
--  srcpath
--     Absolute path in the Hierarchy of the source resource 
--  destfolder
--     Absolute path in the Hierarchy of the dest folder  
--  newname
--     Name of the child in the destination folder
---------------------------------------------
PROCEDURE RenameResource(srcpath IN VARCHAR2, destfolder IN VARCHAR2,
                         newname IN VARCHAR2);

---------------------------------------------
-- FUNCTION - getAclDoc
--     gets acl document that protects resource given in path
-- PARAMETERS -
--  abspath
--     Absolute path in the Hierarchy of the resource whose acl doc is required
-- RETURNS -
--     Returns xmltype for acl document
---------------------------------------------
FUNCTION getAclDocument(abspath IN VARCHAR2) RETURN sys.xmltype;

---------------------------------------------
-- FUNCTION - getPrivileges
--     Gets all system and user privileges granted to the current user 
--     on the given XDB resource
-- PARAMETERS -
--  res_path
--     Absolute path in the Hierarchy for XDB resource 
-- RETURNS -
--     Returns a XMLType instance of <privilege> element 
--     which contains the list of all (leaf) privileges 
--     granted on this resource to the current user.
--     It includes all granted system and user privileges.
--     Example : 
--       <privilege xmlns="http://xmlns.oracle.com/xdb/acl.xsd"
--                  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
--                  xsi:schemaLocation="http://xmlns.oracle.com/xdb/acl.xsd 
--                                      http://xmlns.oracle.com/xdb/acl.xsd"
--                  xmlns:dav="DAV:"
--                  xmlns:emp="http://www.example.com/emp.xsd">
--          <read-contents/>
--          <read-properties/>
--          <resolve/>
--          <dav:read-acl/>
--          <emp:Hire/>
--       </privilege>
---------------------------------------------
FUNCTION getPrivileges(res_path IN VARCHAR2) RETURN sys.xmltype;

---------------------------------------------
-- FUNCTION - changePrivileges
--     change access privileges on given XDB resource 
-- PARAMETERS -
--  res_path
--     Absolute path in the Hierarchy for XDB resource 
--  ace 
--     an XMLType instance of the <ace> element which specifies 
--     the <principal>, the operation <grant> and the list of 
--     privileges.
--     If no ACE with the same principal and the same operation 
--     (grant/deny) already exists in the ACL, the new ACE is added 
--     at the end of the ACL.
--  replace
--    This argument determines the result of changePrivileges if 
--    an ACE with the same principal and same operation (grant/deny) 
--    already exists in the ACL.
--  
--    If set to TRUE, 
--       the old ACE is replaced with the new one.
--    else
--       the privileges of the old and new ACEs are combined into a 
--       single ACE.
--
-- RETURNS -
--     Returns positive integer if ACL was successfully modified
---------------------------------------------
FUNCTION changePrivileges(res_path IN VARCHAR2, 
                          ace      IN xmltype)
                          RETURN pls_integer;

---------------------------------------------
-- FUNCTION - checkPrivileges
--     checks access privileges granted on specified XDB resource
-- PARAMETERS -
--  res_path
--     Absolute path in the Hierarchy for XDB resource 
--  privs
--     Requested set of access privileges  
--     This argument is a XMLType instance of the <privilege> element.
-- RETURNS -
--     Returns positive integer if all requested privileges granted
---------------------------------------------
FUNCTION checkPrivileges(res_path IN VARCHAR2, 
                         privs IN xmltype)
                         RETURN pls_integer;


---------------------------------------------
-- PROCEDURE - setacl
--     sets the ACL on given XDB resource to be the specified in the acl path
-- PARAMETERS -
--  res_path
--     Absolute path in the Hierarchy for XDB resource 
--  acl_path
--     Absolute path in the Hierarchy for XDB acl 
---------------------------------------------
PROCEDURE setacl(res_path IN VARCHAR2, acl_path IN VARCHAR2); 

---------------------------------------------
-- FUNCTION - AclCheckPrivileges
--     checks access privileges granted by specified ACL document
-- PARAMETERS -
--  acl_path
--     Absolute path in the Hierarchy for ACL document
--  owner
--     Resource owner name. The pseudo user "XDBOWNER" is replaced 
--     by this user during ACL privilege resolution
--  privs
--     Requested set of access privileges  
--     This argument is a XMLType instance of the <privilege> element.
-- RETURNS -
--     Returns positive integer if all requested privileges granted
---------------------------------------------
FUNCTION AclCheckPrivileges(acl_path IN VARCHAR2, 
                            owner IN VARCHAR2, 
                            privs IN xmltype)
                            RETURN pls_integer;

---------------------------------------------
-- FUNCTION - GetResOID(abspath VARCHAR2)
--     Returns the OID of the resource, given its absolute path 
--
-- PARAMETERS -
--  abspath
--     Absolute path to the resource
-- RETURNS -
--     OID of resource if present, NULL otherwise
---------------------------------------------
FUNCTION GetResOID(abspath IN VARCHAR2) RETURN RAW;

---------------------------------------------
-- FUNCTION - CreateOIDPath(oid RAW)
--     Returns the OID-based virtual path to the resource
--
-- PARAMETERS -
--  OID
--     OID of the resource 
-- RETURNS -
--     the OID-based virtual path to the resource
---------------------------------------------
FUNCTION CreateOIDPath(oid IN RAW) RETURN VARCHAR2;

-----------------------------------------------------------
-- PROCEDURE - appendResourceMetadata
--     Appends the given piece of metadata to the resource
--
-- PARAMETERS -
--  abspath
--     Absolute path of the resource 
--  data
--     Metadata (can be schema based or NSB). SB metadata
--     will be stored in its own table.
-- RETURNS -
--     Nothing
-----------------------------------------------------------
PROCEDURE appendResourceMetadata(abspath IN VARCHAR2, 
                                 data IN SYS.xmltype);

-----------------------------------------------------------
-- PROCEDURE - appendResourceMetadata
--     Appends the given piece of metadata identified by a REF
--     to the resource
--
-- PARAMETERS -
--  abspath
--     Absolute path of the resource 
--  data
--     REF to the piece of metadata (schema based)
-- RETURNS -
--     Nothing
-----------------------------------------------------------
PROCEDURE appendResourceMetadata(abspath IN VARCHAR2, 
                                 data IN REF SYS.xmltype);

-----------------------------------------------------------
-- PROCEDURE - deleteResourceMetadata
--     Deletes metadata from a resource (can only be used for SB metadata)
--
-- PARAMETERS -
--  abspath
--     Absolute path of the resource 
--  metadata
--     REF to the piece of metadata (schema based) to be deleted
--  delete_option
--     Can be one of the following:
--     DELETE_RES_METADATA_CASCADE : deletes the corresponding row
--     in the metadata table
--     DELETE_RES_METADATA_NOCASCADE : does not delete the row in
--     the metadata table
-- RETURNS -
--     Nothing
-----------------------------------------------------------
PROCEDURE deleteResourceMetadata(abspath IN VARCHAR2,
                                 metadata IN REF SYS.XMLTYPE,
                                 delete_option IN pls_integer := 
                                  DELETE_RES_METADATA_CASCADE);

-----------------------------------------------------------
-- PROCEDURE - deleteResourceMetadata
--     Deletes metadata from a resource (can be used for SB or 
--     NSB metadata)
--
-- PARAMETERS -
--  abspath
--     Absolute path of the resource 
--  metadatans
--     Namespace of the metadata fragment to be removed
--  metadataname
--     Local name of the metadata fragment to be removed
--  delete_option
--     This is only applicable for SB metadata.
--     Can be one of the following:
--     DELETE_RES_METADATA_CASCADE : deletes the corresponding row
--     in the metadata table
--     DELETE_RES_METADATA_NOCASCADE : does not delete the row in
--     the metadata table
-- RETURNS -
--     Nothing
-----------------------------------------------------------
procedure deleteResourceMetadata(abspath IN VARCHAR2,
                                 metadatans IN VARCHAR2,
                                 metadataname IN VARCHAR2,
                                 delete_option IN pls_integer := 
                                 DELETE_RES_METADATA_CASCADE);

-----------------------------------------------------------
-- PROCEDURE - updateResourceMetadata
--     Updates metadata for a resource (can be used to update SB 
--     metadata only). The new metadata must be SB.
--
-- PARAMETERS -
--  abspath
--     Absolute path of the resource 
--  oldmetadata
--     REF to the old piece of metadata
--  newmetadata
--     REF to the new piece of metadata to replace it with
-- RETURNS -
--     Nothing
-----------------------------------------------------------
PROCEDURE updateResourceMetadata(abspath  IN VARCHAR2, 
                                 oldmetadata IN REF SYS.XMLTYPE,
                                 newmetadata IN REF SYS.XMLTYPE);

-----------------------------------------------------------
-- PROCEDURE - updateResourceMetadata
--     Updates metadata for a resource (can be used to update SB 
--     metadata only). The new metadata can be either SB or NSB
--
-- PARAMETERS -
--  abspath
--     Absolute path of the resource 
--  oldmetadata
--     REF to the old piece of metadata
--  newmetadata
--     New piece of metadata (can be either SB or NSB)
-- RETURNS -
--     Nothing
-----------------------------------------------------------
PROCEDURE updateResourceMetadata(abspath  IN VARCHAR2, 
                                 oldmetadata IN REF SYS.XMLTYPE,
                                 newmetadata IN XMLTYPE);

-----------------------------------------------------------
-- PROCEDURE - updateResourceMetadata
--     Updates metadata for a resource - can be used for both
--     SB or NSB metadata.
--
-- PARAMETERS -
--  abspath
--     Absolute path of the resource 
--  oldns, oldname
--     namespace and local name pair identifying old metadata
--  newmetadata
--     New piece of metadata (can be either SB or NSB)
-- RETURNS -
--     Nothing
-----------------------------------------------------------
PROCEDURE updateResourceMetadata(abspath  IN VARCHAR2, 
                                 oldns IN VARCHAR2,
                                 oldname IN VARCHAR,
                                 newmetadata IN XMLTYPE);

-----------------------------------------------------------
-- PROCEDURE - updateResourceMetadata
--     Updates metadata for a resource - can be used for both
--     SB or NSB metadata. New metadata must be SB.
--
-- PARAMETERS -
--  abspath
--     Absolute path of the resource 
--  oldns, oldname
--     namespace and local name pair identifying old metadata
--  newmetadata
--     REF to new metadata
-- RETURNS -
--     Nothing
-----------------------------------------------------------
PROCEDURE updateResourceMetadata(abspath  IN VARCHAR2, 
                                 oldns IN VARCHAR2,
                                 oldname IN VARCHAR,
                                 newmetadata IN REF SYS.XMLTYPE);

-----------------------------------------------------------
-- PROCEDURE - purgeResourceMetadata
--     Deletes all user metadata from a resource 
--     SB metadata is removed in cascade mode i.e. the rows
--     are deleted from the corresponding metadata tables
--
-- PARAMETERS -
--  abspath
--     Absolute path of the resource 
-- RETURNS -
--     Nothing
-----------------------------------------------------------
PROCEDURE purgeResourceMetadata(abspath  IN VARCHAR2);

---------------------------------------------
-- FUNCTION - getResource
--    Given a path in the repository, returns the XDBResource
-- PARAMETERS - 
--    abspath - absolute path in the repository
-- RETURNS -
--    The XDBResource.
---------------------------------------------
FUNCTION getResource(abspath IN VARCHAR2) return dbms_xdbresource.XDBResource;

-----------------------------------------------------------
-- PROCEDURE - refreshContentSize
--     Recompute the content size of the specified resource,
--     disregarding the existing content size. Store it in the Size
--     element in the resource schema, and set the SizeAccurate flag
--     appropriately.
--
-- PARAMETERS -
--  abspath (IN)
--     Absolute path of the resource. If the path is a folder, then
--     use the recurse flag as below.
--  recurse (IN)
--     Used only if abspath specifies a folder. If true, refresh the
--     size of all resources in the resource tree rooted at the
--     specified resource. If false, compute the size of all
--     documents/subfolders in this folder only. 
-- RETURNS -
--     Nothing.
-----------------------------------------------------------
PROCEDURE refreshContentSize ( abspath IN VARCHAR2,
			       recurse IN BOOLEAN := FALSE );

-----------------------------------------------------------
-- PROCEDURE - ProcessLinks
--     Process document links in the specified resource,
--     looking at the current resource configuration parameters.
--
-- PARAMETERS -
--  abspath (IN)
--     Absolute path of the resource. If the path is a folder, then
--     use the recurse flag as below.
--  recurse (IN)
--     Used only if abspath specifies a folder. If true, process
--     links of all resources in the resource tree rooted at the
--     specified resource. If false, process links of all
--     documents in this folder only. 
-- RETURNS -
--     Nothing.
-----------------------------------------------------------
PROCEDURE ProcessLinks (abspath IN VARCHAR2,
                        recurse IN BOOLEAN := FALSE );

-----------------------------------------------------------
-- FUNCTION - isFolder
--
-- PARAMETERS -
--  abspath (IN)
--     Absolute path of the resource. 
-- RETURNS -
--     True if the resource is a folder / container.
-----------------------------------------------------------
FUNCTION isFolder ( 
        abspath IN VARCHAR2
) return BOOLEAN;

-----------------------------------------------------------
-- PROCEDURE - touchResource
--  Change the last mod time of the resource to the current time.
--
-- PARAMETERS -
--  abspath (IN)
--     Absolute path of the resource. 
-----------------------------------------------------------
PROCEDURE touchResource ( abspath IN VARCHAR2 );

-----------------------------------------------------------
-- PROCEDURE - changeOwner
--  Change the owner of the resource to the given user.
--
-- PARAMETERS -
--  abspath (IN)
--     Absolute path of the resource. 
--  owner (IN)
--     Owner
--  recurse (IN)
--     If true, recursively change owner of all resources in the
--     folder tree.
-----------------------------------------------------------
PROCEDURE changeOwner ( abspath IN VARCHAR2,
                        owner   IN VARCHAR2,
                        recurse IN BOOLEAN := FALSE );

-----------------------------------------------------------
-- FUNCTION - hascharcontent
--
-- PARAMETERS -
--  abspath (IN)
--     Absolute path of the resource. 
-- RETURNS -
--     True if the resource has character content.
-----------------------------------------------------------
function HASCHARCONTENT (
	abspath IN VARCHAR2
) return BOOLEAN;

-----------------------------------------------------------
-- FUNCTION - hasxmlcontent
--
-- PARAMETERS -
--  abspath (IN)
--     Absolute path of the resource. 
-- RETURNS -
--     True if the resource has xml content.
-----------------------------------------------------------
function HASXMLCONTENT (
	abspath IN VARCHAR2
) return BOOLEAN;

-----------------------------------------------------------
-- FUNCTION - hasxmlreference
--
-- PARAMETERS -
--  abspath (IN)
--     Absolute path of the resource. 
-- RETURNS -
--     True if the resource has a ref to xml content.
-----------------------------------------------------------
function HASXMLREFERENCE (
	abspath IN VARCHAR2
) return BOOLEAN;

-----------------------------------------------------------
-- FUNCTION - hasblobcontent
--
-- PARAMETERS -
--  abspath (IN)
--     Absolute path of the resource. 
-- RETURNS -
--     True if the resource has blob content.
-----------------------------------------------------------
function HASBLOBCONTENT (
	abspath IN VARCHAR2
) return BOOLEAN;

---------------------------------------------
-- FUNCTION - getContentClob
--    Returns the contents of the resource as a clob.
-- PARAMETERS - 
--    abspath - Absolute path of the resource
-- RETURNS -
--    The contents as CLOB.
---------------------------------------------
FUNCTION getContentClob(
	abspath IN VARCHAR2
) return CLOB;

---------------------------------------------
-- FUNCTION - getContentBlob
--    Returns the contents of the resource as a blob.
-- PARAMETERS - 
--    abspath - Absolute path of the resource.
--    csid - OUT - The character set id of the blob returned.
--    locksrc - if true, lock and return the source lob. If false,
--    return a temp lob copy.
-- RETURNS -
--    The contents as BLOB.
---------------------------------------------
FUNCTION getContentBlob ( 
	abspath IN VARCHAR2,
	csid OUT PLS_INTEGER,
	locksrc IN BOOLEAN := FALSE
) return BLOB;

---------------------------------------------
-- FUNCTION - getContentXMLType
--    Returns the contents of the resource as an XMLType.
-- PARAMETERS - 
--    abspath - Absolute path of the resource.
-- RETURNS -
--    The contents as XMLType.
---------------------------------------------
FUNCTION getContentXMLType ( 
	abspath IN VARCHAR2
) return SYS.XMLType;

---------------------------------------------
-- FUNCTION - getContentVarchar2
--    Returns the contents of the resource as an Varchar2.
-- PARAMETERS - 
--    abspath - Absolute path of the resource.
-- RETURNS -
--    The contents as Varchar2.
---------------------------------------------
FUNCTION getContentVarchar2 ( 
	abspath IN VARCHAR2
) return VARCHAR2;

---------------------------------------------
-- FUNCTION - getContentXMLRef
--    Returns the contents of the resource as a ref to an xmltype.
-- PARAMETERS - 
--    abspath - Absolute path of the resource.
-- RETURNS -
--    The contents as a ref to an xmltype if the resource is ref
--    based, else null.
---------------------------------------------
FUNCTION getContentXMLRef ( 
	abspath IN VARCHAR2
) return ref SYS.XMLType;


---------------------------------------------

---------------------------------------------
-- FUNCTION - getxdb_tablespace
--     Returns the current tablespace of xdb, on the assumption
--     that that is the tablespace of XDB.XDB$RESOURCE.
-- PARAMETERS - None.
--
-- NOTE: Currently used by DBMS_XDBT, which is AUTHID CURRENT_USER
--       package, so this API will not be moved to DBMS_XDB_ADMIN.
--       This API is useful if we envision having XDB's objects
--       span multiple tablespaces. Otherwise, DBA_USERS can be queried.
---------------------------------------------
FUNCTION getxdb_tablespace RETURN VARCHAR2;

end dbms_xdb_repos;
/
show errors;

CREATE OR REPLACE PUBLIC SYNONYM DBMS_XDB_REPOS FOR xdb.dbms_xdb_repos
/
GRANT EXECUTE ON xdb.dbms_xdb_repos TO PUBLIC
/
show errors;

@?/rdbms/admin/sqlsessend.sql
