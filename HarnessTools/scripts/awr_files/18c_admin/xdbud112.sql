Rem
Rem $Header: rdbms/admin/xdbud112.sql /main/6 2017/04/27 17:09:45 raeburns Exp $
Rem
Rem xdbud112.sql
Rem
Rem Copyright (c) 2013, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      xdbud112.sql - XDB Upgrade Dependent objects from release 11.2.0
Rem
Rem    DESCRIPTION
Rem     This script upgrades the XDB dependent objects from release 11.2.0
Rem     to the current release.  Content formerly in xdbu112.sql
Rem
Rem    NOTES
Rem     It is invoked by xdbud.sql, and invokes the xdbudNNN script for the 
Rem     subsequent release.
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/xdbud112.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/xdbud112.sql 
Rem    SQL_PHASE: UPGRADE 
Rem    SQL_STARTUP_MODE: UPGRADE 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/xdbud.sql 
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    04/15/17 - Bug Bug 25790192: Use UPGRADE for SQL_PHASE
Rem    qyu         07/25/16 - add file metadata
Rem    sriksure    07/20/16 - Bug 22967968 - Moving inline XML schemas to
Rem                           external schema files
Rem    yinlu       07/31/14 - bug 19338057: remove xdbxtbix.sql
Rem    raeburns    04/09/14 - fix comment
Rem    raeburns    02/02/14 - rename script
Rem    prthiaga    12/10/13 - backout realm changes
Rem    raeburns    10/25/13 - XDB upgrade restructure
Rem    dmelinge    10/02/13 - Realm changes, bug 17074378
Rem    hxzhang     01/22/13 - XbranchMerge hxzhang_bug-16092359_2 from
Rem                           st_rdbms_12.1.0.1
Rem    hxzhang     01/17/13 - remove servlet element, bug16092359
Rem    prthiaga    10/26/12 - LRG-7246788: not removing xmltr schema during upgrade
Rem    stirmizi    04/11/12 - remove xdblog, ftplog, httplog, xmltr schemas
Rem    stirmizi    04/11/12 - delete registration of XInclude.xsd, re-register
Rem                           csx.XInclude.xsd with genTables=false
Rem    dmelinge    02/03/12 - Remove unnecessary privileges on DOCUMENT_LINKS
Rem    thbaby      08/03/11 - add session-state-cache-param for EM Express
Rem    thbaby      07/21/11 - add white-list
Rem    vhosur      07/19/11 - Populate the dbfs virtual folder
Rem    swerthei    06/23/11 - add new servlets for Recovery Server
Rem    spetride    06/20/11 - add sys.getUserIdOnTarget
Rem    yxie        05/06/11 - add em express servlet
Rem    yxie        05/06/11 - Created

Rem ================================================================
Rem BEGIN XDB Dependent Object Upgrade from 11.2.0
Rem ================================================================

-- BEGIN moved from xdbu112.sql

--evlove the schema and remove servlet element
declare
     newsch   XMLSequenceType;
     urls     XDB$STRING_LIST_T;
     schowner XDB$STRING_LIST_T;
     sch      VARCHAR2(4000) :=
'<schema xmlns="http://www.w3.org/2001/XMLSchema"       
        targetNamespace="http://xmlns.oracle.com/xdb/XDBStandard"
        xmlns:xdb="http://xmlns.oracle.com/xdb"
        version="1.0" elementFormDefault="qualified">

  <element name = "LINK" xdb:SQLType="XDB_LINK_TYPE" xdb:SQLSchema="XDB" xdb:defaultTable="">
   <complexType>
    <sequence>
     <element name="ParentName">
       <simpleType>
         <restriction base = "string">
           <length value = "256"/>
         </restriction>
       </simpleType>
     </element>
     <element name="ChildName">
       <simpleType>
         <restriction base = "string">
           <length value = "1024"/>
         </restriction>
       </simpleType> 
     </element>
     <element name= "Name">
       <simpleType>
         <restriction base = "string">
           <length value = "256"/>
         </restriction>
       </simpleType>
     </element>
     <element name= "Flags">
       <simpleType>
         <restriction base = "base64Binary">
           <length value = "4"/>
         </restriction>
       </simpleType>
     </element>
     <element name="ParentOid">
       <simpleType>
         <restriction base = "base64Binary">
           <length value = "16"/>
         </restriction>
       </simpleType>
     </element>
     <element name="ChildOid">
       <simpleType>
         <restriction base = "base64Binary">
           <length value = "16"/>
         </restriction>
       </simpleType>
    </element>
    <element name="LinkType">
      <simpleType>
        <restriction base="string">
          <enumeration value="Hard"/>
          <enumeration value="Weak"/>
          <enumeration value="Symbolic"/>
        </restriction>
      </simpleType>
    </element>
    </sequence>
   </complexType>
  </element>

