Rem
Rem $Header: rdbms/admin/catxdbdl.sql /main/10 2016/09/13 10:42:23 sriksure Exp $
Rem
Rem catxdbdl.sql
Rem
Rem Copyright (c) 2006, 2016, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catxdbdl.sql - Setup script for document links support
Rem
Rem    DESCRIPTION
Rem          - Register xlink.xsd and XInclude.xsd
Rem          - Create DOCUMENT_LINKS view
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catxdbdl.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catxdbdl.sql
Rem SQL_PHASE: CATXDBDL
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catqm_int.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    sriksure    07/20/16 - Bug 22967968 - Moving inline XML schemas to
Rem                           external schema files
Rem    skayoor     11/30/14 - Proj 58196: Change Select priv to Read Priv
Rem    surman      01/23/14 - 13922626: Update SQL metadata
Rem    qyu         03/18/13 - Common start and end scripts
Rem    stirmizi    04/11/12 - remove XInclude.xsd registration, genTables=false
Rem                           for csx.XInclude.xsd
Rem    dmelinge    02/01/12 - Unnecessary privileges granted on DOCUMENT_LINKS
Rem    badeoti     12/15/08 - avoid any_path like select from rv
Rem    mrafiq      06/29/07 - making it rerunnable
Rem    rmurthy     06/22/06 - register csx forms of xlink and xinclude schemas 
Rem    pnath       02/15/06 - remove link_props from document_links view 
Rem    rmurthy     02/06/06 - add document_links view 
Rem    rmurthy     06/02/06 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

Rem Register XLINK schema 
declare
  c number;
  schema_exists EXCEPTION;
  PRAGMA EXCEPTION_INIT(schema_exists,-31085);
  XLINKXSD BFILE := dbms_metadata_hack.get_bfile('xlink.xsd');
  XLINKURL VARCHAR2(2000) := 'http://www.w3.org/1999/xlink.xsd';
  CSX_XLINKURL VARCHAR2(2000) := 'http://www.w3.org/1999/csx.xlink.xsd';

begin

select count(*) into c 
from resource_view 
where equals_path(RES, '/sys/schemas/PUBLIC/www.w3.org/1999/xlink.xsd')=1; 

dbms_metadata_hack.cre_dir();
if c = 0 then
  xdb.dbms_xmlschema.registerSchema(XLINKURL, XLINKXSD, FALSE, TRUE, FALSE, TRUE,FALSE, 'XDB');
end if;

select count(*) into c 
from resource_view 
where equals_path(RES, '/sys/schemas/PUBLIC/www.w3.org/1999/csx.xlink.xsd')=1;

if c = 0 then
  xdb.dbms_xmlschema.registerSchema(CSX_XLINKURL, XLINKXSD, FALSE, FALSE, FALSE, TRUE,FALSE, 'XDB', options=>DBMS_XMLSCHEMA.REGISTER_BINARYXML);
end if;

exception
  when schema_exists then
    NULL;

end;
/

Rem Register XINCLUDE schema 
declare
  c number;
  schema_exists EXCEPTION;
  PRAGMA EXCEPTION_INIT(schema_exists,-31085);
  XINCLUDEXSD BFILE := dbms_metadata_hack.get_bfile('xinclude.xsd.12.1');
  CSX_XINCLUDEURL VARCHAR2(2000) := 'http://www.w3.org/2001/csx.XInclude.xsd'; 

begin

select count(*) into c 
from resource_view 
where equals_path(RES, '/sys/schemas/PUBLIC/www.w3.org/2001/csx.XInclude.xsd')=1;

dbms_metadata_hack.cre_dir();
if c = 0 then
  xdb.dbms_xmlschema.registerSchema(CSX_XINCLUDEURL, XINCLUDEXSD, FALSE, FALSE, FALSE, FALSE, FALSE, 'XDB', options=>DBMS_XMLSCHEMA.REGISTER_BINARYXML);
end if;

exception
  when schema_exists then
    NULL;
end;
/


Rem DOCUMENT_LINKS VIEW
create or replace view XDB.DOCUMENT_LINKS 
(source_id, 
target_id, 
target_path, 
link_type, 
link_form, 
source_type) as 
SELECT 
dl.source_id, 
dl.target_id, 
dl.target_path, 
decode(bitand(sys_op_rawtonum(dl.flags),1),1, 'Weak', 
       decode(bitand(sys_op_rawtonum(dl.flags),2),2,'Symbolic','Hard')),
decode(bitand(sys_op_rawtonum(dl.flags),4),4, 'XInclude', 'XLink'),
decode(bitand(sys_op_rawtonum(dl.flags),8),8, 'Resource Metadata', 
       'Resource Content')
from xdb.xdb$d_link dl, xdb.xdb$resource r
where dl.source_id = r.object_id 
and sys_checkacl(r.xmldata.acloid, r.xmldata.ownerid, 
xmltype('<privilege
      xmlns="http://xmlns.oracle.com/xdb/acl.xsd"
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
      xsi:schemaLocation="http://xmlns.oracle.com/xdb/acl.xsd
                          http://xmlns.oracle.com/xdb/acl.xsd
                          DAV: http://xmlns.oracle.com/xdb/dav.xsd">
      <read-properties/>
      <read-contents/>
 </privilege>')) = 1;

show errors;

create or replace public synonym document_links for xdb.document_links;
grant read on xdb.document_links to public ; 


@?/rdbms/admin/sqlsessend.sql
