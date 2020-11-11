Rem
Rem $Header: rdbms/admin/xse112.sql /main/11 2017/05/28 22:46:14 stanaya Exp $
Rem
Rem xse112.sql
Rem
Rem Copyright (c) 2008, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      xse112.sql - XS downgrade to 11.2
Rem
Rem    DESCRIPTION
Rem      This script downgrades XS from the current release to 11.2
Rem
Rem    NOTES
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/xse112.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/xse112.sql
Rem    SQL_PHASE: DOWNGRADE
Rem    SQL_STARTUP_MODE: UPGRADE
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    04/11/17 - Bug 25790192: Add SQL_METADATA
Rem    yiru        07/26/16 - Fix bug 24322880:Add downgrade status
Rem    minx        03/01/12 - Add xs objects downgrade to 11.2
Rem    rpang       02/21/12 - Network ACL Triton upgrade
Rem    minx        02/02/12 - Drop package xs_object_migration
Rem    yiru        12/21/11 - Add downgrade to 11.2
Rem    yiru        02/08/11 - Cleanup
Rem    rbhatti     01/19/11 - Drop package DBMS_XS_SIDP
Rem    snadhika    08/26/10 - Drop types,views,public synonyms created 
Rem                           for Triton session enchancement
Rem    yiru        05/21/10 - Drop6R cleanup before mergedown
Rem    rbhatti     12/05/08 - Drop new roles and sessions views
Rem    rbhatti     11/27/08 - Remove roleset views
Rem    taahmed     11/24/08 - sec class view name clnup
Rem    srtata      11/21/08 - fix nsviews for consistency
Rem    snadhika    11/05/08 - drop public synonyms for views on
Rem                           xs$principal table
Rem    taahmed     11/03/08 - sec class view name downgrade
Rem    snadhika    10/31/08 - Fix lrg 3529435
Rem    srtata      10/20/08 - renamed ns template views
Rem    snadhika    09/11/08 - Drop structured xmlindex on security class
Rem    srtata      08/28/08 - Add NStemplate security class and change
Rem                           principal security class
Rem    snadhika    06/17/08 - Drop namespace template views
Rem    snadhika    06/02/08 - drop repository events, drop event package 
Rem                           library DBMS_XSNST_LIB
Rem    snadhika    04/29/08 - delete xsbypass role, drop weak auth package 
Rem    jnarasin    06/02/08 - Admin security class
Rem    snadhika    05/06/08 - Structured xmlindex 
Rem    srtata      04/28/08 - delete namespace template schema
Rem    yiru        03/13/08 - downgrade script for XS project branch
Rem    yiru        03/13/08 - Created
Rem

Rem ===================================================================
Rem BEGIN XS Downgrade from Current Release to 11.2
Rem ===================================================================
execute sys.dbms_registry.set_progress_value('XDB','XS STATUS','DOWNGRADE TO 11.2 IN PROGRESS');

Rem Create resources if they do not exist
DECLARE
  result BOOLEAN;
BEGIN
  if (NOT DBMS_XDB.existsResource('/sys/xs')) then
    result := dbms_xdb.createFolder('/sys/xs');
  end if;  
  if (NOT DBMS_XDB.existsResource('/sys/xs/roles')) then
    result := dbms_xdb.createFolder('/sys/xs/roles');
  end if;
  if (NOT DBMS_XDB.existsResource('/sys/xs/users')) then
    result := dbms_xdb.createFolder('/sys/xs/users');
  end if;
    if (NOT DBMS_XDB.existsResource('/sys/xs/securityclasses')) then
    result := dbms_xdb.createFolder('/sys/xs/securityclasses');
  end if;
exception
  when others then
  NULL;
END;
/

-- need this package to load the schema inforamtion from flat files.
-- First create a directory (db) to load the docs. Load Schemas then
-- drop the package after
@@catxdbh

exec dbms_metadata_hack.cre_dir;
exec dbms_metadata_hack.cre_xml_dir;