</schema>';

begin
     urls := XDB$STRING_LIST_T('http://xmlns.oracle.com/xdb/XDBStandard.xsd');
     newsch := XMLSequenceType(xmltype(sch)) ;
     schowner  := XDB$STRING_LIST_T('XDB');
     dbms_xmlschema.CopyEvolve(urls, newsch, NULL, FALSE, NULL,TRUE,
       FALSE, schowner);
end;
/

Rem ================================================================
Rem BEGIN resecure DOCUMENT_LINKS (view must be valid for revokes)
Rem ================================================================

Rem
Rem DOCUMENT_LINKS was incorrectly granted insert, update, and delete
Rem permissions for PUBLIC.  Revoke them.  Bug 13019222.
Rem

BEGIN
EXECUTE IMMEDIATE 'revoke insert on xdb.document_links from PUBLIC';
EXCEPTION
WHEN others THEN
  IF sqlcode = -1927 THEN NULL;
       -- suppress error if not found
  ELSE raise;
  END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'revoke update on xdb.document_links from PUBLIC';
EXCEPTION
WHEN others THEN
  IF sqlcode = -1927 THEN NULL;
       -- suppress error if not found
  ELSE raise;
  END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'revoke delete on xdb.document_links from PUBLIC';
EXCEPTION
WHEN others THEN
  IF sqlcode = -1927 THEN NULL;
       -- suppress error if not found
  ELSE raise;
  END IF;
END;
/
show errors;

Rem ================================================================
Rem END resecure DOCUMENT_LINKS
Rem ================================================================

Rem ================================================================
Rem BEGIN XDBCONFIG file upgrade
Rem ================================================================

Rem
Rem Add EM Express servlet and remove report framework servlet
Rem

declare
  cfg_data XMLTYPE;
  scount   NUMBER := 0;
