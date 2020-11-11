Rem
Rem $Header: rdbms/admin/catxdbst.sql /main/32 2016/10/06 14:55:25 hxzhang Exp $
Rem
Rem catxdbstd.sql
Rem
Rem Copyright (c) 2001, 2016, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catxdbstd.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catxdbst.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catxdbst.sql
Rem SQL_PHASE: CATXDBST
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catqm_int.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    hxzhang     09/22/16 - bug#24618516, 24706168, move folderlisting to
Rem                           catxdbeo.sql, so it will be called during reload
Rem    sriksure    07/20/16 - Bug 22967968 - Moving inline XML schemas to
Rem                           external schema files
Rem    huiz        12/12/14 - bug# 18857697: annotate XDBFolderListing.xsd 
Rem    hxzhang     05/13/14 - annotate XDBFolderListing.xsd 
Rem    surman      01/23/14 - 13922626: Update SQL metadata
Rem    qyu         03/18/13 - Common start and end scripts
Rem    hxzhang     01/22/13 - XbranchMerge hxzhang_bug-16092359_2 from
Rem                           st_rdbms_12.1.0.1
Rem    hxzhang     01/15/13 - remove servlet element
Rem    prthiaga    10/26/12 - LRG-7246788: Adding support for xmltr schema
Rem    stirmizi    03/01/12 - remove xdblog, ftplog, httplog, xmltr schemas
Rem    vhosur      07/19/11 - Support for dbfs virtual folder
Rem    badeoti     03/20/09 - remove public synonyms for XDB internal packages
Rem    spetride    10/22/08 - add app users and groups virtual folders
Rem    rmurthy     01/17/05 - add path for symbolic links 
Rem    rmurthy     01/10/05 - add link type 
Rem    bkhaladk    04/24/06 - add clob version of xmltr.xsd 
Rem    thbaby      08/30/05 - add version virtual folder
Rem    thbaby      04/21/05 - 
Rem    pnath       12/01/04 - prvtxdb.sql needs prvtxmld.sql to be compiled 
Rem    rmurthy     10/29/03 - enable asm folder 
Rem    rmurthy     08/28/03 - uncomment oid folder 
Rem    sichandr    04/06/03 - add folder listing schema
Rem    spannala    12/19/02 - fixing bug#2702653
Rem    rmurthy     01/13/03 - create OSM virtual folder
Rem    rmurthy     10/07/02 - create system virtual folders
Rem    rmurthy     03/26/02 - add XML Namespace schema
Rem    rmurthy     12/28/01 - set elementForm to qualified
Rem    rmurthy     12/17/01 - TEMP: change dateTime to date
Rem    rmurthy     12/17/01 - fix schemas
Rem    spannala    12/27/01 - xdb setup should run as sys
Rem    tsingh      11/26/01 - use .plb for prvtxmld, prvtxmlp, prvtxslp
Rem    nagarwal    11/05/01 - correct names for path view
Rem    nagarwal    10/31/01 - move path view schema def into standard
Rem    sidicula    10/02/01 - XDB Logging
Rem    nmontoya    08/30/01 - ADD pl/sql dom, xml parser, AND xsl processor
Rem    rmurthy     09/03/01 - change XDB namespace
Rem    esedlar     08/13/01 - Merged esedlar_http
Rem    esedlar     08/09/01 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

declare
 STDURL VARCHAR2(2000) := 'http://xmlns.oracle.com/xdb/XDBStandard.xsd';  
 STDXSD BFILE := dbms_metadata_hack.get_bfile('xdbstandard.xsd.12.1');

begin
dbms_metadata_hack.cre_dir();
xdb.dbms_xmlschema.registerSchema(STDURL, STDXSD, FALSE, TRUE, FALSE, TRUE, FALSE, 'XDB');
end;
/


Rem Register XML Namespace schema 
declare
  XMLNSXSD BFILE := dbms_metadata_hack.get_bfile('xmlns.xsd');
  XMLNSURL VARCHAR2(2000) := 'http://www.w3.org/2001/xml.xsd';

begin
  xdb.dbms_xmlschema.registerSchema(XMLNSURL, XMLNSXSD, FALSE, TRUE, FALSE, TRUE,
                                  FALSE, 'XDB');
end;
/

declare
  TRXSD BFILE := dbms_metadata_hack.get_bfile('xmltr.xsd.11.0');
  TRURL VARCHAR2(2000) := 'http://xmlns.oracle.com/xdb/xmltr.xsd';  
begin
  xdb.dbms_xmlschema.registerSchema(TRURL, TRXSD, FALSE, FALSE, FALSE, FALSE,
                                            FALSE, 'XDB');