-- Register new schema
Rem Register Data Security Documents schema
declare
  DSDXSD BFILE := dbms_metadata_hack.get_bfile('xsdatasec.xsd.11.1');
  DSDURL  varchar2(100) := 'http://xmlns.oracle.com/xs/dataSecurity.xsd';

begin
  dbms_xmlschema.registerSchema(
    schemaurl => DSDURL, 
    schemadoc => DSDXSD, 
    local     => FALSE,
    GENTYPES  => FALSE,
    GENTABLES => TRUE,
    owner     => 'XDB',
    options   => DBMS_XMLSCHEMA.REGISTER_BINARYXML);
exception
  when others then
  NULL;
end;
/

Rem Register sys_acloid column schema
declare
  AIDXSD  BFILE := dbms_metadata_hack.get_bfile('xsaclids.xsd');
  AIDURL  varchar2(100) := 'http://xmlns.oracle.com/xs/aclids.xsd';

begin
  xdb.dbms_xmlschema.registerSchema(AIDURL, AIDXSD, FALSE, FALSE, FALSE, FALSE,
                                    FALSE, 'XDB');
exception
  when others then
  NULL;
end;
/

declare
  SECLASSXSD BFILE := dbms_metadata_hack.get_bfile('xsseccls.xsd.11.1');
  SECLASSURL  varchar2(100) := 'http://xmlns.oracle.com/xs/securityclass.xsd';

BEGIN
  DBMS_XMLSCHEMA.registerSchema(
    schemaurl => SECLASSURL,
    schemadoc =>  SECLASSXSD,
    owner =>'XDB',
    local => FALSE,
    options => DBMS_XMLSCHEMA.REGISTER_BINARYXML,
    GENTYPES => FALSE, 
    GENTABLES => TRUE);
EXCEPTION
  when others then
  NULL;
END;
/

Rem Register principal schema
declare
  PRINCIPALXSD BFILE := dbms_metadata_hack.get_bfile('xsprin.xsd.11.1');
  DSDURL  varchar2(100) := 'http://xmlns.oracle.com/xs/principal.xsd';

begin
  dbms_xmlschema.registerSchema(DSDURL, PRINCIPALXSD,
                                owner=>'XDB',
                                local=>FALSE,
                                GENTYPES=>FALSE,
                                GENTABLES=>FALSE,
                                OPTIONS=>DBMS_XMLSCHEMA.REGISTER_BINARYXML);
exception
  when others then
  NULL;
end;
/

DECLARE
  b BOOLEAN;