begin
  cfg_data := dbms_xdb.cfg_get();

  -- Add EM Express servlet mapping
  SELECT existsNode(
                cfg_data,
                '/xdbconfig/sysconfig/protocolconfig/httpconfig/' ||
                'webappconfig/servletconfig/servlet-mappings/' ||
                'servlet-mapping[servlet-name=''EMExpressServlet'']')  
    INTO scount 
    FROM dual;

  IF (scount = 0) THEN
    SELECT appendchildxml(
                cfg_data, 
                '/xdbconfig/sysconfig/protocolconfig/httpconfig/' ||
                'webappconfig/servletconfig/servlet-mappings', 
                xmltype(
                  '<servlet-mapping xmlns="http://xmlns.oracle.com/xdb/xdbconfig.xsd">
                     <servlet-pattern>/em/*</servlet-pattern>
                     <servlet-name>EMExpressServlet</servlet-name>
                   </servlet-mapping>'))
      INTO cfg_data
      FROM dual;
  END IF;

  -- Add EM Express servlet
  SELECT existsNode(
                cfg_data,
                '/xdbconfig/sysconfig/protocolconfig/httpconfig/' ||
                'webappconfig/servletconfig/servlet-list/' ||
                'servlet[servlet-name=''EMExpressServlet'']')
    INTO scount 
    FROM dual;

  IF (scount = 0) THEN
    SELECT appendchildxml(
                cfg_data,
                '/xdbconfig/sysconfig/protocolconfig/httpconfig/' ||
                'webappconfig/servletconfig/servlet-list',
                xmltype(
                  '<servlet xmlns="http://xmlns.oracle.com/xdb/xdbconfig.xsd">
                     <servlet-name>EMExpressServlet</servlet-name>
                     <servlet-language>C</servlet-language>
                     <display-name>EM Express Servlet</display-name>
                     <description>Servlet for EM Express</description>
                     <session-state-cache-param>
                        <cache-size>128</cache-size>
                        <expiration-timeout>360000</expiration-timeout>
                     </session-state-cache-param>
                   </servlet>'))
      INTO cfg_data
      FROM dual;
  END IF;

  -- Delete report framework servlet mapping
  SELECT existsNode(
                cfg_data,
                '/xdbconfig/sysconfig/protocolconfig/httpconfig/' ||
                '/webappconfig/servletconfig/servlet-mappings/' ||
                'servlet-mapping[servlet-name=''ReportFmwkServlet'']')
    INTO scount 
    FROM dual;

  IF (scount = 1) THEN
    SELECT deleteXML(
                cfg_data,
                '/xdbconfig/sysconfig/protocolconfig/httpconfig/' ||
                'webappconfig/servletconfig/servlet-mappings/' ||
                'servlet-mapping[servlet-name=''ReportFmwkServlet'']')
      INTO cfg_data
      FROM dual; 
  END IF;

  -- Delete report framework servlet
  SELECT existsNode(
                cfg_data,
                '/xdbconfig/sysconfig/protocolconfig/httpconfig/' ||
                'webappconfig/servletconfig/servlet-list/' ||
                'servlet[servlet-name=''ReportFmwkServlet'']')
    INTO scount 
    FROM dual;

  IF (scount = 1) THEN
    SELECT deleteXML(
                cfg_data,
                '/xdbconfig/sysconfig/protocolconfig/httpconfig/' ||
                'webappconfig/servletconfig/servlet-list/' ||
                'servlet[servlet-name=''ReportFmwkServlet'']')
      INTO cfg_data
      FROM dual; 
  END IF;

  -- ORS servlet
  SELECT appendchildxml(
           cfg_data,
           '/xdbconfig/sysconfig/protocolconfig/httpconfig/webappconfig' ||
             '/servletconfig/servlet-mappings',
           xmltype(
            '<servlet-mapping xmlns="http://xmlns.oracle.com/xdb/xdbconfig.xsd">
               <servlet-pattern>/orssv/*</servlet-pattern>
               <servlet-name>ORSServlet</servlet-name>
             </servlet-mapping>'))
  INTO   cfg_data
  FROM   dual;

  SELECT appendchildxml(
           cfg_data,
           '/xdbconfig/sysconfig/protocolconfig/httpconfig/webappconfig' ||
             '/servletconfig/servlet-list',
           xmltype(
             '<servlet xmlns="http://xmlns.oracle.com/xdb/xdbconfig.xsd">
                <servlet-name>ORSServlet</servlet-name>
                <servlet-language>C</servlet-language>
                <display-name>ORS Servlet</display-name>
                <description>Servlet for accessing ORS</description>
                <security-role-ref>
                  <role-name>authenticatedUser</role-name>
                  <role-link>authenticatedUser</role-link>
                </security-role-ref>
              </servlet>'))
  INTO   cfg_data
  FROM   dual;

  -- update xdbconfig file
  dbms_xdb.cfg_update(cfg_data);

end;
/

COMMIT;

REM
REM Add white-list 
REM

declare
  cfg_data XMLTYPE;
  scount   NUMBER := 0;
begin
  cfg_data := dbms_xdb.cfg_get();

  SELECT existsNode(
                cfg_data,
                '/xdbconfig/sysconfig/protocolconfig/httpconfig/white-list')
    INTO scount 
    FROM dual;

  IF (scount = 0) THEN
    SELECT appendchildxml(
                cfg_data, 
                '/xdbconfig/sysconfig/protocolconfig/httpconfig',
                xmltype(
              '<white-list xmlns="http://xmlns.oracle.com/xdb/xdbconfig.xsd">
                 <white-list-pattern>/*</white-list-pattern>
               </white-list>'))
      INTO cfg_data
      FROM dual;
  END IF;

  -- update xdbconfig file
  dbms_xdb.cfg_update(cfg_data);

end;
/

COMMIT;

-- Remove OR version of XInclude.xsd
declare
 c NUMBER;
 xinurl VARCHAR2(2000) := 'http://www.w3.org/2001/XInclude.xsd';
begin
  select count(*) into c from xdb.xdb$schema s
   where s.xmldata.schema_url = xinurl;

  if c > 0 then
    dbms_xmlschema.deleteschema(xinurl, dbms_xmlschema.delete_cascade);
  end if;
  exception when others then null;
end;
/

-- First remove csx.XInclude.xsd and then re-register it with genTables false
declare
 c NUMBER;
 csxxinurl VARCHAR2(2000) := 'http://www.w3.org/2001/csx.XInclude.xsd';
begin
  select count(*) into c from xdb.xdb$schema s
   where s.xmldata.schema_url = csxxinurl;

  if c > 0 then
    dbms_xmlschema.deleteschema(csxxinurl, dbms_xmlschema.delete_cascade);
  end if;
  exception when others then null;
end;
/

declare
  c number;
  schema_exists EXCEPTION;
  PRAGMA EXCEPTION_INIT(schema_exists,-31085);
  XINCLUDEXSD BFILE := dbms_metadata_hack.get_bfile('xinclude.xsd.12.1');

  CSX_XINCLUDEURL VARCHAR2(2000) := 'http://www.w3.org/2001/csx.XInclude.xsd';

begin

select count(*) into c from xdb.xdb$schema s
where s.xmldata.schema_url = CSX_XINCLUDEURL;

dbms_metadata_hack.cre_dir();
if c = 0 then
  xdb.dbms_xmlschema.registerSchema(CSX_XINCLUDEURL, XINCLUDEXSD, FALSE, FALSE, FALSE, FALSE, FALSE, 'XDB', options=>DBMS_XMLSCHEMA.REGISTER_BINARYXML);
end if;

exception
  when schema_exists then
    NULL;
end;
/

COMMIT;

Rem ================================================================
Rem END XDBCONFIG file upgrade
Rem ================================================================

-- Drop all indexes on xdb.xdb$acl (xdb$acl_xidx uses XMLIndex)
begin
  execute immediate 'drop index xdb.xdb$acl_spidx';
  commit;
  exception
     when others then
          null;
end;
/

begin
  execute immediate 'drop index xdb.xdb$acl_xidx force';
  commit;
  exception
     when others then
          null;
end;
/

begin
  execute immediate 'drop package xdb.xdb$acl_pkg_int';
  commit;
  exception 
     when others then
          null;
end;
/

declare
ret boolean;
dbfs_path varchar2(1000) := NULL;
tab_path varchar2(1000);
insertrow boolean := TRUE;
num_entries NUMBER :=0;
begin
  -- See if we have a entry in the table for vf 
  select count(*) into num_entries from xdb.xdb$dbfs_virtual_folder where hidden_def = 1;
  if num_entries <> 0 then
    insertrow := FALSE;
    select mount_path into tab_path from xdb.xdb$dbfs_virtual_folder where hidden_def = 1;
  end if;
  -- We will not insert a new row if one already exists. Instead we will create a folder
  -- same as the entry in the table. 
  if insertrow = FALSE then
    if dbms_xdb.existsResource(tab_path) = FALSE then
       ret := xdb.dbms_xdbutil_int.createSystemVirtualFolder(tab_path);
       if ret then
         dbms_xdb.setacl(tab_path, '/sys/acls/all_all_acl.xml');
       end if;
    end if;
  else
    if dbms_xdb.existsResource( '/dbfs' ) = FALSE then
     dbfs_path := '/dbfs';
    end if;
  end if;
  -- Create the folder if we have identified the path
  if dbfs_path IS NOT NULL then
    ret := xdb.dbms_xdbutil_int.createSystemVirtualFolder(dbfs_path);
    if ret then
      dbms_xdb.setacl(dbfs_path, '/sys/acls/all_all_acl.xml');
    end if;
    if insertrow = TRUE then 
      begin
       execute immediate 'insert into XDB.XDB$DBFS_VIRTUAL_FOLDER values (1, :1)' using dbfs_path;
      exception
       when others then raise;
      end;   
    end if;  
  end if; 
  
end;
/
commit;

-- Remove standard schemas (catxdbst.sql)
declare
 c      NUMBER;
 XLURL  VARCHAR2(2000) := 'http://xmlns.oracle.com/xdb/log/xdblog.xsd';
begin
  select count(*) into c from xdb.xdb$schema s
   where s.xmldata.schema_url = XLURL;

  if c > 0 then
    dbms_xmlschema.deleteschema(XLURL, dbms_xmlschema.delete_cascade);
  end if;
  exception when others then null;
end;
/

declare
 c     NUMBER;
 FLURL VARCHAR2(2000) := 'http://xmlns.oracle.com/xdb/log/ftplog.xsd';
begin
  select count(*) into c from xdb.xdb$schema s
   where s.xmldata.schema_url = FLURL;

  if c > 0 then
    dbms_xmlschema.deleteschema(FLURL, dbms_xmlschema.delete_cascade);
  end if;
  exception when others then null;
end;
/

declare
 c     NUMBER;
 HLURL VARCHAR2(2000) := 'http://xmlns.oracle.com/xdb/log/httplog.xsd';
begin
  select count(*) into c from xdb.xdb$schema s
   where s.xmldata.schema_url = HLURL;

  if c > 0 then
    dbms_xmlschema.deleteschema(HLURL, dbms_xmlschema.delete_cascade);
  end if;
  exception when others then null;
end;
/

-- END moved from xdbu112.sql

Rem ================================================================
Rem END XDB Dependent Object Upgrade from 11.2.0
Rem ================================================================

Rem ================================================================
Rem BEGIN XDB Dependent Object Upgrade from the next release
Rem ================================================================

@@xdbud121.sql