end;
/

--create OID virtual folder 
declare
ret boolean;
begin
  ret := xdb.dbms_xdbutil_int.createSystemVirtualFolder('/sys/oid');
  if ret then
    dbms_xdb.setacl('/sys/oid', '/sys/acls/bootstrap_acl.xml');
  end if;
end;
/
commit;

-- Create the folder /sys/apps
DECLARE
  retval BOOLEAN;
BEGIN
  retval := DBMS_XDB.CREATEFOLDER('/sys/apps');
  IF retval THEN
   DBMS_XDB.SETACL('/sys/apps', '/sys/acls/bootstrap_acl.xml');
  END IF;
END;
/
commit;

Rem create ASM virtual folder
declare
ret boolean;
begin
 ret := xdb.dbms_xdbutil_int.createSystemVirtualFolder('/sys/asm');
 if ret then
   dbms_xdb.setACL('/sys/asm', '/sys/acls/all_owner_acl.xml');
 end if;
end;
/
commit;

Rem create all folders associated with users and groups
declare
ret boolean;
begin
  ret := dbms_xdb.createFolder('/sys/principals');
  if ret then
    dbms_xdb.setACL('/sys/principals', '/sys/acls/bootstrap_acl.xml');
  end if;

  ret := dbms_xdb.createFolder('/sys/principals/users');
  if ret then
    dbms_xdb.setACL('/sys/principals/users', '/sys/acls/bootstrap_acl.xml');
  end if;

  ret := dbms_xdb.createFolder('/sys/principals/groups');
  if ret then
    dbms_xdb.setACL('/sys/principals/groups', '/sys/acls/bootstrap_acl.xml');
  end if;

  ret := 
    xdb.dbms_xdbutil_int.createSystemVirtualFolder('/sys/principals/users/db');
  if ret then
    dbms_xdb.setACL('/sys/principals/users/db', '/sys/acls/bootstrap_acl.xml');
  end if;

  ret := 
    xdb.dbms_xdbutil_int.createSystemVirtualFolder('/sys/principals/users/ldap');
  if ret then
    dbms_xdb.setACL('/sys/principals/users/ldap', 
                    '/sys/acls/bootstrap_acl.xml');
  end if;

  ret := 
    xdb.dbms_xdbutil_int.createSystemVirtualFolder('/sys/principals/users/application');
  if ret then
    dbms_xdb.setACL('/sys/principals/users/application', 
                    '/sys/acls/bootstrap_acl.xml');
  end if;

  ret := 
    xdb.dbms_xdbutil_int.createSystemVirtualFolder('/sys/principals/groups/db');
  if ret then
    dbms_xdb.setACL('/sys/principals/groups/db', 
                    '/sys/acls/bootstrap_acl.xml');
  end if;

  ret := 
    xdb.dbms_xdbutil_int.createSystemVirtualFolder('/sys/principals/groups/ldap');
  if ret then
    dbms_xdb.setACL('/sys/principals/groups/ldap', 
                    '/sys/acls/bootstrap_acl.xml');
  end if;

  ret := 
    xdb.dbms_xdbutil_int.createSystemVirtualFolder('/sys/principals/groups/application');
  if ret then
    dbms_xdb.setACL('/sys/principals/groups/application', 
                    '/sys/acls/bootstrap_acl.xml');
  end if;
end;
/
commit;

Rem Create virtual folder for acl oids
declare
ret boolean;
begin
  ret := 
    xdb.dbms_xdbutil_int.createSystemVirtualFolder('/sys/acloids');
  if ret then
    dbms_xdb.setACL('/sys/acloids', '/sys/acls/bootstrap_acl.xml');
 end if;
end;
/
commit;

Rem create version virtual folder
declare
ret boolean;
begin
 ret := xdb.dbms_xdbutil_int.createSystemVirtualFolder('/sys/version');
 if ret then
   dbms_xdb.setACL('/sys/version', '/sys/acls/bootstrap_acl.xml');
 end if;
end;
/
commit;

Rem create dbfs_virtual_folder table if it does not exist
declare
 exist number;
begin
  select count(*) into exist from DBA_TABLES where table_name ='XDB$DBFS_VIRTUAL_FOLDER'
  and owner ='XDB';
 
  if exist = 0 then
   execute immediate 'CREATE TABLE XDB.XDB$DBFS_VIRTUAL_FOLDER (
   hidden_def         NUMBER default 1,
   mount_path         VARCHAR2(4000) NOT NULL,
   CONSTRAINT snglerow UNIQUE  (hidden_def))';
  end if;
end;
/   
SHOW ERRORS;

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


@?/rdbms/admin/sqlsessend.sql