BEGIN
  b := DBMS_XDB.createResource(
         '/sys/xs/securityclasses/securityclass.xml', 
         '<securityClass xmlns="http://xmlns.oracle.com/xs"
               xmlns:dav="DAV:"
               xmlns:xdb="http://xmlns.oracle.com/xdb"
               xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://xmlns.oracle.com/xs http://xmlns.oracle.com/xs/securityclass.xsd" 
targetNamespace="http://xmlns.oracle.com/xs"
               name="securityclass">
    <title>
        SecurityClass
    </title>
    <inherits-from>dav:dav</inherits-from>
    <privilege name="extend">
        <title>
            extend
        </title>
    </privilege>
</securityClass>');
EXCEPTION
  when others then
  NULL;
END;
/

-- Base privileges in XDB namespace
DECLARE
  b BOOLEAN;
BEGIN
  b := DBMS_XDB.createResource(
         '/sys/xs/securityclasses/baseSystemPrivileges.xml', 
         '<securityClass xmlns="http://xmlns.oracle.com/xs"
               xmlns:xdb="http://xmlns.oracle.com/xdb/acl.xsd"
               xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://xmlns.oracle.com/xs http://xmlns.oracle.com/xs/securityclass.xsd" 
targetNamespace="http://xmlns.oracle.com/xdb/acl.xsd"
               name="baseSystemPrivileges">
  <title>
     Base System Privileges
  </title>

  <privilege name = "read-properties"/>
  <privilege name = "read-contents"/>
  <privilege name = "write-config"/>
  <privilege name = "link"/>
  <privilege name = "unlink"/>
  <privilege name = "read-acl"/>
  <privilege name = "write-acl-ref"/>
  <privilege name = "update-acl"/>
  <privilege name = "resolve"/>
  <privilege name = "link-to"/>
  <privilege name = "unlink-from"/>
</securityClass>');
EXCEPTION
  when others then
  NULL;
END;
/

-- Base privileges in DAV namespace
DECLARE
  b BOOLEAN;
BEGIN
  b := DBMS_XDB.createResource(
         '/sys/xs/securityclasses/baseDavPrivileges.xml', 
         '<securityClass xmlns="http://xmlns.oracle.com/xs"
               xmlns:dav="DAV:"
               xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://xmlns.oracle.com/xs http://xmlns.oracle.com/xs/securityclass.xsd" 
targetNamespace="DAV:"
               name="baseDav">
    <title>
       Base DAV Privileges
    </title>

    <privilege name = "lock"/> 
    <privilege name = "unlock"/> 
    <privilege name = "write-properties"/> 
    <privilege name = "write-content"/> 
    <privilege name = "execute"/> 
    <privilege name = "take-ownership"/> 
    <privilege name = "read-current-user-privilege-set"/> 
</securityClass>');
EXCEPTION
  when others then
  NULL;
END;
/

DECLARE
  b BOOLEAN;
BEGIN
  b := DBMS_XDB.createResource(
         '/sys/xs/securityclasses/systemPrivileges.xml', 
         '<securityClass xmlns="http://xmlns.oracle.com/xs"
               xmlns:dav="DAV:"
               xmlns:xdb="http://xmlns.oracle.com/xdb/acl.xsd"
               xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://xmlns.oracle.com/xs http://xmlns.oracle.com/xs/securityclass.xsd" 
targetNamespace="http://xmlns.oracle.com/xdb/acl.xsd"
               name="systemPrivileges"
               mutable="false">

  <title>
     System Privileges
  </title>

  <inherits-from>xdb:baseSystemPrivileges</inherits-from>
  <inherits-from>dav:baseDav</inherits-from>

  <aggregatePrivilege name="update">
     <privilegeRef name="dav:write-properties"/>
     <privilegeRef name="dav:write-content"/>
  </aggregatePrivilege>

  <aggregatePrivilege name="all">
    <privilegeRef name = "xdb:read-properties"/>
    <privilegeRef name = "xdb:read-contents"/>
    <privilegeRef name = "xdb:write-config"/>
    <privilegeRef name = "xdb:link"/>
    <privilegeRef name = "xdb:unlink"/>
    <privilegeRef name = "xdb:read-acl"/>
    <privilegeRef name = "xdb:write-acl-ref"/>
    <privilegeRef name = "xdb:update-acl"/>
    <privilegeRef name = "xdb:resolve"/>
    <privilegeRef name = "xdb:link-to"/>
    <privilegeRef name = "xdb:unlink-from"/>
    <privilegeRef name = "dav:lock"/> 
    <privilegeRef name = "dav:unlock"/> 
    <privilegeRef name = "dav:write-properties"/> 
    <privilegeRef name = "dav:write-content"/> 
    <privilegeRef name = "dav:execute"/> 
    <privilegeRef name = "dav:take-ownership"/> 
    <privilegeRef name = "dav:read-current-user-privilege-set"/> 
  </aggregatePrivilege>
</securityClass>');
EXCEPTION
  when others then
  NULL;
END;
/


Rem DAV::dav security class
declare
tmp boolean := false;
DAVXML BFILE := dbms_metadata_hack.get_xml_bfile('dav.xml.11.1');
DAVXSD XMLTYPE := XMLTYPE(DAVXML, 0);
begin
  tmp := DBMS_XDB.CreateResource('/sys/xs/securityclasses/dav.xml',DAVXSD);
EXCEPTION
  when others then
  NULL;
end;
/

declare
  tmp boolean;
begin
  tmp := DBMS_XDB.CreateResource('/sys/xs/securityclasses/principalsc.xml',
'<securityClass xmlns="http://xmlns.oracle.com/xs"
   xmlns:dav="DAV:"
   xmlns:xdb="http://xmlns.oracle.com/xdb/acl.xsd"
   xmlns:sxs="http://xmlns.oracle.com/xs"
   xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
   xsi:schemaLocation="http://xmlns.oracle.com/xs http://xmlns.oracle.com/xs/securityclass.xsd" 
  targetNamespace="http://xmlns.oracle.com/xs"
  name="PrincipalSecurityClass"
  mutable="false">
  <title>PrincipalSecurityClass</title> 
  <inherits-from>dav:dav</inherits-from>
  <privilege name="createUser" /> 
  <privilege name="proxyTo" /> 
  <privilege name="createRole" /> 
  <privilege name="enable" /> 
  <privilege name="addtoSet" />
  <privilege name="createRoleSet"/>
  <aggregatePrivilege name="viewUser">
    <privilegeRef name="xdb:read-contents" /> 
    <privilegeRef name="xdb:resolve" />
  </aggregatePrivilege>
  <aggregatePrivilege name="grant">
    <privilegeRef name="xdb:link-to" /> 
    <privilegeRef name="xdb:unlink-from" /> 
    <privilegeRef name="xdb:read-contents" /> 
    <privilegeRef name="xdb:resolve" />
  </aggregatePrivilege>
  <aggregatePrivilege name="grantTo">
    <privilegeRef name="xdb:link" /> 
    <privilegeRef name="xdb:unlink" /> 
    <privilegeRef name="xdb:update" /> 
    <privilegeRef name="xdb:read-contents" /> 
  </aggregatePrivilege>
  <aggregatePrivilege name="viewRole">
    <privilegeRef name="xdb:read-contents" /> 
    <privilegeRef name="xdb:resolve" />
  </aggregatePrivilege>
  <aggregatePrivilege name="viewRoleset">
    <privilegeRef name="xdb:read-contents" /> 
  </aggregatePrivilege>
  <aggregatePrivilege name="admin">
    <privilegeRef name="xdb:read-properties" /> 
    <privilegeRef name="xdb:read-contents" /> 
    <privilegeRef name="xdb:update" /> 
    <privilegeRef name="xdb:link" /> 
    <privilegeRef name="xdb:unlink" /> 
    <privilegeRef name="xdb:link-to" /> 
    <privilegeRef name="xdb:unlink-from" /> 
    <privilegeRef name="xdb:read-acl" /> 
    <privilegeRef name="xdb:write-acl-ref" /> 
    <privilegeRef name="xdb:update-acl" /> 
    <privilegeRef name="xdb:resolve" /> 
  </aggregatePrivilege>
<privilege name = "createSession">
    <title>
      Create a Light Weight User Session
    </title>
  </privilege>
  <privilege name="termSession">
    <title>
      Terminate a Light Weight User Session
    </title>
  </privilege>

  <aggregatePrivilege name="createTermSession">
    <privilegeRef name="sxs:createSession" /> 
    <privilegeRef name="sxs:termSession" /> 
  </aggregatePrivilege>

  <privilege name="attachToSession">
    <title>
      Attach to a Light Weight User Session
    </title>
  </privilege>
  <privilege name="modifySession">
    <title>
      Modify contents of a Light Weight User Session
    </title>
  </privilege>
  <privilege name="switchUser">
    <title>
      Switch User of a Light Weight User Session
    </title>
  </privilege>
  <privilege name="assignUser">
    <title>
      Assign User to an anonymous Light Weight User Session
    </title>
  </privilege>

  <privilege name = "changeUserPassword">
    <title>
        Change Password for users in Fusion Database.
    </title>
  </privilege>

  <privilege name="administerNamespace">
    <title>
      Create/Delete/Change properties of Namespaces.
    </title>
  </privilege>
  <aggregatePrivilege name="administerSession">
    <privilegeRef name="sxs:createTermSession" /> 
    <privilegeRef name="sxs:attachToSession" /> 
    <privilegeRef name="sxs:modifySession" /> 
    <privilegeRef name="sxs:switchUser" /> 
    <privilegeRef name="sxs:assignUser" /> 
    <privilegeRef name="sxs:administerNamespace" /> 
  </aggregatePrivilege>

  <privilege name="setAttribute">
    <title>
      Set a Light Weight User Session Attribute
    </title>
  </privilege>
  <privilege name="readAttribute">
    <title>
      Read value of a Light Weight User Session Attribute
    </title>
  </privilege>

  <aggregatePrivilege name="administerAttributes">
    <privilegeRef name="sxs:setAttribute" /> 
    <privilegeRef name="sxs:readAttribute" /> 
  </aggregatePrivilege>

  </securityClass>');
EXCEPTION
  when others then
  NULL;
end;
/

-- Create new xs$principals table
create table XDB.XS$PRINCIPALS of XMLType XMLType xmlschema "http://xmlns.oracle.com/xs/principal.xsd" element "principal" ;


declare
  ROLESETXSD BFILE := dbms_metadata_hack.get_bfile('xsroleset.xsd');
  ROLESETURL  varchar2(100) := 'http://xmlns.oracle.com/xs/roleset.xsd';

begin
dbms_xmlschema.registerSchema(ROLESETURL, ROLESETXSD,
                                owner=>'XDB',
                                local=>FALSE,
                                GENTYPES=>FALSE,
                                GENTABLES=>TRUE,
                                options => DBMS_XMLSCHEMA.REGISTER_BINARYXML);
exception
  when others then
  NULL;
end; 
/


Rem Add the xspublic role - uid set to KUSRMAX+999
declare
tmp boolean := false;
XSPUBLICXML BFILE := dbms_metadata_hack.get_xml_bfile('xspublic.xml.11.1');
XSPUBLICXSD XMLTYPE := XMLTYPE(XSPUBLICXML, 0);
begin
  tmp := DBMS_XDB.CreateResource('/sys/xs/roles/xspublic.xml',XSPUBLICXSD);
exception
  when others then
  NULL;
end;
/

Rem Add the xsguest user - uid set to KUSRMAX+998
declare
tmp boolean := false;
XSGUESTXML BFILE := dbms_metadata_hack.get_xml_bfile('xsguest.xml.11.1');
XSGUESTXSD XMLTYPE := XMLTYPE(XSGUESTXML, 0);
begin
  tmp := DBMS_XDB.CreateResource('/sys/xs/users/xsguest.xml',XSGUESTXSD);
exception
  when others then
  NULL;
end;
/

Rem Add the xsauthenticated role - uid set to KUSRMAX+997
declare
tmp boolean := false;
XSAUTHXML BFILE := dbms_metadata_hack.get_xml_bfile('xsauthenticated.xml.11.1');
XSAUTHXSD XMLTYPE := XMLTYPE(XSAUTHXML, 0);
begin
  tmp := DBMS_XDB.CreateResource('/sys/xs/roles/xsauthenticated.xml',XSAUTHXSD);
exception
  when others then
  NULL;
end;
/

Rem Add the dbms_auth role - uid set to KUSRMAX+996
declare
tmp boolean := false;
XSAUTHXML BFILE := dbms_metadata_hack.get_xml_bfile('dbms_auth.xml.11.1');
XSAUTHXSD XMLTYPE := XMLTYPE(XSAUTHXML, 0);
begin
  tmp := DBMS_XDB.CreateResource('/sys/xs/roles/dbms_auth.xml',XSAUTHXSD);
exception
  when others then
  NULL;
end;
/

Rem Add the dbms_passwd role - uid set to KUSRMAX+995
declare
tmp boolean := false;
XSAUTHXML BFILE := dbms_metadata_hack.get_xml_bfile('dbms_passwd.xml.11.1');
XSAUTHXSD XMLTYPE := XMLTYPE(XSAUTHXML, 0);
begin
  tmp := DBMS_XDB.CreateResource('/sys/xs/roles/dbms_passwd.xml',XSAUTHXSD);
exception
  when others then
  NULL;
end;
/

Rem Add the midtier_auth role - uid set to KUSRMAX+994
declare
tmp boolean := false;
XSAUTHXML BFILE := dbms_metadata_hack.get_xml_bfile('midtier_auth.xml.11.1');
XSAUTHXSD XMLTYPE := XMLTYPE(XSAUTHXML, 0);
begin
  tmp := DBMS_XDB.CreateResource('/sys/xs/roles/midtier_auth.xml',XSAUTHXSD);
exception
  when others then
  NULL;
end;
/

-- end of dbms_metadata_hack use drop the package
exec dbms_metadata_hack.drop_dir;

drop package dbms_metadata_hack;

-- load XS_OBJ_MIGRATION Package
@@prvtconsacl.plb

-- Downgrade Triton network ACLs to XDB before dropping xs_object_migration
@@nacle112.sql

Rem ===================================================================
Rem END XS Downgrade from Current Release to 11.2
Rem ===================================================================
-- XS$CACHE_ACTIONS used by Mid-Tier Cache
create table XDB.XS$CACHE_ACTIONS
  (
   ROW_KEY NUMBER(1) UNIQUE,
   TIME_VAL TIMESTAMP(9) NOT NULL
  );
comment on table XDB.XS$CACHE_ACTIONS is
'Timestamps used for Mid-Tier-Cache object invalidation'
/
comment on column XDB.XS$CACHE_ACTIONS.ROW_KEY is
'Type of the TimeStamp value.'
/
comment on column XDB.XS$CACHE_ACTIONS.TIME_VAL is
'Timestamp associated with this key'
/

-- create or replace public synonym XS$CACHE_ACTIONS for XDB.XS$CACHE_ACTIONS;

Rem add seed values for this table
insert into XDB.XS$CACHE_ACTIONS(ROW_KEY, TIME_VAL) values (1, systimestamp);
insert into XDB.XS$CACHE_ACTIONS(ROW_KEY, TIME_VAL) values (2, systimestamp);
insert into XDB.XS$CACHE_ACTIONS(ROW_KEY, TIME_VAL) values (3, systimestamp);
insert into XDB.XS$CACHE_ACTIONS(ROW_KEY, TIME_VAL) values (4, systimestamp);
insert into XDB.XS$CACHE_ACTIONS(ROW_KEY, TIME_VAL) values (5, systimestamp);
insert into XDB.XS$CACHE_ACTIONS(ROW_KEY, TIME_VAL) values (6, systimestamp);
-- The frasec field is used as retension  time. Set to 1 week 
-- Fix bug 7331368
insert into XDB.XS$CACHE_ACTIONS(ROW_KEY, TIME_VAL) 
                         values (9, TIMESTAMP '2007-10-04 13:02:43.000010080');

Rem now create the Delete table
Rem OBJ_TYPE  will reflect one of the above values
Rem check kzxh.h, KZXHACLMOD, etc for ObJ_TYPE values
create table XDB.XS$CACHE_DELETE
  (
   OBJ_TYPE   NUMBER(2),
   ID NUMBER,
   DEL_DATE TIMESTAMP NOT NULL
  );
comment on table XDB.XS$CACHE_DELETE is
'Table to retain deleted ACLOIDs, SecurityClasses, roles etc'
/
comment on column XDB.XS$CACHE_DELETE.OBJ_TYPE is
'Column to store type of the object deleted'
/
comment on column XDB.XS$CACHE_DELETE.ID is
'Column to store deleted ID'
/
comment on column XDB.XS$CACHE_DELETE.DEL_DATE is
'Column to store the dates of the deleted objects'
/

--Drop XS object migration package
drop public synonym xs_object_migration;
drop package  xs_object_migration;

execute sys.dbms_registry.set_progress_value('XDB','XS STATUS','DOWNGRADE TO 11.2 COMPLETED');
Rem ===================================================================
Rem END XS Downgrade from Current Release to 11.2
Rem ===================================================================



